Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id EAF966B0256
	for <linux-mm@kvack.org>; Wed, 20 Jan 2016 05:23:31 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id yy13so2596288pab.3
        for <linux-mm@kvack.org>; Wed, 20 Jan 2016 02:23:31 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g25si54309638pfj.135.2016.01.20.02.23.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 20 Jan 2016 02:23:30 -0800 (PST)
Subject: Re: [BUG] oom hangs the system, NMI backtrace shows most CPUs inshrink_slab
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <569D06F8.4040209@redhat.com>
	<569E1010.2070806@I-love.SAKURA.ne.jp>
	<569E5287.4080503@redhat.com>
In-Reply-To: <569E5287.4080503@redhat.com>
Message-Id: <201601201923.DCC48978.FSHLOQtOVJFFOM@I-love.SAKURA.ne.jp>
Date: Wed, 20 Jan 2016 19:23:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jstancek@redhat.com, linux-mm@kvack.org
Cc: ltp@lists.linux.it

Jan Stancek wrote:
> It took slightly longer this time. Here's full console log:
>   http://jan.stancek.eu/tmp/oom_hangs/console.log.2-v4.4-8606-with-memalloc_wc.txt.bz2

Thank you. This time, tasks are unable to make forward progress because
memory used by oom01 (21979) cannot be reclaimed despite there is no longer
OOM victims or dying tasks.

----------
[ 6822.445821] Swap cache stats: add 442518058, delete 442518058, find 382713/717869
[ 6846.196919] Swap cache stats: add 444426248, delete 444419195, find 384554/720831
[ 6846.575207] Out of memory: Kill process 21986 (oom01) score 953 or sacrifice child
[ 6846.583665] Killed process 21979 (oom01) total-vm:31525420kB, anon-rss:14936316kB, file-rss:0kB, shmem-rss:0kB
[ 6904.555880] MemAlloc-Info: 2 stalling task, 0 dying task, 0 victim task.
[ 6904.563387] MemAlloc: oom01(22011) seq=5135 gfp=0x24280ca order=0 delay=10001
[ 6904.571353] MemAlloc: oom01(22013) seq=5101 gfp=0x24280ca order=0 delay=10001
[ 6905.162365] Swap cache stats: add 448028091, delete 448003852, find 386328/724035
[ 6915.195869] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
[ 6929.233835] MemAlloc-Info: 16 stalling task, 0 dying task, 0 victim task.
[ 6942.387848] MemAlloc-Info: 17 stalling task, 0 dying task, 0 victim task.
[ 6953.243802] MemAlloc-Info: 18 stalling task, 0 dying task, 0 victim task.
[ 6964.150790] MemAlloc-Info: 22 stalling task, 0 dying task, 0 victim task.
[ 7117.623703] MemAlloc-Info: 22 stalling task, 0 dying task, 0 victim task.
[ 7128.348659] MemAlloc-Info: 23 stalling task, 0 dying task, 0 victim task.
[ 7215.508583] MemAlloc-Info: 23 stalling task, 0 dying task, 0 victim task.
[ 7216.221140] Swap cache stats: add 448028091, delete 448003852, find 386328/724035
[ 7226.262927] MemAlloc-Info: 24 stalling task, 0 dying task, 0 victim task.
[ 7227.518106] Swap cache stats: add 448028091, delete 448003852, find 386328/724036
[ 7237.551543] MemAlloc-Info: 25 stalling task, 0 dying task, 0 victim task.
[ 8414.846196] Swap cache stats: add 448028091, delete 448003852, find 386328/724036
[ 8424.879423] MemAlloc-Info: 25 stalling task, 0 dying task, 0 victim task.
[ 8425.679183] Swap cache stats: add 448028091, delete 448003852, find 386328/724037
[ 8435.712419] MemAlloc-Info: 26 stalling task, 0 dying task, 0 victim task.
[ 9549.714223] Swap cache stats: add 448028091, delete 448003852, find 386328/724037
[ 9559.747360] MemAlloc-Info: 26 stalling task, 0 dying task, 0 victim task.
[ 9560.546201] Swap cache stats: add 448028091, delete 448003852, find 386328/724038
[ 9570.579371] MemAlloc-Info: 27 stalling task, 0 dying task, 0 victim task.
[ 9648.210276] MemAlloc-Info: 27 stalling task, 0 dying task, 0 victim task.
[ 9649.057129] Swap cache stats: add 448028091, delete 448003852, find 386328/724038
----------

