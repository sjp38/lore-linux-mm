Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E4C346B002D
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 05:39:15 -0500 (EST)
Date: Thu, 10 Nov 2011 11:38:03 +0100
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] mm: Do not stall in synchronous compaction for THP
 allocations
Message-ID: <20111110103803.GH3153@redhat.com>
References: <20111110100616.GD3083@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111110100616.GD3083@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 10, 2011 at 10:06:16AM +0000, Mel Gorman wrote:
> Occasionally during large file copies to slow storage, there are still
> reports of user-visible stalls when THP is enabled. Reports on this
> have been intermittent and not reliable to reproduce locally but;
> 
> Andy Isaacson reported a problem copying to VFAT on SD Card
> 	https://lkml.org/lkml/2011/11/7/2
> 
> 	In this case, it was stuck in munmap for betwen 20 and 60
> 	seconds in compaction. It is also possible that khugepaged
> 	was holding mmap_sem on this process if CONFIG_NUMA was set.
> 
> Johannes Weiner reported stalls on USB
> 	https://lkml.org/lkml/2011/7/25/378
> 
> 	In this case, there is no stack trace but it looks like the
> 	same problem. The USB stick may have been using NTFS as a
> 	filesystem based on other work done related to writing back
> 	to USB around the same time.

Sorry, here is a trace from when I first recorded the problem:

[171252.437688] firefox         D 000000010a31e6b7     0  8502   1110 0x00000000
[171252.437691]  ffff88001e91f8a8 0000000000000082 ffff880000000000 ffff88001e91ffd8
[171252.437693]  ffff88001e91ffd8 0000000000004000 ffffffff8180b020 ffff8800456e4680
[171252.437696]  ffff88001e91f7e8 ffffffff810cd4ed ffffea00028d4500 000000000000000e
[171252.437699] Call Trace:
[171252.437701]  [<ffffffff810cd4ed>] ? __pagevec_free+0x2d/0x40
[171252.437703]  [<ffffffff810d044c>] ? release_pages+0x24c/0x280
[171252.437705]  [<ffffffff81099448>] ? ktime_get_ts+0xa8/0xe0
[171252.437707]  [<ffffffff810c5040>] ? file_read_actor+0x170/0x170
[171252.437709]  [<ffffffff8156ac8a>] io_schedule+0x8a/0xd0
[171252.437711]  [<ffffffff810c5049>] sleep_on_page+0x9/0x10
[171252.437713]  [<ffffffff8156b0f7>] __wait_on_bit+0x57/0x80
[171252.437715]  [<ffffffff810c5630>] wait_on_page_bit+0x70/0x80
[171252.437718]  [<ffffffff810916c0>] ? autoremove_wake_function+0x40/0x40
[171252.437720]  [<ffffffff810f98a5>] migrate_pages+0x2a5/0x490
[171252.437722]  [<ffffffff810f5940>] ? suitable_migration_target+0x50/0x50
[171252.437724]  [<ffffffff810f6234>] compact_zone+0x4e4/0x770
[171252.437727]  [<ffffffff810f65e0>] compact_zone_order+0x80/0xb0
[171252.437729]  [<ffffffff810f66cd>] try_to_compact_pages+0xbd/0xf0
[171252.437731]  [<ffffffff810cc608>] __alloc_pages_direct_compact+0xa8/0x180
[171252.437734]  [<ffffffff810ccbdb>] __alloc_pages_nodemask+0x4fb/0x720
[171252.437736]  [<ffffffff810fbfe3>] do_huge_pmd_wp_page+0x4c3/0x740
[171252.437738]  [<ffffffff81094fff>] ? hrtimer_start_range_ns+0xf/0x20
[171252.437740]  [<ffffffff810e3f9c>] handle_mm_fault+0x1bc/0x2f0
[171252.437743]  [<ffffffff8102e6c6>] ? __switch_to+0x1e6/0x2c0
[171252.437745]  [<ffffffff810511b2>] do_page_fault+0x132/0x430
[171252.437747]  [<ffffffff810a4995>] ? sys_futex+0x105/0x1a0
[171252.437749]  [<ffffffff8156cf9f>] page_fault+0x1f/0x30

