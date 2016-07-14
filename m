Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 163296B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 04:51:58 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so48708201lfg.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 01:51:58 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p12si1850253wma.2.2016.07.14.01.51.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 01:51:56 -0700 (PDT)
Date: Thu, 14 Jul 2016 09:51:53 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: fix pgalloc_stall on unpopulated zone
Message-ID: <20160714085153.GL11400@suse.de>
References: <1468376653-26561-1-git-send-email-minchan@kernel.org>
 <20160713092504.GJ11400@suse.de>
 <20160714011119.GA23512@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160714011119.GA23512@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 14, 2016 at 10:11:19AM +0900, Minchan Kim wrote:
> > The patch means that the vmstat accounting and tracepoint data is also
> > out of sync. One thing I wanted to be able to do was
> > 
> > 1. Observe that there are alloc stalls on DMA32 or some other low zone
> > 2. Activate mm_vmscan_direct_reclaim_begin, filter on classzone_idx ==
> >    DMA32 and identify the source of the lowmem allocations
> > 
> > If your patch is applied, I cannot depend on the stall stats any more
> > and the tracepoint is required to determine if there really any
> > zone-contrained allocations. It can be *inferred* from the skip stats
> > but only if such skips occurred and that is not guaranteed.
> 
> Just a nit:
> 
> Hmm, can't we omit classzone_idx in mm_vm_scan_direct_begin_template?
> Because every functions already have gfp_flags so that we can classzone_idx
> via gfp_zone(gfp_flags) without passing it.
> 

We could but it's potentially wrong. classzone_idx *should* be derived
from the gfp_flags but it's possible a bug would lead it to be another
value. The saving from passing it in is marginal at best.

If it's omitted from the tracepoint itself, there is a small amount of
disk saving which is potentially significant if there is a lot of direct
reclaim. Unfortunately, it also makes it harder to filter that
tracepoint because the filter rules must be an implementation of
gfp_zone.

Right now I believe the saving is marginal and the cost of potentially
using the wrong information or making the filtering harder offsets that
marginal saving.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
