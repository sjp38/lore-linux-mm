Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id 410316B0039
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:01:01 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id uy17so2682964igb.4
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:01:01 -0800 (PST)
Date: Thu, 12 Dec 2013 12:00:57 -0600
From: Alex Thorlton <athorlton@sgi.com>
Subject: [RFC PATCH 3/3] Change THP behavior
Message-ID: <20131212180057.GD134240@sgi.com>
References: <cover.1386790423.git.athorlton@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1386790423.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Rik van Riel <riel@redhat.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Michel Lespinasse <walken@google.com>, Benjamin LaHaise <bcrl@kvack.org>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Andy Lutomirski <luto@amacapital.net>, Al Viro <viro@zeniv.linux.org.uk>, David Rientjes <rientjes@google.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jiang Liu <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Glauber Costa <glommer@parallels.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org

This patch implements the functionality we're really going for here.
It adds the decision making behavior to determine when to grab a
temporary compound page, and whether or not to fault in single pages or
to turn the temporary page into a THP.  This one is rather large, might
split it up a bit more for later versions

I've left most of my comments in here just to provide people with some
insight into what I may have been thinking when I chose to do something
in a certain way.  These will probably be trimmed down in later versions
of the patch.

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nate Zimmer <nzimmer@sgi.com>
Cc: Cliff Wickman <cpw@sgi.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Michel Lespinasse <walken@google.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: David Rientjes <rientjes@google.com>
Cc: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Jiang Liu <jiang.liu@huawei.com>
Cc: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: Glauber Costa <glommer@parallels.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

---
 include/linux/huge_mm.h  |   6 +
 include/linux/mm_types.h |  13 +++
 kernel/fork.c            |   1 +
 mm/huge_memory.c         | 283 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h            |   1 +
 mm/memory.c              |  29 ++++-
 mm/page_alloc.c          |  66 ++++++++++-
 7 files changed, 392 insertions(+), 7 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 0943b1b6..c1e407d 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -5,6 +5,12 @@ extern int do_huge_pmd_anonymous_page(struct mm_struct *mm,
 				      struct vm_area_struct *vma,
 				      unsigned long address, pmd_t *pmd,
 				      unsigned int flags);
+extern struct temp_hugepage *find_pmd_mm_freelist(struct mm_struct *mm,
+						 pmd_t *pmd);
+extern int do_huge_pmd_temp_page(struct mm_struct *mm,
+				 struct vm_area_struct *vma,
+				 unsigned long address, pmd_t *pmd,
+				 unsigned int flags);
 extern int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 			 pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 			 struct vm_area_struct *vma);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b5efa23..d48c6ab 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -322,6 +322,17 @@ struct mm_rss_stat {
 	atomic_long_t count[NR_MM_COUNTERS];
 };
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+struct temp_hugepage {
+	pmd_t *pmd;
+	struct page *page;
+	spinlock_t temp_hugepage_lock;
+	int node;			/* node id of the first page in the chunk */
+	int ref_count;			/* number of pages faulted in from the chunk */
+	struct list_head list;		/* pointers to next/prev chunks */
+};
+#endif
+
 struct kioctx_table;
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
@@ -408,7 +419,9 @@ struct mm_struct {
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	pgtable_t pmd_huge_pte; /* protected by page_table_lock */
+	spinlock_t thp_list_lock; /* lock to protect thp_temp_list */
 	int thp_threshold;
+	struct list_head thp_temp_list; /* list of 512 page chunks for THPs */
 #endif
 #ifdef CONFIG_CPUMASK_OFFSTACK
 	struct cpumask cpumask_allocation;
diff --git a/kernel/fork.c b/kernel/fork.c
index 086fe73..a3ccf857 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -816,6 +816,7 @@ struct mm_struct *dup_mm(struct task_struct *tsk)
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	mm->pmd_huge_pte = NULL;
+	INIT_LIST_HEAD(&mm->thp_temp_list);
 #endif
 #ifdef CONFIG_NUMA_BALANCING
 	mm->first_nid = NUMA_PTE_SCAN_INIT;
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 5d388e4..43ea095 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -788,6 +788,20 @@ static inline struct page *alloc_hugepage_vma(int defrag,
 			       HPAGE_PMD_ORDER, vma, haddr, nd);
 }
 
