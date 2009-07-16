Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0E55C6B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 13:11:52 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <4A5F5454.8070300@redhat.com>
References: <4A5F5454.8070300@redhat.com> <20090716133454.GA20550@localhost> <4987.1247760908@redhat.com>
Subject: Re: [PATCH] mm: count only reclaimable lru pages
Date: Thu, 16 Jul 2009 18:11:26 +0100
Message-ID: <23396.1247764286@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: dhowells@redhat.com, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Rik van Riel <riel@redhat.com> wrote:

> It's part of a series of patches, including the three posted by Kosaki-san
> last night (to track the number of isolated pages) and the patch I posted
> last night (to throttle reclaim when too many pages are isolated).

Okay; Rik gave me a tarball of those patches, which I applied and re-ran the
test.  The first run of msgctl11 produced lots of:

	[root@andromeda ltp]# while ./testcases/bin/msgctl11; do :; done
	msgctl11    0  INFO  :  Using upto 16347 pids
	msgctl11    0  WARN  :  Fork failure in first child of child group 1918
	msgctl11    1  FAIL  :  Child exit status = 4
	msgctl11    0  WARN  :  Fork failure in first child of child group 1890
	msgctl11    0  WARN  :  Fork failure in first child of child group 1886
	msgctl11    0  WARN  :  Fork failure in first child of child group 1851
	[root@andromeda ltp]# msgctl11    0  WARN  :  Fork failure in first child of child group 1936
	msgctl11    0  WARN  :  Fork failure in first child of child group 1879
	msgctl11    0  WARN  :  Fork failure in first child of child group 1882
	msgctl11    0  WARN  :  Fork failure in first child of child group 1103

and the overseer process died without cleaning up all the remaining children
and grandchildren, but the OOM killer didn't put in an appearance.

