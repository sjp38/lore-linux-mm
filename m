Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 077246B004D
	for <linux-mm@kvack.org>; Sun, 28 Jun 2009 03:54:29 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090627125412.GA1667@cmpxchg.org>
References: <20090627125412.GA1667@cmpxchg.org> <3901.1245848839@redhat.com> <20090624023251.GA16483@localhost> <20090620043303.GA19855@localhost> <32411.1245336412@redhat.com> <20090517022327.280096109@intel.com> <2015.1245341938@redhat.com> <20090618095729.d2f27896.akpm@linux-foundation.org> <7561.1245768237@redhat.com> <26537.1246086769@redhat.com> 
Subject: Re: Found the commit that causes the OOMs
Date: Sun, 28 Jun 2009 08:55:48 +0100
Message-ID: <31494.1246175748@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: dhowells@redhat.com, Wu Fengguang <fengguang.wu@intel.com>, "riel@redhat.com" <riel@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Johannes Weiner <hannes@cmpxchg.org> wrote:

> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: vmscan: keep balancing anon lists on swap-full conditions
> 
> Page reclaim doesn't scan and balance the anon LRU lists when
> nr_swap_pages is zero to save the scan overhead for swapless systems.
> 
> Unfortunately, this variable can reach zero when all present swap
> space is occupied as well and we don't want to stop balancing in that
> case or we encounter an unreclaimable mess of anon lists when swap
> space gets freed up and we are theoretically in the position to page
> out again.
> 
> Use the total_swap_pages variable to have a better indicator when to
> scan the anon LRU lists.
> 
> We still might have unbalanced anon lists when swap space is added
> during run time but it is a a less dynamic change in state and we
> still save the scanning overhead for CONFIG_SWAP systems that never
> actually set up swap space.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

This doesn't help.

It may change the behaviour though: rather than locking up after a couple of
OOMs, it generated 42MB of OOM messages.

It didn't go wrong until its 5th pass through the LTP syscalls testsuite this
time.  Attached is the first part of the log where OOM messages were generated.

