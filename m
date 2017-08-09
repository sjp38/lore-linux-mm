Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B9C26B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 09:02:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id z19so6111124oia.13
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:02:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id q188si2957348oig.470.2017.08.09.06.02.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 09 Aug 2017 06:02:05 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
	<20170712124145.GI28912@dhcp22.suse.cz>
	<201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp>
	<20170714124833.GO2618@dhcp22.suse.cz>
	<201708091514.IDG64043.MtFLOQHJFFVOSO@I-love.SAKURA.ne.jp>
In-Reply-To: <201708091514.IDG64043.MtFLOQHJFFVOSO@I-love.SAKURA.ne.jp>
Message-Id: <201708092201.DJI65113.QJHMOFtFFVOLSO@I-love.SAKURA.ne.jp>
Date: Wed, 9 Aug 2017 22:01:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com, penguin-kernel@I-love.SAKURA.ne.jp

Tetsuo Handa wrote:
> I'm failing to test your "mm, oom: fix oom_reaper fallouts" patches using
> http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp
> because it fails to invoke the OOM killer for unknown reason. I analyzed it using
> kmallocwd and confirmed that two dozens of concurrent allocating threads is
> sufficient for hitting this warn_alloc() v.s. printk() lockup.
> Since printk offloading is not yet available, serialization is the the only choice
> we can mitigate this problem for now. How long will we have to waste more?

Above explanation is not appropriate.

As a part of testing your "mm, oom: fix oom_reaper fallouts" patches, I'm trying
to use various stress patterns including changing number of threads. For some
unknown reason (though it is not caused by your patches), sometimes it takes
too much long time (order of minutes) to invoke the OOM killer despite warn_alloc()
is periodically printed or not printed at all. In order to find out what stage is
taking so long time, I'm using kmallocwd with 1 second timeout, for SysRq-t etc. are
useless for tracking how long threads are waiting at specific location because they
do not have in-flight allocation information while they take many seconds for showing
too much noise (including idle threads simply sleeping). And due to kmallocwd's 1 second
timeout setting (which I want to use for finding out at what stage allocating threads
are waiting for so long), printk() from out_of_memory() with oom_lock held is trapped
by periodical printk() by kmallocwd, and caused lockup.

So, this is not direct warn_alloc() v.s. printk() lockup. But what the kmallocwd
tries to warn is similar to warn_alloc(). I can't automate testing of "mm, oom:
fix oom_reaper fallouts" patches because I sometimes need to use SysRq-f etc. to
unstuck the test.

> 
> ----------
> [  645.993827] MemAlloc-Info: stalling=18 dying=0 exiting=0 victim=0 oom_count=29
> (...snipped...)
> [  645.996694] MemAlloc: vmtoolsd(2221) flags=0x400100 switches=5607 seq=3740 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=7541
> [  645.996695] vmtoolsd        R  running task    11960  2221      1 0x00000080
> [  645.996699] Call Trace:
> [  645.996708]  ? console_unlock+0x373/0x4a0
> [  645.996709]  ? vprintk_emit+0x211/0x2f0
> [  645.996714]  ? vprintk_emit+0x21a/0x2f0
> [  645.996720]  ? vprintk_default+0x1a/0x20
> [  645.996722]  ? vprintk_func+0x22/0x60
> [  645.996724]  ? printk+0x53/0x6a
> [  645.996731]  ? dump_stack_print_info+0xab/0xb0
> [  645.996736]  ? dump_stack+0x5e/0x9e
> [  645.996739]  ? dump_header+0x9d/0x3fa
> [  645.996744]  ? trace_hardirqs_on+0xd/0x10
> [  645.996751]  ? oom_kill_process+0x226/0x650
> [  645.996757]  ? out_of_memory+0x13d/0x570
> [  645.996758]  ? out_of_memory+0x20d/0x570
> [  645.996763]  ? __alloc_pages_nodemask+0xbc8/0xed0
> [  645.996780]  ? alloc_pages_current+0x65/0xb0
> [  645.996784]  ? __page_cache_alloc+0x10b/0x140
> [  645.996789]  ? filemap_fault+0x3df/0x6a0
> [  645.996790]  ? filemap_fault+0x2ab/0x6a0
> [  645.996797]  ? xfs_filemap_fault+0x34/0x50
> [  645.996799]  ? __do_fault+0x19/0x120
> [  645.996803]  ? __handle_mm_fault+0xa99/0x1260
> [  645.996814]  ? handle_mm_fault+0x1b2/0x350
> [  645.996816]  ? handle_mm_fault+0x46/0x350
> [  645.996820]  ? __do_page_fault+0x1da/0x510
> [  645.996828]  ? do_page_fault+0x21/0x70
> [  645.996832]  ? page_fault+0x22/0x30
> (...snipped...)
> [  645.998748] MemAlloc-Info: stalling=18 dying=0 exiting=0 victim=0 oom_count=29
> (...snipped...)
> [ 1472.484590] MemAlloc-Info: stalling=25 dying=0 exiting=0 victim=0 oom_count=29
> (...snipped...)
> [ 1472.487341] MemAlloc: vmtoolsd(2221) flags=0x400100 switches=5607 seq=3740 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=834032
> [ 1472.487342] vmtoolsd        R  running task    11960  2221      1 0x00000080
> [ 1472.487346] Call Trace:
> [ 1472.487353]  ? console_unlock+0x373/0x4a0
> [ 1472.487355]  ? vprintk_emit+0x211/0x2f0
> [ 1472.487360]  ? vprintk_emit+0x21a/0x2f0
> [ 1472.487367]  ? vprintk_default+0x1a/0x20
> [ 1472.487369]  ? vprintk_func+0x22/0x60
> [ 1472.487370]  ? printk+0x53/0x6a
> [ 1472.487377]  ? dump_stack_print_info+0xab/0xb0
> [ 1472.487381]  ? dump_stack+0x5e/0x9e
> [ 1472.487384]  ? dump_header+0x9d/0x3fa
> [ 1472.487389]  ? trace_hardirqs_on+0xd/0x10
> [ 1472.487396]  ? oom_kill_process+0x226/0x650
> [ 1472.487402]  ? out_of_memory+0x13d/0x570
> [ 1472.487403]  ? out_of_memory+0x20d/0x570
> [ 1472.487408]  ? __alloc_pages_nodemask+0xbc8/0xed0
> [ 1472.487426]  ? alloc_pages_current+0x65/0xb0
> [ 1472.487429]  ? __page_cache_alloc+0x10b/0x140
> [ 1472.487434]  ? filemap_fault+0x3df/0x6a0
> [ 1472.487435]  ? filemap_fault+0x2ab/0x6a0
> [ 1472.487441]  ? xfs_filemap_fault+0x34/0x50
> [ 1472.487444]  ? __do_fault+0x19/0x120
> [ 1472.487447]  ? __handle_mm_fault+0xa99/0x1260
> [ 1472.487459]  ? handle_mm_fault+0x1b2/0x350
> [ 1472.487460]  ? handle_mm_fault+0x46/0x350
> [ 1472.487465]  ? __do_page_fault+0x1da/0x510
> [ 1472.487472]  ? do_page_fault+0x21/0x70
> [ 1472.487476]  ? page_fault+0x22/0x30
> (...snipped...)
> [ 1472.489975] MemAlloc-Info: stalling=25 dying=0 exiting=0 victim=0 oom_count=29
> ----------
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
