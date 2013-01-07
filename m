Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id D18216B005D
	for <linux-mm@kvack.org>; Mon,  7 Jan 2013 07:25:21 -0500 (EST)
Date: Mon, 7 Jan 2013 12:25:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: ppoll() stuck on POLLIN while TCP peer is sending
Message-ID: <20130107122516.GC3885@suse.de>
References: <20121228014503.GA5017@dcvr.yhbt.net>
 <20130102200848.GA4500@dcvr.yhbt.net>
 <20130104160148.GB3885@suse.de>
 <20130106120700.GA24671@dcvr.yhbt.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20130106120700.GA24671@dcvr.yhbt.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wong <normalperson@yhbt.net>
Cc: linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun, Jan 06, 2013 at 12:07:00PM +0000, Eric Wong wrote:
> Mel Gorman <mgorman@suse.de> wrote:
> > Using a 3.7.1 or 3.8-rc2 kernel, can you reproduce the problem and then
> > answer the following questions please?
> 
> This is on my main machine running 3.8-rc2
> 
> > 1. What are the contents of /proc/vmstat at the time it is stuck?
> 
> ===> /proc/vmstat <===

According to this, THP is barely being used -- only 24 THP pages at the time
and the LRU lists are dominated by file pages. The isolated and throttled
counters look fine. There is a lot of memory currently under writeback and
a large number of dirty pages are reaching the end of the LRU list which
is inefficient but does not account for the reported bug.

