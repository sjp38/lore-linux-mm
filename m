Date: Wed, 28 Nov 2007 19:30:54 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 05/19] Use page_cache_xxx in mm/rmap.c
In-Reply-To: <20071129031921.GS119954183@sgi.com>
Message-ID: <Pine.LNX.4.64.0711281928220.20367@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011145.414062339@sgi.com>
 <20071129031921.GS119954183@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, David Chinner wrote:

> >  	unsigned int mapcount;
> >  	struct address_space *mapping = page->mapping;
> > -	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
> > +	pgoff_t pgoff = page->index << (page_cache_shift(mapping) - PAGE_SHIFT);
> 
> Based on the first hunk, shouldn't this be:
> 
> 	pgoff_t pgoff = page->index << mapping_order(mapping);

Yes that is much simpler


rmap: simplify page_referenced_file use of page cache inlines

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 mm/rmap.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mm/mm/rmap.c
===================================================================
--- mm.orig/mm/rmap.c	2007-11-28 19:28:45.689883608 -0800
+++ mm/mm/rmap.c	2007-11-28 19:29:35.090382690 -0800
@@ -350,7 +350,7 @@ static int page_referenced_file(struct p
 {
 	unsigned int mapcount;
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (page_cache_shift(mapping) - PAGE_SHIFT);
+	pgoff_t pgoff = page->index << mapping_order(mapping);
 	struct vm_area_struct *vma;
 	struct prio_tree_iter iter;
 	int referenced = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