+static inline gfp_t alloc_temp_hugepage_gfpmask(gfp_t extra_gfp)
+{
+	return GFP_TEMP_TRANSHUGE | extra_gfp;
+}
+
+static inline struct page *alloc_temp_hugepage_vma(int defrag,
+					      struct vm_area_struct *vma,
+					      unsigned long haddr, int nd,
+					      gfp_t extra_gfp)
+{
+	return alloc_pages_vma(alloc_temp_hugepage_gfpmask(extra_gfp),
+			       HPAGE_PMD_ORDER, vma, haddr, nd);
+}
+
 #ifndef CONFIG_NUMA
 static inline struct page *alloc_hugepage(int defrag)
 {
@@ -871,6 +885,275 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	return 0;
 }
 
+/* We need to hold mm->thp_list_lock during this search */
+struct temp_hugepage *find_pmd_mm_freelist(struct mm_struct *mm, pmd_t *pmd)
+{
+	struct temp_hugepage *temp_thp;
+	/*
+	 * we need to check to make sure that the PMD isn't already
+	 * on the list. return the temp_hugepage struct if we find one
+	 * otherwise we just return NULL
+	 */
+	list_for_each_entry(temp_thp, &mm->thp_temp_list, list) {
+		if (temp_thp->pmd == pmd) {
+			return temp_thp;
+		}
+	}
+
+	return NULL;
+}
+
+int do_huge_pmd_temp_page(struct mm_struct *mm, struct vm_area_struct *vma,
+			       unsigned long address, pmd_t *pmd,
+			       unsigned int flags)
+{
+	int i;
+	spinlock_t *ptl;
+	struct page *page;
+	pte_t *pte;
+	pte_t entry;
+	struct temp_hugepage *temp_thp;
+	unsigned long haddr = address & HPAGE_PMD_MASK;
+
+	if (haddr < vma->vm_start || haddr + HPAGE_PMD_SIZE > vma->vm_end)
+		return VM_FAULT_FALLBACK;
+	if (unlikely(anon_vma_prepare(vma)))
+		return VM_FAULT_OOM;
+	if (unlikely(khugepaged_enter(vma)))
+		return VM_FAULT_OOM;
+	/*
+	 * we're not going to handle this case yet, for now
+	 * we'll just fall back to regular pages
+	 */
+	if (!(flags & FAULT_FLAG_WRITE) &&
+			transparent_hugepage_use_zero_page()) {
+		pgtable_t pgtable;
+		struct page *zero_page;
+		bool set;
+		pgtable = pte_alloc_one(mm, haddr);
+		if (unlikely(!pgtable))
+			return VM_FAULT_OOM;
+		zero_page = get_huge_zero_page();
+		if (unlikely(!zero_page)) {
+			pte_free(mm, pgtable);
+			count_vm_event(THP_FAULT_FALLBACK);
+			return VM_FAULT_FALLBACK;
+		}
+		spin_lock(&mm->page_table_lock);
+		set = set_huge_zero_page(pgtable, mm, vma, haddr, pmd,
+				zero_page);
+		spin_unlock(&mm->page_table_lock);
+		if (!set) {
+			pte_free(mm, pgtable);
+			put_huge_zero_page();
+		}
+		return 0;
+	}
+
+	/*
+	 * Here's where we either need to store the PMD on the list
+	 * and give them a regular page, or make the decision to flip
+	 * the PSE bit and send them back with a hugepage
+	 *
+	 * + First we call find_pmd_mm_freelist to determine if the pmd
+	 *   we're interested in has already been faulted into
+	 */
+	spin_lock(&mm->thp_list_lock);
+	temp_thp = find_pmd_mm_freelist(mm, pmd);
+
+	/* this is a temporary workaround to avoid putting the pages back on the freelist */
+	if (temp_thp && temp_thp->node == -1) {
+		spin_unlock(&mm->thp_list_lock);
+		goto single_fault;
+	}
+
+	/*
+	 * we need to create a list entry and add it to the
+	 * new per-mm free list if we didn't find an existing
+	 * entry
+	 */
+	if (!temp_thp && pmd_none(*pmd)) {
+		/* try to get 512 pages from the freelist */
+		page = alloc_temp_hugepage_vma(transparent_hugepage_defrag(vma),
+					  vma, haddr, numa_node_id(), 0);
+
+		if (unlikely(!page)) {
+			/* we should probably change the VM event here? */
+			count_vm_event(THP_FAULT_FALLBACK);
+			return VM_FAULT_FALLBACK;
+		}
+
+		/* do this here instead of below, to get the whole page ready */
+		clear_huge_page(page, haddr, HPAGE_PMD_NR);
+
+		/* add a new temp_hugepage entry to the local freelist */
+		temp_thp = kmalloc(sizeof(struct temp_hugepage), GFP_KERNEL);
+		if (!temp_thp)
+			return VM_FAULT_OOM;
+		temp_thp->pmd = pmd;
+		temp_thp->page = page;
+		temp_thp->node = numa_node_id();
+		temp_thp->ref_count = 1;
+		list_add(&temp_thp->list, &mm->thp_temp_list);
+	/*
+	 * otherwise we increment the reference count, and decide whether
+	 * or not to create a THP
+	 */
+	} else if (temp_thp && !pmd_none(*pmd) && temp_thp->node == numa_node_id()) {
+		temp_thp->ref_count++;
+	/* if they allocated from a different node, they don't get a thp */
+	} else if (temp_thp && !pmd_none(*pmd) && temp_thp->node != numa_node_id()) {
+		/*
+		 * for now we handle this by pushing the rest of the faults through our
+		 * custom fault code below, eventually we will want to put the unused
+		 * pages from out temp_hugepage back on the freelist, so they can be
+		 * faulted in by the normal code paths
+		 */
+
+		temp_thp->node = -1;
+	} else {
+		spin_unlock(&mm->thp_list_lock);
+		return VM_FAULT_FALLBACK;
+	}
+
+	spin_unlock(&mm->thp_list_lock);
+
+	/*
+	 * now that we've done the accounting work, we check to see if
+	 * we've exceeded our threshold
+	 */
+	if (temp_thp->ref_count >= mm->thp_threshold) {
+		pmd_t pmd_entry;
+		pgtable_t pgtable;
+
+		/*
+		 * we'll do all of the following beneath the big ptl for now
+		 * this will need to be modified to work with the split ptl
+		 */
+		spin_lock(&mm->page_table_lock);
+
+		/*
+		 * once we get past the lock we have to make sure that somebody
+		 * else hasn't already turned this guy into a THP, if they have,
+		 * then the page we need is already faulted in as part of the THP
+		 * they created
+		 */
+		if (PageTransHuge(temp_thp->page)) {
+			spin_unlock(&mm->page_table_lock);
+			return 0;
+		}
+
+		pgtable = pte_alloc_one(mm, haddr);
+		if (unlikely(!pgtable)) {
+			spin_unlock(&mm->page_table_lock);
+			return VM_FAULT_OOM;
+		}
+
+		/* might wanna move this? */
+		__SetPageUptodate(temp_thp->page);
+
+		/* turn the pages into one compound page */
+		make_compound_page(temp_thp->page, HPAGE_PMD_ORDER);
+
+		/* set up the pmd */
+		pmd_entry = mk_huge_pmd(temp_thp->page, vma->vm_page_prot);
+		pmd_entry = maybe_pmd_mkwrite(pmd_mkdirty(pmd_entry), vma);
+
+		/* remap the new page since we cleared the mappings */
+		page_add_anon_rmap(temp_thp->page, vma, address);
+
+		/* deposit the thp */
+		pgtable_trans_huge_deposit(mm, pmd, pgtable);
+
+		set_pmd_at(mm, haddr, pmd, pmd_entry);
+		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR - mm->thp_threshold + 1);
+		/* mm->nr_ptes++; */
+
+		/* delete the reference to this compound page from our list */
+		spin_lock(&mm->thp_list_lock);
+		list_del(&temp_thp->list);
+		spin_unlock(&mm->thp_list_lock);
+
+		spin_unlock(&mm->page_table_lock);
+		return 0;
+	} else {
+single_fault:
+		/* fault in the page */
+		if (pmd_none(*pmd) && __pte_alloc(mm, vma, temp_thp->pmd, address))
+			return VM_FAULT_OOM;
+
+		/*
+		 * we'll do all of the following beneath the big ptl for now
+		 * this will need to be modified to work with the split ptl
+		 */
+		spin_lock(&mm->page_table_lock);
+
+		page = temp_thp->page + (int) pte_index(address);
+
+		/* set the page's refcount */
+		set_page_refcounted(page);
+		pte = pte_offset_map(temp_thp->pmd, address);
+
+		/* might wanna move this? */
+		__SetPageUptodate(page);
+
+		if (!pte_present(*pte)) {
+			if (pte_none(*pte)) {
+				pte_unmap(pte);
+
+				if (unlikely(anon_vma_prepare(vma))) {
+					spin_unlock(&mm->page_table_lock);
+					return VM_FAULT_OOM;
+				}
+
+				entry = mk_pte(page, vma->vm_page_prot);
+				if (vma->vm_flags & VM_WRITE)
+					entry = pte_mkwrite(pte_mkdirty(entry));
+
+				pte = pte_offset_map_lock(mm, temp_thp->pmd, address, &ptl);
+
+				page_add_new_anon_rmap(page, vma, haddr);
+				add_mm_counter(mm, MM_ANONPAGES, 1);
+
+				set_pte_at(mm, address, pte, entry);
+
+				pte_unmap_unlock(pte, ptl);
+				spin_unlock(&mm->page_table_lock);
+
+				return 0;
+			}
+		} else {
+			spin_unlock(&mm->page_table_lock);
+			return VM_FAULT_FALLBACK;
+		}
+	}
+
+	/* I don't know what this does right now.  I'm leaving it */
+	if (unlikely(mem_cgroup_newpage_charge(page, mm, GFP_KERNEL))) {
+		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK);
+		return VM_FAULT_FALLBACK;
+	}
+
+	/*
+	 * here's the important piece, where we actually make our 512
+	 * page chunk into a THP, by setting the PSE bit.  This is the
+	 * spot we really need to change.  In the end, we could probably
+	 * spin this up into the old function, but we'll keep them separate
+	 * for now
+	 */
+	if (unlikely(__do_huge_pmd_anonymous_page(mm, vma, haddr, pmd, page))) {
+		mem_cgroup_uncharge_page(page);
+		put_page(page);
+		count_vm_event(THP_FAULT_FALLBACK);
+		return VM_FAULT_FALLBACK;
+	}
+
+	/* again, probably want a different VM event here */
+	count_vm_event(THP_FAULT_ALLOC);
+	return 0;
+}
+
 int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		  pmd_t *dst_pmd, pmd_t *src_pmd, unsigned long addr,
 		  struct vm_area_struct *vma)