> > 2. What are the contents of /proc/PID/stack for every toosleepy
> >    process when they are stuck?
> 
> pid and tid stack info, 28018 is the thread I used to automate
> reporting (pushed to git://bogomips.org/toosleepy.git)
> 
> ===> 28014[28014]/stack <===
> [<ffffffff8105a97b>] futex_wait_queue_me+0xb7/0xd2
> [<ffffffff8105b7fc>] futex_wait+0xf6/0x1f6
> [<ffffffff811bb3af>] cpumask_next_and+0x2b/0x37
> [<ffffffff8104ebfa>] select_task_rq_fair+0x518/0x59a
> [<ffffffff8105c8f1>] do_futex+0xa9/0x88f
> [<ffffffff810509a4>] check_preempt_wakeup+0x10d/0x1a7
> [<ffffffff8104757d>] check_preempt_curr+0x25/0x62
> [<ffffffff8104d4cc>] wake_up_new_task+0x96/0xc2
> [<ffffffff8105d1e9>] sys_futex+0x112/0x14d
> [<ffffffff81322a49>] stub_clone+0x69/0x90
> [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

Looks ok.

> ===> 28014[28015]/stack <===
> [<ffffffff812ae316>] dev_hard_start_xmit+0x281/0x3f1
> [<ffffffff81041010>] add_wait_queue+0x14/0x40
> [<ffffffff810de0bc>] poll_schedule_timeout+0x43/0x5d
> [<ffffffff810deb46>] do_sys_poll+0x314/0x39b
> [<ffffffff810de220>] pollwake+0x0/0x4e
> [<ffffffff8129fc1d>] release_sock+0xe5/0x11b
> [<ffffffff812d7f61>] tcp_recvmsg+0x713/0x846
> [<ffffffff812f432c>] inet_recvmsg+0x64/0x75
> [<ffffffff8129a26b>] sock_recvmsg+0x86/0x9e
> [<ffffffff8100541c>] emulate_vsyscall+0x1e6/0x28e
> [<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
> [<ffffffff8129c18b>] sys_recvfrom+0x110/0x128
> [<ffffffff81000e34>] __switch_to+0x235/0x3c5
> [<ffffffff810ca402>] kmem_cache_free+0x32/0xb9
> [<ffffffff810b809d>] remove_vma+0x44/0x4c
> [<ffffffff810df0a5>] sys_ppoll+0xaf/0x123
> [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

Polling waiting for data, looks ok to me.

> ===> 28014[28016]/stack <===
> [<ffffffff812ae7ad>] dev_queue_xmit+0x327/0x336
> [<ffffffff8102cb9f>] _local_bh_enable_ip+0x7a/0x8b
> [<ffffffff81041010>] add_wait_queue+0x14/0x40
> [<ffffffff810de0bc>] poll_schedule_timeout+0x43/0x5d
> [<ffffffff810deb46>] do_sys_poll+0x314/0x39b
> [<ffffffff810de220>] pollwake+0x0/0x4e
> [<ffffffff8129fc1d>] release_sock+0xe5/0x11b
> [<ffffffff812d7f61>] tcp_recvmsg+0x713/0x846
> [<ffffffff812f432c>] inet_recvmsg+0x64/0x75
> [<ffffffff8129a26b>] sock_recvmsg+0x86/0x9e
> [<ffffffff8100541c>] emulate_vsyscall+0x1e6/0x28e
> [<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
> [<ffffffff8129c18b>] sys_recvfrom+0x110/0x128
> [<ffffffff81000e34>] __switch_to+0x235/0x3c5
> [<ffffffff810df0a5>] sys_ppoll+0xaf/0x123
> [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

Waiting on receive again.

> ===> 28014[28017]/stack <===
> [<ffffffff8129fc1d>] release_sock+0xe5/0x11b
> [<ffffffff812a642c>] sk_stream_wait_memory+0x1f7/0x1fc
> [<ffffffff81040d5e>] autoremove_wake_function+0x0/0x2a
> [<ffffffff812d8fc3>] tcp_sendmsg+0x710/0x86d
> [<ffffffff8129a33e>] sock_sendmsg+0x7b/0x93
> [<ffffffff8129a642>] sys_sendto+0xee/0x145
> [<ffffffff8129a3bc>] sockfd_lookup_light+0x1a/0x50
> [<ffffffff8129a668>] sys_sendto+0x114/0x145
> [<ffffffff81000e34>] __switch_to+0x235/0x3c5
> [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff

This seems to be the guy that's stuck. It's waiting for more memory for
the socket but who or what is allocating that memory? There are a few other
bugs from over the weekend that I want to take a look at so I did not dig
further or try to reproduce this bug yet. I'm adding Eric Dumazet back to
the cc in case he has the quick answer.

> ===> 28014[28018]/stack <===
> [<ffffffff8102b23e>] do_wait+0x1a6/0x21a
> [<ffffffff8104757d>] check_preempt_curr+0x25/0x62
> [<ffffffff8102b34a>] sys_wait4+0x98/0xb5
> [<ffffffff81026321>] do_fork+0x12c/0x1a7
> [<ffffffff810297b0>] child_wait_callback+0x0/0x48
> [<ffffffff8131c688>] page_fault+0x28/0x30
> [<ffffffff81322769>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> > 3. Can you do a sysrq+m and post the resulting dmesg?
> 
> SysRq : Show Memory
> Mem-Info:
> DMA per-cpu:
> CPU    0: hi:    0, btch:   1 usd:   0
> CPU    1: hi:    0, btch:   1 usd:   0
> CPU    2: hi:    0, btch:   1 usd:   0
> CPU    3: hi:    0, btch:   1 usd:   0
> DMA32 per-cpu:
> CPU    0: hi:  186, btch:  31 usd:   4
> CPU    1: hi:  186, btch:  31 usd: 181
> CPU    2: hi:  186, btch:  31 usd:  46
> CPU    3: hi:  186, btch:  31 usd:  13
> Normal per-cpu:
> CPU    0: hi:  186, btch:  31 usd: 106
> CPU    1: hi:  186, btch:  31 usd: 183
> CPU    2: hi:  186, btch:  31 usd:  20
> CPU    3: hi:  186, btch:  31 usd:  76
> active_anon:85782 inactive_anon:25023 isolated_anon:0
>  active_file:209440 inactive_file:2610279 isolated_file:0
>  unevictable:0 dirty:696664 writeback:629020 unstable:0
>  free:44152 slab_reclaimable:68414 slab_unreclaimable:14178
>  mapped:6017 shmem:24101 pagetables:3136 bounce:0
>  free_cma:0
> DMA free:15872kB min:84kB low:104kB high:124kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15640kB managed:15896kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:24kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
> lowmem_reserve[]: 0 3132 12078 12078
> DMA32 free:85264kB min:17504kB low:21880kB high:26256kB active_anon:46808kB inactive_anon:21212kB active_file:122040kB inactive_file:2833064kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3208020kB managed:3185856kB mlocked:0kB dirty:92120kB writeback:225356kB mapped:356kB shmem:6776kB slab_reclaimable:67156kB slab_unreclaimable:7412kB kernel_stack:80kB pagetables:816kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 8946 8946
> Normal free:75472kB min:49988kB low:62484kB high:74980kB active_anon:296320kB inactive_anon:78880kB active_file:715720kB inactive_file:7608052kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:9160704kB managed:9084264kB mlocked:0kB dirty:2694536kB writeback:2290724kB mapped:23712kB shmem:89628kB slab_reclaimable:206500kB slab_unreclaimable:49276kB kernel_stack:2432kB pagetables:11728kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
> lowmem_reserve[]: 0 0 0 0
> DMA: 0*4kB 0*8kB 0*16kB 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15872kB
> DMA32: 1681*4kB (UEM) 3196*8kB (UEM) 3063*16kB (UEM) 63*32kB (UEM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB (R) 0*4096kB = 85364kB
> Normal: 8874*4kB (UEM) 1885*8kB (UEM) 581*16kB (UEM) 412*32kB (UM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 1*2048kB (R) 0*4096kB = 75104kB

Nothing wrong there that I can see. The free list contents roughly match
up with the NR_FREE_PAGES counter so it doesn't look like an accounting
bug. However, an accounting bug could have broken the bisection and
found a different bug.

When taking pages straight off the buddy list like this patch does,
there is a danger that the watermarks will be broken resulting in a
livelock but the watermarks are checked properly and the free pages are
over the min watermark above.

There is this patch https://lkml.org/lkml/2013/1/6/219 but it is
unlikely that it has anything to do with your workload as it does not
use splice().

Right now it's difficult to see how the capture could be the source of
this bug but I'm not ruling it out either so try the following (untested
but should be ok) patch.  It's not a proper revert, it just disables the
capture page logic to see if it's at fault.

diff --git a/mm/compaction.c b/mm/compaction.c
index 6b807e4..81a637d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1054,9 +1054,6 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 				goto out;
 			}
 		}
-
-		/* Capture a page now if it is a suitable size */
-		compact_capture_page(cc);
 	}
 
 out:
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4ba5e37..85d3f9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2179,11 +2179,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 						contended_compaction, &page);
 	current->flags &= ~PF_MEMALLOC;
 
-	/* If compaction captured a page, prep and use it */
-	if (page) {
-		prep_new_page(page, order, gfp_mask);
-		goto got_page;
-	}
+	/* capture page is disabled, this should be impossible */
+	BUG_ON(page);
 
 	if (*did_some_progress != COMPACT_SKIPPED) {
 		/* Page migration frees to the PCP lists but we want merging */
@@ -2195,7 +2192,6 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 				alloc_flags & ~ALLOC_NO_WATERMARKS,
 				preferred_zone, migratetype);
 		if (page) {
-got_page:
 			preferred_zone->compact_blockskip_flush = false;
 			preferred_zone->compact_considered = 0;
 			preferred_zone->compact_defer_shift = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