I noticed three strange things.

(1) oom01 (22011 amd 22013) did not declare out of memory.

    0x24280ca is ___GFP_KSWAPD_RECLAIM | ___GFP_DIRECT_RECLAIM | ___GFP_HARDWALL |
    ___GFP_ZERO | ___GFP_FS | ___GFP_IO | ___GFP_MOVABLE | ___GFP_HIGHMEM. Thus, if
    oom01 (22011 amd 22013) declares out of memory, the OOM killer will be invoked.

    This time you did not hit first and second possibility, for 22011 and 22013
    did not declare out of memory. I guess current vmscan logic prevented them
    from declaring out of memory because one of zones was reclaimable.

	/* Any of the zones still reclaimable?  Don't OOM. */
	if (zones_reclaimable)
		return 1;

(Please ignore mlocked: field, for that value is bogus.)
----------
[ 6904.919732] Node 0 DMA free:15860kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
present:15996kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[ 6904.971210] Node 0 DMA32 free:56072kB min:1132kB low:1412kB high:1696kB active_anon:523468kB inactive_anon:524296kB active_file:8kB inactive_file:12kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:1214568kB managed:1117824kB mlocked:707844970119168kB dirty:0kB writeback:0kB mapped:24kB shmem:80kB slab_reclaimable:636kB slab_unreclaimable:4868kB kernel_stack:336kB
pagetables:3776kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 6905.026961] Node 0 Normal free:13836kB min:14428kB low:18032kB high:21640kB active_anon:12764756kB inactive_anon:1161944kB active_file:52kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:14426112kB managed:14145740kB mlocked:8627678764597248kB dirty:0kB writeback:0kB mapped:208kB shmem:144kB slab_reclaimable:27720kB slab_unreclaimable:60416kB
kernel_stack:3408kB pagetables:44436kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:14084 all_unreclaimable? yes

[ 9648.814118] Node 0 DMA free:15860kB min:16kB low:20kB high:24kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB
present:15996kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:32kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB
free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
[ 9648.865599] Node 0 DMA32 free:56072kB min:1132kB low:1412kB high:1696kB active_anon:523468kB inactive_anon:524296kB active_file:8kB inactive_file:12kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:1214568kB managed:1117824kB mlocked:707844970119168kB dirty:0kB writeback:0kB mapped:24kB shmem:80kB slab_reclaimable:636kB slab_unreclaimable:4868kB kernel_stack:336kB
pagetables:3776kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[ 9648.921343] Node 0 Normal free:13260kB min:14428kB low:18032kB high:21640kB active_anon:12764756kB inactive_anon:1161944kB active_file:12kB inactive_file:0kB unevictable:0kB isolated(anon):0kB
isolated(file):0kB present:14426112kB managed:14145740kB mlocked:8627678764597248kB dirty:0kB writeback:0kB mapped:208kB shmem:144kB slab_reclaimable:27720kB slab_unreclaimable:60416kB
kernel_stack:3344kB pagetables:44436kB unstable:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:108547704 all_unreclaimable? yes
----------

(2) free: field of Normal zone remained smaller than min: field.

    After oom01 which was killed at uptime = 6846 terminated, free: field
    should have been recovered because there is no longer OOM victims or
    dying tasks. Something (third possibility) is preventing it.

(3) I/O for swap memory was effectively disabled by uptime = 6904.

    I don't know the reason why the kernel cannot access swap memory.
    To access swap memory, some memory allocation is needed which is
    failing due to free: field of Normal zone smaller than min: field?
    If accessing swap memory depends on workqueue items, are they
    created with WQ_MEM_RECLAIM?

Anyway, a help from MM people is needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
