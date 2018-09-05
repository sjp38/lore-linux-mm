Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF726B72DA
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 07:23:59 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so8185037ois.21
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 04:23:59 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 76-v6si1183201oie.75.2018.09.05.04.23.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 04:23:57 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85BNZBj140341
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 07:23:56 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mad5ek7px-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 07:23:56 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.ibm.com>;
	Wed, 5 Sep 2018 07:23:55 -0400
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Subject: [RFC PATCH] mm/hugetlb: make hugetlb_lock irq safe
Date: Wed,  5 Sep 2018 16:53:41 +0530
Message-Id: <20180905112341.21355-1-aneesh.kumar@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

 ================================
 WARNING: inconsistent lock state
 4.18.0-12148-g905aab86cd98 #28 Not tainted
 --------------------------------
 inconsistent {SOFTIRQ-ON-W} -> {IN-SOFTIRQ-W} usage.
 swapper/68/0 [HC0[0]:SC1[1]:HE1:SE0] takes:
 0000000052a030a7 (hugetlb_lock){+.?.}, at: free_huge_page+0x9c/0x340
 {SOFTIRQ-ON-W} state was registered at:
   lock_acquire+0xd4/0x230
   _raw_spin_lock+0x44/0x70
   set_max_huge_pages+0x4c/0x360
   hugetlb_sysctl_handler_common+0x108/0x160
   proc_sys_call_handler+0x134/0x190
   __vfs_write+0x3c/0x1f0
   vfs_write+0xd8/0x220
   ksys_write+0x64/0x110
   system_call+0x5c/0x70
 irq event stamp: 20918624
 hardirqs last  enabled at (20918624): [<c0000000002138a4>] rcu_process_callbacks+0x814/0xa30
 hardirqs last disabled at (20918623): [<c0000000002132c8>] rcu_process_callbacks+0x238/0xa30
 softirqs last  enabled at (20918612): [<c00000000016005c>] irq_enter+0x9c/0xd0
 softirqs last disabled at (20918613): [<c000000000160198>] irq_exit+0x108/0x1c0

 other info that might help us debug this:
  Possible unsafe locking scenario:

        CPU0
        ----
   lock(hugetlb_lock);
   <Interrupt>
     lock(hugetlb_lock);

  *** DEADLOCK ***

 1 lock held by swapper/68/0:
  #0: 0000000097408d5f (rcu_callback){....}, at: rcu_process_callbacks+0x328/0xa30

 stack backtrace:
 CPU: 68 PID: 0 Comm: swapper/68 Not tainted 4.18.0-12148-g905aab86cd98 #28
 Call Trace:
 [c00020398d3cf2d0] [c0000000011d57d4] dump_stack+0xe8/0x164 (unreliable)
 [c00020398d3cf320] [c0000000001e6d94] print_usage_bug+0x2c4/0x390
 [c00020398d3cf3d0] [c0000000001e6fc0] mark_lock+0x160/0x960
 [c00020398d3cf480] [c0000000001e7dd0] __lock_acquire+0x530/0x1dd0
 [c00020398d3cf600] [c0000000001ea144] lock_acquire+0xd4/0x230
 [c00020398d3cf6c0] [c0000000011f8e24] _raw_spin_lock+0x44/0x70
 [c00020398d3cf6f0] [c00000000042394c] free_huge_page+0x9c/0x340
 [c00020398d3cf740] [c0000000003a5334] __put_compound_page+0x64/0x80
 [c00020398d3cf770] [c000000000092098] mm_iommu_free+0x158/0x170
 [c00020398d3cf7c0] [c000000000213358] rcu_process_callbacks+0x2c8/0xa30
 [c00020398d3cf8e0] [c0000000011f9fb8] __do_softirq+0x168/0x590
 [c00020398d3cf9e0] [c000000000160198] irq_exit+0x108/0x1c0
 [c00020398d3cfa40] [c000000000029f30] timer_interrupt+0x160/0x440
 [c00020398d3cfaa0] [c0000000000091b4] decrementer_common+0x124/0x130
 --- interrupt: 901 at replay_interrupt_return+0x0/0x4
     LR = arch_local_irq_restore.part.4+0x78/0x90
 [c00020398d3cfd90] [c00000000001b334] arch_local_irq_restore.part.4+0x34/0x90 (unreliable)
 [c00020398d3cfdc0] [c000000000eec768] cpuidle_enter_state+0xf8/0x4b0
 [c00020398d3cfe30] [c0000000001aa33c] call_cpuidle+0x4c/0x90
 [c00020398d3cfe50] [c0000000001aa7fc] do_idle+0x34c/0x420
 [c00020398d3cfec0] [c0000000001aac7c] cpu_startup_entry+0x3c/0x40
 [c00020398d3cfef0] [c0000000000528f8] start_secondary+0x4f8/0x520
 [c00020398d3cff90] [c00000000000ad70] start_secondary_prolog+0x10/0x14

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
---
 mm/hugetlb.c        | 87 ++++++++++++++++++++++++++-------------------
 mm/hugetlb_cgroup.c | 10 +++---
 2 files changed, 57 insertions(+), 40 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 88881b3f8628..c8d3a34c48e0 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1242,6 +1242,7 @@ void free_huge_page(struct page *page)
 	 * Can't pass hstate in here because it is called from the
 	 * compound page destructor.
 	 */
