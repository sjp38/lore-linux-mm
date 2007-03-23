Date: Thu, 22 Mar 2007 23:48:48 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/5] Quicklists for page table pages V4
Message-Id: <20070322234848.100abb3d.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
References: <20070323062843.19502.19827.sendpatchset@schroedinger.engr.sgi.com>
	<20070322223927.bb4caf43.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0703222339560.19630@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Mar 2007 23:52:05 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> On Thu, 22 Mar 2007, Andrew Morton wrote:
> 
> > On Thu, 22 Mar 2007 23:28:41 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:
> > 
> > > 1. Proven code from the IA64 arch.
> > > 
> > > 	The method used here has been fine tuned for years and
> > > 	is NUMA aware. It is based on the knowledge that accesses
> > > 	to page table pages are sparse in nature. Taking a page
> > > 	off the freelists instead of allocating a zeroed pages
> > > 	allows a reduction of number of cachelines touched
> > > 	in addition to getting rid of the slab overhead. So
> > > 	performance improves.
> > 
> > By how much?
> 
> About 40% on fork+exit. See 
> 
> http://marc.info/?l=linux-ia64&m=110942798406005&w=2
> 

afacit that two-year-old, totally-different patch has nothing to do with my
repeatedly-asked question.  It appears to be consolidating three separate
quicklist allocators into one common implementation.

In an attempt to answer my own question (and hence to justify the retention
of this custom allocator) I did this:


diff -puN include/linux/quicklist.h~qlhack include/linux/quicklist.h
--- a/include/linux/quicklist.h~qlhack
+++ a/include/linux/quicklist.h
@@ -32,45 +32,17 @@ DECLARE_PER_CPU(struct quicklist, quickl
  */
 static inline void *quicklist_alloc(int nr, gfp_t flags, void (*ctor)(void *))
 {
-	struct quicklist *q;
-	void **p = NULL;
-
-	q =&get_cpu_var(quicklist)[nr];
-	p = q->page;
-	if (likely(p)) {
-		q->page = p[0];
-		p[0] = NULL;
-		q->nr_pages--;
-	}
-	put_cpu_var(quicklist);
-	if (likely(p))
-		return p;
-
-	p = (void *)__get_free_page(flags | __GFP_ZERO);
+	void *p = (void *)__get_free_page(flags | __GFP_ZERO);
 	if (ctor && p)
 		ctor(p);
 	return p;
 }
 
-static inline void quicklist_free(int nr, void (*dtor)(void *), void *pp)
+static inline void quicklist_free(int nr, void (*dtor)(void *), void *p)
 {
-	struct quicklist *q;
-	void **p = pp;
-	struct page *page = virt_to_page(p);
-	int nid = page_to_nid(page);
-
-	if (unlikely(nid != numa_node_id())) {
-		if (dtor)
-			dtor(p);
-		free_page((unsigned long)p);
-		return;
-	}
-
-	q = &get_cpu_var(quicklist)[nr];
-	p[0] = q->page;
-	q->page = p;
-	q->nr_pages++;
-	put_cpu_var(quicklist);
+	if (dtor)
+		dtor(p);
+	free_page((unsigned long)p);
 }
 
 void quicklist_trim(int nr, void (*dtor)(void *),
@@ -81,4 +53,3 @@ unsigned long quicklist_total_size(void)
 #endif
 
 #endif /* LINUX_QUICKLIST_H */
-
_

but it crashes early in the page allocator (i386) and I don't see why.  It
makes me wonder if we have a use-after-free which is hidden by the presence
of the quicklist buffering or something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
