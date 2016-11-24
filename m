Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id C0B506B0038
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 08:29:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w13so14882005wmw.0
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:29:21 -0800 (PST)
Received: from mail-wj0-f196.google.com (mail-wj0-f196.google.com. [209.85.210.196])
        by mx.google.com with ESMTPS id 137si8260323wmr.70.2016.11.24.05.29.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Nov 2016 05:29:20 -0800 (PST)
Received: by mail-wj0-f196.google.com with SMTP id f8so3274351wje.2
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 05:29:20 -0800 (PST)
Date: Thu, 24 Nov 2016 14:29:17 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
Message-ID: <20161124132916.GF20668@dhcp22.suse.cz>
References: <20160727182411.GE21859@dhcp22.suse.cz>
 <87eg6e4vhc.fsf@notabene.neil.brown.name>
 <20160728071711.GB31860@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
 <20160803143419.GC1490@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com>
 <20160812123242.GH3639@dhcp22.suse.cz>
 <alpine.LRH.2.02.1608131323550.3291@file01.intranet.prod.int.rdu2.redhat.com>
 <20160814103409.GC9248@dhcp22.suse.cz>
 <alpine.LRH.2.02.1611231558420.31481@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LRH.2.02.1611231558420.31481@file01.intranet.prod.int.rdu2.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Douglas Anderson <dianders@chromium.org>, shli@kernel.org, Dmitry Torokhov <dmitry.torokhov@gmail.com>

On Wed 23-11-16 16:11:59, Mikulas Patocka wrote:
[...]
> Hi Michal
> 
> So, here Google developers hit a stacktrace where a block device driver is 
> being throttled in the memory management:
> 
> https://www.redhat.com/archives/dm-devel/2016-November/msg00158.html
> 
> dm-bufio layer is something like a buffer cache, used by block device 
> drivers. Unlike the real buffer cache, dm-bufio guarantees forward 
> progress even if there is no memory free.
> 
> dm-bufio does something similar like a mempool allocation, it tries an 
> allocation with GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN 
> (just like a mempool) and if it fails, it will reuse some existing buffer.
> 
> Here, they caught it being throttled in the memory management:
> 
>    Workqueue: kverityd verity_prefetch_io
>    __switch_to+0x9c/0xa8
>    __schedule+0x440/0x6d8
>    schedule+0x94/0xb4
>    schedule_timeout+0x204/0x27c
>    schedule_timeout_uninterruptible+0x44/0x50
>    wait_iff_congested+0x9c/0x1f0
>    shrink_inactive_list+0x3a0/0x4cc
>    shrink_lruvec+0x418/0x5cc
>    shrink_zone+0x88/0x198
>    try_to_free_pages+0x51c/0x588
>    __alloc_pages_nodemask+0x648/0xa88
>    __get_free_pages+0x34/0x7c
>    alloc_buffer+0xa4/0x144
>    __bufio_new+0x84/0x278
>    dm_bufio_prefetch+0x9c/0x154
>    verity_prefetch_io+0xe8/0x10c
>    process_one_work+0x240/0x424
>    worker_thread+0x2fc/0x424
>    kthread+0x10c/0x114
> 
> Will you consider removing vm throttling for __GFP_NORETRY allocations?

As I've already said before I do not think that tweaking __GFP_NORETRY
is the right approach is the right approach. The whole point of the flag
is to not loop in the _allocator_ and it has nothing to do with the reclaim
and the way how it is doing throttling.

On the other hand I perfectly understand your point and a lack of
anything between GFP_NOWAIT and ___GFP_DIRECT_RECLAIM can be a bit
frustrating. It would be nice to have sime middle ground - only a
light reclaim involved and a quick back off if the memory is harder to
reclaim. That is a hard thing to do, though because all the reclaimers
(including slab shrinkers) would have to be aware of this concept to
work properly.

I have read the report from the link above and I am really wondering why
s@GFP_NOIO@GFP_NOWAIT@ is not the right way to go there. You have argued
about a clean page cache would force buffer reuse. That might be true
to some extent but is it a real problem? Please note that even
GFP_NOWAIT allocations will wake up kspwad which should clean up that
clean page cache in the background. I would even expect kswapd being
active at the time when NOWAIT requests hit the min watermark. If that
is not the case then we should probably think about why kspwad is not
proactive enough rather than tweaking __GFP_NORETRY semantic.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
