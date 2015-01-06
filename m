Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id A01016B0129
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 16:26:36 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id x3so63700qcv.29
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:36 -0800 (PST)
Received: from mail-qa0-x22e.google.com (mail-qa0-x22e.google.com. [2607:f8b0:400d:c00::22e])
        by mx.google.com with ESMTPS id t17si65713771qam.64.2015.01.06.13.26.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 06 Jan 2015 13:26:35 -0800 (PST)
Received: by mail-qa0-f46.google.com with SMTP id w8so218078qac.5
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 13:26:35 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 03/45] memcg: encode page_cgflags in the lower bits of page->mem_cgroup
Date: Tue,  6 Jan 2015 16:25:40 -0500
Message-Id: <1420579582-8516-4-git-send-email-tj@kernel.org>
In-Reply-To: <1420579582-8516-1-git-send-email-tj@kernel.org>
References: <1420579582-8516-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk
Cc: linux-kernel@vger.kernel.org, jack@suse.cz, hch@infradead.org, hannes@cmpxchg.org, linux-fsdevel@vger.kernel.org, vgoyal@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, clm@fb.com, fengguang.wu@intel.com, david@fromorbit.com, Tejun Heo <tj@kernel.org>

cgroup writeback support will require several bits per page.  They can
easily be encoded in the lower bits of page->mem_cgroup which only
increases the alignement of struct mem_cgroup.  This patch

* Converts page->mem_cgroup to unsigned long so that nobody
  dereferences it directly and bit operations are easier.

* Introduces enum page_cgflags which will list the flags.  It
  currently only defines PCG_FLAGS_BITS and PCG_FLAGS_MASK.  The
  former is used to align struct mem_cgroup accordingly.

* Adds and applies two accessors - page_memcg_is_set() and
  page_memcg().

With PCG_FLAGS_BITS at zero, this patch shouldn't introduce any
noticeable functional changes.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
---
 include/linux/mm_types.h |  3 +-
 mm/debug.c               |  2 +-
 mm/memcontrol.c          | 84 ++++++++++++++++++++++++++++++++----------------
 3 files changed, 59 insertions(+), 30 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 97f2bb3..7f6c5ef 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -21,7 +21,6 @@
 #define AT_VECTOR_SIZE (2*(AT_VECTOR_SIZE_ARCH + AT_VECTOR_SIZE_BASE + 1))
 
 struct address_space;
-struct mem_cgroup;
 
 #define USE_SPLIT_PTE_PTLOCKS	(NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS)
 #define USE_SPLIT_PMD_PTLOCKS	(USE_SPLIT_PTE_PTLOCKS && \
@@ -176,7 +175,7 @@ struct page {
 	};
 
 #ifdef CONFIG_MEMCG
-	struct mem_cgroup *mem_cgroup;
+	unsigned long mem_cgroup;
 #endif
 
 	/*
diff --git a/mm/debug.c b/mm/debug.c
index 0e58f32..94d91f9 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -97,7 +97,7 @@ void dump_page_badflags(struct page *page, const char *reason,
 	}
 #ifdef CONFIG_MEMCG
 	if (page->mem_cgroup)
-		pr_alert("page->mem_cgroup:%p\n", page->mem_cgroup);
+		pr_alert("page->mem_cgroup:%p\n", (void *)page->mem_cgroup);
 #endif
 }
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 202e386..3ab3f04 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -87,6 +87,35 @@ static int really_do_swap_account __initdata;
 #define do_swap_account		0
 #endif
 
+/*
+ * Lower bits of page->mem_cgroup encodes the following flags.  Use
+ * page_memcg*() and page_cgflags*() to access the pointer and flags
+ * respectively.  The flags can be used only while the pointer is set and
+ * are cleared together with it.
+ */
+enum page_cgflags {
+	PCG_FLAGS_BITS		= 0,
+	PCG_FLAGS_MASK		= ((1UL << PCG_FLAGS_BITS) - 1),
+};
+
+/* struct mem_cgroup should be accordingly aligned */
+#define MEM_CGROUP_ALIGN						\
+	((1UL << PCG_FLAGS_BITS) >= __alignof__(unsigned long long) ?	\
+	 (1UL << PCG_FLAGS_BITS) : __alignof__(unsigned long long))
+
+static bool page_memcg_is_set(struct page *page)
+{
+	if (page->mem_cgroup) {
+		WARN_ON_ONCE(!(page->mem_cgroup & ~PCG_FLAGS_MASK));
+		return true;
+	}
+	return false;
+}
+
+static struct mem_cgroup *page_memcg(struct page *page)
+{
+	return (void *)(page->mem_cgroup & ~PCG_FLAGS_MASK);
+}
 
 static const char * const mem_cgroup_stat_names[] = {
 	"cache",
@@ -362,7 +391,7 @@ struct mem_cgroup {
 
 	struct mem_cgroup_per_node *nodeinfo[0];
 	/* WARNING: nodeinfo must be the last member here */
-};
+} __aligned(MEM_CGROUP_ALIGN);
 
 #ifdef CONFIG_MEMCG_KMEM
 static bool memcg_kmem_is_active(struct mem_cgroup *memcg)
