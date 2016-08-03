Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id 340C96B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 09:59:18 -0400 (EDT)
Received: by mail-ua0-f200.google.com with SMTP id j59so279313141uaj.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 06:59:18 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q29si4787877qte.113.2016.08.03.06.59.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 06:59:14 -0700 (PDT)
Date: Wed, 3 Aug 2016 09:59:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [dm-devel] [RFC PATCH 2/2] mm, mempool: do not throttle
 PF_LESS_THROTTLE tasks
In-Reply-To: <20160727184021.GF21859@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1608030853430.15274@file01.intranet.prod.int.rdu2.redhat.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org> <1468831285-27242-2-git-send-email-mhocko@kernel.org> <87oa5q5abi.fsf@notabene.neil.brown.name> <20160722091558.GF794@dhcp22.suse.cz>
 <878twt5i1j.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607251730280.11852@file01.intranet.prod.int.rdu2.redhat.com> <87invr4tjm.fsf@notabene.neil.brown.name> <alpine.LRH.2.02.1607270948040.1779@file01.intranet.prod.int.rdu2.redhat.com>
 <20160727184021.GF21859@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: NeilBrown <neilb@suse.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, dm-devel@redhat.com, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ondrej Kozina <okozina@redhat.com>, Andrew Morton <akpm@linux-foundation.org>



On Wed, 27 Jul 2016, Michal Hocko wrote:

> On Wed 27-07-16 10:28:40, Mikulas Patocka wrote:
> > 
> > 
> > On Wed, 27 Jul 2016, NeilBrown wrote:
> > 
> > > On Tue, Jul 26 2016, Mikulas Patocka wrote:
> > > 
> > > > On Sat, 23 Jul 2016, NeilBrown wrote:
> > > >
> > > >> "dirtying ... from the reclaim context" ??? What does that mean?
> > > >> According to
> > > >>   Commit: 26eecbf3543b ("[PATCH] vm: pageout throttling")
> > > >> From the history tree, the purpose of throttle_vm_writeout() is to
> > > >> limit the amount of memory that is concurrently under I/O.
> > > >> That seems strange to me because I thought it was the responsibility of
> > > >> each backing device to impose a limit - a maximum queue size of some
> > > >> sort.
> > > >
> > > > Device mapper doesn't impose any limit for in-flight bios.
> > > 
> > > I would suggest that it probably should. At least it should
> > > "set_wb_congested()" when the number of in-flight bios reaches some
> > > arbitrary threshold.
> > 
> > If we set the device mapper device as congested, it can again trigger that 
> > mempool alloc throttling bug.
> > 
> > I.e. suppose that we swap to a dm-crypt device. The dm-crypt device 
> > becomes clogged and sets its state as congested. The underlying block 
> > device is not congested.
> > 
> > The mempool_alloc function in the dm-crypt workqueue sets the 
> > PF_LESS_THROTTLE flag, and tries to allocate memory, but according to 
> > Michal's patches, processes with PF_LESS_THROTTLE may still get throttled.
> > 
> > So if we set the dm-crypt device as congested, it can incorrectly throttle 
> > the dm-crypt workqueue that does allocations of temporary pages and 
> > encryption.
> > 
> > I think that approach with PF_LESS_THROTTLE in mempool_alloc is incorrect 
> > and that mempool allocations should never be throttled.
> 
> I'm not really sure this is the right approach. If a particular mempool
> user cannot ever be throttled by the page allocator then it should
> perform GFP_NOWAIT.

Then, all block device drivers should have GFP_NOWAIT - which means that 
we can as well make it default.

But GFP_NOWAIT also disables direct reclaim. We really want direct reclaim 
when allocating from mempool - we just don't want to throttle due to block 
device congestion.

We could use __GFP_NORETRY as an indication that we don't want to sleep - 
or make a new flag __GFP_NO_THROTTLE.

> Even mempool allocations shouldn't allow reclaim to
> scan pages too quickly even when LRU lists are full of dirty pages. But
> as I've said that would restrict the success rates even under light page
> cache load. Throttling on the wait_iff_congested should be quite rare.
> 
> Anyway do you see an excessive throttling with the patch posted
> http://lkml.kernel.org/r/20160725192344.GD2166@dhcp22.suse.cz ? Or from

It didn't have much effect.

Since the patch 4e390b2b2f34b8daaabf2df1df0cf8f798b87ddb (revert of the 
limitless mempool allocations), swapping to dm-crypt works in the simple 
example.

> another side. Do you see an excessive number of dirty/writeback pages
> wrt. the dirty threshold or any other undesirable side effects?
> -- 
> Michal Hocko
> SUSE Labs

I also got got dmcrypt stalled in bt_get when submitting I/Os to the 
underlying virtio device. I don't know what could be done about it.

[   30.441074] dmcrypt_write   D ffff88003de7bba8     0  2155      2 0x00080000
[   30.441956]  ffff88003de7bba8 ffff88003de7be70 ffff88003de7c000 ffff88003fc34740
[   30.442934]  7fffffffffffffff ffff88003fc3a680 ffff880037a911f8 ffff88003de7bbc0
[   30.443969]  ffffffff812770df 7fffffffffffffff ffff88003de7bc10 ffffffff81278ca7
[   30.444926] Call Trace:
[   30.445232]  [<ffffffff812770df>] schedule+0x83/0x98
[   30.445825]  [<ffffffff81278ca7>] schedule_timeout+0x2f/0xcf
[   30.446506]  [<ffffffff81276c84>] io_schedule_timeout+0x64/0x90
[   30.447235]  [<ffffffff81276c84>] ? io_schedule_timeout+0x64/0x90
[   30.448088]  [<ffffffff8115787a>] bt_get+0x11a/0x1bc
[   30.448688]  [<ffffffff8105ef86>] ? wake_up_atomic_t+0x25/0x25
[   30.449392]  [<ffffffff81157abb>] blk_mq_get_tag+0x7e/0x9b
[   30.450041]  [<ffffffff81155066>] __blk_mq_alloc_request+0x1b/0x1e0
[   30.450805]  [<ffffffff81155ee8>] blk_mq_map_request+0xf6/0x136
[   30.451516]  [<ffffffff81156866>] blk_sq_make_request+0xac/0x173
[   30.452322]  [<ffffffff8114db56>] generic_make_request+0xb8/0x15b
[   30.453038]  [<ffffffffa012ba65>] dmcrypt_write+0x13b/0x174 [dm_crypt]
[   30.453852]  [<ffffffff81052779>] ? wake_up_q+0x42/0x42
[   30.454508]  [<ffffffffa012b92a>] ? crypt_iv_tcw_dtr+0x62/0x62 [dm_crypt]
[   30.455369]  [<ffffffff8104dc6a>] kthread+0xa0/0xa8
[   30.456041]  [<ffffffff8104dc6a>] ? kthread+0xa0/0xa8
[   30.456688]  [<ffffffff8127999f>] ret_from_fork+0x1f/0x40
[   30.457396]  [<ffffffff8104dbca>] ? init_completion+0x24/0x24

Mikulas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
