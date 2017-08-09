Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8098E6B025F
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 02:14:46 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id h70so45266919ioi.14
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 23:14:46 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x135si3642623itx.108.2017.08.08.23.14.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Aug 2017 23:14:44 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170712085431.GD28912@dhcp22.suse.cz>
	<201707122123.CDD21817.FOQSFJtOHOVLFM@I-love.SAKURA.ne.jp>
	<20170712124145.GI28912@dhcp22.suse.cz>
	<201707142130.JJF10142.FHJFOQSOOtMVLF@I-love.SAKURA.ne.jp>
	<20170714124833.GO2618@dhcp22.suse.cz>
In-Reply-To: <20170714124833.GO2618@dhcp22.suse.cz>
Message-Id: <201708091514.IDG64043.MtFLOQHJFFVOSO@I-love.SAKURA.ne.jp>
Date: Wed, 9 Aug 2017 15:14:26 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky.work@gmail.com, pmladek@suse.com

Michal Hocko wrote:
> On Fri 14-07-17 21:30:54, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > As I've said earlier, if there is no other way to make printk work without all
> > > these nasty side effected then I would be OK to add a printk context
> > > specific calls into the oom killer.
> > > 
> > > Removing the rest because this is again getting largely tangent. The
> > > primary problem you are seeing is that we stumble over printk here.
> > > Unless I can see a sound argument this is not the case it doesn't make
> > > any sense to discuss allocator changes.
> > 
> > You are still ignoring my point. I agree that we stumble over printk(), but
> > printk() is nothing but one of locations we stumble.
> 
> I am not ignoring it. You just mix too many things together to have a
> meaningful conversation...
>  
> > Look at schedule_timeout_killable(1) in out_of_memory() which is called with
> > oom_lock still held. I'm reporting that even printk() is offloaded to printk
> > kernel thread, scheduling priority can make schedule_timeout_killable(1) sleep
> > for more than 12 minutes (which is intended to sleep for only one millisecond).
> > (I gave up waiting and pressed SysRq-i. I can't imagine how long it would have
> > continued sleeping inside schedule_timeout_killable(1) with oom_lock held.)
> > 
> > Without cooperation from other allocating threads which failed to hold oom_lock,
> > it is dangerous to keep out_of_memory() preemptible/schedulable context.
> 
> I have already tried to explain that this is something that the whole
> reclaim path suffers from the priority inversions problem because it has
> never been designed to handle that. You are just poking to one
> particular path of the reclaim stack and missing the whole forest for a
> tree. How the hack is this any different from a reclaim path stumbling
> over a lock down inside the filesystem and stalling basically everybody
> from making a reasonable progress? Is this a problem? Of course it is,
> theoretically. In practice not all that much to go and reimplement the
> whole stack. At least I haven't seen any real life reports complaining
> about this.

I'm failing to test your "mm, oom: fix oom_reaper fallouts" patches using
http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp
because it fails to invoke the OOM killer for unknown reason. I analyzed it using
kmallocwd and confirmed that two dozens of concurrent allocating threads is
sufficient for hitting this warn_alloc() v.s. printk() lockup.
Since printk offloading is not yet available, serialization is the the only choice
we can mitigate this problem for now. How long will we have to waste more?

