Date: Wed, 28 May 2008 16:01:06 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 12/23] hugetlb: support boot allocate different sizes
Message-ID: <20080528140106.GJ2630@wotan.suse.de>
References: <20080525142317.965503000@nick.local0.net> <20080525143453.424711000@nick.local0.net> <1211923735.12036.41.camel@localhost.localdomain> <20080528105759.GG2630@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080528105759.GG2630@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 12:57:59PM +0200, Nick Piggin wrote:
> On Tue, May 27, 2008 at 04:28:55PM -0500, Adam Litke wrote:
> > Seems nice, but what exactly is this patch for?  From reading the code
> > it would seem that this allows more than one >MAX_ORDER hstates to exist
> > and removes assumptions about their positioning withing the hstates
> > array?  A small patch leader would definitely clear up my confusion.
> 
> Yes it allows I guess hugetlb_init_one_hstate to be called multiple
> times on an hstate, and also some logic dealing with giant page setup.
> 
> Though hmm, possibly it can be made a little cleaner by separating
> hstate init from the actual page allocation a little more. I'll have
> a look but it is kind of tricky... otherwise I can try a changelog.

This is how I've made the patch:

---

hugetlb: support boot allocate different sizes

Make some infrastructure changes to allow boot allocation of different
hugepage page sizes.

- move all basic hstate initialisation into hugetlb_add_hstate
- create a new function hugetlb_hstate_alloc_pages() to do the
  actual initial page allocations. Call this function early in
  order to allocate giant pages from bootmem.
- Check for multiple hugepages= parameters

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Andrew Hastings <abh@cray.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/hugetlb.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c
+++ linux-2.6/mm/hugetlb.c
@@ -617,15 +617,10 @@ static void __init gather_bootmem_preall
 	}
 }
 
-static void __init hugetlb_init_one_hstate(struct hstate *h)
+static void __init hugetlb_hstate_alloc_pages(struct hstate *h)
 {
 	unsigned long i;
 
-	for (i = 0; i < MAX_NUMNODES; ++i)
-		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
-
-	h->hugetlb_next_nid = first_node(node_online_map);
-
 	for (i = 0; i < h->max_huge_pages; ++i) {
 		if (h->order >= MAX_ORDER) {
 			if (!alloc_bootmem_huge_page(h))
@@ -633,7 +628,7 @@ static void __init hugetlb_init_one_hsta
 		} else if (!alloc_fresh_huge_page(h))
 			break;
 	}
-	h->max_huge_pages = h->free_huge_pages = h->nr_huge_pages = i;
+	h->max_huge_pages = i;
 }
 
 static void __init hugetlb_init_hstates(void)
@@ -641,7 +636,10 @@ static void __init hugetlb_init_hstates(
 	struct hstate *h;
 
 	for_each_hstate(h) {
-		hugetlb_init_one_hstate(h);
+		/* oversize hugepages were init'ed in early boot */
+		if (h->order < MAX_ORDER)
+			hugetlb_hstate_alloc_pages(h);
+		max_huge_pages[h - hstates] = h->max_huge_pages;
 	}
 }
 
@@ -679,6 +677,8 @@ module_init(hugetlb_init);
 void __init hugetlb_add_hstate(unsigned order)
 {
 	struct hstate *h;
+	unsigned long i;
+
 	if (size_to_hstate(PAGE_SIZE << order)) {
 		printk(KERN_WARNING "hugepagesz= specified twice, ignoring\n");
 		return;
@@ -688,13 +688,19 @@ void __init hugetlb_add_hstate(unsigned 
 	h = &hstates[max_hstate++];
 	h->order = order;
 	h->mask = ~((1ULL << (order + PAGE_SHIFT)) - 1);
-	hugetlb_init_one_hstate(h);
+	h->nr_huge_pages = 0;
+	h->free_huge_pages = 0;
+	for (i = 0; i < MAX_NUMNODES; ++i)
+		INIT_LIST_HEAD(&h->hugepage_freelists[i]);
+	h->hugetlb_next_nid = first_node(node_online_map);
+
 	parsed_hstate = h;
 }
 
 static int __init hugetlb_setup(char *s)
 {
 	unsigned long *mhp;
+	static unsigned long *last_mhp;
 
 	/*
 	 * !max_hstate means we haven't parsed a hugepagesz= parameter yet,
@@ -705,9 +711,24 @@ static int __init hugetlb_setup(char *s)
 	else
 		mhp = &parsed_hstate->max_huge_pages;
 
+	if (mhp == last_mhp) {
+		printk(KERN_WARNING "hugepages= specified twice without interleaving hugepagesz=, ignoring\n");
+		return 1;
+	}
+
 	if (sscanf(s, "%lu", mhp) <= 0)
 		*mhp = 0;
 
+	/*
+	 * Global state is always initialized later in hugetlb_init.
+	 * But we need to allocate >= MAX_ORDER hstates here early to still
+	 * use the bootmem allocator.
+	 */
+	if (max_hstate && parsed_hstate->order >= MAX_ORDER)
+		hugetlb_hstate_alloc_pages(parsed_hstate);
+
+	last_mhp = mhp;
+
 	return 1;
 }
 __setup("hugepages=", hugetlb_setup);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
