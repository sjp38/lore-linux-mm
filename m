Received: by rv-out-0506.google.com with SMTP id g37so843565rvb.26
        for <linux-mm@kvack.org>; Mon, 21 Apr 2008 02:25:35 -0700 (PDT)
Message-ID: <c4e36d110804210225j2e3f3d67v277f7231c0ef7fdb@mail.gmail.com>
Date: Mon, 21 Apr 2008 11:25:35 +0200
From: "Zdenek Kabelac" <zdenek.kabelac@gmail.com>
Subject: Re: OOM killer doesn't kill the right task....
In-Reply-To: <20080421172255.C45A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080421070123.GM108924158@sgi.com>
	 <20080421172255.C45A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Chinner <dgc@sgi.com>, lkml <linux-kernel@vger.kernel.org>, xfs-oss <xfs@oss.sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

2008/4/21, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> Hi David
>
>  > Running in a 512MB UML system without swap, XFSQA test 084 reliably
>  > kills the kernel completely as the OOM killer is unable to find a
>  > task to kill. log output is below.
>  >
>  > I don't know when it started failing - ISTR this working just fine
>  > on 2.6.24 kernels.
>
>  Can you reproduce it on non UML box?
>

Hi

I'll add my comments to this discussion.

I'm seeing recently also very strange OOM behavior when I limit memory
in my qemu-kvm.
There are few weird things:

a) - if I call  echo 3>/proc/sys/vm/drop_caches   prior dselect in my
case - the operation normaly proceeds and everything is fine

b) - if the dselect is started and memory is low - either I get this
crash or dselect simple gets killed - even thought obviously the
memory is there and could be used for the task - because when the
caches are dropped it is doable.

Regards
Zdenek

Enjoy my backtrace: (Using latest 2.6.25 Linus-gits)

Mem-info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:   90, btch:  15 usd:  90

CPU    1: hi:   90, btch:  15 usd:  87

Active:33126 inactive:0 dirty:0 writeback:0 unstable:0

 free:732 slab:17423 mapped:0 pagetables:109 bounce:0

DMA free:1052kB min:120kB low:148kB high:180kB active:14880kB
inactive:0kB present:15576kB pages_scanned:29604 all_unreclaimable?
yes

lowmem_reserve[]: 0 238 238 238

DMA32 free:1876kB min:1912kB low:2388kB high:2868kB active:117496kB
inactive:88kB present:243940kB pages_scanned:177406 all_unreclaimable?
no

lowmem_reserve[]: 0 0 0 0

DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 1052kB

DMA32: 32*4kB 3*8kB 3*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB
1*1024kB 0*2048kB 0*4096kB = 1864kB

117 total pagecache pages

Swap cache: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

Free swap:            0kB

66544 pages of RAM

5711 reserved pages

82 pages shared

0 pages swap cached

Out of memory: kill process 2530 (getty) score 26 or a child

Killed process 2530 (getty)

udevd invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=-17

Pid: 507, comm: udevd Not tainted 2.6.25 #55



Call Trace:

 [<ffffffff8108d631>] oom_kill_process+0x91/0x210

 [<ffffffff8108d958>] ? badness+0x168/0x200

 [<ffffffff8108dba5>] out_of_memory+0x1b5/0x200

 [<ffffffff81090e6f>] __alloc_pages+0x3bf/0x3f0

 [<ffffffff81092dce>] __do_page_cache_readahead+0x11e/0x260

 [<ffffffff81092f71>] do_page_cache_readahead+0x61/0x90

 [<ffffffff8108ad42>] filemap_fault+0x372/0x510

 [<ffffffff81099e28>] __do_fault+0x68/0x490

 [<ffffffff8105fd0e>] ? put_lock_stats+0xe/0x30

 [<ffffffff8109bd96>] handle_mm_fault+0x1c6/0x7c0

 [<ffffffff812ef49c>] do_page_fault+0x3fc/0xad0

 [<ffffffff81087b94>] ? call_rcu+0x74/0xb0

 [<ffffffff81087ba2>] ? call_rcu+0x82/0xb0

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff810d1a90>] ? mntput_no_expire+0x20/0x90

 [<ffffffff810b7d39>] ? __fput+0x179/0x1b0

 [<ffffffff812eb931>] ? trace_hardirqs_on_thunk+0x35/0x3a

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff812ecc4d>] error_exit+0x0/0xa9



Mem-info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:   90, btch:  15 usd:  86

CPU    1: hi:   90, btch:  15 usd:  87

Active:33097 inactive:0 dirty:0 writeback:0 unstable:0

 free:725 slab:17432 mapped:1 pagetables:109 bounce:0