diff --git a/mm/internal.h b/mm/internal.h
index 684f7aa..8fc296b 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -98,6 +98,7 @@ extern pmd_t *mm_find_pmd(struct mm_struct *mm, unsigned long address);
  */
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
+extern void make_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
 extern bool is_free_buddy_page(struct page *page);
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index d176154..014d9ba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3764,13 +3764,30 @@ retry:
 	pmd = pmd_alloc(mm, pud, address);
 	if (!pmd)
 		return VM_FAULT_OOM;
-	if (pmd_none(*pmd) && transparent_hugepage_enabled(vma)) {
+	if (transparent_hugepage_enabled(vma)) {
 		int ret = VM_FAULT_FALLBACK;
-		if (!vma->vm_ops)
-			ret = do_huge_pmd_anonymous_page(mm, vma, address,
-					pmd, flags);
-		if (!(ret & VM_FAULT_FALLBACK))
-			return ret;
+		/*
+		 * This is a temporary location for this code, just to get things
+		 * up and running.  I'll come up with a better way to handle this
+		 * later
+		 */
+		if (!mm->thp_threshold)
+			mm->thp_threshold = thp_threshold_check();
+		if (!mm->thp_temp_list.next && !mm->thp_temp_list.prev)
+			INIT_LIST_HEAD(&mm->thp_temp_list);
+		if (mm->thp_threshold > 1) {
+			if (!vma->vm_ops)
+				ret = do_huge_pmd_temp_page(mm, vma, address,
+							    pmd, flags);
+			if (!(ret & VM_FAULT_FALLBACK))
+				return ret;
+		} else if (pmd_none(*pmd)) {
+			if (!vma->vm_ops)
+				ret = do_huge_pmd_anonymous_page(mm, vma, address,
+								 pmd, flags);
+			if (!(ret & VM_FAULT_FALLBACK))
+				return ret;
+		}
 	} else {
 		pmd_t orig_pmd = *pmd;
 		int ret;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dd886fa..48e13fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -375,6 +375,65 @@ void prep_compound_page(struct page *page, unsigned long order)
 	}
 }
 
