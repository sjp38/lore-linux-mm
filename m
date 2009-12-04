Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4B80460021B
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 01:52:55 -0500 (EST)
Date: Fri, 4 Dec 2009 14:52:55 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 6/7] memcg: move charges of anonymous swap
Message-Id: <20091204145255.85160b8b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
References: <20091204144609.b61cc8c4.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch is another core part of this move-charge-at-task-migration feature.
It enables moving charges of anonymous swaps.

To move the charge of swap, we need to exchange swap_cgroup's record.

In current implementation, swap_cgroup's record is protected by:

  - page lock: if the entry is on swap cache.
  - swap_lock: if the entry is not on swap cache.

This works well in usual swap-in/out activity.

But this behavior make the feature of moving swap charge check many conditions
to exchange swap_cgroup's record safely.

So I changed modification of swap_cgroup's recored(swap_cgroup_record())
to use xchg, and define a new function to cmpxchg swap_cgroup's record.

This patch also enables moving charge of non pte_present but not uncharged swap
caches, which can be exist on swap-out path, by getting the target pages via
find_get_page() as do_mincore() does.

Changelog: 2009/12/04
- minor changes in comments and valuable names.
Changelog: 2009/11/19
- in can_attach(), instead of parsing the page table, make use of per process
  mm_counter(swap_usage).
Changelog: 2009/11/06
- drop support for shmem's swap(revisit in future).
- add mem_cgroup_count_swap_user() to prevent moving charges of swaps used by
  multiple processes(revisit in future).
Changelog: 2009/09/24
- do no swap-in in moving swap account any more.
- add support for shmem's swap.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/page_cgroup.h |    2 +
 include/linux/swap.h        |    1 +
 mm/memcontrol.c             |  154 +++++++++++++++++++++++++++++++++----------
 mm/page_cgroup.c            |   35 +++++++++-
 mm/swapfile.c               |   31 +++++++++
 5 files changed, 185 insertions(+), 38 deletions(-)

diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
index b0e4eb1..30b0813 100644
--- a/include/linux/page_cgroup.h
+++ b/include/linux/page_cgroup.h
@@ -118,6 +118,8 @@ static inline void __init page_cgroup_init_flatmem(void)
 #include <linux/swap.h>
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
+extern unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
+					unsigned short old, unsigned short new);
 extern unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id);
 extern unsigned short lookup_swap_cgroup(swp_entry_t ent);
 extern int swap_cgroup_swapon(int type, unsigned long max_pages);
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 9f0ca32..2a3209e 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -355,6 +355,7 @@ static inline void disable_swap_token(void)
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
 extern void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout);
+extern int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep);
 #else
 static inline void
 mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, bool swapout)
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f50ad15..6b3d17f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -33,6 +33,7 @@
 #include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
@@ -2258,6 +2259,53 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
 	}
 	rcu_read_unlock();
 }
+
+/**
+ * mem_cgroup_move_swap_account - move swap charge and swap_cgroup's record.
+ * @entry: swap entry to be moved
+ * @from:  mem_cgroup which the entry is moved from
+ * @to:  mem_cgroup which the entry is moved to
+ *
+ * It succeeds only when the swap_cgroup's record for this entry is the same
+ * as the mem_cgroup's id of @from.
+ *
+ * Returns 0 on success, -EINVAL on failure.
+ *
+ * The caller must have charged to @to, IOW, called res_counter_charge() about
+ * both res and memsw, and called css_get().
+ */
+static int mem_cgroup_move_swap_account(swp_entry_t entry,
+				struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	unsigned short old_id, new_id;
+
+	old_id = css_id(&from->css);
+	new_id = css_id(&to->css);
+
+	if (swap_cgroup_cmpxchg(entry, old_id, new_id) == old_id) {
+		if (!mem_cgroup_is_root(from))
+			res_counter_uncharge(&from->memsw, PAGE_SIZE);
+		mem_cgroup_swap_statistics(from, false);
+		mem_cgroup_put(from);
+		/*
+		 * we charged both to->res and to->memsw, so we should uncharge
+		 * to->res.
+		 */
+		if (!mem_cgroup_is_root(to))
+			res_counter_uncharge(&to->res, PAGE_SIZE);
+		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_get(to);
+
+		return 0;
+	}
+	return -EINVAL;
+}
+#else
+static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
+				struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	return -EINVAL;
+}
 #endif
 
 /*
@@ -3542,71 +3590,96 @@ one_by_one:
  * @vma: the vma the pte to be checked belongs
  * @addr: the address corresponding to the pte to be checked
  * @ptent: the pte to be checked
- * @target: the pointer the target page will be stored(can be NULL)
+ * @target: the pointer the target page or swap ent will be stored(can be NULL)
  *
  * Returns
  *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
  *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
  *     move charge. if @target is not NULL, the page is stored in target->page
  *     with extra refcnt got(Callers should handle it).
+ *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
+ *     target for charge migration. if @target is not NULL, the entry is stored
+ *     in target->ent.
  *
  * Called with pte lock held.
  */
