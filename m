Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 0638E6B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 06:28:36 -0500 (EST)
Date: Fri, 13 Jan 2012 11:28:32 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH v2] mm/compaction : check the watermark when cc->order is
 -1
Message-ID: <20120113112832.GR4118@suse.de>
References: <1325818201-1865-1-git-send-email-b32955@freescale.com>
 <4F0E76BE.1070806@freescale.com>
 <20120112120530.GJ4118@suse.de>
 <4F0F9770.10004@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F0F9770.10004@freescale.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <b32955@freescale.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, shijie8@gmail.com

On Fri, Jan 13, 2012 at 10:31:12AM +0800, Huang Shijie wrote:
> >>>  	/*
> >>>+	 * Watermarks for order-0 must be met for compaction.
> >>>+	 * During the migration, copies of pages need to be
> >>>+	 * allocated and for a short time, so the footprint is higher.
> >>>  	 * order == -1 is expected when compacting via
> >>>-	 * /proc/sys/vm/compact_memory
> >>>+	 * /proc/sys/vm/compact_memory.
> >>>  	 */
> >>>-	if (order == -1)
> >>>-		return COMPACT_CONTINUE;
> >>>+	watermark = low_wmark_pages(zone) +
> >>>+		((order == -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL<<  order));
> >>>
> >>>-	/*
> >>>-	 * Watermarks for order-0 must be met for compaction. Note the 2UL.
> >>>-	 * This is because during migration, copies of pages need to be
> >>>-	 * allocated and for a short time, the footprint is higher
> >>>-	 */
> >>>-	watermark = low_wmark_pages(zone) + (2UL<<  order);
> >>>  	if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> >>>  		return COMPACT_SKIPPED;
> >>>
> >>>+	if (order == -1)
> >>>+		return COMPACT_CONTINUE;
> >>>+
> >>>  	/*
> >>>  	 * fragmentation index determines if allocation failures are due to
> >>>  	 * low memory or external fragmentation
> >>Is this patch meaningless?
> >>I really think this patch is useful when the zone is nearly full.
> >>
> >Code wise the patch is fine. One reason why it fell off my radar is
> >because you mangled the comments for no apparent reason. Specifically,
> >after your patch is applied the code looks like this
> >
> >         /*
> >          * Watermarks for order-0 must be met for compaction.
> >          * During the migration, copies of pages need to be
> >          * allocated and for a short time, so the footprint is higher.
> >          * order == -1 is expected when compacting via
> >          * /proc/sys/vm/compact_memory.
> >          */
> >         watermark = low_wmark_pages(zone) +
> >                 ((order == -1) ? (COMPACT_CLUSTER_MAX * 2) : (2UL<<  order));
> "order == -1" first appears here.
> >         if (!zone_watermark_ok(zone, 0, watermark, 0, 0))
> >                 return COMPACT_SKIPPED;
> >
> >         if (order == -1)
> >                 return COMPACT_CONTINUE;
> >
> >The comment about "order == -1" is no longer with the code it refers
> If I keep the comment here, someone may wonder why the `order == -1`
> firstly appears above.
> 
> I just want to keep the comment where it firstly appears. Don't you
> think it's right?
> 

Bah, I'm an idiot.

When I glanced at this first, I missed that you altered the watermark
check as well. When I said "Code wise the patch is fine", I was wrong.
Compaction works in units of pageblocks and the watermark check
is necessary. Reducing it to COMPACT_CLUSTER_MAX*2 leads to the
possibility of compaction via /proc causing livelocks in low memory
situations depending on the value of min_free_kbytes.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
