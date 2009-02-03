Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id A16D65F0001
	for <linux-mm@kvack.org>; Tue,  3 Feb 2009 02:29:17 -0500 (EST)
Subject: Re: [patch] SLQB slab allocator
From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
In-Reply-To: <1233565214.17835.13.camel@penberg-laptop>
References: <20090121143008.GV24891@wotan.suse.de>
	 <Pine.LNX.4.64.0901211705570.7020@blonde.anvils>
	 <84144f020901220201g6bdc2d5maf3395fc8b21fe67@mail.gmail.com>
	 <Pine.LNX.4.64.0901221239260.21677@blonde.anvils>
	 <Pine.LNX.4.64.0901231357250.9011@blonde.anvils>
	 <1233545923.2604.60.camel@ymzhang>
	 <1233565214.17835.13.camel@penberg-laptop>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 03 Feb 2009 15:29:05 +0800
Message-Id: <1233646145.2604.137.camel@ymzhang>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Lin Ming <ming.m.lin@intel.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-02 at 11:00 +0200, Pekka Enberg wrote:
> Hi Yanmin,
> 
> On Mon, 2009-02-02 at 11:38 +0800, Zhang, Yanmin wrote:
> > Can we add a checking about free memory page number/percentage in function
> > allocate_slab that we can bypass the first try of alloc_pages when memory
> > is hungry?
> 
> If the check isn't too expensive, I don't any reason not to. How would
> you go about checking how much free pages there are, though? Is there
> something in the page allocator that we can use for this?

i>>?We can use nr_free_pages(), totalram_pages and hugetlb_total_pages(). Below
patch is a try. I tested it with hackbench and tbench on my stoakley
(2 qual-core processors) and tigerton (4 qual-core processors). There is almost no
regression.

Besides this patch, I have another patch to try to reduce the calculation
of "i>>?totalram_pages - hugetlb_total_pages()", but it touches many files. So just
post the first simple patch here for review.


Hugh,

Would you like to test it on your machines?

Thanks,
Yanmin


---

--- linux-2.6.29-rc2/mm/slub.c	2009-01-20 14:20:45.000000000 +0800
+++ linux-2.6.29-rc2_slubfreecheck/mm/slub.c	2009-02-03 14:40:52.000000000 +0800
@@ -23,6 +23,8 @@
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/memory.h>
+#include <linux/swap.h>
+#include <linux/hugetlb.h>
 #include <linux/math64.h>
 #include <linux/fault-inject.h>
 
@@ -1076,14 +1078,18 @@ static inline struct page *alloc_slab_pa
 
 static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 {
-	struct page *page;
+	struct page *page = NULL;
 	struct kmem_cache_order_objects oo = s->oo;
+	unsigned long free_pages = nr_free_pages();
+	unsigned long total_pages = totalram_pages - hugetlb_total_pages();
 
 	flags |= s->allocflags;
 
-	page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY, node,
-									oo);
-	if (unlikely(!page)) {
+	if (free_pages > total_pages >> 3) {
+		page = alloc_slab_page(flags | __GFP_NOWARN | __GFP_NORETRY,
+				node, oo);
+	}
+	if (!page) {
 		oo = s->min;
 		/*
 		 * Allocation may have failed due to fragmentation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
