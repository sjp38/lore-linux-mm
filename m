Date: Thu, 13 Dec 2007 23:17:39 +0100
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: QUEUE_FLAG_CLUSTER: not working in 2.6.24 ?
Message-ID: <20071213221738.GE19673@kernel.dk>
References: <20071213192633.GD10104@kernel.dk> <4761883A.7050908@rtr.ca> <476188C4.9030802@rtr.ca> <20071213193937.GG10104@kernel.dk> <47618B0B.8020203@rtr.ca> <20071213195350.GH10104@kernel.dk> <20071213200219.GI10104@kernel.dk> <476190BE.9010405@rtr.ca> <20071213200958.GK10104@kernel.dk> <20071213140207.111f94e2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071213140207.111f94e2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: liml@rtr.ca, lkml@rtr.ca, matthew@wil.cx, linux-ide@vger.kernel.org, linux-kernel@vger.kernel.org, linux-scsi@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 13 2007, Andrew Morton wrote:
> On Thu, 13 Dec 2007 21:09:59 +0100
> Jens Axboe <jens.axboe@oracle.com> wrote:
> 
> >
> > OK, it's a vm issue,
> 
> cc linux-mm and probable culprit.
> 
> >  I have tens of thousand "backward" pages after a
> > boot - IOW, bvec->bv_page is the page before bvprv->bv_page, not
> > reverse. So it looks like that bug got reintroduced.
> 
> Bill Irwin fixed this a couple of years back: changed the page allocator so
> that it mostly hands out pages in ascending physical-address order.
> 
> I guess we broke that, quite possibly in Mel's page allocator rework.
> 
> It would help if you could provide us with a simple recipe for
> demonstrating this problem, please.

Basically anything involving IO :-). A boot here showed a handful of
good merges, and probably in the order of 100,000 descending
allocations. A kernel make is a fine test as well.

Something like the below should work fine - if you see oodles of these
basicaly doing any type of IO, then you are screwed.

diff --git a/block/ll_rw_blk.c b/block/ll_rw_blk.c
index e30b1a4..8ce3fcc 100644
--- a/block/ll_rw_blk.c
+++ b/block/ll_rw_blk.c
@@ -1349,6 +1349,10 @@ new_segment:
 				sg = sg_next(sg);
 			}
 
+			if (bvprv) {
+				if (page_address(bvec->bv_page) + PAGE_SIZE == page_address(bvprv->bv_page) && printk_ratelimit())
+					printk("page alloc order backwards\n");
+			}
 			sg_set_page(sg, bvec->bv_page, nbytes, bvec->bv_offset);
 			nsegs++;
 		}

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