DMA free:1052kB min:120kB low:148kB high:180kB active:14848kB
inactive:0kB present:15576kB pages_scanned:29796 all_unreclaimable?
yes

lowmem_reserve[]: 0 238 238 238

DMA32 free:1848kB min:1912kB low:2388kB high:2868kB active:117540kB
inactive:0kB present:243940kB pages_scanned:54533 all_unreclaimable?
no

lowmem_reserve[]: 0 0 0 0

DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 1052kB

DMA32: 30*4kB 4*8kB 3*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB
1*1024kB 0*2048kB 0*4096kB = 1864kB

116 total pagecache pages

Swap cache: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

Free swap:            0kB

66544 pages of RAM

5711 reserved pages

81 pages shared

0 pages swap cached

Out of memory: kill process 2531 (getty) score 26 or a child

Killed process 2531 (getty)

udevd invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=-17

Pid: 2848, comm: udevd Not tainted 2.6.25 #55



Call Trace:

 [<ffffffff8108d631>] oom_kill_process+0x91/0x210

 [<ffffffff8108d958>] ? badness+0x168/0x200

 [<ffffffff8108dba5>] out_of_memory+0x1b5/0x200

 [<ffffffff81090e6f>] __alloc_pages+0x3bf/0x3f0

 [<ffffffff81092dce>] __do_page_cache_readahead+0x11e/0x260

 [<ffffffff81092f71>] do_page_cache_readahead+0x61/0x90

 [<ffffffff8108ad42>] filemap_fault+0x372/0x510

 [<ffffffff81099e28>] __do_fault+0x68/0x490

 [<ffffffff8105fd0e>] ? put_lock_stats+0xe/0x30

 [<ffffffff8109bd96>] handle_mm_fault+0x1c6/0x7c0

 [<ffffffff812ef49c>] do_page_fault+0x3fc/0xad0

 [<ffffffff810b3f3f>] ? kmem_cache_free+0xaf/0x110

 [<ffffffff810ca8fc>] ? d_free+0x6c/0x80

 [<ffffffff810ca94b>] ? d_kill+0x3b/0x60

 [<ffffffff810d1a90>] ? mntput_no_expire+0x20/0x90

 [<ffffffff810b7d39>] ? __fput+0x179/0x1b0

 [<ffffffff812eb931>] ? trace_hardirqs_on_thunk+0x35/0x3a

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff812ecc4d>] error_exit+0x0/0xa9



Mem-info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:   90, btch:  15 usd:  83

CPU    1: hi:   90, btch:  15 usd:  79

Active:33104 inactive:45 dirty:0 writeback:0 unstable:0

 free:728 slab:17406 mapped:0 pagetables:103 bounce:0

DMA free:1052kB min:120kB low:148kB high:180kB active:14864kB
inactive:0kB present:15576kB pages_scanned:30052 all_unreclaimable?
yes

lowmem_reserve[]: 0 238 238 238

DMA32 free:1860kB min:1912kB low:2388kB high:2868kB active:117680kB
inactive:52kB present:243940kB pages_scanned:218359 all_unreclaimable?
yes

lowmem_reserve[]: 0 0 0 0

DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 1052kB

DMA32: 39*4kB 1*8kB 3*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB
1*1024kB 0*2048kB 0*4096kB = 1876kB

119 total pagecache pages

Swap cache: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

Free swap:            0kB

66544 pages of RAM

5711 reserved pages

80 pages shared

0 pages swap cached

Out of memory: kill process 2532 (getty) score 26 or a child

Killed process 2532 (getty)

init invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=0

Pid: 1, comm: init Not tainted 2.6.25 #55



Call Trace:

 [<ffffffff8108d631>] oom_kill_process+0x91/0x210

 [<ffffffff8108d958>] ? badness+0x168/0x200

 [<ffffffff8108dba5>] out_of_memory+0x1b5/0x200

 [<ffffffff81090e6f>] __alloc_pages+0x3bf/0x3f0

 [<ffffffff81092dce>] __do_page_cache_readahead+0x11e/0x260

 [<ffffffff81092f71>] do_page_cache_readahead+0x61/0x90

 [<ffffffff8108ad42>] filemap_fault+0x372/0x510

 [<ffffffff81099e28>] __do_fault+0x68/0x490

 [<ffffffff8105fd0e>] ? put_lock_stats+0xe/0x30

 [<ffffffff8109bd96>] handle_mm_fault+0x1c6/0x7c0

 [<ffffffff812ef49c>] do_page_fault+0x3fc/0xad0

 [<ffffffff812ec2a0>] ? _spin_unlock+0x30/0x60

 [<ffffffff810d1a90>] ? mntput_no_expire+0x20/0x90

 [<ffffffff810bf4ac>] ? path_put+0x2c/0x40

 [<ffffffff810b54fa>] ? sys_faccessat+0x1ba/0x1c0

 [<ffffffff812eb931>] ? trace_hardirqs_on_thunk+0x35/0x3a

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff812ecc4d>] error_exit+0x0/0xa9



