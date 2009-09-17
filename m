Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 52C3B6B005A
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 23:11:06 -0400 (EDT)
Date: Thu, 17 Sep 2009 11:26:56 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH 5/8] memcg: migrate charge of anon
Message-Id: <20090917112656.908b44fa.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
References: <20090917112304.6cd4e6f6.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Li Zefan <lizf@cn.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch is the core part of this charge migration feature.
It adds functions to migrate charge of anonymous pages of the task.

Implementation:
- define struct migrate_charge and a valuable of it(mc) to remember
  the target pages and other information.
- At can_attach(), isolate the target pages, call __mem_cgroup_try_charge(),
  and move them to mc->list.
- Call mem_cgroup_move_account() at attach() about all pages on mc->list
  after necessary checks under page_cgroup lock, and put back them to LRU.
- Cancel charges about all pages remains on mc->list on failure or at the end
  of charge migration, and put back them to LRU.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |  196 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 195 insertions(+), 1 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a6b07f8..3a3f4ac 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -21,6 +21,8 @@
 #include <linux/memcontrol.h>
 #include <linux/cgroup.h>
 #include <linux/mm.h>
+#include <linux/migrate.h>
+#include <linux/hugetlb.h>
 #include <linux/pagemap.h>
 #include <linux/smp.h>
 #include <linux/page-flags.h>