@@ -1268,7 +1297,7 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *page, struct zone *zone)
 		goto out;
 	}
 
-	memcg = page->mem_cgroup;
+	memcg = page_memcg(page);
 	/*
 	 * Swapcache readahead pages are added to the LRU - and
 	 * possibly migrated - before they are charged.
@@ -2011,7 +2040,7 @@ struct mem_cgroup *mem_cgroup_begin_page_stat(struct page *page)
 	if (mem_cgroup_disabled())
 		return NULL;
 again:
-	memcg = page->mem_cgroup;
+	memcg = page_memcg(page);
 	if (unlikely(!memcg))
 		return NULL;
 
@@ -2019,7 +2048,7 @@ again:
 		return memcg;
 
 	spin_lock_irqsave(&memcg->move_lock, flags);
-	if (memcg != page->mem_cgroup) {
+	if (memcg != page_memcg(page)) {
 		spin_unlock_irqrestore(&memcg->move_lock, flags);
 		goto again;
 	}
@@ -2401,7 +2430,7 @@ struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
 
 	VM_BUG_ON_PAGE(!PageLocked(page), page);
 
-	memcg = page->mem_cgroup;
+	memcg = page_memcg(page);
 	if (memcg) {
 		if (!css_tryget_online(&memcg->css))
 			memcg = NULL;
@@ -2453,7 +2482,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 {
 	int isolated;
 
-	VM_BUG_ON_PAGE(page->mem_cgroup, page);
+	VM_BUG_ON_PAGE(page_memcg_is_set(page), page);
 
 	/*
 	 * In some cases, SwapCache and FUSE(splice_buf->radixtree), the page
@@ -2476,7 +2505,7 @@ static void commit_charge(struct page *page, struct mem_cgroup *memcg,
 	 * - a page cache insertion, a swapin fault, or a migration
 	 *   have the page locked
 	 */
-	page->mem_cgroup = memcg;
+	page->mem_cgroup = (unsigned long)memcg;
 
 	if (lrucare)
 		unlock_page_lru(page, isolated);
@@ -2751,12 +2780,12 @@ void __memcg_kmem_commit_charge(struct page *page, struct mem_cgroup *memcg,
 		memcg_uncharge_kmem(memcg, 1 << order);
 		return;
 	}
-	page->mem_cgroup = memcg;
+	page->mem_cgroup = (unsigned long)memcg;
 }
 
 void __memcg_kmem_uncharge_pages(struct page *page, int order)
 {
-	struct mem_cgroup *memcg = page->mem_cgroup;
+	struct mem_cgroup *memcg = page_memcg(page);
 
 	if (!memcg)
 		return;
@@ -2764,7 +2793,7 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
 	VM_BUG_ON_PAGE(mem_cgroup_is_root(memcg), page);
 
 	memcg_uncharge_kmem(memcg, 1 << order);
-	page->mem_cgroup = NULL;
+	page->mem_cgroup = 0;
 }
 #endif /* CONFIG_MEMCG_KMEM */
 
