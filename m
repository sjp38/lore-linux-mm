Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 772B16B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 10:10:12 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb10so793656pad.9
        for <linux-mm@kvack.org>; Thu, 15 Aug 2013 07:10:11 -0700 (PDT)
Date: Thu, 15 Aug 2013 23:10:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: kswapd skips compaction if reclaim order drops to zero?
Message-ID: <20130815141004.GD8437@gmail.com>
References: <CAJd=RBBF2h_tRpbTV6OkxQOfkvKt=ebn_PbE8+r7JxAuaFZxFQ@mail.gmail.com>
 <20130815104727.GT2296@suse.de>
 <20130815134139.GC8437@gmail.com>
 <20130815135627.GX2296@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130815135627.GX2296@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Hillf Danton <dhillf@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Thu, Aug 15, 2013 at 02:56:27PM +0100, Mel Gorman wrote:
> On Thu, Aug 15, 2013 at 10:41:39PM +0900, Minchan Kim wrote:
> > Hey Mel,
> > 
> > On Thu, Aug 15, 2013 at 11:47:27AM +0100, Mel Gorman wrote:
> > > On Thu, Aug 15, 2013 at 06:02:53PM +0800, Hillf Danton wrote:
> > > > If the allocation order is not high, direct compaction does nothing.
> > > > Can we skip compaction here if order drops to zero?
> > > > 
> > > 
> > > If the allocation order is not high then
> > > 
> > > pgdat_needs_compaction == (order > 0) == false == no calling compact_pdatt
> > > 
> > > In the case where order is reset to 0 due to fragmentation then it does
> > > call compact_pgdat but it does no work due to the cc->order check in
> > > __compact_pgdat.
> > > 
> > 
> > I am looking at mmotm-2013-08-07-16-55 but couldn't find cc->order
> > check right before compact_zone in __comact_pgdat.
> > Could you pinpoint code piece?
> > 
> 
> Thanks, I screwed up as that check happens too late. However, it still
> ends up not mattering because it does this
> 
> compact_pgdat
>   -> __compact_pgdat
>     -> compact_zone
>       -> compaction_suitable
> 
> For order == 0, compaction_suitable will return either COMPACT_SKIPPED
> (if the watermarks are not met) and COMPACT_PARTIAL otherwise. Either
> way, compaction doesn't run.

In compaction_suitable, it could pass first zone_watermark_ok
but failed second zone_watermark_ok while fragindex is -1000
so compaction could run.

And we shouldn't depend on such coincidence.


> 
> -- 
> Mel Gorman
> SUSE Labs
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