Mem-info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:   90, btch:  15 usd:  86

CPU    1: hi:   90, btch:  15 usd:  77

Active:33185 inactive:12 dirty:0 writeback:0 unstable:0

 free:741 slab:17370 mapped:0 pagetables:106 bounce:0

DMA free:1052kB min:120kB low:148kB high:180kB active:14848kB
inactive:0kB present:15576kB pages_scanned:27115 all_unreclaimable?
yes

lowmem_reserve[]: 0 238 238 238

DMA32 free:1912kB min:1912kB low:2388kB high:2868kB active:117940kB
inactive:0kB present:243940kB pages_scanned:222562 all_unreclaimable?
yes

lowmem_reserve[]: 0 0 0 0

DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 1052kB

DMA32: 48*4kB 1*8kB 3*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB
1*1024kB 0*2048kB 0*4096kB = 1912kB

110 total pagecache pages

Swap cache: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

Free swap:            0kB

66544 pages of RAM

5711 reserved pages

129 pages shared

0 pages swap cached

Out of memory: kill process 2533 (getty) score 26 or a child

Killed process 2533 (getty)

udevd invoked oom-killer: gfp_mask=0x1201d2, order=0, oomkilladj=-17

Pid: 2848, comm: udevd Not tainted 2.6.25 #55



Call Trace:

 [<ffffffff8108d631>] oom_kill_process+0x91/0x210

 [<ffffffff8108d958>] ? badness+0x168/0x200

 [<ffffffff8108dba5>] out_of_memory+0x1b5/0x200

 [<ffffffff81090e6f>] __alloc_pages+0x3bf/0x3f0

 [<ffffffff81092dce>] __do_page_cache_readahead+0x11e/0x260

 [<ffffffff81092f71>] do_page_cache_readahead+0x61/0x90

 [<ffffffff8108ad42>] filemap_fault+0x372/0x510

 [<ffffffff81099e28>] __do_fault+0x68/0x490

 [<ffffffff8105fd0e>] ? put_lock_stats+0xe/0x30

 [<ffffffff8109bd96>] handle_mm_fault+0x1c6/0x7c0

 [<ffffffff812ef49c>] do_page_fault+0x3fc/0xad0

 [<ffffffff8105fd0e>] ? put_lock_stats+0xe/0x30

 [<ffffffff812ec245>] ? _spin_unlock_irqrestore+0x65/0x90

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff812ec225>] ? _spin_unlock_irqrestore+0x45/0x90

 [<ffffffff81036d7a>] ? hrtick_set+0x7a/0x130

 [<ffffffff812e8ebd>] ? thread_return+0x9e/0x571

 [<ffffffff810d1a90>] ? mntput_no_expire+0x20/0x90

 [<ffffffff812eb931>] ? trace_hardirqs_on_thunk+0x35/0x3a

 [<ffffffff81061ba1>] ? trace_hardirqs_on+0x131/0x190

 [<ffffffff812ecc4d>] error_exit+0x0/0xa9



Mem-info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:   90, btch:  15 usd:  82

CPU    1: hi:   90, btch:  15 usd:  86

Active:33076 inactive:110 dirty:0 writeback:0 unstable:0

 free:743 slab:17354 mapped:4 pagetables:103 bounce:0

DMA free:1052kB min:120kB low:148kB high:180kB active:14864kB
inactive:0kB present:15576kB pages_scanned:27435 all_unreclaimable?
yes

lowmem_reserve[]: 0 238 238 238

DMA32 free:1884kB min:1912kB low:2388kB high:2868kB active:117568kB
inactive:292kB present:243940kB pages_scanned:101687
all_unreclaimable? no

lowmem_reserve[]: 0 0 0 0

DMA: 1*4kB 1*8kB 1*16kB 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 1*1024kB
0*2048kB 0*4096kB = 1052kB

DMA32: 41*4kB 1*8kB 3*16kB 0*32kB 0*64kB 1*128kB 0*256kB 1*512kB
1*1024kB 0*2048kB 0*4096kB = 1884kB

113 total pagecache pages

Swap cache: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

Free swap:            0kB

66544 pages of RAM

5711 reserved pages

140 pages shared

0 pages swap cached

Out of memory: kill process 2534 (getty) score 26 or a child

Killed process 2534 (getty)

Kernel panic - not syncing: Out of memory and no killable processes...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