----------
[  645.993827] MemAlloc-Info: stalling=18 dying=0 exiting=0 victim=0 oom_count=29
(...snipped...)
[  645.996694] MemAlloc: vmtoolsd(2221) flags=0x400100 switches=5607 seq=3740 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=7541
[  645.996695] vmtoolsd        R  running task    11960  2221      1 0x00000080
[  645.996699] Call Trace:
[  645.996708]  ? console_unlock+0x373/0x4a0
[  645.996709]  ? vprintk_emit+0x211/0x2f0
[  645.996714]  ? vprintk_emit+0x21a/0x2f0
[  645.996720]  ? vprintk_default+0x1a/0x20
[  645.996722]  ? vprintk_func+0x22/0x60
[  645.996724]  ? printk+0x53/0x6a
[  645.996731]  ? dump_stack_print_info+0xab/0xb0
[  645.996736]  ? dump_stack+0x5e/0x9e
[  645.996739]  ? dump_header+0x9d/0x3fa
[  645.996744]  ? trace_hardirqs_on+0xd/0x10
[  645.996751]  ? oom_kill_process+0x226/0x650
[  645.996757]  ? out_of_memory+0x13d/0x570
[  645.996758]  ? out_of_memory+0x20d/0x570
[  645.996763]  ? __alloc_pages_nodemask+0xbc8/0xed0
[  645.996780]  ? alloc_pages_current+0x65/0xb0
[  645.996784]  ? __page_cache_alloc+0x10b/0x140
[  645.996789]  ? filemap_fault+0x3df/0x6a0
[  645.996790]  ? filemap_fault+0x2ab/0x6a0
[  645.996797]  ? xfs_filemap_fault+0x34/0x50
[  645.996799]  ? __do_fault+0x19/0x120
[  645.996803]  ? __handle_mm_fault+0xa99/0x1260
[  645.996814]  ? handle_mm_fault+0x1b2/0x350
[  645.996816]  ? handle_mm_fault+0x46/0x350
[  645.996820]  ? __do_page_fault+0x1da/0x510
[  645.996828]  ? do_page_fault+0x21/0x70
[  645.996832]  ? page_fault+0x22/0x30
(...snipped...)
[  645.998748] MemAlloc-Info: stalling=18 dying=0 exiting=0 victim=0 oom_count=29
(...snipped...)
[ 1472.484590] MemAlloc-Info: stalling=25 dying=0 exiting=0 victim=0 oom_count=29
(...snipped...)
[ 1472.487341] MemAlloc: vmtoolsd(2221) flags=0x400100 switches=5607 seq=3740 gfp=0x14200ca(GFP_HIGHUSER_MOVABLE) order=0 delay=834032
[ 1472.487342] vmtoolsd        R  running task    11960  2221      1 0x00000080
[ 1472.487346] Call Trace:
[ 1472.487353]  ? console_unlock+0x373/0x4a0
[ 1472.487355]  ? vprintk_emit+0x211/0x2f0
[ 1472.487360]  ? vprintk_emit+0x21a/0x2f0
[ 1472.487367]  ? vprintk_default+0x1a/0x20
[ 1472.487369]  ? vprintk_func+0x22/0x60
[ 1472.487370]  ? printk+0x53/0x6a
[ 1472.487377]  ? dump_stack_print_info+0xab/0xb0
[ 1472.487381]  ? dump_stack+0x5e/0x9e
[ 1472.487384]  ? dump_header+0x9d/0x3fa
[ 1472.487389]  ? trace_hardirqs_on+0xd/0x10
[ 1472.487396]  ? oom_kill_process+0x226/0x650
[ 1472.487402]  ? out_of_memory+0x13d/0x570
[ 1472.487403]  ? out_of_memory+0x20d/0x570
[ 1472.487408]  ? __alloc_pages_nodemask+0xbc8/0xed0
[ 1472.487426]  ? alloc_pages_current+0x65/0xb0
[ 1472.487429]  ? __page_cache_alloc+0x10b/0x140
[ 1472.487434]  ? filemap_fault+0x3df/0x6a0
[ 1472.487435]  ? filemap_fault+0x2ab/0x6a0
[ 1472.487441]  ? xfs_filemap_fault+0x34/0x50
[ 1472.487444]  ? __do_fault+0x19/0x120
[ 1472.487447]  ? __handle_mm_fault+0xa99/0x1260
[ 1472.487459]  ? handle_mm_fault+0x1b2/0x350
[ 1472.487460]  ? handle_mm_fault+0x46/0x350
[ 1472.487465]  ? __do_page_fault+0x1da/0x510
[ 1472.487472]  ? do_page_fault+0x21/0x70
[ 1472.487476]  ? page_fault+0x22/0x30
(...snipped...)
[ 1472.489975] MemAlloc-Info: stalling=25 dying=0 exiting=0 victim=0 oom_count=29
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
