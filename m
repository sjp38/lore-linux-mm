Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id E25816B0032
	for <linux-mm@kvack.org>; Sun,  1 Mar 2015 06:18:05 -0500 (EST)
Received: by pabli10 with SMTP id li10so6133483pab.2
        for <linux-mm@kvack.org>; Sun, 01 Mar 2015 03:18:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id km8si4434685pdb.175.2015.03.01.03.18.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 01 Mar 2015 03:18:04 -0800 (PST)
Subject: Re: How to handle TIF_MEMDIE stalls?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150221235227.GA25079@phnom.home.cmpxchg.org>
	<20150223004521.GK12722@dastard>
	<20150228162943.GA17989@phnom.home.cmpxchg.org>
	<20150228164158.GE5404@thunk.org>
	<20150228221558.GA23028@phnom.home.cmpxchg.org>
In-Reply-To: <20150228221558.GA23028@phnom.home.cmpxchg.org>
Message-Id: <201503012017.EAD00571.HOOJVOStMFLFQF@I-love.SAKURA.ne.jp>
Date: Sun, 1 Mar 2015 20:17:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org, tytso@mit.edu
Cc: david@fromorbit.com, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com, fernando_b1@lab.ntt.co.jp

Johannes Weiner wrote:
> On Sat, Feb 28, 2015 at 11:41:58AM -0500, Theodore Ts'o wrote:
> > On Sat, Feb 28, 2015 at 11:29:43AM -0500, Johannes Weiner wrote:
> > > 
> > > I'm trying to figure out if the current nofail allocators can get
> > > their memory needs figured out beforehand.  And reliably so - what
> > > good are estimates that are right 90% of the time, when failing the
> > > allocation means corrupting user data?  What is the contingency plan?
> > 
> > In the ideal world, we can figure out the exact memory needs
> > beforehand.  But we live in an imperfect world, and given that block
> > devices *also* need memory, the answer is "of course not".  We can't
> > be perfect.  But we can least give some kind of hint, and we can offer
> > to wait before we get into a situation where we need to loop in
> > GFP_NOWAIT --- which is the contingency/fallback plan.
> 
> Overestimating should be fine, the result would a bit of false memory
> pressure.  But underestimating and looping can't be an option or the
> original lockups will still be there.  We need to guarantee forward
> progress or the problem is somewhat mitigated at best - only now with
> quite a bit more complexity in the allocator and the filesystems.
> 
> The block code would have to be looked at separately, but doesn't it
> already use mempools etc. to guarantee progress?
> 

If underestimating is tolerable, can we simply set different watermark
levels for GFP_ATOMIC / GFP_NOIO / GFP_NOFS / GFP_KERNEL allocations?
For example,

   GFP_KERNEL (or above) can fail if memory usage exceeds 95%
   GFP_NOFS can fail if memory usage exceeds 97%
   GFP_NOIO can fail if memory usage exceeds 98%
   GFP_ATOMIC can fail if memory usage exceeds 99%

I think that below order-0 GFP_NOIO allocation enters into retry-forever loop
when GFP_KERNEL (or above) allocation starts waiting for reclaim sounds
strange. Use of same watermark is preventing kernel worker threads from
processing workqueue. While it is legal to do blocking operation from
workqueue, being blocked forever is an exclusive occupation for workqueue;
other jobs in the workqueue get stuck.

[  907.302050] kworker/1:0     R  running task        0 10832      2 0x00000080
[  907.303961] Workqueue: events_freezable_power_ disk_events_workfn
[  907.305706]  ffff88007c8ab7d8 0000000000000046 ffff88007c8ab8a0 ffff88007c894190
[  907.307761]  0000000000012500 ffff88007c8abfd8 0000000000012500 ffff88007c894190
[  907.309894]  0000000000000020 ffff88007c8ab8b0 0000000000000002 ffffffff81848408
[  907.311949] Call Trace:
[  907.312989]  [<ffffffff8159f814>] _cond_resched+0x24/0x40
[  907.314578]  [<ffffffff81122119>] shrink_slab+0x139/0x150
[  907.316182]  [<ffffffff811252bf>] do_try_to_free_pages+0x35f/0x4d0
[  907.317889]  [<ffffffff811254c4>] try_to_free_pages+0x94/0xc0
[  907.319535]  [<ffffffff8111a793>] __alloc_pages_nodemask+0x4e3/0xa40
[  907.321259]  [<ffffffff8115a8ce>] alloc_pages_current+0x8e/0x100
[  907.322945]  [<ffffffff8125bed6>] bio_copy_user_iov+0x1d6/0x380
[  907.324606]  [<ffffffff8125e4cd>] ? blk_rq_init+0xed/0x160
[  907.326196]  [<ffffffff8125c119>] bio_copy_kern+0x49/0x100
[  907.327788]  [<ffffffff810a14a0>] ? prepare_to_wait_event+0x100/0x100
[  907.329549]  [<ffffffff81265e6f>] blk_rq_map_kern+0x6f/0x130
[  907.331184]  [<ffffffff8116393e>] ? kmem_cache_alloc+0x48e/0x4b0
[  907.332877]  [<ffffffff813a66cf>] scsi_execute+0x12f/0x160
[  907.334452]  [<ffffffff813a7f14>] scsi_execute_req_flags+0x84/0xf0
[  907.336156]  [<ffffffffa01e29cc>] sr_check_events+0xbc/0x2e0 [sr_mod]
[  907.337893]  [<ffffffff8109834c>] ? put_prev_entity+0x2c/0x3b0
[  907.339539]  [<ffffffffa01d6177>] cdrom_check_events+0x17/0x30 [cdrom]
[  907.341289]  [<ffffffffa01e2e5d>] sr_block_check_events+0x2d/0x30 [sr_mod]
[  907.343115]  [<ffffffff812701c6>] disk_check_events+0x56/0x1b0
[  907.344771]  [<ffffffff81270331>] disk_events_workfn+0x11/0x20
[  907.346421]  [<ffffffff8107ceaf>] process_one_work+0x13f/0x370
[  907.348057]  [<ffffffff8107de99>] worker_thread+0x119/0x500
[  907.349650]  [<ffffffff8107dd80>] ? rescuer_thread+0x350/0x350
[  907.351295]  [<ffffffff81082f7c>] kthread+0xdc/0x100
[  907.352765]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0
[  907.354520]  [<ffffffff815a383c>] ret_from_fork+0x7c/0xb0
[  907.356097]  [<ffffffff81082ea0>] ? kthread_create_on_node+0x1b0/0x1b0

If I change GFP_NOIO in scsi_execute() to GFP_ATOMIC, above trace went away.
If we can reserve some amount of memory for block / filesystem layer than
allow non critical allocation, above trace will likely go away. 

Or, instead maybe we can change GFP_NOIO to do

  (1) try allocation using GFP_ATOMIC|GFP_NOWARN
  (2) try allocating from freelist for GFP_NOIO
  (3) fail the allocation with warning message

steps if we can implement freelist for GFP_NOIO. Ditto for GFP_NOFS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
