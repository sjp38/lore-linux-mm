Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 829096B0005
	for <linux-mm@kvack.org>; Sat, 25 Jun 2016 13:04:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id x68so280194722ioi.0
        for <linux-mm@kvack.org>; Sat, 25 Jun 2016 10:04:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 135si1453659itm.17.2016.06.25.10.04.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 25 Jun 2016 10:04:51 -0700 (PDT)
Subject: Re: 4.6.2 frequent crashes under memory + IO pressure
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160616212641.GA3308@sig21.net>
	<c9c87635-6e00-5ce7-b05a-966011c8fe3f@I-love.SAKURA.ne.jp>
	<20160623091830.GA32535@sig21.net>
	<201606232026.GFJ26539.QVtFFOJOOLHFMS@I-love.SAKURA.ne.jp>
	<20160625155006.GA4166@sig21.net>
In-Reply-To: <20160625155006.GA4166@sig21.net>
Message-Id: <201606260204.BDB48978.FSFFJQHOMLVOtO@I-love.SAKURA.ne.jp>
Date: Sun, 26 Jun 2016 02:04:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js@sig21.net
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

Johannes Stezenbach wrote:
> On Thu, Jun 23, 2016 at 08:26:35PM +0900, Tetsuo Handa wrote:
> > 
> > Since you think you saw OOM messages with the older kernels, I assume that the OOM
> > killer was invoked on your 4.6.2 kernel. The OOM reaper in Linux 4.6 and Linux 4.7
> > will not help if the OOM killed process was between down_write(&mm->mmap_sem) and
> > up_write(&mm->mmap_sem).
> > 
> > I was not able to confirm whether the OOM killed process (I guess it was java)
> > was holding mm->mmap_sem for write, for /proc/sys/kernel/hung_task_warnings
> > dropped to 0 before traces of java threads are printed or console became
> > unusable due to the "delayed: kcryptd_crypt, ..." line. Anyway, I think that
> > kmallocwd will report it.
> > 
> > > > It is sad that we haven't merged kmallocwd which will report
> > > > which memory allocations are stalling
> > > >  ( http://lkml.kernel.org/r/1462630604-23410-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp ).
> > > 
> > > Would you like me to try it?  It wouldn't prevent the hang, though,
> > > just print better debug ouptut to serial console, right?
> > > Or would it OOM kill some process?
> > 
> > Yes, but for bisection purpose, please try commit 78ebc2f7146156f4 without
> > applying kmallocwd. If that commit helps avoiding flood of the allocation
> > failure warnings, we can consider backporting it. If that commit does not
> > help, I think you are reporting a new location which we should not use
> > memory reserves.
> > 
> > kmallocwd will not OOM kill some process. kmallocwd will not prevent the hang.
> > kmallocwd just prints information of threads which are stalling inside memory
> > allocation request.
> 
> First I tried today's git, linux-4.7-rc4-187-g086e3eb, and
> the good news is that the oom killer seems to work very
> well and reliably killed the offending task (java).
> It happened a few times, the AOSP build broke and I restarted
> it until it completed.  E.g.:
> 
> [ 2083.604374] Purging GPU memory, 0 pages freed, 4508 pages still pinned.
> [ 2083.611000] 96 and 0 pages still available in the bound and unbound GPU page lists.
> [ 2083.618815] make invoked oom-killer: gfp_mask=0x27000c0(GFP_KERNEL_ACCOUNT|__GFP_NOTRACK), order=2, oom_score_adj=0
> [ 2083.629257] make cpuset=/ mems_allowed=0
> ...
> [ 2084.688753] Out of memory: Kill process 10431 (java) score 378 or sacrifice child
> [ 2084.696593] Killed process 10431 (java) total-vm:5200964kB, anon-rss:2521764kB, file-rss:0kB, shmem-rss:0kB
> [ 2084.938058] oom_reaper: reaped process 10431 (java), now anon-rss:0kB, file-rss:8kB, shmem-rss:0kB
> 

Good. Your problem does not exist in Linux 4.7 kernels.

> Next I tried 4.6.2 with 78ebc2f7146156f4, then with kmallocwd (needed one manual fixup),
> then both patches.  It still livelocked in all cases, the log spew looked
> a bit different with 78ebc2f7146156f4 applied but still continued
> endlessly.  kmallocwd alone didn't trigger, with both patches
> applied kmallocwd triggered but:
> 
> [  363.815595] MemAlloc-Info: stalling=33 dying=0 exiting=42 victim=0 oom_count=0
> [  363.815601] MemAlloc: kworker/0:0(4) flags=0x4208860 switches=212 seq=1 gfp=0x26012c0(GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY|__GFP_NOTRACK) order=0 delay=17984
> ** 1402 printk messages dropped ** [  363.818816]  [<ffffffff8116d519>] __do_page_cache_readahead+0x144/0x29d
> ** 501 printk messages dropped **
> 
> I'll zip up the logs and send them off-list.

Thank you for testing it.
I found that your 4.6.2 kernel is depleting memory reserves before invoking the OOM
killer. (oom_count=0 in MemAlloc-Info: line says out_of_memory() was never called).

----------
[  483.832644] DMA free:0kB min:32kB low:44kB high:56kB active_anon:704kB inactive_anon:1008kB active_file:0kB inactive_file:0kB unevictable:20kB isolated(anon):0kB isolated(file):0kB present:15984kB managed:15900kB mlocked:20kB dirty:0kB writeback:248kB mapped:24kB shmem:112kB slab_reclaimable:376kB slab_unreclaimable:13456kB kernel_stack:0kB pagetables:52kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:11096 all_unreclaimable? yes
[  483.875261] lowmem_reserve[]: 0 3154 3154 3154
[  483.879818] DMA32 free:0kB min:7168kB low:10396kB high:13624kB active_anon:2427064kB inactive_anon:615444kB active_file:1120kB inactive_file:1152kB unevictable:4532kB isolated(anon):844kB isolated(file):0kB present:3334492kB managed:3241464kB mlocked:4532kB dirty:16kB writeback:139208kB mapped:11328kB shmem:17300kB slab_reclaimable:46672kB slab_unreclaimable:97072kB kernel_stack:5264kB pagetables:16048kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:7533108 all_unreclaimable? no
[  483.926816] lowmem_reserve[]: 0 0 0 0
[  483.930596] DMA: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  483.940528] DMA32: 0*4kB 0*8kB 0*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 0kB
[  483.950633] 40743 total pagecache pages
[  483.954482] 34986 pages in swap cache
[  483.958166] Swap cache stats: add 180805, delete 145819, find 29901/34406
[  483.964950] Free swap  = 3731508kB
[  483.965921] MemAlloc-Info: stalling=36 dying=0 exiting=42 victim=0 oom_count=0
----------

Thus, my assumption that the OOM killer was invoked on your 4.6.2 kernel was wrong.

It seems to me that somebody is using ALLOC_NO_WATERMARKS (with possibly
__GFP_NOWARN), but I don't know how to identify such callers. Maybe print
backtrace from __alloc_pages_slowpath() when ALLOC_NO_WATERMARKS is used?

> 
> 
> Thanks,
> Johannes
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