@@ -274,6 +276,18 @@ enum charge_type {
 #define MEM_CGROUP_RECLAIM_SOFT_BIT	0x2
 #define MEM_CGROUP_RECLAIM_SOFT		(1 << MEM_CGROUP_RECLAIM_SOFT_BIT)
 
+/*
+ * Stuffs for migrating charge at task move.
+ * mc and its members are protected by cgroup_lock
+ */
+struct migrate_charge {
+	struct task_struct *tsk;
+	struct mem_cgroup *from;
+	struct mem_cgroup *to;
+	struct list_head list;
+};
+static struct migrate_charge *mc;
+
 static void mem_cgroup_get(struct mem_cgroup *mem);
 static void mem_cgroup_put(struct mem_cgroup *mem);
 static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
@@ -2829,6 +2843,7 @@ static int mem_cgroup_swappiness_write(struct cgroup *cgrp, struct cftype *cft,
 }
 
 enum migrate_charge_type {
+	MIGRATE_CHARGE_ANON,
 	NR_MIGRATE_CHARGE_TYPE,
 };
 
@@ -3184,10 +3199,164 @@ static int mem_cgroup_populate(struct cgroup_subsys *ss,
 	return ret;
 }
 
+static int migrate_charge_prepare_pte_range(pmd_t *pmd,
+					unsigned long addr, unsigned long end,
+					struct mm_walk *walk)
+{
+	int ret = 0;
+	struct page *page, *tmp;
+	LIST_HEAD(list);
+	struct vm_area_struct *vma = walk->private;
+	pte_t *pte, ptent;
+	spinlock_t *ptl;
+	bool move_anon = (mc->to->migrate_charge & (1 << MIGRATE_CHARGE_ANON));
+
+	lru_add_drain_all();
+	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
+	for (; addr != end; pte++, addr += PAGE_SIZE) {
+		struct page_cgroup *pc;
+
+		ptent = *pte;
+		if (!pte_present(ptent))
+			continue;
+
+		page = vm_normal_page(vma, addr, ptent);
+		if (!page)
+			continue;
+
+		if (PageAnon(page) && move_anon)
+			;
+		else
+			continue;
+
+		pc = lookup_page_cgroup(page);
+		lock_page_cgroup(pc);
+		if (!PageCgroupUsed(pc) || pc->mem_cgroup != mc->from) {
+			unlock_page_cgroup(pc);
+			continue;
+		}
+		unlock_page_cgroup(pc);
+
+		if (!get_page_unless_zero(page))
+			continue;
+
+		if (!isolate_lru_page(page))
+			list_add_tail(&page->lru, &list);
+		else
+			put_page(page);
+	}
+	pte_unmap_unlock(pte - 1, ptl);
+	cond_resched();
+
+	if (!list_empty(&list))
+		list_for_each_entry_safe(page, tmp, &list, lru) {
+			struct mem_cgroup *mem = mc->to;
+			ret = __mem_cgroup_try_charge(NULL, GFP_KERNEL, &mem,
+								false, page);
+			if (ret || !mem)
+				break;
+			list_move_tail(&page->lru, &mc->list);
+			cond_resched();
+		}
+
+	/*
+	 * We should put back all pages which remain on "list".
+	 * This means try_charge above has failed.
+	 * Pages which have been moved to mc->list would be put back at
+	 * clear_migrate_charge.
+	 */
+	if (!list_empty(&list))
+		list_for_each_entry_safe(page, tmp, &list, lru) {
+			list_del(&page->lru);
+			putback_lru_page(page);
+			put_page(page);
+		}
+
+	return ret;
+}
+
+static int migrate_charge_prepare(void)
+{
+	int ret = 0;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+
+	mm = get_task_mm(mc->tsk);
+	if (!mm)
+		return 0;
+
+	down_read(&mm->mmap_sem);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		struct mm_walk migrate_charge_walk = {
+			.pmd_entry = migrate_charge_prepare_pte_range,
+			.mm = mm,
+			.private = vma,
+		};
+		if (signal_pending(current)) {
+			ret = -EINTR;
+			break;
+		}
+		if (is_vm_hugetlb_page(vma))
+			continue;
+		/* We migrate charge of private pages for now */
+		if (vma->vm_flags & (VM_SHARED | VM_MAYSHARE))
+			continue;
+		if (mc->to->migrate_charge) {
+			ret = walk_page_range(vma->vm_start, vma->vm_end,
+							&migrate_charge_walk);
+			if (ret)
+				break;
+		}
+	}
+	up_read(&mm->mmap_sem);
+
+	mmput(mm);
+	return ret;
+}
+
+static void mem_cgroup_clear_migrate_charge(void)
+{
+	struct page *page, *tmp;
+
+	VM_BUG_ON(!mc);
+
+	if (!list_empty(&mc->list))
+		list_for_each_entry_safe(page, tmp, &mc->list, lru) {
+			mem_cgroup_cancel_charge(mc->to);
+			list_del(&page->lru);
+			putback_lru_page(page);
+			put_page(page);
+		}
+
+	kfree(mc);
+	mc = NULL;
+}
+
 static int mem_cgroup_can_migrate_charge(struct mem_cgroup *mem,
 					struct task_struct *p)
 {
-	return 0;
+	int ret;
+	struct mem_cgroup *from = mem_cgroup_from_task(p);
+
+	VM_BUG_ON(mc);
+
+	if (from == mem)
+		return 0;
+
+	mc = kmalloc(sizeof(struct migrate_charge), GFP_KERNEL);
+	if (!mc)
+		return -ENOMEM;
+
+	mc->tsk = p;
+	mc->from = from;
+	mc->to = mem;
+	INIT_LIST_HEAD(&mc->list);
+
+	ret = migrate_charge_prepare();
+
+	if (ret)
+		mem_cgroup_clear_migrate_charge();
+	return ret;
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -3207,10 +3376,35 @@ static void mem_cgroup_cancel_attach(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
+	if (mc)
+		mem_cgroup_clear_migrate_charge();
 }
 
 static void mem_cgroup_migrate_charge(void)
 {
+	struct page *page, *tmp;
+	struct page_cgroup *pc;
+
+	if (!mc)
+		return;
+
+	if (!list_empty(&mc->list))
+		list_for_each_entry_safe(page, tmp, &mc->list, lru) {
+			pc = lookup_page_cgroup(page);
+			lock_page_cgroup(pc);
+			if (PageCgroupUsed(pc) && pc->mem_cgroup == mc->from) {
+				mem_cgroup_move_account(pc, mc->from, mc->to);
+				/* drop extra refcnt by try_charge() */
+				css_put(&mc->to->css);
+				list_del(&page->lru);
+				putback_lru_page(page);
+				put_page(page);
+			}
+			unlock_page_cgroup(pc);
+			cond_resched();
+		}
+
+	mem_cgroup_clear_migrate_charge();
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
