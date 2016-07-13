Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id BF0326B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:02:22 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id i12so87791521ywa.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:02:22 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q188si2227903qkf.300.2016.07.13.08.02.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:02:21 -0700 (PDT)
Date: Wed, 13 Jul 2016 11:02:15 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160713111006.GF28723@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1607131021410.31769@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com> <20160712064905.GA14586@dhcp22.suse.cz>
 <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com> <20160713111006.GF28723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On Wed, 13 Jul 2016, Michal Hocko wrote:

> On Tue 12-07-16 19:44:11, Mikulas Patocka wrote:
> > The problem of swapping to dm-crypt is this.
> > 
> > The free memory goes low, kswapd decides that some page should be swapped 
> > out. However, when you swap to an ecrypted device, writeback of each page 
> > requires another page to hold the encrypted data. dm-crypt uses mempools 
> > for all its structures and pages, so that it can make forward progress 
> > even if there is no memory free. However, the mempool code first allocates 
> > from general memory allocator and resorts to the mempool only if the 
> > memory is below limit.
> 
> OK, thanks for the clarification. I guess the core part happens in
> crypt_alloc_buffer, right?
> 
> > So every attempt to swap out some page allocates another page.
> > 
> > As long as swapping is in progress, the free memory is below the limit 
> > (because the swapping activity itself consumes any memory over the limit). 
> > And that triggered the OOM killer prematurely.
> 
> I am not sure I understand the last part. Are you saing that we trigger
> OOM because the initiated swapout will not be able to finish the IO thus
> release the page in time?

On kernel 4.6 - premature OOM is triggered just because the free memory 
stays below the limit for some time.

On kernel 4.7-rc6 (that contains your OOM patch 
0a0337e0d1d134465778a16f5cbea95086e8e9e0), OOM is not triggered, but the 
machine slows down to a crawl, because the allocator applies throttling to 
the process that is doing the encryption.

> The oom detection checks waits for an ongoing writeout if there is no
> reclaim progress and at least half of the reclaimable memory is either
> dirty or under writeback. Pages under swaout are marked as under
> writeback AFAIR. The writeout path (dm-crypt worker in this case) should
> be able to allocate a memory from the mempool, hand over to the crypt
> layer and finish the IO. Is it possible this might take a lot of time?

See the backtrace below - the dm-crypt worker is making progress, but the 
memory allocator deliberatelly stalls it in throttle_vm_writeout.

> > On Tue, 12 Jul 2016, Michal Hocko wrote:
> > > 
> > > Look at the amount of free memory. It is completely depleted. So it
> > > smells like a process which has access to memory reserves has consumed
> > > all of it. I suspect a __GFP_MEMALLOC resp. PF_MEMALLOC from softirq
> > > context user which went off the leash.
> > 
> > It is caused by the commit f9054c70d28bc214b2857cf8db8269f4f45a5e23. Prior 
> > to this commit, mempool allocations set __GFP_NOMEMALLOC, so they never 
> > exhausted reserved memory. With this commit, mempool allocations drop 
> > __GFP_NOMEMALLOC, so they can dig deeper (if the process has PF_MEMALLOC, 
> > they can bypass all limits).
> 
> Hmm, but the patch allows access to the memory reserves only when the
> pool is empty. And even then the caller would have to request access to
> reserves explicitly either by __GFP_NOMEMALLOC or PF_MEMALLOC. That

PF_MEMALLOC is set when you enter the block driver when swapping. So, some 
of the mempool allocations are done with PF_MEMALLOC.

> doesn't seem to be the case for the dm-crypt, though. Or do you suspect
> that some other mempool user might be doing so? 

Bisection showed that that patch triggered the dm-crypt swapping problems.

Without the patch f9054c70d28bc214b2857cf8db8269f4f45a5e23, mempool_alloc
1. allocates memory up to __GFP_NOMEMALLOC limit
2. allocates memory from the mempool reserve
3. waits, until some objects are returned to the mempool

With the patch f9054c70d28bc214b2857cf8db8269f4f45a5e23, mempool_alloc 
1. allocates memory up to __GFP_NOMEMALLOC limit
2. allocates memory from the mempool reserve
3. allocates all remaining memory until total exhaustion
4. waits, until some objects are returned to the mempool

> > > No this doesn't sound like a proper solution. The current decision
> > > logic, as explained above relies on the feedback from the reclaim. A
> > > free swap space doesn't really mean we can make a forward progress.
> > 
> > I'm interested - why would you need to trigger the OOM killer if there is 
> > free swap space?
> 
> Let me clarify. If there is a swapable memory then we shouldn't trigger
> the OOM killer normally of course. And that should be the case with the
> current implementation. We just rely on the swapout making some progress

