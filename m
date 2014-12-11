Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id DB7B96B0032
	for <linux-mm@kvack.org>; Wed, 10 Dec 2014 22:04:07 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so4153794pad.3
        for <linux-mm@kvack.org>; Wed, 10 Dec 2014 19:04:07 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id gp2si9482160pac.82.2014.12.10.19.04.04
        for <linux-mm@kvack.org>;
        Wed, 10 Dec 2014 19:04:06 -0800 (PST)
Date: Thu, 11 Dec 2014 12:08:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141211030801.GA16381@js1304-P5Q-DELUXE>
References: <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
 <20141201083118.GB2499@js1304-P5Q-DELUXE>
 <20141202014724.GA22239@cucumber.bridge.anchor.net.au>
 <20141202045324.GC6268@js1304-P5Q-DELUXE>
 <20141202050608.GA11051@cucumber.bridge.anchor.net.au>
 <20141203075747.GB6276@js1304-P5Q-DELUXE>
 <20141204073045.GA2960@cucumber.anchor.net.au>
 <20141205010733.GA13751@js1304-P5Q-DELUXE>
 <5488616B.3070104@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5488616B.3070104@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org

On Wed, Dec 10, 2014 at 04:06:19PM +0100, Vlastimil Babka wrote:
> On 12/05/2014 02:07 AM, Joonsoo Kim wrote:
> >------------>8-----------------
> > From b7daa232c327a4ebbb48ca0538a2dbf9ca83ca1f Mon Sep 17 00:00:00 2001
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Date: Fri, 5 Dec 2014 09:38:30 +0900
> >Subject: [PATCH] mm/compaction: stop the compaction if there isn't enough
> >  freepage
> >
> >After compaction_suitable() passed, there is no check whether the system
> >has enough memory to compact and blindly try to find freepage through
> >iterating all memory range. This causes excessive cpu usage in low free
> >memory condition and finally compaction would be failed. It makes sense
> >that compaction would be stopped if there isn't enough freepage. So,
> >this patch adds watermark check to isolate_freepages() in order to stop
> >the compaction in this case.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c |    9 +++++++++
> >  1 file changed, 9 insertions(+)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index e005620..31c4009 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -828,6 +828,7 @@ static void isolate_freepages(struct compact_control *cc)
> >  	unsigned long low_pfn;	     /* lowest pfn scanner is able to scan */
> >  	int nr_freepages = cc->nr_freepages;
> >  	struct list_head *freelist = &cc->freepages;
> >+	unsigned long watermark = low_wmark_pages(zone) + (2UL << cc->order);
> 
> Given that we maybe have already isolated up to 31 free pages (if
> cc->nr_migratepages is the maximum 32), then this is somewhat
> stricter than the check in isolation_suitable() (when nothing was
> isolated yet) and may interrupt us prematurely. We should allow for
> some slack.

Okay. Will allow some slack.

> 
> >
> >  	/*
> >  	 * Initialise the free scanner. The starting point is where we last
> >@@ -903,6 +904,14 @@ static void isolate_freepages(struct compact_control *cc)
> >  		 */
> >  		if (cc->contended)
> >  			break;
> >+
> >+		/*
> >+		 * Watermarks for order-0 must be met for compaction.
> >+		 * See compaction_suitable for more detailed explanation.
> >+		 */
> >+		if (!zone_watermark_ok(zone, 0, watermark,
> >+			cc->classzone_idx, cc->alloc_flags))
> >+			break;
> >  	}
> 
> I'm a also bit concerned about the overhead of doing this in each pageblock.

Yep, we can do it whenever SWAP_CLUSTER_MAX pageblock is scanned. It
will reduce overhead somewhat. I will change it.

> 
> I wonder if there could be a mechanism where a process entering
> reclaim or compaction with the goal of meeting the watermarks to
> allocate, should increase the watermarks needed for further parallel
> allocation attempts to pass. Then it shouldn't happen that somebody
> else steals the memory.

I don't know, neither.

Thanks.

> 
> >  	/* split_free_page does not map the pages */
> >
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
