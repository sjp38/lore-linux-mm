Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f50.google.com (mail-bk0-f50.google.com [209.85.214.50])
	by kanga.kvack.org (Postfix) with ESMTP id F00C66B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 11:15:43 -0400 (EDT)
Received: by mail-bk0-f50.google.com with SMTP id w10so800744bkz.37
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 08:15:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id tt9si1745529bkb.304.2014.03.27.08.15.41
        for <linux-mm@kvack.org>;
        Thu, 27 Mar 2014 08:15:42 -0700 (PDT)
Date: Thu, 27 Mar 2014 11:15:13 -0400
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH RFC] hugetlb: add support for 1GB huge page allocation at
 runtime
Message-ID: <20140327111513.7e19e612@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, mtosatti@redhat.com, aarcange@redhat.com, mgorman@suse.de, akpm@linux-foundation.org, andi@firstfloor.org, davidlohr@hp.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, riel@redhat.com

Currently, 1GB huge page allocation is only possible at boottime, by means
of the hugepages= command-line option. This has a number of drawbacks, the
most important of them being:

 1. On a NUMA machine, the kernel will evenly distribute page allocation
    among nodes. For example, if you have a NUMA machine with 4 nodes and
    want to allocate four 1GB huge pages, the kernel will try to allocate
    one page per node.

    On the other hand, we have users who want to be able to specify
    from which node an allocation should be made. For example, they
    want to be able to allocate two 1GB huge pages from node 1 only.
    Supporting this use-case is the main motivation for this feature.

 2. Once allocated, boottime huge pages can't be freed

This commit solves both issues by adding support for allocating 1GB huge
pages during runtime, just like 2MB huge pages, which supports NUMA and
has a standard use interface in sysfs.

For example, to allocate two 1GB huge pages from node 1, one can do:

 # echo 2 > \
   /sys/devices/system/node/node1/hugepages/hugepages-1048576kB/nr_hugepages

  (You need hugeTLB properly configured to have that sysfs entry)

The one problem with 1GB huge page runtime allocation is that such gigantic
allocation can't be serviced by the buddy allocator, which is limited to
allocating 2048 pages on most archs. To overcome that problem, we scan all
zones from a node looking for a 1GB contiguous region. When one is found,
it's allocated by using CMA, that is, we call alloc_contig_range().

One expected issue with 1GB huge page support is that free 1GB contiguous
regions tend to vanish as time goes by. The best way to avoid this for now
is to make 1GB huge pages allocations very early during boot, say from a
init script. Other possible optimization include using compaction, which
is already supported by CMA but is not explicitly used by this commit.

This patch is quite complete and works, I'm labelling it RFC because of
the following:

1. I haven't tested surplus pages, cgroup support, allocating through
   hugetlbfs and a few other things

2. I haven't looked at adding 1GB huge page support to alloc_huge_page_node(),
   which seems to allocate huge pages on demand. Do we need this for the
   first merge?

3. Should 1GB huge page allocation code update HTLB_BUDDY_PGALLOC and
   HTLB_BUDDY_PGALLOC_FAIL? I think it shouldn't, as we don't allocate from
   the buddy

Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>
---

This patch is a follow up for this series:

 http://marc.info/?l=linux-mm&m=139234006724423&w=2

That series introduced a command-line option to allow the user to specify from
which NUMA node a 1GB hugepage allocation should be made. In that discussion
is was suggested that having support for runtime allocation was a better solution.

 arch/x86/include/asm/hugetlb.h |  10 +++
 include/linux/hugetlb.h        |   5 ++
 mm/hugetlb.c                   | 176 ++++++++++++++++++++++++++++++++++++++---
 3 files changed, 181 insertions(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index a809121..2b262f7 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -91,6 +91,16 @@ static inline void arch_release_hugepage(struct page *page)
 {
 }
 
+static inline int arch_prepare_gigantic_page(struct page *page)
+{
+	return 0;
+}
+
+static inline void arch_release_gigantic_page(struct page *page)
+{
+}
+
+
 static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 8c43cc4..8590134 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -333,6 +333,11 @@ static inline unsigned huge_page_shift(struct hstate *h)
 	return h->order + PAGE_SHIFT;
 }
 