And what does exactly "making some progress" mean? How do you measure it?

> and back off only if that is not the case after several attempts with a
> throttling based on the writeback counters. Checking the available swap
> space doesn't guarantee a forward progress, though. If the swap out is
> stuck for some reason then it should be safer to trigger to OOM rather
> than wait or trash for ever (or an excessive amount of time).
>
> Now, I can see that the retry logic might need some tuning for complex
> setups like dm-crypt swap partitions because the progress might be much
> slower there. But I would like the understand what is the worst estimate
> for the swapout path with all the roadblocks on the way for this setup
> before we can think of a proper retry logic tuning.

For example, you could increment a percpu counter each time writeback of a 
page is finished. If the counters stays the same for some pre-determined 
period of time, writeback is stuck and you could trigger OOM prematurely.

But the memory management code doesn't do that. So what it really does and 
what is the intention behind it?

Another question is - do we really want to try to recover in case of stuck 
writeback? If the swap device dies so that it stops processing I/Os, the 
system is dead anyway - there is no point in trying to recover it by 
killing processes.

The question is if these safeguards against stuck writeback are really 
doing more harm than good. Do you have some real use case where you get 
stuck writeback and where you need to recover by OOM killing?

This is not the first time I've seen premature OOM. Long time ago, I saw a 
case when the admin set /proc/sys/vm/swappiness to a low value (because he 
was running some scientific calculations on the machine and he preferred 
memory being allocated to those calculations rather than to the cache) - 
and the result was premature OOM killing while the machine had plenty of 
free swap swace.

