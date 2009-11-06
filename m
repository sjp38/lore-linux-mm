Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 45F5D6B0062
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 00:33:56 -0500 (EST)
Date: Fri, 6 Nov 2009 14:16:04 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -mmotm 8/8] memcg: recharge charges of anonymous swap
Message-Id: <20091106141604.ff80e40f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch is another core part of this recharge-at-task-move feature.
It enables recharge of anonymous swaps.

To move the charge of swap, we need to exchange swap_cgroup's record.

In current implementation, swap_cgroup's record is protected by:

  - page lock: if the entry is on swap cache.
  - swap_lock: if the entry is not on swap cache.

This works well in usual swap-in/out activity.

But this behavior make charge migration of swap check many conditions to
exchange swap_cgroup's record safely.

So I changed modification of swap_cgroup's recored(swap_cgroup_record())
to use xchg, and define a new function to cmpxchg swap_cgroup's record.

This patch also enables recharge of non pte_present but not uncharged swap
caches, which can be exist on swap-out path,  by getting the target pages via
find_get_page() as do_mincore() does.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 Documentation/cgroups/memory.txt |    5 +-
 include/linux/page_cgroup.h      |    2 +
 include/linux/swap.h             |    1 +
 mm/memcontrol.c                  |  140 ++++++++++++++++++++++++++++++--------
 mm/page_cgroup.c                 |   35 +++++++++-
 mm/swapfile.c                    |   32 +++++++++
 6 files changed, 182 insertions(+), 33 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 54281ff..2820626 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -441,8 +441,9 @@ And if you want disable it again
 We recharge a charge which meets the following conditions.
 
 a. It must be charged to the old cgroup.
-b. A charge of an anonymous page used by the target task. The page must be used
-   only by the target task.
+b. A charge of an anonymous page(or swap of it) used by the target task.
+   The page(or swap) must be used only by the target task. You must enable
+   Swap Extension(see 2.4) to enable recharge of swap.
 
 Note: More type of pages(e.g. file cache, shmem,) will be supported in future.
 
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
index 7e96f3b..50e28df 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -34,6 +34,7 @@
 #include <linux/rbtree.h>
 #include <linux/slab.h>
 #include <linux/swap.h>
+#include <linux/swapops.h>
 #include <linux/spinlock.h>
 #include <linux/fs.h>
 #include <linux/seq_file.h>
@@ -2231,6 +2232,49 @@ void mem_cgroup_uncharge_swap(swp_entry_t ent)
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
+ * It successes only when the swap_cgroup's record for this entry is the same
+ * as the mem_cgroup's id of @from.
+ *
+ * Returns 0 on success, 1 on failure.
+ *
+ * The caller must have called __mem_cgroup_try_charge on @to.
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
+
+		if (!mem_cgroup_is_root(to))
+			res_counter_uncharge(&to->res, PAGE_SIZE);
+		mem_cgroup_swap_statistics(to, true);
+		mem_cgroup_get(to);
+
+		return 0;
+	}
+	return 1;
+}
+#else
+static inline int mem_cgroup_move_swap_account(swp_entry_t entry,
+				struct mem_cgroup *from, struct mem_cgroup *to)
+{
+	return 1;
+}
 #endif
 
 /*
@@ -3460,63 +3504,92 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
  * @vma: the vma the pte to be checked belongs
  * @addr: the address corresponding to the pte to be checked
  * @ptent: the pte to be checked
- * @target: the pointer the target page will be stored(can be NULL)
+ * @target: the pointer the target page or entry will be stored(can be NULL)
  *
  * Returns
  *   0(RECHARGE_TARGET_NONE): if the pte is not a target for recharge.
  *   1(RECHARGE_TARGET_PAGE): if the page corresponding to this pte is a target
  *     for recharge. if @target is not NULL, the page is stored in target->page
  *     with extra refcnt got(Callers should handle it).
+ *   2(MIGRATION_TARGET_SWAP): if the swap entry corresponding to this pte is a
+ *     target for charge migration. if @target is not NULL, the entry is stored
+ *     in target->ent.
  *
  * Called with pte lock held.
  */
-/* We add a new member later. */
 union recharge_target {
 	struct page	*page;
+	swp_entry_t	ent;
 };
 
