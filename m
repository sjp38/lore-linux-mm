Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF8C6B0069
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 12:10:13 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id m67so38958889qkf.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 09:10:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j9si15562273qtj.101.2016.11.24.09.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 09:10:12 -0800 (PST)
Date: Thu, 24 Nov 2016 12:10:08 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20161124132916.GF20668@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1611241158250.9110@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160727182411.GE21859@dhcp22.suse.cz> <87eg6e4vhc.fsf@notabene.neil.brown.name> <20160728071711.GB31860@dhcp22.suse.cz> <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com> <20160803143419.GC1490@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com> <20160812123242.GH3639@dhcp22.suse.cz> <alpine.LRH.2.02.1608131323550.3291@file01.intranet.prod.int.rdu2.redhat.com> <20160814103409.GC9248@dhcp22.suse.cz>
 <alpine.LRH.2.02.1611231558420.31481@file01.intranet.prod.int.rdu2.redhat.com> <20161124132916.GF20668@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Douglas Anderson <dianders@chromium.org>, shli@kernel.org, Dmitry Torokhov <dmitry.torokhov@gmail.com>



On Thu, 24 Nov 2016, Michal Hocko wrote:

> On Wed 23-11-16 16:11:59, Mikulas Patocka wrote:
> [...]
> > Hi Michal
> > 
> > So, here Google developers hit a stacktrace where a block device driver is 
> > being throttled in the memory management:
> > 
> > https://www.redhat.com/archives/dm-devel/2016-November/msg00158.html
> > 
> > dm-bufio layer is something like a buffer cache, used by block device 
> > drivers. Unlike the real buffer cache, dm-bufio guarantees forward 
> > progress even if there is no memory free.
> > 
> > dm-bufio does something similar like a mempool allocation, it tries an 
> > allocation with GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN 
> > (just like a mempool) and if it fails, it will reuse some existing buffer.
> > 
> > Here, they caught it being throttled in the memory management:
> > 
> >    Workqueue: kverityd verity_prefetch_io
> >    __switch_to+0x9c/0xa8
> >    __schedule+0x440/0x6d8
> >    schedule+0x94/0xb4
> >    schedule_timeout+0x204/0x27c
> >    schedule_timeout_uninterruptible+0x44/0x50
> >    wait_iff_congested+0x9c/0x1f0
> >    shrink_inactive_list+0x3a0/0x4cc
> >    shrink_lruvec+0x418/0x5cc
> >    shrink_zone+0x88/0x198
> >    try_to_free_pages+0x51c/0x588
> >    __alloc_pages_nodemask+0x648/0xa88
> >    __get_free_pages+0x34/0x7c
> >    alloc_buffer+0xa4/0x144
> >    __bufio_new+0x84/0x278
> >    dm_bufio_prefetch+0x9c/0x154
> >    verity_prefetch_io+0xe8/0x10c
> >    process_one_work+0x240/0x424
> >    worker_thread+0x2fc/0x424
> >    kthread+0x10c/0x114
> > 
> > Will you consider removing vm throttling for __GFP_NORETRY allocations?
> 
> As I've already said before I do not think that tweaking __GFP_NORETRY
> is the right approach is the right approach. The whole point of the flag
> is to not loop in the _allocator_ and it has nothing to do with the reclaim
> and the way how it is doing throttling.
> 
> On the other hand I perfectly understand your point and a lack of
> anything between GFP_NOWAIT and ___GFP_DIRECT_RECLAIM can be a bit
> frustrating. It would be nice to have sime middle ground - only a
> light reclaim involved and a quick back off if the memory is harder to
> reclaim. That is a hard thing to do, though because all the reclaimers
> (including slab shrinkers) would have to be aware of this concept to
> work properly.
> 
> I have read the report from the link above and I am really wondering why
> s@GFP_NOIO@GFP_NOWAIT@ is not the right way to go there. You have argued
> about a clean page cache would force buffer reuse. That might be true
> to some extent but is it a real problem?

The dm-bufio cache is limited by default to 2% of all memory. And the 
buffers are freed after 5 minutes of not being used.

It is unfair to reclaim the small dm-bufio cache (that was recently used) 
instead of the big page cache (that could be indefinitely old).

> Please note that even
> GFP_NOWAIT allocations will wake up kspwad which should clean up that

The mempool is also using GFP_NOIO allocations - so do you claim that it 
should not use GFP_NOIO too?

You should provide a clear API that the block device drivers should use to 
allocate memory - not to apply band aid to vm throttling problems as they 
are being discovered.

> clean page cache in the background. I would even expect kswapd being
> active at the time when NOWAIT requests hit the min watermark. If that
> is not the case then we should probably think about why kspwad is not
> proactive enough rather than tweaking __GFP_NORETRY semantic.
> 
> Thanks!
> -- 
> Michal Hocko
> SUSE Labs

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
