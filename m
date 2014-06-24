Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 833156B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 21:07:07 -0400 (EDT)
Received: by mail-pd0-f174.google.com with SMTP id y10so6279782pdj.19
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 18:07:07 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id fl10si24124873pab.132.2014.06.23.18.07.05
        for <linux-mm@kvack.org>;
        Mon, 23 Jun 2014 18:07:06 -0700 (PDT)
Date: Tue, 24 Jun 2014 11:02:33 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS WARN_ON in xfs_vm_writepage
Message-ID: <20140624010233.GZ9508@dastard>
References: <20140613051631.GA9394@redhat.com>
 <20140613062645.GZ9508@dastard>
 <20140613141925.GA24199@redhat.com>
 <20140619020340.GI4453@dastard>
 <20140623202714.GA2714@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140623202714.GA2714@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, xfs@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jun 23, 2014 at 04:27:14PM -0400, Dave Jones wrote:
> On Thu, Jun 19, 2014 at 12:03:40PM +1000, Dave Chinner wrote:
>  > On Fri, Jun 13, 2014 at 10:19:25AM -0400, Dave Jones wrote:
>  > > On Fri, Jun 13, 2014 at 04:26:45PM +1000, Dave Chinner wrote:
>  > > 
>  > > > >  970         if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
>  > > > >  971                         PF_MEMALLOC))
>  > > >
>  > > > What were you running at the time? The XFS warning is there to
>  > > > indicate that memory reclaim is doing something it shouldn't (i.e.
>  > > > dirty page writeback from direct reclaim), so this is one for the mm
>  > > > folk to work out...
>  > > 
>  > > Trinity had driven the machine deeply into swap, and the oom killer was
>  > > kicking in pretty often. Then this happened.
>  > 
>  > Yup, sounds like a problem somewhere in mm/vmscan.c....
>  
> I'm now hitting this fairly often, and no-one seems to have offered up
> any suggestions yet, so I'm going to flail and guess randomly until someone
> has a better idea what could be wrong.

You are not alone - I haven't been able to get anyone from the MM
side of things to comment on any of the bad behaviours we've had
reported recently.

> That WARN commentary for the benefit of linux-mm readers..
> 
>  960         /*
>  961          * Refuse to write the page out if we are called from reclaim context.
>  962          *
>  963          * This avoids stack overflows when called from deeply used stacks in
>  964          * random callers for direct reclaim or memcg reclaim.  We explicitly
>  965          * allow reclaim from kswapd as the stack usage there is relatively low.
>  966          *
>  967          * This should never happen except in the case of a VM regression so
>  968          * warn about it.
>  969          */
>  970         if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
>  971                         PF_MEMALLOC))
>  972                 goto redirty;
> 
> 
> Looking at this trace..
> 
> xfs_vm_writepage+0x5ce/0x630 [xfs]
> ? preempt_count_sub+0xab/0x100
> ? __percpu_counter_add+0x85/0xc0
> shrink_page_list+0x8f9/0xb90
> shrink_inactive_list+0x253/0x510
> shrink_lruvec+0x563/0x6c0
> shrink_zone+0x3b/0x100
> shrink_zones+0x1f1/0x3c0
> try_to_free_pages+0x164/0x380
> __alloc_pages_nodemask+0x822/0xc90
> alloc_pages_vma+0xaf/0x1c0
> read_swap_cache_async+0x123/0x220
> ? final_putname+0x22/0x50
> swapin_readahead+0x149/0x1d0
> ? find_get_entry+0xd5/0x130
> ? pagecache_get_page+0x30/0x210
> ? debug_smp_processor_id+0x17/0x20
> handle_mm_fault+0x9d5/0xc50
> __do_page_fault+0x1d2/0x640
> ? __acct_update_integrals+0x8b/0x120
> ? preempt_count_sub+0xab/0x100
> do_page_fault+0x1e/0x70
> page_fault+0x22/0x30
> 
> The reclaim here looks to be triggered from the readahead code.
> Should something in that path be setting PF_KSWAPD in the gfp mask ?

Definitely not. It's not kswapd that is doing the memory allocation
and we most certainly do not want direct reclaim to get a free pass
through reclaim congestion and backoff algorithms.

This could be another symptom of the other problems we've been
seeing which involve direct reclaim thottling way too hard (via the
too_many_isolated() loops) and getting stuck. This is a case of
direct reclaim finding dirty pages on the LRU, which should have
been handled by writeback threads or kswapd before direct reclaim
can find them. IOWs, direct reclaim is doing work when it probably
should have been throttled.

As the comment in the XFS code says: "This should never happen
except in the case of a VM regression..."

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