-/* We add a new member later. */
 union mc_target {
 	struct page	*page;
+	swp_entry_t	ent;
 };
 
-/* We add a new type later. */
 enum mc_target_type {
 	MC_TARGET_NONE,	/* not used */
 	MC_TARGET_PAGE,
+	MC_TARGET_SWAP,
 };
 
 static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union mc_target *target)
 {
-	struct page *page;
+	struct page *page = NULL;
 	struct page_cgroup *pc;
 	int ret = 0;
+	swp_entry_t ent = { .val = 0 };
+	int usage_count = 0;
 	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
 					&mc.to->move_charge_at_immigrate);
 
-	if (!pte_present(ptent))
-		return 0;
-
-	page = vm_normal_page(vma, addr, ptent);
-	if (!page || !page_mapped(page))
-		return 0;
-	/*
-	 * TODO: We don't move charges of file(including shmem/tmpfs) pages for
-	 * now.
-	 */
-	if (!move_anon || !PageAnon(page))
-		return 0;
-	/*
-	 * TODO: We don't move charges of shared(used by multiple processes)
-	 * pages for now.
-	 */
-	if (page_mapcount(page) > 1)
-		return 0;
-	if (!get_page_unless_zero(page))
+	if (!pte_present(ptent)) {
+		/* TODO: handle swap of shmes/tmpfs */
+		if (pte_none(ptent) || pte_file(ptent))
+			return 0;
+		else if (is_swap_pte(ptent)) {
+			ent = pte_to_swp_entry(ptent);
+			if (!move_anon || non_swap_entry(ent))
+				return 0;
+			usage_count = mem_cgroup_count_swap_user(ent, &page);
+		}
+	} else {
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page || !page_mapped(page))
+			return 0;
+		/*
+		 * TODO: We don't move charges of file(including shmem/tmpfs)
+		 * pages for now.
+		 */
+		if (!move_anon || !PageAnon(page))
+			return 0;
+		if (!get_page_unless_zero(page))
+			return 0;
+		usage_count = page_mapcount(page);
+	}
+	if (usage_count > 1) {
+		/*
+		 * TODO: We don't move charges of shared(used by multiple
+		 * processes) pages for now.
+		 */
+		if (page)
+			put_page(page);
 		return 0;
-
-	pc = lookup_page_cgroup(page);
-	/*
-	 * Do only loose check w/o page_cgroup lock. mem_cgroup_move_account()
-	 * checks the pc is valid or not under the lock.
-	 */
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
-		ret = MC_TARGET_PAGE;
+	}
+	if (page) {
+		pc = lookup_page_cgroup(page);
+		/*
+		 * Do only loose check w/o page_cgroup lock.
+		 * mem_cgroup_move_account() checks the pc is valid or not under
+		 * the lock.
+		 */
+		if (PageCgroupUsed(pc) && pc->mem_cgroup == mc.from) {
+			ret = MC_TARGET_PAGE;
+			if (target)
+				target->page = page;
+		}
+		if (!ret || !target)
+			put_page(page);
+	}
+	/* throught */
+	if (ent.val && do_swap_account && !ret &&
+			css_id(&mc.from->css) == lookup_swap_cgroup(ent)) {
+		ret = MC_TARGET_SWAP;
 		if (target)
-			target->page = page;
+			target->ent = ent;
 	}