+static inline bool hstate_is_gigantic(struct hstate *h)
+{
+	return huge_page_order(h) >= MAX_ORDER;
+}
+
 static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1 << h->order;
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index c01cb9f..53b5ddc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -570,11 +570,146 @@ err:
 	return NULL;
 }
 
+#ifdef CONFIG_CMA
+static void destroy_compound_gigantic_page(struct page *page,
+					unsigned long order)
+{
+	int i;
+	int nr_pages = 1 << order;
+	struct page *p = page + 1;
+
+	for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
+		__ClearPageTail(p);
+		set_page_refcounted(p);
+		p->first_page = NULL;
+	}
+
+	set_compound_order(page, 0);
+	__ClearPageHead(page);
+}
+
+static void free_gigantic_page(struct page *page, unsigned order)
+{
+	free_contig_range(page_to_pfn(page), 1 << order);
+}
+
+static int __alloc_gigantic_page(unsigned long start_pfn, unsigned long count)
+{
+	unsigned long end_pfn = start_pfn + count;
+	return alloc_contig_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+}
+
+static bool pfn_valid_gigantic(unsigned long pfn)
+{
+	struct page *page;
+
+	if (!pfn_valid(pfn))
+		return false;
+
+	page = pfn_to_page(pfn);
+
+	if (PageReserved(page))
+		return false;
+
+	if (page_count(page) > 0)
+		return false;
+
+	return true;
+}
+
+static bool pfn_aligned_gigantic(unsigned long pfn, unsigned order)
+{
+	return IS_ALIGNED((phys_addr_t) pfn << PAGE_SHIFT, PAGE_SIZE << order);
+}
+
+static struct page *alloc_gigantic_page(int nid, unsigned order)
+{
+	unsigned long ret, i, count, start_pfn, flags;
+	unsigned long nr_pages = 1 << order;
+	struct zone *z;
+
+	z = NODE_DATA(nid)->node_zones;
+	for (; z - NODE_DATA(nid)->node_zones < MAX_NR_ZONES; z++) {
+		spin_lock_irqsave(&z->lock, flags);
+		if (z->spanned_pages < nr_pages) {
+			spin_unlock_irqrestore(&z->lock, flags);
+			continue;
+		}
+
+		/* scan zone 'z' looking for a contiguous 'nr_pages' range */
+		count = 0;
+		start_pfn = z->zone_start_pfn; /* to silence gcc */
+		for (i = z->zone_start_pfn; i < zone_end_pfn(z); i++) {
+			if (!pfn_valid_gigantic(i)) {
+				count = 0;
+				continue;
+			}
+			if (!count) {
+				if (!pfn_aligned_gigantic(i, order))
+					continue;
+				start_pfn = i;
+			}
+			if (++count == nr_pages) {
+				/*
+				 * We release the zone lock here because
+				 * alloc_contig_range() will also lock the zone
+				 * at some point. If there's an allocation
+				 * spinning on this lock, it may win the race
+				 * and cause alloc_contig_range() to fail...
+				 */
+				spin_unlock_irqrestore(&z->lock, flags);
+				ret = __alloc_gigantic_page(start_pfn, count);
+				if (!ret)
+					return pfn_to_page(start_pfn);
+				count = 0;
+				spin_lock_irqsave(&z->lock, flags);
+			}
+		}
+
+		spin_unlock_irqrestore(&z->lock, flags);
+	}
+
+	return NULL;
+}
+
+static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
+static void prep_compound_gigantic_page(struct page *page, unsigned long order);
+
+static struct page *alloc_fresh_gigantic_page_node(struct hstate *h, int nid)
+{
+	struct page *page;
+
+	page = alloc_gigantic_page(nid, huge_page_order(h));
+	if (page) {
+		if (arch_prepare_gigantic_page(page)) {
+			free_gigantic_page(page, huge_page_order(h));
+			return NULL;
+		}
+		prep_compound_gigantic_page(page, huge_page_order(h));
+		prep_new_huge_page(h, page, nid);
+	}
+
+	return page;
+}
+static inline bool gigantic_page_supported(void) { return true; }
+#else /* !CONFIG_CMA */
+static inline bool gigantic_page_supported(void) { return false; }
+static inline struct page *alloc_fresh_gigantic_page_node(struct hstate *h,
+							int nid)
+{
+	return NULL;
+}
+static inline void free_gigantic_page(struct page *page, unsigned order) {}
+static inline void destroy_compound_gigantic_page(struct page *page,
+						unsigned long order) { }
+#endif /* CONFIG_CMA */
+
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	VM_BUG_ON(h->order >= MAX_ORDER);
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
+		return;
 
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
@@ -587,8 +722,14 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	VM_BUG_ON_PAGE(hugetlb_cgroup_from_page(page), page);
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
-	arch_release_hugepage(page);
-	__free_pages(page, huge_page_order(h));
+	if (huge_page_order(h) < MAX_ORDER) {
+		arch_release_hugepage(page);
+		__free_pages(page, huge_page_order(h));
+	} else {
+		arch_release_gigantic_page(page);
+		destroy_compound_gigantic_page(page, huge_page_order(h));
+		free_gigantic_page(page, huge_page_order(h));
+	}
 }
 
 struct hstate *size_to_hstate(unsigned long size)
