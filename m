Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3F5756B0038
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 08:47:52 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r126so16228467wmr.2
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 05:47:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 65si11284865wro.182.2017.01.13.05.47.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 05:47:51 -0800 (PST)
Date: Fri, 13 Jan 2017 14:47:48 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: alloc_contig: re-allow CMA to compact FS pages
Message-ID: <20170113134748.GK25212@dhcp22.suse.cz>
References: <20170113115155.24335-1-l.stach@pengutronix.de>
 <b7c0b216-5777-ecb3-589a-24288c2eeec8@suse.cz>
 <1484314510.30810.31.camel@pengutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1484314510.30810.31.camel@pengutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lucas Stach <l.stach@pengutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, kernel@pengutronix.de, patchwork-lst@pengutronix.de

On Fri 13-01-17 14:35:10, Lucas Stach wrote:
> Am Freitag, den 13.01.2017, 14:24 +0100 schrieb Vlastimil Babka:
> > On 01/13/2017 12:51 PM, Lucas Stach wrote:
> > > Commit 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
> > > changed compation to skip FS pages if not explicitly allowed to touch them,
> > > but missed to update the CMA compact_control.
> > >
> > > This leads to a very high isolation failure rate, crippling performance of
> > > CMA even on a lightly loaded system. Re-allow CMA to compact FS pages by
> > > setting the correct GFP flags, restoring CMA behavior and performance to
> > > the kernel 4.9 level.
> > >
> > > Fixes: 73e64c51afc5 (mm, compaction: allow compaction for GFP_NOFS requests)
> > > Signed-off-by: Lucas Stach <l.stach@pengutronix.de>
> > 
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > 
> > It's true that this restores the behavior for CMA to 4.9. But it also reveals 
> > that CMA always implicitly assumed to be called from non-fs context. That's 
> > expectable for the original CMA use-case of drivers for devices such as cameras, 
> > but I now wonder if there's danger when CMA gets invoked via dma-cma layer with 
> > generic cma range for e.g. a disk device... I guess that would be another 
> > argument for scoped GFP_NOFS, which should then be applied to adjust the 
> > gfp_mask here. Or we could apply at least memalloc_noio_flags() right now, which 
> > should already handle the disk device -> dma -> cma scenario?
> 
> That's right. But I don't think we need to fix this for 4.10. The
> minimal fix in this patch brings things back to the old assumptions.
> 
> As dma allocations already carry proper GFP flags it's just a matter of
> passing them through to CMA, to make things work correctly. I'll cook up
> a follow up patch for that, but I think this should wait for the next
> merge window to be applied.

Agreed. Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
