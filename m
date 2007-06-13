Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5DFgaMR016896
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 11:42:36 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5DFaF1u230700
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 09:42:36 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5DFQptI005615
	for <linux-mm@kvack.org>; Wed, 13 Jun 2007 09:26:51 -0600
Date: Wed, 13 Jun 2007 08:26:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH v3][RFC] hugetlb: numafy several functions
Message-ID: <20070613152649.GN3798@us.ibm.com>
References: <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com> <20070612191347.GE11781@holomorphy.com> <20070613000446.GL3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070613000446.GL3798@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [17:04:46 -0700], Nishanth Aravamudan wrote:
> On 12.06.2007 [12:13:47 -0700], William Lee Irwin III wrote:
> > On 11.06.2007 [22:15:12 -0700], William Lee Irwin III wrote:
> > >> For initially filling the pool one can just loop over nid's modulo the
> > >> number of populated nodes and pass down a stack-allocated variable.
> > 
> > On Tue, Jun 12, 2007 at 10:45:03AM -0700, Nishanth Aravamudan wrote:
> > > But how does one differentiate between "initally filling" the pool and a
> > > later attempt to add to the pool (or even just marginally later).
> > > I guess I don't see why folks are so against this static variable :) It
> > > does the job and removing it seems like it could be an independent
> > > cleanup?
> > 
> > Well, another approach is to just statically initialize it to something
> > and then always check to make sure the node for the nid has memory, and
> > if not, find the next nid with a node with memory from the populated map.
> 
> How does something like this look? Or is it overkill?

If that patch looks ok, then the other patches (numafy and sysfs) are
relatively unchanged.

commit 041cb3d3c2fd3640aff50e2f701b8b5a670193de
Author: Nishanth Aravamudan <nacc@us.ibm.com>
Date:   Tue Jun 12 17:10:21 2007 -0700

hugetlb: numafy several functions

Add node-parameterized helpers for dequeue_huge_page,
alloc_fresh_huge_page and try_to_free_low. Also have
update_and_free_page() take a nid parameter. This is necessary to add a
per-node sysfs attribute to specify the number of hugepages on that
node.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Anton Blanchard <anton@sambar.org>
Cc: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1c13687..c4a966e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -66,11 +66,22 @@ static void enqueue_huge_page(struct page *page)
 	free_huge_pages_node[nid]++;
 }
 
+static struct page *dequeue_huge_page_node(int nid)
+{
+	struct page *page;
+
+	page = list_entry(hugepage_freelists[nid].next,
+					  struct page, lru);
+	list_del(&page->lru);
+	free_huge_pages--;
+	free_huge_pages_node[nid]--;
+	return page;
+}
+
 static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 				unsigned long address)
 {
 	int nid;
-	struct page *page = NULL;
 	struct zonelist *zonelist = huge_zonelist(vma, address,
 						htlb_alloc_mask);
 	struct zone **z;
@@ -82,14 +93,9 @@ static struct page *dequeue_huge_page(struct vm_area_struct *vma,
 			break;
 	}
 
-	if (*z) {
-		page = list_entry(hugepage_freelists[nid].next,
-				  struct page, lru);
-		list_del(&page->lru);
-		free_huge_pages--;
-		free_huge_pages_node[nid]--;
-	}
-	return page;
+	if (*z)
+		return dequeue_huge_page_node(nid);
+	return NULL;
 }
 
 static void free_huge_page(struct page *page)
@@ -103,6 +109,25 @@ static void free_huge_page(struct page *page)
 	spin_unlock(&hugetlb_lock);
 }
 
+static struct page *alloc_fresh_huge_page_node(int nid)
+{
+	struct page *page;
+
+	page = alloc_pages_node(nid,
+			GFP_HIGHUSER|__GFP_COMP|GFP_THISNODE,
+			HUGETLB_PAGE_ORDER);
+	if (page) {
+		set_compound_page_dtor(page, free_huge_page);
+		spin_lock(&hugetlb_lock);
+		nr_huge_pages++;
+		nr_huge_pages_node[nid]++;
+		spin_unlock(&hugetlb_lock);
+		put_page(page); /* free it into the hugepage allocator */
+	}
+
+	return page;
+}
+
 static int alloc_fresh_huge_page(struct mempolicy *policy)
 {
 	int nid;
@@ -112,20 +137,12 @@ static int alloc_fresh_huge_page(struct mempolicy *policy)
 	nid = start_nid;
 
 	do {
-		page = alloc_pages_node(nid,
-				htlb_alloc_mask|__GFP_COMP|GFP_THISNODE,
-				HUGETLB_PAGE_ORDER);
+		page = alloc_fresh_huge_page_node(nid);
 		nid = interleave_nodes(policy);
 	} while (!page && nid != start_nid);
-	if (page) {
-		set_compound_page_dtor(page, free_huge_page);
-		spin_lock(&hugetlb_lock);
-		nr_huge_pages++;
-		nr_huge_pages_node[page_to_nid(page)]++;
-		spin_unlock(&hugetlb_lock);
-		put_page(page); /* free it into the hugepage allocator */
+
+	if (page)
 		return 1;
-	}
 	return 0;
 }
 
@@ -201,11 +218,11 @@ static unsigned int cpuset_mems_nr(unsigned int *array)
 }
 
 #ifdef CONFIG_SYSCTL
-static void update_and_free_page(struct page *page)
+static void update_and_free_page(int nid, struct page *page)
 {
 	int i;
 	nr_huge_pages--;
-	nr_huge_pages_node[page_to_nid(page)]--;
+	nr_huge_pages_node[nid]--;
 	for (i = 0; i < (HPAGE_SIZE / PAGE_SIZE); i++) {
 		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
 				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
@@ -217,25 +234,37 @@ static void update_and_free_page(struct page *page)
 }
 
 #ifdef CONFIG_HIGHMEM
+static void try_to_free_low_node(int nid, unsigned long count)
+{
+	struct page *page, *next;
+
+	list_for_each_entry_safe(page, next,
+				&hugepage_freelists[nid], lru) {
+		if (PageHighMem(page))
+			continue;
+		list_del(&page->lru);
+		update_and_free_page(nid, page);
+		free_huge_pages--;
+		free_huge_pages_node[nid]--;
+		if (count >= nr_huge_pages_node[nid])
+			return;
+	}
+}
+
 static void try_to_free_low(unsigned long count)
 {
 	int i;
 
 	for (i = 0; i < MAX_NUMNODES; ++i) {
-		struct page *page, *next;
-		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
-			if (PageHighMem(page))
-				continue;
-			list_del(&page->lru);
-			update_and_free_page(page);
-			free_huge_pages--;
-			free_huge_pages_node[page_to_nid(page)]--;
-			if (count >= nr_huge_pages)
-				return;
-		}
+		try_to_free_low_node(i, count);
+		if (count >= nr_huge_pages)
+			break;
 	}
 }
 #else
+static inline void try_to_free_low_node(int nid, unsigned long count)
+{
+}
 static inline void try_to_free_low(unsigned long count)
 {
 }
@@ -263,7 +292,7 @@ static unsigned long set_max_huge_pages(unsigned long count)
 		struct page *page = dequeue_huge_page(NULL, 0);
 		if (!page)
 			break;
-		update_and_free_page(page);
+		update_and_free_page(page_to_nid(page), page);
 	}
 	spin_unlock(&hugetlb_lock);
 	return nr_huge_pages;

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