@@ -2778,15 +2807,16 @@ void __memcg_kmem_uncharge_pages(struct page *page, int order)
  */
 void mem_cgroup_split_huge_fixup(struct page *head)
 {
+	struct mem_cgroup *memcg = page_memcg(head);
 	int i;
 
 	if (mem_cgroup_disabled())
 		return;
 
 	for (i = 1; i < HPAGE_PMD_NR; i++)
-		head[i].mem_cgroup = head->mem_cgroup;
+		head[i].mem_cgroup = (unsigned long)memcg;
 
-	__this_cpu_sub(head->mem_cgroup->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
+	__this_cpu_sub(memcg->stat->count[MEM_CGROUP_STAT_RSS_HUGE],
 		       HPAGE_PMD_NR);
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
@@ -2834,7 +2864,7 @@ static int mem_cgroup_move_account(struct page *page,
 		goto out;
 
 	ret = -EINVAL;
-	if (page->mem_cgroup != from)
+	if (page_memcg(page) != from)
 		goto out_unlock;
 
 	spin_lock_irqsave(&from->move_lock, flags);
@@ -2860,7 +2890,7 @@ static int mem_cgroup_move_account(struct page *page,
 	 */
 
 	/* caller should have done css_get */
-	page->mem_cgroup = to;
+	page->mem_cgroup = (unsigned long)to;
 	spin_unlock_irqrestore(&from->move_lock, flags);
 
 	ret = 0;
@@ -4838,7 +4868,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
 		 * mem_cgroup_move_account() checks the page is valid or
 		 * not under LRU exclusion.
 		 */
-		if (page->mem_cgroup == mc.from) {
+		if (page_memcg(page) == mc.from) {
 			ret = MC_TARGET_PAGE;
 			if (target)
 				target->page = page;
@@ -4872,7 +4902,7 @@ static enum mc_target_type get_mctgt_type_thp(struct vm_area_struct *vma,
 	VM_BUG_ON_PAGE(!page || !PageHead(page), page);
 	if (!move_anon())
 		return ret;
-	if (page->mem_cgroup == mc.from) {
+	if (page_memcg(page) == mc.from) {
 		ret = MC_TARGET_PAGE;
 		if (target) {
 			get_page(page);
@@ -5316,7 +5346,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	if (!do_swap_account)
 		return;
 
-	memcg = page->mem_cgroup;
+	memcg = page_memcg(page);
 
 	/* Readahead page, never charged */
 	if (!memcg)
@@ -5326,7 +5356,7 @@ void mem_cgroup_swapout(struct page *page, swp_entry_t entry)
 	VM_BUG_ON_PAGE(oldid, page);
 	mem_cgroup_swap_statistics(memcg, true);
 
-	page->mem_cgroup = NULL;
+	page->mem_cgroup = 0;
 
 	if (!mem_cgroup_is_root(memcg))
 		page_counter_uncharge(&memcg->memory, 1);
@@ -5400,7 +5430,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
 		 * the page lock, which serializes swap cache removal, which
 		 * in turn serializes uncharging.
 		 */
-		if (page->mem_cgroup)
+		if (page_memcg_is_set(page))
 			goto out;
 	}
 
@@ -5560,7 +5590,7 @@ static void uncharge_list(struct list_head *page_list)
 		VM_BUG_ON_PAGE(PageLRU(page), page);
 		VM_BUG_ON_PAGE(page_count(page), page);
 
-		if (!page->mem_cgroup)
+		if (!page_memcg_is_set(page))
 			continue;
 
 		/*
@@ -5569,13 +5599,13 @@ static void uncharge_list(struct list_head *page_list)
 		 * exclusive access to the page.
 		 */
 
-		if (memcg != page->mem_cgroup) {
+		if (memcg != page_memcg(page)) {
 			if (memcg) {
 				uncharge_batch(memcg, pgpgout, nr_anon, nr_file,
 					       nr_huge, page);
 				pgpgout = nr_anon = nr_file = nr_huge = 0;
 			}
-			memcg = page->mem_cgroup;
+			memcg = page_memcg(page);
 		}
 
 		if (PageTransHuge(page)) {
@@ -5589,7 +5619,7 @@ static void uncharge_list(struct list_head *page_list)
 		else
 			nr_file += nr_pages;
 
-		page->mem_cgroup = NULL;
+		page->mem_cgroup = 0;
 
 		pgpgout++;
 	} while (next != page_list);
@@ -5612,7 +5642,7 @@ void mem_cgroup_uncharge(struct page *page)
 		return;
 
 	/* Don't touch page->lru of any random page, pre-check: */
-	if (!page->mem_cgroup)
+	if (!page_memcg_is_set(page))
 		return;
 
 	INIT_LIST_HEAD(&page->lru);
@@ -5663,7 +5693,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 		return;
 
 	/* Page cache replacement: new page already charged? */
-	if (newpage->mem_cgroup)
+	if (page_memcg_is_set(newpage))
 		return;
 
 	/*
@@ -5672,14 +5702,14 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage,
 	 * uncharged page when the PFN walker finds a page that
 	 * reclaim just put back on the LRU but has not released yet.
 	 */
-	memcg = oldpage->mem_cgroup;
+	memcg = page_memcg(oldpage);
 	if (!memcg)
 		return;
 
 	if (lrucare)
 		lock_page_lru(oldpage, &isolated);
 
-	oldpage->mem_cgroup = NULL;
+	oldpage->mem_cgroup = 0;
 
 	if (lrucare)
 		unlock_page_lru(oldpage, isolated);
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