+/*
+ * This function is used to create a proper compound page from a chunk of
+ * contiguous pages, most likely allocated as a temporary hugepage
+ */
+void make_compound_page(struct page *page, unsigned long order)
+{
+	int i, max_count = 0, max_mapcount = 0;
+	int nr_pages = 1 << order;
+
+	set_compound_page_dtor(page, free_compound_page);
+	set_compound_order(page, order);
+
+	__SetPageHead(page);
+
+	/*
+	 * we clear all the mappings here, so we have to remember to set
+	 * them back up!
+	 */
+	page->mapping = NULL;
+
+	max_count = (int) atomic_read(&page->_count);
+	max_mapcount = (int) atomic_read(&page->_mapcount);
+
+	for (i = 1; i < nr_pages; i++) {
+		int cur_count, cur_mapcount;
+		struct page *p = page + i;
+		p->flags = 0; /* this seems dumb */
+		__SetPageTail(p);
+		set_page_count(p, 0);
+		p->first_page = page;
+		p->mapping = NULL;
+
+		cur_count = (int) atomic_read(&page->_count);
+		cur_mapcount = (int) atomic_read(&page->_mapcount);
+		atomic_set(&page->_count, 0);
+		atomic_set(&page->_mapcount, -1);
+		if (cur_count > max_count)
+			max_count = cur_count;
+		if (cur_mapcount > max_mapcount)
+			max_mapcount = cur_mapcount;
+
+		/*
+		 * poison the LRU entries for all the tail pages (aside from the
+		 * first one), the entries for the head page should be okay
+		 */
+		if (i != 1) {
+			p->lru.next = LIST_POISON1;
+			p->lru.prev = LIST_POISON2;
+		}
+	}
+
+	atomic_set(&page->_count, max_count);
+	/*
+	 * we set to max_mapcount - 1 here because we're going to
+	 * map this page again later.  This definitely doesn't seem right.
+	 */
+	atomic_set(&page->_mapcount, max_mapcount - 1);
+}
+
 /* update __split_huge_page_refcount if you change this function */
 static int destroy_compound_page(struct page *page, unsigned long order)
 {
@@ -865,7 +924,12 @@ static int prep_new_page(struct page *page, int order, gfp_t gfp_flags)
 	}
 
 	set_page_private(page, 0);
-	set_page_refcounted(page);
+	 /*
+	  * We don't want to set _count for temporary compound pages, since
+	  * we may not immediately fault in the first page
+	  */
+	if (!(gfp_flags & __GFP_COMP_TEMP))
+		set_page_refcounted(page);
 
 	arch_alloc_page(page, order);
 	kernel_map_pages(page, 1 << order, 1);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