It could have been vfat, I don't remember for sure.  But I would think
the problem depends only on the duration of PageWriteback being set.

> Internally in SUSE, I received a bug report related to stalls in firefox
> 	when using Java and Flash heavily while copying from NFS
> 	to VFAT on USB. It has not been confirmed to be the same problem
> 	but if it looks like a duck and quacks like a duck.....
> 
> In the past, commit [11bc82d6: mm: compaction: Use async migration for
> __GFP_NO_KSWAPD and enforce no writeback] forced that sync compaction
> would never be used for THP allocations. This was reverted in commit
> [c6a140bf: mm/compaction: reverse the change that forbade sync
> migraton with __GFP_NO_KSWAPD] on the grounds that it was uncertain
> it was beneficial.
> 
> While user-visible stalls do not happen for me when writing to USB,
> I setup a test running postmark while short-lived processes created
> anonymous mapping. The objective was to exercise the paths that
> allocate transparent huge pages. I then logged when processes were
> stalled for more than 1 second, recorded a stack strace and did some
> analysis to aggregate unique "stall events" which revealed
> 
> Time stalled in this event:    47369 ms
> Event count:                      20
> usemem               sleep_on_page          3690 ms
> usemem               sleep_on_page          2148 ms
> usemem               sleep_on_page          1534 ms
> usemem               sleep_on_page          1518 ms
> usemem               sleep_on_page          1225 ms
> usemem               sleep_on_page          2205 ms
> usemem               sleep_on_page          2399 ms
> usemem               sleep_on_page          2398 ms
> usemem               sleep_on_page          3760 ms
> usemem               sleep_on_page          1861 ms
> usemem               sleep_on_page          2948 ms
> usemem               sleep_on_page          1515 ms
> usemem               sleep_on_page          1386 ms
> usemem               sleep_on_page          1882 ms
> usemem               sleep_on_page          1850 ms
> usemem               sleep_on_page          3715 ms
> usemem               sleep_on_page          3716 ms
> usemem               sleep_on_page          4846 ms
> usemem               sleep_on_page          1306 ms
> usemem               sleep_on_page          1467 ms
> [<ffffffff810ef30c>] wait_on_page_bit+0x6c/0x80
> [<ffffffff8113de9f>] unmap_and_move+0x1bf/0x360
> [<ffffffff8113e0e2>] migrate_pages+0xa2/0x1b0
> [<ffffffff81134273>] compact_zone+0x1f3/0x2f0
> [<ffffffff811345d8>] compact_zone_order+0xa8/0xf0
> [<ffffffff811346ff>] try_to_compact_pages+0xdf/0x110
> [<ffffffff810f773a>] __alloc_pages_direct_compact+0xda/0x1a0
> [<ffffffff810f7d5d>] __alloc_pages_slowpath+0x55d/0x7a0
> [<ffffffff810f8151>] __alloc_pages_nodemask+0x1b1/0x1c0
> [<ffffffff811331db>] alloc_pages_vma+0x9b/0x160
> [<ffffffff81142bb0>] do_huge_pmd_anonymous_page+0x160/0x270
> [<ffffffff814410a7>] do_page_fault+0x207/0x4c0
> [<ffffffff8143dde5>] page_fault+0x25/0x30
> 
> The stall times are approximate at best but the estimates represent 25%
> of the worst stalls and even if the estimates are off by a factor of
> 10, it's severe.
>
> This patch once again prevents sync migration for transparent
> hugepage allocations as it is preferable to fail a THP allocation
> than stall. It was suggested that __GFP_NORETRY be used instead of
> __GFP_NO_KSWAPD. This would look less like a special case but would
> still cause compaction to run at least once with sync compaction.
> 
> If accepted, this is a -stable candidate.
> 
> Reported-by: Andy Isaacson <adi@hexapodia.org>
> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Tested-by: Johannes Weiner <jweiner@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
