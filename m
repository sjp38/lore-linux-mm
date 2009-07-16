Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5C9C56B009B
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:15:24 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090716133454.GA20550@localhost>
References: <20090716133454.GA20550@localhost>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
Date: Thu, 16 Jul 2009 17:15:08 +0100
Message-ID: <4987.1247760908@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: dhowells@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Wu Fengguang <fengguang.wu@intel.com> wrote:

> It can greatly (and correctly) increase the slab scan rate under high memory
> pressure (when most file pages have been reclaimed and swap is full/absent),
> thus avoid possible false OOM kills.

I applied this to my test machine's kernel and rebooted.  It hit the OOM
killer a few seconds after starting msgctl11 .  Furthermore, it was not then
responsive to SysRq+b or anything else and had to have the magic button
pushed.

I then rebooted and ran it again, and that time it ran through one complete
iteration of the test and hit the oom killer on the second run.  That time the
box survived and was usable afterwards.  Running top afterwards, I see:

top - 17:12:19 up 4 min,  1 user,  load average: 484.34, 372.52, 151.31
Tasks:  66 total,   1 running,  65 sleeping,   0 stopped,   0 zombie
Cpu(s):  0.0%us,  0.2%sy,  0.0%ni, 99.8%id,  0.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1000604k total,    69800k used,   930804k free,      536k buffers
Swap:        0k total,        0k used,        0k free,     6408k cached

I then ran msgctl11 again, and the box became unusable, though it would accept
SysRq keys.

I've attached all three OOM reports below.  The first failed on an order 1
allocation, the second and third on order 0.

David
---
modprobe: FATAL: Could not load /lib/modules/2.6.31-rc3-cachefs/modules.dep: No such file or directory

msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 3932, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #188
Call Trace:
 [<ffffffff810728a6>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff810749b1>] ? drain_local_pages+0x0/0x13
 [<ffffffff81072b6d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072bee>] ? out_of_memory+0x6a/0x94
 [<ffffffff810752d6>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff81091de3>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff81077ca0>] ? put_page+0x2a/0xf2
 [<ffffffff81031485>] ? copy_process+0x95/0x112b
 [<ffffffff810923c1>] ? kmem_cache_alloc+0x83/0xc5
 [<ffffffff81031485>] ? copy_process+0x95/0x112b
 [<ffffffff8108292a>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff8103265a>] ? do_fork+0x13f/0x2ba
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
 [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:  32
Active_anon:73735 active_file:6 inactive_anon:714
 inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
 free:2039 slab:38152 mapped:450 pagetables:61310 bounce:0
DMA free:3916kB min:60kB low:72kB high:88kB active_anon:3076kB inactive_anon:128kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4240kB min:3948kB low:4932kB high:5920kB active_anon:291964kB inactive_anon:2728kB active_file:24kB inactive_file:0kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 3*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3916kB
DMA32: 473*4kB 26*8kB 6*16kB 0*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4116kB
1044 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
241938 pages shared
219222 pages non-shared
Out of memory: kill process 2760 (msgctl11) score 138725 or a child
Killed process 2766 (msgctl11)
---

msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 1178, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #188
Call Trace:
 [<ffffffff810728a6>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072b6d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072bee>] ? out_of_memory+0x6a/0x94
 [<ffffffff810752d6>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff810810ac>] ? do_wp_page+0x2c6/0x5f5
 [<ffffffff8108292a>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812e23ff>] ? page_fault+0x1f/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd: 179
CPU    1: hi:  186, btch:  31 usd: 122
Active_anon:78442 active_file:0 inactive_anon:1343
 inactive_file:15 unevictable:0 dirty:0 writeback:0 unstable:0
 free:1989 slab:38702 mapped:167 pagetables:62645 bounce:0
DMA free:3932kB min:60kB low:72kB high:88kB active_anon:3328kB inactive_anon:128kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4024kB min:3948kB low:4932kB high:5920kB active_anon:310440kB inactive_anon:5244kB active_file:0kB inactive_file:60kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 12*4kB 0*8kB 1*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3936kB
DMA32: 474*4kB 21*8kB 3*16kB 0*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4032kB
297 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
250638 pages shared
220085 pages non-shared
Out of memory: kill process 20339 (msgctl11) score 93860 or a child
Killed process 28347 (msgctl11)
---

msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0

msgctl11 cpuset=/ mems_allowed=0

Pid: 14055, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #188

Call Trace:

 [<ffffffff810728a6>] ? oom_kill_process.clone.0+0xa9/0x245

 [<ffffffff81072b6d>] ? __out_of_memory+0x12b/0x142

 [<ffffffff81072bee>] ? out_of_memory+0x6a/0x94

 [<ffffffff810752d6>] ? __alloc_pages_nodemask+0x42b/0x517

 [<ffffffff810810ac>] ? do_wp_page+0x2c6/0x5f5

 [<ffffffff8108292a>] ? handle_mm_fault+0x5dd/0x62f

 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d

 [<ffffffff812e23ff>] ? page_fault+0x1f/0x30

Mem-Info:

DMA per-cpu:

CPU    0: hi:    0, btch:   1 usd:   0

CPU    1: hi:    0, btch:   1 usd:   0

DMA32 per-cpu:

CPU    0: hi:  186, btch:  31 usd:  35

CPU    1: hi:  186, btch:  31 usd: 159

Active_anon:80514 active_file:28 inactive_anon:2010

 inactive_file:29 unevictable:0 dirty:0 writeback:0 unstable:0

 free:1951 slab:37559 mapped:144 pagetables:63890 bounce:0

DMA free:3924kB min:60kB low:72kB high:88kB active_anon:3440kB inactive_anon:128kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? yes

lowmem_reserve[]: 0 968 968 968

DMA32 free:3880kB min:3948kB low:4932kB high:5920kB active_anon:318616kB inactive_anon:7912kB active_file:112kB inactive_file:116kB unevictable:0kB present:992032kB pages_scanned:384 all_unreclaimable? yes

lowmem_reserve[]: 0 0 0 0

DMA: 2*4kB 2*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3928kB

DMA32: 20*4kB 21*8kB 37*16kB 35*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 3880kB

232 total pagecache pages

0 pages in swap cache

Swap cache stats: add 0, delete 0, find 0/0

Free swap  = 0kB

Total swap = 0kB

255744 pages RAM

5593 pages reserved

238771 pages shared

223138 pages non-shared

Out of memory: kill process 5137 (msgctl11) score 172673 or a child

Killed process 5709 (msgctl11)

SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
