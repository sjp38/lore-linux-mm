Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC32D6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 19:44:14 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id c52so59127592qte.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 16:44:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x63si2738131qka.80.2016.07.12.16.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 16:44:14 -0700 (PDT)
Date: Tue, 12 Jul 2016 19:44:11 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: System freezes after OOM
In-Reply-To: <20160712064905.GA14586@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1607121907160.24806@file01.intranet.prod.int.rdu2.redhat.com>
References: <57837CEE.1010609@redhat.com> <f80dc690-7e71-26b2-59a2-5a1557d26713@redhat.com> <9be09452-de7f-d8be-fd5d-4a80d1cd1ba3@redhat.com> <alpine.LRH.2.02.1607111027080.14327@file01.intranet.prod.int.rdu2.redhat.com>
 <20160712064905.GA14586@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ondrej Kozina <okozina@redhat.com>, Jerome Marchand <jmarchan@redhat.com>, Stanislav Kozina <skozina@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The problem of swapping to dm-crypt is this.

The free memory goes low, kswapd decides that some page should be swapped 
out. However, when you swap to an ecrypted device, writeback of each page 
requires another page to hold the encrypted data. dm-crypt uses mempools 
for all its structures and pages, so that it can make forward progress 
even if there is no memory free. However, the mempool code first allocates 
from general memory allocator and resorts to the mempool only if the 
memory is below limit.

So every attempt to swap out some page allocates another page.

As long as swapping is in progress, the free memory is below the limit 
(because the swapping activity itself consumes any memory over the limit). 
And that triggered the OOM killer prematurely.


On Tue, 12 Jul 2016, Michal Hocko wrote:

> On Mon 11-07-16 11:43:02, Mikulas Patocka wrote:
> [...]
> > The general problem is that the memory allocator does 16 retries to 
> > allocate a page and then triggers the OOM killer (and it doesn't take into 
> > account how much swap space is free or how many dirty pages were really 
> > swapped out while it waited).
> 
> Well, that is not how it works exactly. We retry as long as there is a
> reclaim progress (at least one page freed) back off only if the
> reclaimable memory can exceed watermks which is scaled down in 16
> retries. The overal size of free swap is not really that important if we
> cannot swap out like here due to complete memory reserves depletion:
> https://okozina.fedorapeople.org/bugs/swap_on_dmcrypt/vmlog-1462458369-00000/sample-00011/dmesg:
> [   90.491276] Node 0 DMA free:0kB min:60kB low:72kB high:84kB active_anon:4096kB inactive_anon:4636kB active_file:212kB inactive_file:280kB unevictable:488kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:488kB dirty:276kB writeback:4636kB mapped:476kB shmem:12kB slab_reclaimable:204kB slab_unreclaimable:4700kB kernel_stack:48kB pagetables:120kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:61132 all_unreclaimable? yes
> [   90.491283] lowmem_reserve[]: 0 977 977 977
> [   90.491286] Node 0 DMA32 free:0kB min:3828kB low:4824kB high:5820kB active_anon:423820kB inactive_anon:424916kB active_file:17996kB inactive_file:21800kB unevictable:20724kB isolated(anon):384kB isolated(file):0kB present:1032184kB managed:1001260kB mlocked:20724kB dirty:25236kB writeback:49972kB mapped:23076kB shmem:1364kB slab_reclaimable:13796kB slab_unreclaimable:43008kB kernel_stack:2816kB pagetables:7320kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:5635400 all_unreclaimable? yes
> 
> Look at the amount of free memory. It is completely depleted. So it
> smells like a process which has access to memory reserves has consumed
> all of it. I suspect a __GFP_MEMALLOC resp. PF_MEMALLOC from softirq
> context user which went off the leash.

It is caused by the commit f9054c70d28bc214b2857cf8db8269f4f45a5e23. Prior 
to this commit, mempool allocations set __GFP_NOMEMALLOC, so they never 
exhausted reserved memory. With this commit, mempool allocations drop 
__GFP_NOMEMALLOC, so they can dig deeper (if the process has PF_MEMALLOC, 
they can bypass all limits).

But swapping should proceed even if there is no memory free. There is a 
comment "TODO: this could cause a theoretical memory reclaim deadlock in 
the swap out path." in the function add_to_swap - but apart from that, 
swap should proceed even with no available memory, as long as all the 
drivers in the block layer use mempools.

> > So, it could prematurely trigger OOM killer on any slow swapping device 
> > (including dm-crypt). Michal Hocko reworked the OOM killer in the patch 
> > 0a0337e0d1d134465778a16f5cbea95086e8e9e0, but it still has the flaw that 
> > it triggers OOM if there is plenty of free swap space free.
> > 
> > Michal, would you accept a change to the OOM killer, to prevent it from 
> > triggerring when there is free swap space?
> 
> No this doesn't sound like a proper solution. The current decision
> logic, as explained above relies on the feedback from the reclaim. A
> free swap space doesn't really mean we can make a forward progress.