Once the remaining msgctl11 processes had exited and the system had come back
to normal responsiveness, I ran the test again.  *This* time, after dumping a
load of Fork failure messages on stdout, the OOM killer took a hand, and then
the machine became unusable (though SysRq still works and it's still pingable).

The OOM killer was invoked four times.  The first for an order-1 allocation
and the rest for order-0.

David
---
msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 20789, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #189
Call Trace:
 [<ffffffff81072956>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072c1d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072c9e>] ? out_of_memory+0x6a/0x94
 [<ffffffff8107568b>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff810922d3>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff8107027f>] ? find_get_page+0x1a/0x72
 [<ffffffff810314fa>] ? copy_process+0x95/0x1138
 [<ffffffff810928b1>] ? kmem_cache_alloc+0x83/0xc5
 [<ffffffff810314fa>] ? copy_process+0x95/0x1138
 [<ffffffff81082af6>] ? handle_mm_fault+0x2b9/0x62f
 [<ffffffff810326dc>] ? do_fork+0x13f/0x2ba
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
 [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd: 162
Active_anon:74111 inactive_anon:4831 isolated_anon:0
 active_file:10 inactive_file:42 isolated_file:47
 unevictable:0 dirty:0 writeback:0 unstable:0 buffer:23
 free:2159 slab:36718 mapped:30 shmem:15 pagetables:61578 bounce:0
DMA free:3920kB min:60kB low:72kB high:88kB active_anon:3424kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15364kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:1524kB kernel_stack:888kB pagetables:3076kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4716kB min:3948kB low:4932kB high:5920kB active_anon:293020kB inactive_anon:19324kB active_file:40kB inactive_file:192kB unevictable:0kB isolated(anon):0kB isolated(file):128kB present:992032kB mlocked:0kB dirty:0kB writeback:0kB mapped:120kB shmem:60kB slab_reclaimable:3900kB slab_unreclaimable:141448kB kernel_stack:61080kB pagetables:243236kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:128 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3936kB
DMA32: 511*4kB 88*8kB 1*16kB 1*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4716kB
91 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
166622 pages shared
224346 pages non-shared
Out of memory: kill process 18698 (msgctl11) score 173957 or a child
Killed process 19153 (msgctl11)
msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 20258, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #189
Call Trace:
 [<ffffffff81072956>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072c1d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072c9e>] ? out_of_memory+0x6a/0x94
 [<ffffffff8107568b>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff8108159c>] ? do_wp_page+0x2c6/0x5f5
 [<ffffffff81029da2>] ? update_curr+0x53/0xdf
 [<ffffffff81082e1a>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81032794>] ? do_fork+0x1f7/0x2ba
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812e29cf>] ? page_fault+0x1f/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  38
CPU    1: hi:  186, btch:  31 usd:  53
Active_anon:73400 inactive_anon:5539 isolated_anon:79
 active_file:3 inactive_file:71 isolated_file:73
 unevictable:0 dirty:0 writeback:0 unstable:0 buffer:18
 free:2104 slab:36735 mapped:34 shmem:15 pagetables:61591 bounce:0
DMA free:3936kB min:60kB low:72kB high:88kB active_anon:3420kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15364kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:1524kB kernel_stack:888kB pagetables:3068kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4108kB min:3948kB low:4932kB high:5920kB active_anon:290180kB inactive_anon:22280kB active_file:112kB inactive_file:308kB unevictable:0kB isolated(anon):288kB isolated(file):384kB present:992032kB mlocked:0kB dirty:0kB writeback:0kB mapped:136kB shmem:60kB slab_reclaimable:3896kB slab_unreclaimable:141520kB kernel_stack:61072kB pagetables:243296kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 0*8kB 0*16kB 1*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3936kB
DMA32: 411*4kB 62*8kB 1*16kB 1*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4108kB
166 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
151184 pages shared
224445 pages non-shared
Out of memory: kill process 18698 (msgctl11) score 173866 or a child
Killed process 19155 (msgctl11)
msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 21138, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #189
Call Trace:
 [<ffffffff81072956>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072c1d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072c9e>] ? out_of_memory+0x6a/0x94
 [<ffffffff8107568b>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff8108159c>] ? do_wp_page+0x2c6/0x5f5
 [<ffffffff8102f581>] ? try_to_wake_up+0x1d3/0x1e5
 [<ffffffff81082e1a>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812e29cf>] ? page_fault+0x1f/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  52
CPU    1: hi:  186, btch:  31 usd:  76
Active_anon:73160 inactive_anon:5876 isolated_anon:10
 active_file:10 inactive_file:30 isolated_file:0
 unevictable:0 dirty:0 writeback:0 unstable:0 buffer:18
 free:2151 slab:36746 mapped:14 shmem:15 pagetables:61579 bounce:0
DMA free:3908kB min:60kB low:72kB high:88kB active_anon:3424kB inactive_anon:0kB active_file:0kB inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15364kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:1524kB kernel_stack:888kB pagetables:3068kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4696kB min:3948kB low:4932kB high:5920kB active_anon:289216kB inactive_anon:23504kB active_file:40kB inactive_file:112kB unevictable:0kB isolated(anon):40kB isolated(file):0kB present:992032kB mlocked:0kB dirty:0kB writeback:0kB mapped:56kB shmem:60kB slab_reclaimable:3896kB slab_unreclaimable:141564kB kernel_stack:61056kB pagetables:243248kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:192 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3908kB
DMA32: 516*4kB 79*8kB 3*16kB 1*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4696kB
86 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
150688 pages shared
224441 pages non-shared
Out of memory: kill process 18698 (msgctl11) score 173774 or a child
Killed process 19157 (msgctl11)
msgctl11 invoked oom-killer: gfp_mask=0x200da, order=0, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 21259, comm: msgctl11 Not tainted 2.6.31-rc3-cachefs #189
Call Trace:
 [<ffffffff81072956>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81072c1d>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81072c9e>] ? out_of_memory+0x6a/0x94
 [<ffffffff8107568b>] ? __alloc_pages_nodemask+0x42b/0x517
 [<ffffffff8108159c>] ? do_wp_page+0x2c6/0x5f5
 [<ffffffff8102f581>] ? try_to_wake_up+0x1d3/0x1e5
 [<ffffffff81082e1a>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81022c3e>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812e29cf>] ? page_fault+0x1f/0x30
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  77
CPU    1: hi:  186, btch:  31 usd:  87
Active_anon:73073 inactive_anon:5907 isolated_anon:73
 active_file:0 inactive_file:21 isolated_file:83
 unevictable:0 dirty:0 writeback:0 unstable:0 buffer:18
 free:2087 slab:36749 mapped:28 shmem:15 pagetables:61579 bounce:0
DMA free:3908kB min:60kB low:72kB high:88kB active_anon:3424kB inactive_anon:0kB active_file:0kB inactive_file:8kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15364kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:1524kB kernel_stack:888kB pagetables:3068kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4440kB min:3948kB low:4932kB high:5920kB active_anon:288756kB inactive_anon:23756kB active_file:84kB inactive_file:132kB unevictable:0kB isolated(anon):292kB isolated(file):204kB present:992032kB mlocked:0kB dirty:0kB writeback:0kB mapped:112kB shmem:60kB slab_reclaimable:3896kB slab_unreclaimable:141576kB kernel_stack:61056kB pagetables:243248kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:96 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 1*4kB 0*8kB 0*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3908kB
DMA32: 464*4kB 75*8kB 2*16kB 1*32kB 2*64kB 2*128kB 0*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4440kB
161 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5593 pages reserved
151055 pages shared
224378 pages non-shared
Out of memory: kill process 18698 (msgctl11) score 173682 or a child
Killed process 19158 (msgctl11)
SysRq : HELP : loglevel(0-9) reBoot Crash terminate-all-tasks(E) memory-full-oom-kill(F) kill-all-tasks(I) thaw-filesystems(J) saK show-backtrace-all-active-cpus(L) show-memory-usage(M) nice-all-RT-tasks(N) powerOff show-registers(P) show-all-timers(Q) unRaw Sync show-task-states(T) Unmount show-blocked-tasks(W) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
