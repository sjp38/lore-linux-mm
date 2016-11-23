Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 603796B0038
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 16:12:04 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id d45so14699218qta.2
        for <linux-mm@kvack.org>; Wed, 23 Nov 2016 13:12:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r6si20421747qkr.318.2016.11.23.13.12.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Nov 2016 13:12:03 -0800 (PST)
Date: Wed, 23 Nov 2016 16:11:59 -0500 (EST)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160814103409.GC9248@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1611231558420.31481@file01.intranet.prod.int.rdu2.redhat.com>
References: <20160725083247.GD9401@dhcp22.suse.cz> <87lh0n4ufs.fsf@notabene.neil.brown.name> <20160727182411.GE21859@dhcp22.suse.cz> <87eg6e4vhc.fsf@notabene.neil.brown.name> <20160728071711.GB31860@dhcp22.suse.cz> <alpine.LRH.2.02.1608030844470.15274@file01.intranet.prod.int.rdu2.redhat.com>
 <20160803143419.GC1490@dhcp22.suse.cz> <alpine.LRH.2.02.1608041446430.21662@file01.intranet.prod.int.rdu2.redhat.com> <20160812123242.GH3639@dhcp22.suse.cz> <alpine.LRH.2.02.1608131323550.3291@file01.intranet.prod.int.rdu2.redhat.com>
 <20160814103409.GC9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "dm-devel@redhat.com David Rientjes" <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Douglas Anderson <dianders@chromium.org>, shli@kernel.org, Dmitry Torokhov <dmitry.torokhov@gmail.com>



On Sun, 14 Aug 2016, Michal Hocko wrote:

> On Sat 13-08-16 13:34:29, Mikulas Patocka wrote:
> > 
> > 
> > On Fri, 12 Aug 2016, Michal Hocko wrote:
> > 
> > > On Thu 04-08-16 14:49:41, Mikulas Patocka wrote:
> > > 
> > > > On Wed, 3 Aug 2016, Michal Hocko wrote:
> > > > 
> > > > > But the device congestion is not the only condition required for the
> > > > > throttling. The pgdat has also be marked congested which means that the
> > > > > LRU page scanner bumped into dirty/writeback/pg_reclaim pages at the
> > > > > tail of the LRU. That should only happen if we are rotating LRUs too
> > > > > quickly. AFAIU the reclaim shouldn't allow free ticket scanning in that
> > > > > situation.
> > > > 
> > > > The obvious problem here is that mempool allocations should sleep in 
> > > > mempool_alloc() on &pool->wait (until someone returns some entries into 
> > > > the mempool), they should not sleep inside the page allocator.
> > > 
> > > I agree that mempool_alloc should _primarily_ sleep on their own
> > > throttling mechanism. I am not questioning that. I am just saying that
> > > the page allocator has its own throttling which it relies on and that
> > > cannot be just ignored because that might have other undesirable side
> > > effects. So if the right approach is really to never throttle certain
> > > requests then we have to bail out from a congested nodes/zones as soon
> > > as the congestion is detected.
> > > 
> > > Now, I would like to see that something like that is _really_ necessary.
> > 
> > Currently, it is not a problem - device mapper reports the device as 
> > congested only if the underlying physical disks are congested.
> > 
> > But once we change it so that device mapper reports congested state on its 
> > own (when it has too many bios in progress), this starts being a problem.
> 
> OK, can we wait until it starts becoming a real problem and solve it
> appropriately then?
> 
> I will repost the patch which removes thottle_vm_pageout in the meantime
> as it doesn't seem to be needed anymore.
> 
> -- 
> Michal Hocko
> SUSE Labs

Hi Michal

So, here Google developers hit a stacktrace where a block device driver is 
being throttled in the memory management:

https://www.redhat.com/archives/dm-devel/2016-November/msg00158.html

dm-bufio layer is something like a buffer cache, used by block device 
drivers. Unlike the real buffer cache, dm-bufio guarantees forward 
progress even if there is no memory free.

dm-bufio does something similar like a mempool allocation, it tries an 
allocation with GFP_NOIO | __GFP_NORETRY | __GFP_NOMEMALLOC | __GFP_NOWARN 
(just like a mempool) and if it fails, it will reuse some existing buffer.

Here, they caught it being throttled in the memory management:

   Workqueue: kverityd verity_prefetch_io
   __switch_to+0x9c/0xa8
   __schedule+0x440/0x6d8
   schedule+0x94/0xb4
   schedule_timeout+0x204/0x27c
   schedule_timeout_uninterruptible+0x44/0x50
   wait_iff_congested+0x9c/0x1f0
   shrink_inactive_list+0x3a0/0x4cc
   shrink_lruvec+0x418/0x5cc
   shrink_zone+0x88/0x198
   try_to_free_pages+0x51c/0x588
   __alloc_pages_nodemask+0x648/0xa88
   __get_free_pages+0x34/0x7c
   alloc_buffer+0xa4/0x144
   __bufio_new+0x84/0x278
   dm_bufio_prefetch+0x9c/0x154
   verity_prefetch_io+0xe8/0x10c
   process_one_work+0x240/0x424
   worker_thread+0x2fc/0x424
   kthread+0x10c/0x114

Will you consider removing vm throttling for __GFP_NORETRY allocations?

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