-/* We add a new type later. */
 enum recharge_target_type {
 	RECHARGE_TARGET_NONE,	/* not used */
 	RECHARGE_TARGET_PAGE,
+	RECHARGE_TARGET_SWAP,
 };
 
 static int is_target_pte_for_recharge(struct vm_area_struct *vma,
 		unsigned long addr, pte_t ptent, union recharge_target *target)
 {
-	struct page *page;
+	struct page *page = NULL;
 	struct page_cgroup *pc;
+	swp_entry_t ent = { .val = 0 };
 	int ret = 0;
+	int user = 0;
 
-	if (!pte_present(ptent))
-		return 0;
-
-	page = vm_normal_page(vma, addr, ptent);
-	if (!page || !page_mapped(page))
-		return 0;
-	/* TODO: We don't recharge file(including shmem/tmpfs) pages for now. */
-	if (!PageAnon(page))
-		return 0;
-	/*
-	 * TODO: We don't recharge shared(used by multiple processes) pages
-	 * for now.
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
+			if (non_swap_entry(ent))
+				return 0;
+			user = mem_cgroup_count_swap_user(ent, &page);
+		}
+	} else {
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page || !page_mapped(page))
+			return 0;
+		/*
+		 * TODO: We don't recharge file(including shmem/tmpfs) pages
+		 * for now.
+		 */
+		if (!PageAnon(page))
+			return 0;
+		if (!get_page_unless_zero(page))
+			return 0;
+		user = page_mapcount(page);
+	}
+	if (user > 1) {
+		/*
+		 * TODO: We don't recharge shared(used by multiple processes)
+		 * pages for now.
+		 */
+		if (page)
+			put_page(page);
 		return 0;
+	}
 
-	pc = lookup_page_cgroup(page);
-	lock_page_cgroup(pc);
-	if (PageCgroupUsed(pc) && pc->mem_cgroup == recharge.from) {
-		ret = RECHARGE_TARGET_PAGE;
+	if (page) {
+		pc = lookup_page_cgroup(page);
+		lock_page_cgroup(pc);
+		if (PageCgroupUsed(pc) && pc->mem_cgroup == recharge.from) {
+			ret = RECHARGE_TARGET_PAGE;
+			if (target)
+				target->page = page;
+		}
+		unlock_page_cgroup(pc);
+		if (!ret || !target)
+			put_page(page);
+	}
+	/* fall throught */
+	if (ent.val && do_swap_account && !ret &&
+		css_id(&recharge.from->css) == lookup_swap_cgroup(ent)) {
+		ret = RECHARGE_TARGET_SWAP;
 		if (target)
-			target->page = page;
+			target->ent = ent;
 	}
-	unlock_page_cgroup(pc);
-
-	if (!ret || !target)
-		put_page(page);
 
 	return ret;
 }
@@ -3667,6 +3740,7 @@ retry:
 		int type;
 		struct page *page;
 		struct page_cgroup *pc;
+		swp_entry_t ent;
 
 		if (!recharge.precharge)
 			break;
@@ -3687,6 +3761,14 @@ retry:
 put:			/* is_target_pte_for_recharge() gets the page */
 			put_page(page);
 			break;
+		case RECHARGE_TARGET_SWAP:
+			ent = target.ent;
+			if (!mem_cgroup_move_swap_account(ent,
+						recharge.from, recharge.to)) {
+				css_put(&recharge.to->css);
+				recharge.precharge--;
+			}
+			break;
 		default:
 			continue;
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
index 93e71cf..28eef54 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -719,6 +719,38 @@ int free_swap_and_cache(swp_entry_t entry)
 	return p != NULL;
 }
 
+#ifdef CONFIG_CGROUP_MEM_RES_CTLR
+/**
+ * mem_cgroup_count_swap_user - count the user of a swap entry
+ * @ent: the swap entry to be checked
+ * @pagep: the pointer for the swap cache page of the entry to be stored
+ *
+ * Returns the number of the user of the swap entry.
+ * If the entry is found on swap cache, the page is stored to pagep with
+ * refcount of it being incremented.
+ *
+ * This function can be used only for swaps for anonymous pages.
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
