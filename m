Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD3B6B0069
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 03:27:59 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id rd3so10619115pab.14
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 00:27:59 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id vu1si27805256pbc.23.2014.12.01.00.27.56
        for <linux-mm@kvack.org>;
        Mon, 01 Dec 2014 00:27:58 -0800 (PST)
Date: Mon, 1 Dec 2014 17:31:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: isolate_freepages_block and excessive CPU usage by OSD process
Message-ID: <20141201083118.GB2499@js1304-P5Q-DELUXE>
References: <20141119012110.GA2608@cucumber.iinet.net.au>
 <CABYiri99WAj+6hfTq+6x+_w0=VNgBua8N9+mOvU6o5bynukPLQ@mail.gmail.com>
 <20141119212013.GA18318@cucumber.anchor.net.au>
 <546D2366.1050506@suse.cz>
 <20141121023554.GA24175@cucumber.bridge.anchor.net.au>
 <20141123093348.GA16954@cucumber.anchor.net.au>
 <CABYiri8LYukujETMCb4gHUQd=J-MQ8m=rGRiEkTD1B42Jh=Ksg@mail.gmail.com>
 <20141128080331.GD11802@js1304-P5Q-DELUXE>
 <54783FB7.4030502@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54783FB7.4030502@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrey Korolyov <andrey@xdel.ru>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Nov 28, 2014 at 10:26:15AM +0100, Vlastimil Babka wrote:
> On 28.11.2014 9:03, Joonsoo Kim wrote:
> >On Tue, Nov 25, 2014 at 01:48:42AM +0400, Andrey Korolyov wrote:
> >>On Sun, Nov 23, 2014 at 12:33 PM, Christian Marie <christian@ponies.io> wrote:
> >>>Here's an update:
> >>>
> >>>Tried running 3.18.0-rc5 over the weekend to no avail. A load spike through
> >>>Ceph brings no perceived improvement over the chassis running 3.10 kernels.
> >>>
> >>>Here is a graph of *system* cpu time (not user), note that 3.18 was a005.block:
> >>>
> >>>http://ponies.io/raw/cluster.png
> >>>
> >>>It is perhaps faring a little better that those chassis running the 3.10 in
> >>>that it did not have min_free_kbytes raised to 2GB as the others did, instead
> >>>it was sitting around 90MB.
> >>>
> >>>The perf recording did look a little different. Not sure if this was just the
> >>>luck of the draw in how the fractal rendering works:
> >>>
> >>>http://ponies.io/raw/perf-3.10.png
> >>>
> >>>Any pointers on how we can track this down? There's at least three of us
> >>>following at this now so we should have plenty of area to test.
> >>
> >>Checked against 3.16 (3.17 hanged for an unrelated problem), the issue
> >>is presented for single- and two-headed systems as well. Ceph-users
> >>reported presence of the problem for 3.17, so probably we are facing
> >>generic compaction issue.
> >>
> >Hello,
> >
> >I didn't follow-up this discussion, but, at glance, this excessive CPU
> >usage by compaction is related to following fixes.
> >
> >Could you test following two patches?
> >
> >If these fixes your problem, I will resumit patches with proper commit
> >description.
> >
> >Thanks.
> >
> >-------->8-------------
> > From 079f3f119f1e3cbe9d981e7d0cada94e0c532162 Mon Sep 17 00:00:00 2001
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >Date: Fri, 28 Nov 2014 16:36:00 +0900
> >Subject: [PATCH 1/2] mm/compaction: fix wrong order check in
> >  compact_finished()
> >
> >What we want to check here is whether there is highorder freepage
> >in buddy list of other migratetype in order to steal it without
> >fragmentation. But, current code just checks cc->order which means
> >allocation request order. So, this is wrong.
> >
> >Without this fix, non-movable synchronous compaction below pageblock order
> >would not stopped until compaction complete, because migratetype of most
> >pageblocks are movable and cc->order is always below than pageblock order
> >in this case.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/compaction.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/mm/compaction.c b/mm/compaction.c
> >index b544d61..052194f 100644
> >--- a/mm/compaction.c
> >+++ b/mm/compaction.c
> >@@ -1082,7 +1082,7 @@ static int compact_finished(struct zone *zone, struct compact_control *cc,
> >  			return COMPACT_PARTIAL;
> >  		/* Job done if allocation would set block type */
> >-		if (cc->order >= pageblock_order && area->nr_free)
> >+		if (order >= pageblock_order && area->nr_free)
> >  			return COMPACT_PARTIAL;
> 
> Dang, good catch!
> But I wonder, are MIGRATE_RESERVE pages counted towards area->nr_free?
> Seems to me that they are, so this check can have false positives?
> Hm probably for unmovable allocation, MIGRATE_CMA pages is the same case?
> 

Hello,

Althoth MIGRATE_RESERVE are counted for area->nr_free, at this
moment, there is no freepage on MIGRATE_RESERVE. It would be used
already before triggering compaction.

In case of MIGRATE_CMA, false positives are possible. But, it also
broken on __zone_watermark_ok(). Without area->nr_free_cma, we can't
fix inaccurate check. Please see following link.

https://lkml.org/lkml/2014/6/2/1

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