-
-	if (!ret || !target)
-		put_page(page);
-
 	return ret;
 }
 
@@ -3745,6 +3818,7 @@ retry:
 		int type;
 		struct page *page;
 		struct page_cgroup *pc;
+		swp_entry_t ent;
 
 		if (!mc.precharge)
 			break;
@@ -3766,6 +3840,14 @@ retry:
 put:			/* is_target_pte_for_mc() gets the page */
 			put_page(page);
 			break;
+		case MC_TARGET_SWAP:
+			ent = target.ent;
+			if (!mem_cgroup_move_swap_account(ent,
+						mc.from, mc.to)) {
+				css_put(&mc.to->css);
+				mc.precharge--;
+			}
+			break;
 		default:
 			break;
 		}
diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
index 3d535d5..213b0ee 100644
--- a/mm/page_cgroup.c
+++ b/mm/page_cgroup.c
@@ -9,6 +9,7 @@
 #include <linux/vmalloc.h>
 #include <linux/cgroup.h>
 #include <linux/swapops.h>
+#include <asm/cmpxchg.h>
 
 static void __meminit
 __init_page_cgroup(struct page_cgroup *pc, unsigned long pfn)
@@ -335,6 +336,37 @@ not_enough_page:
 }
 
 /**
+ * swap_cgroup_cmpxchg - cmpxchg mem_cgroup's id for this swp_entry.
+ * @end: swap entry to be cmpxchged
+ * @old: old id
+ * @new: new id
+ *
+ * Returns old id at success, 0 at failure.
+ * (There is no mem_cgroup useing 0 as its id)
+ */
+unsigned short swap_cgroup_cmpxchg(swp_entry_t ent,
+					unsigned short old, unsigned short new)
+{
+	int type = swp_type(ent);
+	unsigned long offset = swp_offset(ent);
+	unsigned long idx = offset / SC_PER_PAGE;
+	unsigned long pos = offset & SC_POS_MASK;
+	struct swap_cgroup_ctrl *ctrl;
+	struct page *mappage;
+	struct swap_cgroup *sc;
+
+	ctrl = &swap_cgroup_ctrl[type];
+
+	mappage = ctrl->map[idx];
+	sc = page_address(mappage);
+	sc += pos;
+	if (cmpxchg(&sc->id, old, new) == old)
+		return old;
+	else
+		return 0;
+}
+
+/**
  * swap_cgroup_record - record mem_cgroup for this swp_entry.
  * @ent: swap entry to be recorded into
  * @mem: mem_cgroup to be recorded
@@ -358,8 +390,7 @@ unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
 	mappage = ctrl->map[idx];
 	sc = page_address(mappage);
 	sc += pos;
-	old = sc->id;
-	sc->id = id;
+	old = xchg(&sc->id, id);
 
 	return old;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 67f808b..09ab458 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -722,6 +722,37 @@ int free_swap_and_cache(swp_entry_t entry)
 	return p != NULL;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/**
+ * mem_cgroup_count_swap_user - count the user of a swap entry
+ * @ent: the swap entry to be checked
+ * @pagep: the pointer for the swap cache page of the entry to be stored
+ *
+ * Returns the number of the user of the swap entry. The number is valid only
+ * for swaps of anonymous pages.
+ * If the entry is found on swap cache, the page is stored to pagep with
+ * refcount of it being incremented.
+ */
+int mem_cgroup_count_swap_user(swp_entry_t ent, struct page **pagep)
+{
+	struct page *page;
+	struct swap_info_struct *p;
+	int count = 0;
+
+	page = find_get_page(&swapper_space, ent.val);
+	if (page)
+		count += page_mapcount(page);
+	p = swap_info_get(ent);
+	if (p) {
+		count += swap_count(p->swap_map[swp_offset(ent)]);
+		spin_unlock(&swap_lock);
+	}
+
+	*pagep = page;
+	return count;
+}
+#endif
+
 #ifdef CONFIG_HIBERNATION
 /*
  * Find the swap type that corresponds to given device (if any).
-- 
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