+	unsigned long flags;
 	struct hstate *h = page_hstate(page);
 	int nid = page_to_nid(page);
 	struct hugepage_subpool *spool =
@@ -1263,7 +1264,7 @@ void free_huge_page(struct page *page)
 	if (hugepage_subpool_put_pages(spool, 1) == 0)
 		restore_reserve = true;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	clear_page_huge_active(page);
 	hugetlb_cgroup_uncharge_page(hstate_index(h),
 				     pages_per_huge_page(h), page);
@@ -1284,18 +1285,20 @@ void free_huge_page(struct page *page)
 		arch_clear_hugepage_flags(page);
 		enqueue_huge_page(h, page);
 	}
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 }
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid)
 {
+	unsigned long flags;
+
 	INIT_LIST_HEAD(&page->lru);
 	set_compound_page_dtor(page, HUGETLB_PAGE_DTOR);
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	set_hugetlb_cgroup(page, NULL);
 	h->nr_huge_pages++;
 	h->nr_huge_pages_node[nid]++;
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 }
 
 static void prep_compound_gigantic_page(struct page *page, unsigned int order)
@@ -1485,8 +1488,9 @@ static int free_pool_huge_page(struct hstate *h, nodemask_t *nodes_allowed,
 int dissolve_free_huge_page(struct page *page)
 {
 	int rc = 0;
+	unsigned long flags;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	if (PageHuge(page) && !page_count(page)) {
 		struct page *head = compound_head(page);
 		struct hstate *h = page_hstate(head);
@@ -1510,7 +1514,7 @@ int dissolve_free_huge_page(struct page *page)
 		update_and_free_page(h, head);
 	}
 out:
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	return rc;
 }
 
@@ -1549,21 +1553,22 @@ int dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_pfn)
 static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nmask)
 {
+	unsigned long flags;
 	struct page *page = NULL;
 
 	if (hstate_is_gigantic(h))
 		return NULL;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	if (h->surplus_huge_pages >= h->nr_overcommit_huge_pages)
 		goto out_unlock;
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	page = alloc_fresh_huge_page(h, gfp_mask, nid, nmask);
 	if (!page)
 		return NULL;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	/*
 	 * We could have raced with the pool size change.
 	 * Double check that and simply deallocate the new page
@@ -1581,7 +1586,7 @@ static struct page *alloc_surplus_huge_page(struct hstate *h, gfp_t gfp_mask,
 	}
 
 out_unlock:
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	return page;
 }
@@ -1630,16 +1635,17 @@ struct page *alloc_buddy_huge_page_with_mpol(struct hstate *h,
 /* page migration callback function */
 struct page *alloc_huge_page_node(struct hstate *h, int nid)
 {
+	unsigned long flags;
 	gfp_t gfp_mask = htlb_alloc_mask(h);
 	struct page *page = NULL;
 
 	if (nid != NUMA_NO_NODE)
 		gfp_mask |= __GFP_THISNODE;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	if (h->free_huge_pages - h->resv_huge_pages > 0)
 		page = dequeue_huge_page_nodemask(h, gfp_mask, nid, NULL);
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	if (!page)
 		page = alloc_migrate_huge_page(h, gfp_mask, nid, NULL);
@@ -1651,19 +1657,20 @@ struct page *alloc_huge_page_node(struct hstate *h, int nid)
 struct page *alloc_huge_page_nodemask(struct hstate *h, int preferred_nid,
 		nodemask_t *nmask)
 {
+	unsigned long flags;
 	gfp_t gfp_mask = htlb_alloc_mask(h);
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	if (h->free_huge_pages - h->resv_huge_pages > 0) {
 		struct page *page;
 
 		page = dequeue_huge_page_nodemask(h, gfp_mask, preferred_nid, nmask);
 		if (page) {
-			spin_unlock(&hugetlb_lock);
+			spin_unlock_irqrestore(&hugetlb_lock, flags);
 			return page;
 		}
 	}
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	return alloc_migrate_huge_page(h, gfp_mask, preferred_nid, nmask);
 }
@@ -1997,6 +2004,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	long map_chg, map_commit;
 	long gbl_chg;
 	int ret, idx;
+	unsigned long flags;
 	struct hugetlb_cgroup *h_cg;
 
 	idx = hstate_index(h);
@@ -2039,7 +2047,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	if (ret)
 		goto out_subpool_put;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	/*
 	 * glb_chg is passed to indicate whether or not a page must be taken
 	 * from the global free pool (global change).  gbl_chg == 0 indicates
@@ -2047,7 +2055,7 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 	 */
 	page = dequeue_huge_page_vma(h, vma, addr, avoid_reserve, gbl_chg);
 	if (!page) {
-		spin_unlock(&hugetlb_lock);
+		spin_unlock_irqrestore(&hugetlb_lock, flags);
 		page = alloc_buddy_huge_page_with_mpol(h, vma, addr);
 		if (!page)
 			goto out_uncharge_cgroup;
@@ -2055,12 +2063,12 @@ struct page *alloc_huge_page(struct vm_area_struct *vma,
 			SetPagePrivate(page);
 			h->resv_huge_pages--;
 		}
-		spin_lock(&hugetlb_lock);
+		spin_lock_irqsave(&hugetlb_lock, flags);
 		list_move(&page->lru, &h->hugepage_activelist);
 		/* Fall through */
 	}
 	hugetlb_cgroup_commit_charge(idx, pages_per_huge_page(h), h_cg, page);
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	set_page_private(page, (unsigned long)spool);
 
@@ -2279,6 +2287,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 						nodemask_t *nodes_allowed)
 {
+	unsigned long flags;
 	unsigned long min_count, ret;
 
 	if (hstate_is_gigantic(h) && !gigantic_page_supported())
@@ -2295,7 +2304,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2307,13 +2316,13 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		 * page, free_huge_page will handle it by freeing the page
 		 * and reducing the surplus.
 		 */
-		spin_unlock(&hugetlb_lock);
+		spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 		/* yield cpu to avoid soft lockup */
 		cond_resched();
 
 		ret = alloc_pool_huge_page(h, nodes_allowed);
-		spin_lock(&hugetlb_lock);
+		spin_lock_irqsave(&hugetlb_lock, flags);
 		if (!ret)
 			goto out;
 
@@ -2351,7 +2360,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	}
 out:
 	ret = persistent_huge_pages(h);
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	return ret;
 }
 