> > The kernel 4.7-rc almost deadlocks in another way. The machine got stuck 
> > and the following stacktrace was obtained when swapping to dm-crypt.
> > 
> > We can see that dm-crypt does a mempool allocation. But the mempool 
> > allocation somehow falls into throttle_vm_writeout. There, it waits for 
> > 0.1 seconds. So, as a result, the dm-crypt worker thread ends up 
> > processing requests at an unusually slow rate of 10 requests per second 
> > and it results in the machine being stuck (it would proabably recover if 
> > we waited for extreme amount of time).
> 
> Hmm, that throttling is there since ever basically. I do not see what
> would have changed that recently, but I haven't looked too close to be
> honest.
> 
> I agree that throttling a flusher (which this worker definitely is)
> doesn't look like a correct thing to do. We have PF_LESS_THROTTLE for
> this kind of things. So maybe the right thing to do is to use this flag
> for the dm_crypt worker:
> 
> diff --git a/drivers/md/dm-crypt.c b/drivers/md/dm-crypt.c
> index 4f3cb3554944..0b806810efab 100644
> --- a/drivers/md/dm-crypt.c
> +++ b/drivers/md/dm-crypt.c
> @@ -1392,11 +1392,14 @@ static void kcryptd_async_done(struct crypto_async_request *async_req,
>  static void kcryptd_crypt(struct work_struct *work)
>  {
>  	struct dm_crypt_io *io = container_of(work, struct dm_crypt_io, work);
> +	unsigned int pflags = current->flags;
>  
> +	current->flags |= PF_LESS_THROTTLE;
>  	if (bio_data_dir(io->base_bio) == READ)
>  		kcryptd_crypt_read_convert(io);
>  	else
>  		kcryptd_crypt_write_convert(io);
> +	tsk_restore_flags(current, pflags, PF_LESS_THROTTLE);
>  }
>  
>  static void kcryptd_queue_crypt(struct dm_crypt_io *io)

^^^ That fixes just one specific case - but there may be other threads 
doing mempool allocations in the device mapper subsystem - and you would 
need to mark all of them.

I would try the patch below - generally, allocations from the mempool 
subsystem should not wait in the memory allocator at all. I don't know if 
there are other cases when these allocations can sleep. I'm interested if 
it fixes Ondrej's case - or if it uncovers some other sleeping.

An alternate possibility would be to drop the flag __GFP_DIRECT_RECLAIM in 
mempool_alloc - so that mempool allocations never sleep in the allocator.

---
 mm/page-writeback.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-4.7-rc7/mm/page-writeback.c
===================================================================
--- linux-4.7-rc7.orig/mm/page-writeback.c	2016-07-12 20:57:53.000000000 +0200
+++ linux-4.7-rc7/mm/page-writeback.c	2016-07-12 20:59:41.000000000 +0200
@@ -1945,6 +1945,14 @@ void throttle_vm_writeout(gfp_t gfp_mask
 	unsigned long background_thresh;
 	unsigned long dirty_thresh;
 
+	/*
+	 * If we came here from mempool_alloc, we don't want to wait 0.1s.
+	 * We want to fail as soon as possible, so that the allocation is tried
+	 * from mempool reserve.
+	 */
+	if (unlikely(gfp_mask & __GFP_NORETRY))
+		return;
+
         for ( ; ; ) {
 		global_dirty_limits(&background_thresh, &dirty_thresh);
 		dirty_thresh = hard_dirty_limit(&global_wb_domain, dirty_thresh);

> > 
> > [  345.352536] kworker/u4:0    D ffff88003df7f438 10488     6      2 0x00000000
> > [  345.352536] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
> > [  345.352536]  ffff88003df7f438 ffff88003e5d0380 ffff88003e5d0380 ffff88003e5d8e80
> > [  345.352536]  ffff88003dfb3240 ffff88003df73240 ffff88003df80000 ffff88003df7f470
> > [  345.352536]  ffff88003e5d0380 ffff88003e5d0380 ffff88003df7f828 ffff88003df7f450
> > [  345.352536] Call Trace:
> > [  345.352536]  [<ffffffff818d466c>] schedule+0x3c/0x90
> > [  345.352536]  [<ffffffff818d96a8>] schedule_timeout+0x1d8/0x360
> > [  345.352536]  [<ffffffff81135e40>] ? detach_if_pending+0x1c0/0x1c0
> > [  345.352536]  [<ffffffff811407c3>] ? ktime_get+0xb3/0x150
> > [  345.352536]  [<ffffffff811958cf>] ? __delayacct_blkio_start+0x1f/0x30
> > [  345.352536]  [<ffffffff818d39e4>] io_schedule_timeout+0xa4/0x110
> > [  345.352536]  [<ffffffff8121d886>] congestion_wait+0x86/0x1f0
> > [  345.352536]  [<ffffffff810fdf40>] ? prepare_to_wait_event+0xf0/0xf0
> > [  345.352536]  [<ffffffff812061d4>] throttle_vm_writeout+0x44/0xd0
> > [  345.352536]  [<ffffffff81211533>] shrink_zone_memcg+0x613/0x720
> > [  345.352536]  [<ffffffff81211720>] shrink_zone+0xe0/0x300
> > [  345.352536]  [<ffffffff81211aed>] do_try_to_free_pages+0x1ad/0x450
> > [  345.352536]  [<ffffffff81211e7f>] try_to_free_pages+0xef/0x300
> > [  345.352536]  [<ffffffff811fef19>] __alloc_pages_nodemask+0x879/0x1210
> > [  345.352536]  [<ffffffff810e8080>] ? sched_clock_cpu+0x90/0xc0
> > [  345.352536]  [<ffffffff8125a8d1>] alloc_pages_current+0xa1/0x1f0
> > [  345.352536]  [<ffffffff81265ef5>] ? new_slab+0x3f5/0x6a0
> > [  345.352536]  [<ffffffff81265dd7>] new_slab+0x2d7/0x6a0
> > [  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
> > [  345.352536]  [<ffffffff812678cb>] ___slab_alloc+0x3fb/0x5c0
> > [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> > [  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
> > [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> > [  345.352536]  [<ffffffff81267ae1>] __slab_alloc+0x51/0x90
> > [  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
> > [  345.352536]  [<ffffffff81267d9b>] kmem_cache_alloc+0x27b/0x310
> > [  345.352536]  [<ffffffff811f71bd>] mempool_alloc_slab+0x1d/0x30
> > [  345.352536]  [<ffffffff811f6f11>] mempool_alloc+0x91/0x230
> > [  345.352536]  [<ffffffff8141a02d>] bio_alloc_bioset+0xbd/0x260
> > [  345.352536]  [<ffffffffc02f1a54>] kcryptd_crypt+0x114/0x3b0 [dm_crypt]
> > [  345.352536]  [<ffffffff810cc312>] process_one_work+0x242/0x700
> > [  345.352536]  [<ffffffff810cc28a>] ? process_one_work+0x1ba/0x700
> > [  345.352536]  [<ffffffff810cc81e>] worker_thread+0x4e/0x490
> > [  345.352536]  [<ffffffff810cc7d0>] ? process_one_work+0x700/0x700
> > [  345.352536]  [<ffffffff810d3c01>] kthread+0x101/0x120
> > [  345.352536]  [<ffffffff8110b9f5>] ? trace_hardirqs_on_caller+0xf5/0x1b0
> > [  345.352536]  [<ffffffff818db1af>] ret_from_fork+0x1f/0x40
> > [  345.352536]  [<ffffffff810d3b00>] ? kthread_create_on_node+0x250/0x250
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
