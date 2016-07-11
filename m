Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFF196B0253
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 15:50:49 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id q2so76232697pap.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 12:50:49 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id qc5si5403822pac.119.2016.07.11.12.50.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 12:50:48 -0700 (PDT)
Received: by mail-pa0-x234.google.com with SMTP id fi15so24473328pac.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 12:50:48 -0700 (PDT)
Date: Mon, 11 Jul 2016 12:50:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-4.7] mm, compaction: prevent VM_BUG_ON when terminating
 freeing scanner fix
Message-ID: <alpine.DEB.2.10.1607111244150.83138@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@techsingularity.net, minchan@kernel.org, stable@vger.kernel.org, vbabka@suse.cz

On Wed, 6 Jul 2016, Joonsoo Kim wrote:

> > diff --git a/mm/compaction.c b/mm/compaction.c
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1009,8 +1009,6 @@ static void isolate_freepages(struct compact_control *cc)
> >  				block_end_pfn = block_start_pfn,
> >  				block_start_pfn -= pageblock_nr_pages,
> >  				isolate_start_pfn = block_start_pfn) {
> > -		unsigned long isolated;
> > -
> >  		/*
> >  		 * This can iterate a massively long zone without finding any
> >  		 * suitable migration targets, so periodically check if we need
> > @@ -1034,36 +1032,31 @@ static void isolate_freepages(struct compact_control *cc)
> >  			continue;
> >  
> >  		/* Found a block suitable for isolating free pages from. */
> > -		isolated = isolate_freepages_block(cc, &isolate_start_pfn,
> > -						block_end_pfn, freelist, false);
> > -		/* If isolation failed early, do not continue needlessly */
> > -		if (!isolated && isolate_start_pfn < block_end_pfn &&
> > -		    cc->nr_migratepages > cc->nr_freepages)
> > -			break;
> > +		isolate_freepages_block(cc, &isolate_start_pfn, block_end_pfn,
> > +					freelist, false);
> >  
> >  		/*
> > -		 * If we isolated enough freepages, or aborted due to async
> > -		 * compaction being contended, terminate the loop.
> > -		 * Remember where the free scanner should restart next time,
> > -		 * which is where isolate_freepages_block() left off.
> > -		 * But if it scanned the whole pageblock, isolate_start_pfn
> > -		 * now points at block_end_pfn, which is the start of the next
> > -		 * pageblock.
> > -		 * In that case we will however want to restart at the start
> > -		 * of the previous pageblock.
> > +		 * If we isolated enough freepages, or aborted due to lock
> > +		 * contention, terminate.
> >  		 */
> >  		if ((cc->nr_freepages >= cc->nr_migratepages)
> >  							|| cc->contended) {
> > -			if (isolate_start_pfn >= block_end_pfn)
> > +			if (isolate_start_pfn >= block_end_pfn) {
> > +				/*
> > +				 * Restart at previous pageblock if more
> > +				 * freepages can be isolated next time.
> > +				 */
> >  				isolate_start_pfn =
> >  					block_start_pfn - pageblock_nr_pages;
> > +			}
> >  			break;
> > -		} else {
> > +		} else if (isolate_start_pfn < block_end_pfn) {
> >  			/*
> > -			 * isolate_freepages_block() should not terminate
> > -			 * prematurely unless contended, or isolated enough
> > +			 * If isolation failed early, do not continue
> > +			 * needlessly.
> >  			 */
> > -			VM_BUG_ON(isolate_start_pfn < block_end_pfn);
> > +			isolate_start_pfn = block_start_pfn;
> > +			break;
> 
> I don't think this line is correct. It would make cc->free_pfn go
> backward though it would not be a big problem. Just leaving
> isolate_start_pfn as isolate_freepages_block returns would be a proper
> solution here.
> 

I guess, but I don't see what value there is in starting free page 
isolation within a pageblock.

----->o-----

mm, compaction: prevent VM_BUG_ON when terminating freeing scanner fix

Per Joonsoo.

An artifact of __isolate_free_page() doing per-zone watermark checks (?), 
we don't want to rescan pages in a pageblock that were not successfully 
isolated last time.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/compaction.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index e4f89da..45eaa2a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1114,7 +1114,6 @@ static void isolate_freepages(struct compact_control *cc)
 			 * If isolation failed early, do not continue
 			 * needlessly.
 			 */
-			isolate_start_pfn = block_start_pfn;
 			break;
 		}
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