@@ -2502,6 +2511,7 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 {
 	int err;
 	unsigned long input;
+	unsigned long flags;
 	struct hstate *h = kobj_to_hstate(kobj, NULL);
 
 	if (hstate_is_gigantic(h))
@@ -2511,9 +2521,9 @@ static ssize_t nr_overcommit_hugepages_store(struct kobject *kobj,
 	if (err)
 		return err;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	h->nr_overcommit_huge_pages = input;
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 
 	return count;
 }
@@ -2943,7 +2953,7 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 			size_t *length, loff_t *ppos)
 {
 	struct hstate *h = &default_hstate;
-	unsigned long tmp;
+	unsigned long tmp, flags;
 	int ret;
 
 	if (!hugepages_supported())
@@ -2961,9 +2971,9 @@ int hugetlb_overcommit_handler(struct ctl_table *table, int write,
 		goto out;
 
 	if (write) {
-		spin_lock(&hugetlb_lock);
+		spin_lock_irqsave(&hugetlb_lock, flags);
 		h->nr_overcommit_huge_pages = tmp;
-		spin_unlock(&hugetlb_lock);
+		spin_unlock_irqrestore(&hugetlb_lock, flags);
 	}
 out:
 	return ret;
@@ -3053,8 +3063,9 @@ unsigned long hugetlb_total_pages(void)
 static int hugetlb_acct_memory(struct hstate *h, long delta)
 {
 	int ret = -ENOMEM;
+	unsigned long flags;
 
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	/*
 	 * When cpuset is configured, it breaks the strict hugetlb page
 	 * reservation as the accounting is done on a global variable. Such
@@ -3087,7 +3098,7 @@ static int hugetlb_acct_memory(struct hstate *h, long delta)
 		return_unused_surplus_pages(h, (unsigned long) -delta);
 
 out:
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	return ret;
 }
 
@@ -4806,9 +4817,10 @@ follow_huge_pgd(struct mm_struct *mm, unsigned long address, pgd_t *pgd, int fla
 bool isolate_huge_page(struct page *page, struct list_head *list)
 {
 	bool ret = true;
+	unsigned long flags;
 
 	VM_BUG_ON_PAGE(!PageHead(page), page);
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	if (!page_huge_active(page) || !get_page_unless_zero(page)) {
 		ret = false;
 		goto unlock;
@@ -4816,22 +4828,25 @@ bool isolate_huge_page(struct page *page, struct list_head *list)
 	clear_page_huge_active(page);
 	list_move_tail(&page->lru, list);
 unlock:
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	return ret;
 }
 
 void putback_active_hugepage(struct page *page)
 {
+	unsigned long flags;
+
 	VM_BUG_ON_PAGE(!PageHead(page), page);
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	set_page_huge_active(page);
 	list_move_tail(&page->lru, &(page_hstate(page))->hugepage_activelist);
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	put_page(page);
 }
 
 void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
 {
+	unsigned long flags;
 	struct hstate *h = page_hstate(oldpage);
 
 	hugetlb_cgroup_migrate(oldpage, newpage);
@@ -4854,11 +4869,11 @@ void move_hugetlb_state(struct page *oldpage, struct page *newpage, int reason)
 		SetPageHugeTemporary(oldpage);
 		ClearPageHugeTemporary(newpage);
 
-		spin_lock(&hugetlb_lock);
+		spin_lock_irqsave(&hugetlb_lock, flags);
 		if (h->surplus_huge_pages_node[old_nid]) {
 			h->surplus_huge_pages_node[old_nid]--;
 			h->surplus_huge_pages_node[new_nid]++;
 		}
-		spin_unlock(&hugetlb_lock);
+		spin_unlock_irqrestore(&hugetlb_lock, flags);
 	}
 }
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 68c2f2f3c05b..e4e969d566f3 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -160,6 +160,7 @@ static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
  */
 static void hugetlb_cgroup_css_offline(struct cgroup_subsys_state *css)
 {
+	unsigned long flags;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
 	struct hstate *h;
 	struct page *page;
@@ -167,11 +168,11 @@ static void hugetlb_cgroup_css_offline(struct cgroup_subsys_state *css)
 
 	do {
 		for_each_hstate(h) {
-			spin_lock(&hugetlb_lock);
+			spin_lock_irqsave(&hugetlb_lock, flags);
 			list_for_each_entry(page, &h->hugepage_activelist, lru)
 				hugetlb_cgroup_move_parent(idx, h_cg, page);
 
-			spin_unlock(&hugetlb_lock);
+			spin_unlock_irqrestore(&hugetlb_lock, flags);
 			idx++;
 		}
 		cond_resched();
@@ -415,6 +416,7 @@ void __init hugetlb_cgroup_file_init(void)
  */
 void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 {
+	unsigned long flags;
 	struct hugetlb_cgroup *h_cg;
 	struct hstate *h = page_hstate(oldhpage);
 
@@ -422,14 +424,14 @@ void hugetlb_cgroup_migrate(struct page *oldhpage, struct page *newhpage)
 		return;
 
 	VM_BUG_ON_PAGE(!PageHuge(oldhpage), oldhpage);
-	spin_lock(&hugetlb_lock);
+	spin_lock_irqsave(&hugetlb_lock, flags);
 	h_cg = hugetlb_cgroup_from_page(oldhpage);
 	set_hugetlb_cgroup(oldhpage, NULL);
 
 	/* move the h_cg details to new cgroup */
 	set_hugetlb_cgroup(newhpage, h_cg);
 	list_move(&newhpage->lru, &h->hugepage_activelist);
-	spin_unlock(&hugetlb_lock);
+	spin_unlock_irqrestore(&hugetlb_lock, flags);
 	return;
 }
 
-- 
2.17.1
