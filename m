Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 47DAD6B0062
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 11:27:49 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com>
References: <28c262360906290800v37f91d7av3642b1ad8b5f0477@mail.gmail.com> <26537.1246086769@redhat.com> <28c262360906280630n557bb182n5079e33d21ea4a83@mail.gmail.com> <28c262360906280636l93130ffk14086314e2a6dcb7@mail.gmail.com> <20090628142239.GA20986@localhost> <2f11576a0906280801w417d1b9fpe10585b7a641d41b@mail.gmail.com> <20090628151026.GB25076@localhost> <20090629091741.ab815ae7.minchan.kim@barrios-desktop> <17678.1246270219@redhat.com> <20090629125549.GA22932@localhost> <29432.1246285300@redhat.com> 
Subject: Re: Found the commit that causes the OOMs
Date: Mon, 29 Jun 2009 16:27:51 +0100
Message-ID: <29869.1246289271@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: dhowells@redhat.com, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes,
                         Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>


Minchan Kim <minchan.kim@gmail.com> wrote:

> Totally, I can't understand this situation.
> Now, this page allocation is order zero and It is just likely GFP_HIGHUSER.
> So it's unlikely interrupt context.
> 
> Buddy already has enough fallback DMA32, I think.
> Why kernel can't allocate page for order 0 ?
> Is it allocator bug ?

I don't know, but I've got you some more information.

I can reproduce the problem much, much quicker, it turns out by just running
msgctl11 from the LTP syscalls testsuite a few times.  No NFSD traffic this
time to confuse the issue or any other tests.

I also managed to get a list of the most in-use slabs at the time:

	002732 shmem_inode_cache         2750    800      5      1
	003143 fs_cache                  3180     72     53      1
	003145 files_cache               3145    728      5      1
	003150 mm_struct                 3150    840      9      2
	003152 task_xstate               3160    512      8      1
	003174 sighand_cache             3180   2112      3      2
	003185 task_struct               3185   1632      5      2
	003192 signal_cache              3192    928      4      1
	003192 task_delay_info           3304    136     28      1
	003205 pid                       3330    104     37      1
	003262 cred_jar                  3381    168     23      1
	003438 size-2048                 3438   2072      3      2
	003589 inode_cache               3606    608      6      1
	004570 size-192                  4572    216     18      1
	007644 size-64                   7656     88     44      1
	007687 sysfs_dir_cache           7733    104     37      1
	007875 selinux_inode_security    7920     96     40      1
	008149 dentry                    8190    216     18      1
	013692 size-128                 13900    152     25      1
	047134 vm_area_struct           47440    192     20      1
	182903 size-32                 183178     56     67      1
	312010 avtab_node              312081     48     77      1

This is from /proc/slabinfo, with the first two columns swapped to make
sorting on it easier.  I've also attached the OOM report.

David

msgctl11 invoked oom-killer: gfp_mask=0xd0, order=1, oom_adj=0
msgctl11 cpuset=/ mems_allowed=0
Pid: 12170, comm: msgctl11 Not tainted 2.6.31-rc1-cachefs #146
Call Trace:
 [<ffffffff8107207e>] ? oom_kill_process.clone.0+0xa9/0x245
 [<ffffffff81074168>] ? drain_local_pages+0x0/0x13
 [<ffffffff81072345>] ? __out_of_memory+0x12b/0x142
 [<ffffffff810723c6>] ? out_of_memory+0x6a/0x94
 [<ffffffff81074a90>] ? __alloc_pages_nodemask+0x42e/0x51d
 [<ffffffff81091546>] ? cache_alloc_refill+0x353/0x69c
 [<ffffffff81031424>] ? copy_process+0x93/0x1136
 [<ffffffff81091b24>] ? kmem_cache_alloc+0x83/0xc5
 [<ffffffff81031424>] ? copy_process+0x93/0x1136
 [<ffffffff81029da3>] ? update_curr+0x53/0xdf
 [<ffffffff810820c1>] ? handle_mm_fault+0x5dd/0x62f
 [<ffffffff81032606>] ? do_fork+0x13f/0x2ba
 [<ffffffff81022c32>] ? do_page_fault+0x1f8/0x20d
 [<ffffffff8100b0d3>] ? stub_clone+0x13/0x20
 [<ffffffff8100ad6b>] ? system_call_fastpath+0x16/0x1b
Mem-Info:
DMA per-cpu:
CPU    0: hi:    0, btch:   1 usd:   0
CPU    1: hi:    0, btch:   1 usd:   0
DMA32 per-cpu:
CPU    0: hi:  186, btch:  31 usd:   0
CPU    1: hi:  186, btch:  31 usd:  25
Active_anon:75004 active_file:0 inactive_anon:2192
 inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
 free:2200 slab:37795 mapped:618 pagetables:60369 bounce:0
DMA free:3928kB min:60kB low:72kB high:88kB active_anon:3024kB inactive_anon:128kB active_file:0kB inactive_file:0kB unevictable:0kB present:15364kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 968 968 968
DMA32 free:4748kB min:3948kB low:4932kB high:5920kB active_anon:297092kB inactive_anon:8640kB active_file:0kB inactive_file:0kB unevictable:0kB present:992032kB pages_scanned:0 all_unreclaimable? no
lowmem_reserve[]: 0 0 0 0
DMA: 0*4kB 1*8kB 1*16kB 0*32kB 1*64kB 0*128kB 1*256kB 1*512kB 1*1024kB 1*2048kB 0*4096kB = 3928kB
DMA32: 476*4kB 56*8kB 14*16kB 4*32kB 0*64kB 1*128kB 1*256kB 1*512kB 1*1024kB 0*2048kB 0*4096kB = 4624kB
1154 total pagecache pages
0 pages in swap cache
Swap cache stats: add 0, delete 0, find 0/0
Free swap  = 0kB
Total swap = 0kB
255744 pages RAM
5589 pages reserved
248214 pages shared
219940 pages non-shared
Out of memory: kill process 4164 (msgctl11) score 119366 or a child
Killed process 10211 (msgctl11)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
