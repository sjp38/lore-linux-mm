Date: Wed, 28 Nov 2007 19:50:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 13/19] Use page_cache_xxx in fs/splice.c
In-Reply-To: <20071129034011.GU119954183@sgi.com>
Message-ID: <Pine.LNX.4.64.0711281949550.20688@schroedinger.engr.sgi.com>
References: <20071129011052.866354847@sgi.com> <20071129011147.323915994@sgi.com>
 <20071129034011.GU119954183@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Christoph Hellwig <hch@lst.de>, Mel Gorman <mel@skynet.ie>, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, Badari Pulavarty <pbadari@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, Fengguang Wu <fengguang.wu@gmail.com>, swin wang <wangswin@gmail.com>, totty.lu@gmail.com, hugh@veritas.com, joern@lazybastard.org
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007, David Chinner wrote:

> On Wed, Nov 28, 2007 at 05:11:05PM -0800, Christoph Lameter wrote:
> > @@ -453,7 +454,7 @@ fill_it:
> >  	 */
> >  	while (page_nr < nr_pages)
> >  		page_cache_release(pages[page_nr++]);
> > -	in->f_ra.prev_pos = (loff_t)index << PAGE_CACHE_SHIFT;
> > +	in->f_ra.prev_pos = page_cache_index(mapping, index);
> 
> 	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);
> 

splice.c: Wrong inline function used

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/splice.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: mm/fs/splice.c
===================================================================
--- mm.orig/fs/splice.c	2007-11-28 19:48:43.246633219 -0800
+++ mm/fs/splice.c	2007-11-28 19:49:06.405882592 -0800
@@ -454,7 +454,7 @@ fill_it:
 	 */
 	while (page_nr < nr_pages)
 		page_cache_release(pages[page_nr++]);
-	in->f_ra.prev_pos = page_cache_index(mapping, index);
+	in->f_ra.prev_pos = page_cache_pos(mapping, index, 0);
 
 	if (spd.nr_pages)
 		return splice_to_pipe(pipe, &spd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