@@ -731,9 +872,6 @@ static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
 {
 	struct page *page;
 
-	if (h->order >= MAX_ORDER)
-		return NULL;
-
 	page = alloc_pages_exact_node(nid,
 		htlb_alloc_mask(h)|__GFP_COMP|__GFP_THISNODE|
 						__GFP_REPEAT|__GFP_NOWARN,
@@ -822,6 +960,21 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
+static int alloc_fresh_gigantic_page(struct hstate *h,
+				nodemask_t *nodes_allowed)
+{
+	struct page *page = NULL;
+	int nr_nodes, node;
+
+	for_each_node_mask_to_alloc(h, nr_nodes, node, nodes_allowed) {
+		page = alloc_fresh_gigantic_page_node(h, node);
+		if (page)
+			return 1;
+	}
+
+	return 0;
+}
+
 static int alloc_fresh_huge_page(struct hstate *h, nodemask_t *nodes_allowed)
 {
 	struct page *page;
@@ -1451,7 +1604,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 {
 	unsigned long min_count, ret;
 
-	if (h->order >= MAX_ORDER)
+	if (hstate_is_gigantic(h) && !gigantic_page_supported())
 		return h->max_huge_pages;
 
 	/*
@@ -1478,7 +1631,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 		 * and reducing the surplus.
 		 */
 		spin_unlock(&hugetlb_lock);
-		ret = alloc_fresh_huge_page(h, nodes_allowed);
+		if (huge_page_order(h) < MAX_ORDER)
+			ret = alloc_fresh_huge_page(h, nodes_allowed);
+		else
+			ret = alloc_fresh_gigantic_page(h, nodes_allowed);
 		spin_lock(&hugetlb_lock);
 		if (!ret)
 			goto out;
@@ -1577,7 +1733,7 @@ static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
 		goto out;
 
 	h = kobj_to_hstate(kobj, &nid);
-	if (h->order >= MAX_ORDER) {
+	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -2071,7 +2227,7 @@ static int hugetlb_sysctl_handler_common(bool obey_mempolicy,
 
 	tmp = h->max_huge_pages;
 
-	if (write && h->order >= MAX_ORDER)
+	if (write && hstate_is_gigantic(h) && !gigantic_page_supported())
 		return -EINVAL;
 
 	table->data = &tmp;
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
