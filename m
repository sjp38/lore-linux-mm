Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 250C16B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 05:47:35 -0400 (EDT)
Received: by qyk34 with SMTP id 34so68299qyk.14
        for <linux-mm@kvack.org>; Thu, 29 Jul 2010 02:47:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <AANLkTi=fk8B-TnC6m3AoLT7k_G239rMaQA1COwHLxwRM@mail.gmail.com>
References: <20100727200804.2F40.A69D9226@jp.fujitsu.com> <AANLkTin47_htYK8eV-6C4QkRK_U__qYeWX16Ly=YK-0w@mail.gmail.com>
	<20100728135850.7A92.A69D9226@jp.fujitsu.com> <AANLkTi=fk8B-TnC6m3AoLT7k_G239rMaQA1COwHLxwRM@mail.gmail.com>
From: dave b <db.pub.mail@gmail.com>
Date: Thu, 29 Jul 2010 19:47:13 +1000
Message-ID: <AANLkTikq=v_7dbW1Z+LUbTKmnezKT0cd8ZTErwP1X0C+@mail.gmail.com>
Subject: Re: PROBLEM: oom killer and swap weirdness on 2.6.3* kernels
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 28 July 2010 17:14, dave b <db.pub.mail@gmail.com> wrote:
> On 28 July 2010 15:06, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> On 27 July 2010 21:14, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> >> On 27 July 2010 18:09, dave b <db.pub.mail@gmail.com> wrote:
>>> >> > On 27 July 2010 16:09, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
>>> >> >>> > Do you mean the issue will be gone if disabling intel graphics?
>>> >> >>> It may be a general issue or it could just be specific :)
>>> >> >
>>> >> > I will try with the latest ubuntu and report how that goes (that will
>>> >> > be using fairly new xorg etc.) it is likely to be hidden issue just
>>> >> > with the intel graphics driver. However, my concern is that it isn't -
>>> >> > and it is about how shared graphics memory is handled :)
>>> >>
>>> >>
>>> >> Ok my desktop still stalled and no oom killer was invoked when I added
>>> >> swap to a live-cd of 10.04 amd64.
>>> >>
>>> >> *Without* *swap* *on* - the oom killer was invoked - here is a copy of it.
>>> >
>>> > This stack seems similar following bug. can you please try to disable intel graphics
>>> > driver?
>>> >
>>> > https://bugzilla.kernel.org/show_bug.cgi?id=14933
>>>
>>> Ok I am not sure how to do that :)
>>> I could revert the patch and see if it 'fixes' this :)
>>
>> Oops, no, revert is not good action. the patch is correct.
>> probably my explanation was not clear. sorry.
>>
>> I did hope to disable 'driver' (i.e. using vga), not disable the patch.
>
> Oh you mean in xorg, I will also blacklist the module. Sure that patch
> might not it but in 2.6.26 the problem isn't there :)

Ok I re-tested with 2.6.26 and 2.6.34.1
So I will describe what happens below:

2.6.26 - with xorg running
"Given I have a test file called a.out
 And I can see Xorg
 And I am using 2.6.26
 And I have swap on
 When I run it I run a.out
 Then I see the system freeze up slightly
 And the hard drive churns( and the cpu is doing something as the
large fan kicks)
 And after a while the system unfreezes"

2.6.26 - from single mode - before xorg starts and i915 is *not* loaded.
"Given I have a test file called a.out
 And I cannot see Xorg
 And I am using 2.6.26
 And I have swap on
 When I run it I run a.out
 Then I see the system freeze up
 And the system fan doesn't spin any faster
 And the system just sits idle"

2.6.34.1
With and without xorg - WITH spam on the same behaviour as in the
2.6.26 kernel appears (when xorg is not loaded).

OOM attached from the 2.6.26 kernel when I used magic keys to invoke
the oom killer :) (this was on the 2.6.26 kernel - before i915 had
loaded and in single mode).