David
---
msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 689, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #143
Call Trace:
 [<ffffffff810718a2>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81071b69>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81071bea>] ? out_of_memory+0x6a/0x94
 [<ffffffff810742b4>] ? __alloc_pages_nodemask+0x42e/0x51d
 [<ffffffff81090d86>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff8106f20f>] ? find_get_page+0x1a/0x72
 [<ffffffff810313e6>] ? copy_process+0x95/0x114f
 [<ffffffff81091364>] ? kmem_cache_alloc+0x83/0xc5
 [<ffffffff810313e6>] ? copy_process+0x95/0x114f
 [<ffffffff810815da>] ? handle_mm_fault+0x2b9/0x62f
 [<ffffffff810325df>] ? do_fork+0x13f/0x2ba
 [<ffffffff81022c02>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
 [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:  62
CPU    1: hi:  186, btch:  31 usd:   0
Active_anon:71393 active_file:1 inactive_anon:4670
 inactive_file:0 unevictable:0 dirty:11 writeback:0 unstable:0
 free:3987 slab:38927 mapped:451 pagetables:58190 bounce:0
DMA free:3928kB min:60kB low:72kB high:88kB active_anon:3176kB inactive_anon:256kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:12020kB min:3948kB low:4932kB high:5920kB active_anon:282396kB inactive_anon:18424kB active_file:4kB inactive_file:0kB unevictable:0kB present:992000kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 8*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3928kB
DMA32: 2367*4kB 71*8kB 10*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 12020kB
2342 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5597 pages reserved
230753 pages shared
216782 pages non-shared
Out of memory: kill process 30280 (msgctl11) score 161571 or a child
Killed process 31149 (msgctl11)
msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 689, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #143
Call Trace:
 [<ffffffff810718a2>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81071b69>] ? __out_of_memory+0x12b/0x142
 [<ffffffff81071bea>] ? out_of_memory+0x6a/0x94
 [<ffffffff810742b4>] ? __alloc_pages_nodemask+0x42e/0x51d
 [<ffffffff81090d86>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff8106f20f>] ? find_get_page+0x1a/0x72
 [<ffffffff810313e6>] ? copy_process+0x95/0x114f
 [<ffffffff81091364>] ? kmem_cache_alloc+0x83/0xc5
 [<ffffffff810313e6>] ? copy_process+0x95/0x114f
 [<ffffffff810815da>] ? handle_mm_fault+0x2b9/0x62f
 [<ffffffff810325df>] ? do_fork+0x13f/0x2ba
 [<ffffffff81022c02>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
 [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:   0
Active_anon:75955 active_file:0 inactive_anon:4990
 inactive_file:2 unevictable:0 dirty:0 writeback:0 unstable:0
 free:1970 slab:38326 mapped:5 pagetables:59166 bounce:0
DMA free:3932kB min:60kB low:72kB high:88kB active_anon:3172kB inactive_anon:256kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:3948kB min:3948kB low:4932kB high:5920kB active_anon:300648kB inactive_anon:19704kB active_file:0kB inactive_file:8kB unevictable:0kB present:992000kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 9*4kB 1*8kB 1*16kB 1*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3932kB
DMA32: 457*4kB 39*8kB 1*16kB 0*32kB 0*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 3948kB
36 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5597 pages reserved
162238 pages shared
220698 pages non-shared
Out of memory: kill process 30280 (msgctl11) score 160654 or a child
Killed process 31155 (msgctl11)
msgctl11: page allocation failure. order:1, mode:0x20
Pid: 3095, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #143
Call Trace:
 <IRQ>  [<ffffffff8107435a>] ? __alloc_pages_nodemask+0x4d4/0x51d
 [<ffffffff81090d86>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff810734a4>] ? free_pages_bulk.clone.1+0x4d/0x20d
 [<ffffffff81265935>] ? __alloc_skb+0x38/0x148
 [<ffffffff81266512>] ? __netdev_alloc_skb+0x15/0x2f
 [<ffffffff81091195>] ? __kmalloc_track_caller+0xc6/0x108
 [<ffffffff8126595e>] ? __alloc_skb+0x61/0x148
 [<ffffffff81266512>] ? __netdev_alloc_skb+0x15/0x2f
 [<ffffffff8123f092>] ? e1000_clean_rx_irq+0x1ab/0x2de
 [<ffffffff8124072f>] ? e1000_clean+0x71/0x20f
 [<ffffffff81269cab>] ? net_rx_action+0x64/0x129
 [<ffffffff8103b47d>] ? process_timeout+0x0/0xb
 [<ffffffff810375d1>] ? __do_softirq+0x92/0x129
 [<ffffffff8100be7c>] ? call_softirq+0x1c/0x28
 [<ffffffff8100d824>] ? do_softirq+0x2c/0x68
 [<ffffffff8100cf3b>] ? do_IRQ+0x9c/0xb2
 [<ffffffff8100b713>] ? ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff810791e9>] ? shrink_zone+0x1d6/0x30f
 [<ffffffff810cec7d>] ? mb_cache_shrink_fn+0x26/0x115
 [<ffffffff8118b977>] ? __up_read+0x13/0x90
 [<ffffffff81079460>] ? shrink_slab+0x13e/0x150
 [<ffffffff8107a004>] ? try_to_free_pages+0x20d/0x362
 [<ffffffff8107760f>] ? isolate_pages_global+0x0/0x219
 [<ffffffff810741d3>] ? __alloc_pages_nodemask+0x34d/0x51d
 [<ffffffff81075f05>] ? __do_page_cache_readahead+0x9e/0x1a1
 [<ffffffff81076024>] ? ra_submit+0x1c/0x20
 [<ffffffff8106f9f4>] ? filemap_fault+0x18a/0x316
 [<ffffffff8107f7cb>] ? __do_fault+0x54/0x3d6
 [<ffffffff810815da>] ? handle_mm_fault+0x2b9/0x62f
 [<ffffffff81022c02>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff812dfb7f>] ? page_fault+0x1f/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