I'm interested - why would you need to trigger the OOM killer if there is 
free swap space?

The only possibility is that all the memory is filled with unswappable 
kernel pages - but that condition could be detected if there is unusually 
low number of anonymous and cache pages. Besides that - in what situation 
is triggering the OOM killer with free swap desired?

> -- 
> Michal Hocko
> SUSE Labs
> 

The kernel 4.7-rc almost deadlocks in another way. The machine got stuck 
and the following stacktrace was obtained when swapping to dm-crypt.

We can see that dm-crypt does a mempool allocation. But the mempool 
allocation somehow falls into throttle_vm_writeout. There, it waits for 
0.1 seconds. So, as a result, the dm-crypt worker thread ends up 
processing requests at an unusually slow rate of 10 requests per second 
and it results in the machine being stuck (it would proabably recover if 
we waited for extreme amount of time).

[  345.352536] kworker/u4:0    D ffff88003df7f438 10488     6      2 0x00000000
[  345.352536] Workqueue: kcryptd kcryptd_crypt [dm_crypt]
[  345.352536]  ffff88003df7f438 ffff88003e5d0380 ffff88003e5d0380 ffff88003e5d8e80
[  345.352536]  ffff88003dfb3240 ffff88003df73240 ffff88003df80000 ffff88003df7f470
[  345.352536]  ffff88003e5d0380 ffff88003e5d0380 ffff88003df7f828 ffff88003df7f450
[  345.352536] Call Trace:
[  345.352536]  [<ffffffff818d466c>] schedule+0x3c/0x90
[  345.352536]  [<ffffffff818d96a8>] schedule_timeout+0x1d8/0x360
[  345.352536]  [<ffffffff81135e40>] ? detach_if_pending+0x1c0/0x1c0
[  345.352536]  [<ffffffff811407c3>] ? ktime_get+0xb3/0x150
[  345.352536]  [<ffffffff811958cf>] ? __delayacct_blkio_start+0x1f/0x30
[  345.352536]  [<ffffffff818d39e4>] io_schedule_timeout+0xa4/0x110
[  345.352536]  [<ffffffff8121d886>] congestion_wait+0x86/0x1f0
[  345.352536]  [<ffffffff810fdf40>] ? prepare_to_wait_event+0xf0/0xf0
[  345.352536]  [<ffffffff812061d4>] throttle_vm_writeout+0x44/0xd0
[  345.352536]  [<ffffffff81211533>] shrink_zone_memcg+0x613/0x720
[  345.352536]  [<ffffffff81211720>] shrink_zone+0xe0/0x300
[  345.352536]  [<ffffffff81211aed>] do_try_to_free_pages+0x1ad/0x450
[  345.352536]  [<ffffffff81211e7f>] try_to_free_pages+0xef/0x300
[  345.352536]  [<ffffffff811fef19>] __alloc_pages_nodemask+0x879/0x1210
[  345.352536]  [<ffffffff810e8080>] ? sched_clock_cpu+0x90/0xc0
[  345.352536]  [<ffffffff8125a8d1>] alloc_pages_current+0xa1/0x1f0
[  345.352536]  [<ffffffff81265ef5>] ? new_slab+0x3f5/0x6a0
[  345.352536]  [<ffffffff81265dd7>] new_slab+0x2d7/0x6a0
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff812678cb>] ___slab_alloc+0x3fb/0x5c0
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff810e7f87>] ? sched_clock_local+0x17/0x80
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267ae1>] __slab_alloc+0x51/0x90
[  345.352536]  [<ffffffff811f71bd>] ? mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff81267d9b>] kmem_cache_alloc+0x27b/0x310
[  345.352536]  [<ffffffff811f71bd>] mempool_alloc_slab+0x1d/0x30
[  345.352536]  [<ffffffff811f6f11>] mempool_alloc+0x91/0x230
[  345.352536]  [<ffffffff8141a02d>] bio_alloc_bioset+0xbd/0x260
[  345.352536]  [<ffffffffc02f1a54>] kcryptd_crypt+0x114/0x3b0 [dm_crypt]
[  345.352536]  [<ffffffff810cc312>] process_one_work+0x242/0x700
[  345.352536]  [<ffffffff810cc28a>] ? process_one_work+0x1ba/0x700
[  345.352536]  [<ffffffff810cc81e>] worker_thread+0x4e/0x490
[  345.352536]  [<ffffffff810cc7d0>] ? process_one_work+0x700/0x700
[  345.352536]  [<ffffffff810d3c01>] kthread+0x101/0x120
[  345.352536]  [<ffffffff8110b9f5>] ? trace_hardirqs_on_caller+0xf5/0x1b0
[  345.352536]  [<ffffffff818db1af>] ret_from_fork+0x1f/0x40
[  345.352536]  [<ffffffff810d3b00>] ? kthread_create_on_node+0x250/0x250

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