[  280.323899] SysRq : Manual OOM execution
[  280.324009] events/0 invoked oom-killer: gfp_mask=0xd0, order=0, oomkilladj=0
[  280.324056] Pid: 9, comm: events/0 Not tainted 2.6.26-2-amd64 #1
[  280.324098]
[  280.324099] Call Trace:
[  280.324200]  [<ffffffff8027388c>] oom_kill_process+0x57/0x1dc
[  280.324247]  [<ffffffff8023b49d>] __capable+0x9/0x1c
[  280.324290]  [<ffffffff80273bb7>] badness+0x188/0x1c7
[  280.324341]  [<ffffffff80273deb>] out_of_memory+0x1f5/0x28e
[  280.324396]  [<ffffffff8037824c>] moom_callback+0x0/0x1a
[  280.324449]  [<ffffffff80243070>] run_workqueue+0x82/0x111
[  280.324497]  [<ffffffff8024393d>] worker_thread+0xd5/0xe0
[  280.324543]  [<ffffffff80246171>] autoremove_wake_function+0x0/0x2e
[  280.324596]  [<ffffffff80243868>] worker_thread+0x0/0xe0
[  280.324637]  [<ffffffff8024604b>] kthread+0x47/0x74
[  280.324678]  [<ffffffff802300ed>] schedule_tail+0x27/0x5c
[  280.326721]  [<ffffffff8020cf38>] child_rip+0xa/0x12
[  280.326788]  [<ffffffff80246004>] kthread+0x0/0x74
[  280.326831]  [<ffffffff8020cf2e>] child_rip+0x0/0x12
[  280.326877]
[  280.326911] Mem-info:
[  280.326948] Node 0 DMA per-cpu:
[  280.327010] CPU    0: hi:    0, btch:   1 usd:   0
[  280.327050] CPU    1: hi:    0, btch:   1 usd:   0
[  280.327090] Node 0 DMA32 per-cpu:
[  280.327151] CPU    0: hi:  186, btch:  31 usd: 139
[  280.327192] CPU    1: hi:  186, btch:  31 usd: 175
[  280.327234] Active:31 inactive:491089 dirty:0 writeback:23480 unstable:0
[  280.327235]  free:3005 slab:7514 mapped:1 pagetables:1063 bounce:0
[  280.327318] Node 0 DMA free:7880kB min:28kB low:32kB high:40kB
active:0kB inactive:3620kB present:10788kB pages_scanned:16863
all_unreclaimable? yes
[  280.327404] lowmem_reserve[]: 0 1971 1971 1971
[  280.327553] Node 0 DMA32 free:4140kB min:5664kB low:7080kB
high:8496kB active:124kB inactive:1960736kB present:2019172kB
pages_scanned:782860 all_unreclaimable? no
[  280.327651] lowmem_reserve[]: 0 0 0 0
[  280.327686] Node 0 DMA: 4*4kB 3*8kB 2*16kB 4*32kB 2*64kB 1*128kB
3*256kB 3*512kB 1*1024kB 0*2048kB 1*4096kB = 7880kB
[  280.327686] Node 0 DMA32: 477*4kB 7*8kB 0*16kB 2*32kB 3*64kB
1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4140kB
[  280.327686] 491299 total pagecache pages
[  280.327686] Swap cache: add 495985, delete 4762, find 0/1
[  280.327686] Free swap  = 3963444kB
[  280.327686] Total swap = 5947384kB
[  280.335694] 515887 pages of RAM
[  280.335694] 8379 reserved pages
[  280.335694] 83 pages shared
[  280.335694] 491223 pages swap cached
[  280.335694] Out of memory: kill process 2842 (a.out) score 494723 or a child
[  280.335694] Killed process 2842 (a.out)
[  283.864479] SysRq : Manual OOM execution



And this is from 2.6.26 when xorg is running:

[  325.828622] [drm] Initialized i915 1.6.0 20060119 on minor 0
[  575.537309] hald invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[  575.537319] Pid: 3183, comm: hald Not tainted 2.6.26-2-amd64 #1
[  575.537323]
[  575.537324] Call Trace:
[  575.537362]  [<ffffffff8027388c>] oom_kill_process+0x57/0x1dc
[  575.537374]  [<ffffffff8023b49d>] __capable+0x9/0x1c
[  575.537383]  [<ffffffff80273bb7>] badness+0x188/0x1c7
[  575.537406]  [<ffffffff80273deb>] out_of_memory+0x1f5/0x28e
[  575.537444]  [<ffffffff80276b3c>] __alloc_pages_internal+0x31d/0x3bf
[  575.537494]  [<ffffffff802787f2>] __do_page_cache_readahead+0x79/0x183
[  575.537531]  [<ffffffff802730a1>] filemap_fault+0x15d/0x33c
[  575.537570]  [<ffffffff8027e620>] __do_fault+0x50/0x3e6
[  575.537623]  [<ffffffff80281983>] handle_mm_fault+0x3f4/0x867
[  575.537654]  [<ffffffff80248b56>] hrtimer_start+0x112/0x134
[  575.537664]  [<ffffffff80229020>] hrtick_start_fair+0xfb/0x144
[  575.537700]  [<ffffffff80221fbc>] do_page_fault+0x5d8/0x9c8
[  575.537715]  [<ffffffff8042916f>] thread_return+0x6b/0xac
[  575.537755]  [<ffffffff8042a869>] error_exit+0x0/0x60
[  575.537815]
[  575.537818] Mem-info:
[  575.537821] Node 0 DMA per-cpu:
[  575.537826] CPU    0: hi:    0, btch:   1 usd:   0
[  575.537830] CPU    1: hi:    0, btch:   1 usd:   0
[  575.537833] Node 0 DMA32 per-cpu:
[  575.537837] CPU    0: hi:  186, btch:  31 usd: 171
[  575.537841] CPU    1: hi:  186, btch:  31 usd: 134
[  575.537847] Active:227811 inactive:228679 dirty:0 writeback:0 unstable:0
[  575.537849]  free:3352 slab:4828 mapped:620 pagetables:7858 bounce:0
[  575.537853] Node 0 DMA free:7900kB min:28kB low:32kB high:40kB
active:1884kB inactive:1732kB present:10788kB pages_scanned:17985
all_unreclaimable? no
[  575.537861] lowmem_reserve[]: 0 1971 1971 1971
[  575.537868] Node 0 DMA32 free:5508kB min:5664kB low:7080kB
high:8496kB active:909360kB inactive:912984kB present:2019172kB
pages_scanned:4362542 all_unreclaimable? yes
[  575.537876] lowmem_reserve[]: 0 0 0 0
[  575.537883] Node 0 DMA: 15*4kB 14*8kB 9*16kB 3*32kB 5*64kB 2*128kB
3*256kB 2*512kB 1*1024kB 0*2048kB 1*4096kB = 7900kB
[  575.537902] Node 0 DMA32: 113*4kB 34*8kB 25*16kB 11*32kB 1*64kB
1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 5508kB
[  575.537921] 697 total pagecache pages
[  575.537925] Swap cache: add 1990647, delete 1990647, find 16681/17672
[  575.537928] Free swap  = 0kB
[  575.537931] Total swap = 5947384kB
[  575.551393] 515887 pages of RAM
[  575.551400] 8380 reserved pages
[  575.551402] 40837 pages shared
[  575.551405] 0 pages swap cached
[  575.551410] Out of memory: kill process 3956 (a.out) score 1888511 or a child
[  575.551439] Killed process 3956 (a.out)
[  575.623722] hald invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0
[  575.623731] Pid: 3183, comm: hald Not tainted 2.6.26-2-amd64 #1
[  575.623735]
[  575.623736] Call Trace:
[  575.623772]  [<ffffffff8027388c>] oom_kill_process+0x57/0x1dc
[  575.623783]  [<ffffffff8023b49d>] __capable+0x9/0x1c
[  575.623791]  [<ffffffff80273bb7>] badness+0x188/0x1c7
[  575.623809]  [<ffffffff80273deb>] out_of_memory+0x1f5/0x28e
[  575.623846]  [<ffffffff80276b3c>] __alloc_pages_internal+0x31d/0x3bf
[  575.623894]  [<ffffffff802787f2>] __do_page_cache_readahead+0x79/0x183
[  575.623930]  [<ffffffff802730a1>] filemap_fault+0x15d/0x33c
[  575.623966]  [<ffffffff8027e620>] __do_fault+0x50/0x3e6
[  575.624017]  [<ffffffff80281983>] handle_mm_fault+0x3f4/0x867
[  575.624046]  [<ffffffff80248b56>] hrtimer_start+0x112/0x134
[  575.624055]  [<ffffffff80229020>] hrtick_start_fair+0xfb/0x144
[  575.624088]  [<ffffffff80221fbc>] do_page_fault+0x5d8/0x9c8
[  575.624101]  [<ffffffff8042916f>] thread_return+0x6b/0xac
[  575.624139]  [<ffffffff8042a869>] error_exit+0x0/0x60
[  575.624198]
[  575.624201] Mem-info:
[  575.624204] Node 0 DMA per-cpu:
[  575.624208] CPU    0: hi:    0, btch:   1 usd:   0
[  575.624212] CPU    1: hi:    0, btch:   1 usd:   0
[  575.624215] Node 0 DMA32 per-cpu:
[  575.624219] CPU    0: hi:  186, btch:  31 usd: 153
[  575.624222] CPU    1: hi:  186, btch:  31 usd: 134
[  575.624228] Active:228889 inactive:227627 dirty:0 writeback:310 unstable:0
[  575.624230]  free:3352 slab:4828 mapped:620 pagetables:7858 bounce:0
[  575.624234] Node 0 DMA free:7900kB min:28kB low:32kB high:40kB
active:1880kB inactive:1720kB present:10788kB pages_scanned:18498
all_unreclaimable? yes
[  575.624241] lowmem_reserve[]: 0 1971 1971 1971
[  575.624248] Node 0 DMA32 free:5508kB min:5664kB low:7080kB
high:8496kB active:913676kB inactive:908788kB present:2019172kB
pages_scanned:4479719 all_unreclaimable? yes
[  575.624256] lowmem_reserve[]: 0 0 0 0
[  575.624262] Node 0 DMA: 15*4kB 14*8kB 9*16kB 3*32kB 5*64kB 2*128kB
3*256kB 2*512kB 1*1024kB 0*2048kB 1*4096kB = 7900kB
[  575.624280] Node 0 DMA32: 113*4kB 34*8kB 25*16kB 11*32kB 1*64kB
1*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 5508kB
[  575.624297] 1007 total pagecache pages
[  575.624301] Swap cache: add 1990950, delete 1990647, find 16681/17673
[  575.624304] Free swap  = 6660kB
[  575.624306] Total swap = 5947384kB
[  575.636736] 515887 pages of RAM
[  575.636736] 8380 reserved pages
[  575.636736] 40742 pages shared
[  575.636736] 303 pages swap cached
[  575.636736] Out of memory: kill process 3500 (x-session-manag)
score 410763 or a child
[  575.636736] Killed process 3568 (seahorse-agent)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
