Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DFA07600429
	for <linux-mm@kvack.org>; Mon,  2 Aug 2010 04:13:02 -0400 (EDT)
Date: Mon, 2 Aug 2010 16:12:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Bug 12309 - Large I/O operations result in poor interactive
 performance and high iowait times
Message-ID: <20100802081253.GA27492@localhost>
References: <20100802003616.5b31ed8b@digital-domain.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20100802003616.5b31ed8b@digital-domain.net>
Sender: owner-linux-mm@kvack.org
To: Andrew Clayton <andrew@digital-domain.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, pvz@pvz.pp.se, bgamari@gmail.com, larppaxyz@gmail.com, seanj@xyke.com, kernel-bugs.dev1world@spamgourmet.com, akatopaz@gmail.com, frankrq2009@gmx.com, thomas.pi@arcor.de, spawels13@gmail.com, vshader@gmail.com, rockorequin@hotmail.com, ylalym@gmail.com, theholyettlz@googlemail.com, hassium@yandex.ru
List-ID: <linux-mm.kvack.org>

> I've pointed to your two patches in the bug report, so hopefully someone
> who is seeing the issues can try them out.

Thanks.

> I noticed your comment about the no swap situation
> 
> "#26: Per von Zweigbergk
> Disabling swap makes the terminal launch much faster while copying;
> However Firefox and vim hang much more aggressively and frequently
> during copying.
> 
> It's interesting to see processes behave differently. Is this
> reproducible at all?"
> 
> Recently there have been some other people who have noticed this.
> 
> Comment #460 From  SA,ren Holm   2010-07-22 20:33:00   (-) [reply] -------
> 
> I've tried stress also.
> I have 2 Gb og memory and 1.5 Gb swap
> 
> With swap activated stress -d 1 hangs my machine
> 
> Same does stress -d while swapiness set to 0
> 
> Widh swap deactivated things runs pretty fine. Of couse apps utilizing
> syncronous disk-io fight stress for priority.
> 
> Comment #461 From  Nels Nielson   2010-07-23 16:23:06   (-) [reply] -------
> 
> I can also confirm this. Disabling swap with swapoff -a solves the problem.
> I have 8gb of ram and 8gb of swap with a fake raid mirror.
> 
> Before this I couldn't do backups without the whole system grinding to a halt.
> Right now I am doing a backup from the drives, watching a movie from the same
> drives and more. No more iowait times and programs freezing as they are starved
> from being able to access the drives.

So swapping is another major cause of responsiveness lags.

I just tested the heavy swapping case with the patches to remove
the congestion_wait() and wait_on_page_writeback() stalls on high
order allocations. The patches work as expected. No single stall shows
up with the debug patch posted in http://lkml.org/lkml/2010/8/1/10.

However there are still stalls on get_request_wait():
- kswapd trying to pageout anonymous pages
- _any_ process in direct reclaim doing pageout()

Since 90% pages are dirty anonymous pages, the chances to stall is high.
kswapd can hardly make smooth progress. The applications end up doing
direct reclaim by themselves, which also ends up stuck in pageout().
They are not explicitly stalled in vmscan code, but implicitly in
get_request_wait() when trying to swapping out the dirty pages.

It sure hurts responsiveness with so many applications stalled on
get_request_wait(). But question is, what can we do otherwise? The
system is running short of memory and cannot keep up freeing enough
memory anyway. So page allocations have to be throttled somewhere..

But wait.. What if there are only 50% anonymous pages? In this case
applications don't necessarily need to sleep in get_request_wait().
The memory pressure is not really high. The poor man's solution is to
disable swapping totally, as the bug reporters find to be helpful..

One easy fix is to skip swap-out when bdi is congested and priority is
close to DEF_PRIORITY. However it would be unfair to selectively
(largely in random) keep some pages and reclaim the others that
actually have the same age.

A more complete fix may be to introduce some swap_out LRU list(s).
Pages in it will be swap out as fast as possible by a dedicated
kernel thread. And pageout() can freely add pages to it until it
grows larger than some threshold, eg. 30% reclaimable memory, at which
point pageout() will stall on the list. The basic idea is to switch
the random get_request_wait() stalls to some more global wise stalls.

Does this sound feasible?

Thanks,
Fengguang
---

The test case is basically

        usemem -n $nr_cpu --random $((2 * mem / nr_cpu)) --repeat 1000&
        cp /dev/zero /mnt/tmp/

which creates 8 usemem processes randomly doing page faults on a dataset that
is 2 times the physical memory size and one cp writing to a local file. The
usemem processes are mostly waiting in lock_page() for the completion of
swap-in IO, which is expected.

[  575.598378] kswapd0       D 0000000100010c04  4416   605      2 0x00000000
[  575.598526]  ffff8800bac9b850 0000000000000006 0000000000000000 00000000001d55c0
[  575.598770]  ffff8800b98dc6a0 00000000001d55c0 ffff8800bac9bfd8 ffff8800bac9bfd8
[  575.599015]  00000000001d55c0 ffff8800b98dca08 00000000001d55c0 00000000001d55c0
[  575.599263] Call Trace:
[  575.599343]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.599429]  [<ffffffff815535c3>] get_request_wait+0x103/0x1f0
[  575.599514]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[  575.599599]  [<ffffffff81554067>] __make_request+0xb7/0x6f0
[  575.599679]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.599760]  [<ffffffff81550c8c>] generic_make_request+0x25c/0x6e0
[  575.599842]  [<ffffffff811ca0db>] ? inc_zone_page_state+0x8b/0xf0
[  575.599925]  [<ffffffff8110274b>] ? trace_hardirqs_on+0x1b/0x30
[  575.600006]  [<ffffffff815511a5>] submit_bio+0x95/0x140
[  575.600086]  [<ffffffff811a60df>] ? unlock_page+0x4f/0x70
[  575.600166]  [<ffffffff811e8df7>] swap_writepage+0xa7/0x130
[  575.600247]  [<ffffffff811bc6cb>] shrink_page_list+0x5db/0xdd0
[  575.600903]  [<ffffffff811bd33f>] shrink_inactive_list+0x11f/0x500
[  575.600985]  [<ffffffff811bdfdc>] shrink_zone+0x49c/0x610
[  575.601066]  [<ffffffff811bf339>] balance_pgdat+0x529/0x650
[  575.601147]  [<ffffffff811bf5c6>] kswapd+0x166/0x3f0
[  575.601227]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[  575.601309]  [<ffffffff811bf460>] ? kswapd+0x0/0x3f0
[  575.601393]  [<ffffffff810e3dad>] kthread+0xcd/0xe0
[  575.601473]  [<ffffffff8104e9e4>] kernel_thread_helper+0x4/0x10
[  575.601555]  [<ffffffff81b83b10>] ? restore_args+0x0/0x30
[  575.601635]  [<ffffffff810e3ce0>] ? kthread+0x0/0xe0
[  575.601715]  [<ffffffff8104e9e0>] ? kernel_thread_helper+0x0/0x10

[  575.712282] jbd2/sda1-8   D 0000000100010c14  3856  5000      2 0x00000000
[  575.712410]  ffff8800b4fafb00 0000000000000006 ffff8800ffffffff 00000000001d55c0
[  575.712625]  ffff8800b4c78000 00000000001d55c0 ffff8800b4faffd8 ffff8800b4faffd8
[  575.712841]  00000000001d55c0 ffff8800b4c78368 00000000001d55c0 00000000001d55c0
[  575.713056] Call Trace:
[  575.713121]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.713191]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.713260]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.713892]  [<ffffffff81b7efdd>] __wait_on_bit+0x8d/0xe0
[  575.713961]  [<ffffffff811a54f0>] ? find_get_pages_tag+0x0/0x280
[  575.714032]  [<ffffffff811a62ff>] wait_on_page_bit+0x8f/0xa0
[  575.714103]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.714174]  [<ffffffff811b5b3c>] ? pagevec_lookup_tag+0x2c/0x40
[  575.714244]  [<ffffffff811a756e>] filemap_fdatawait_range+0x1de/0x250
[  575.714316]  [<ffffffff811a7611>] filemap_fdatawait+0x31/0x40
[  575.714392]  [<ffffffff81343275>] jbd2_journal_commit_transaction+0x6b5/0x1ee0
[  575.714496]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[  575.714568]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[  575.714639]  [<ffffffff810cb170>] ? del_timer_sync+0x0/0x120
[  575.714708]  [<ffffffff8134b72f>] kjournald2+0xef/0x320
[  575.714777]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[  575.714848]  [<ffffffff8134b640>] ? kjournald2+0x0/0x320
[  575.714917]  [<ffffffff810e3dad>] kthread+0xcd/0xe0
[  575.714985]  [<ffffffff8104e9e4>] kernel_thread_helper+0x4/0x10
[  575.715058]  [<ffffffff81b83b10>] ? restore_args+0x0/0x30
[  575.715130]  [<ffffffff810e3ce0>] ? kthread+0x0/0xe0
[  575.715201]  [<ffffffff8104e9e0>] ? kernel_thread_helper+0x0/0x10

[  575.716786] usemem        S ffff8800b824c6a0  3112  5009   4998 0x00000000
[  575.716913]  ffff8800b6e3fe78 0000000000000006 0000000000000002 00000000001d55c0
[  575.717128]  ffff8800b824c6a0 00000000001d55c0 ffff8800b6e3ffd8 ffff8800b6e3ffd8
[  575.717343]  00000000001d55c0 ffff8800b824ca08 00000000001d55c0 00000000001d55c0
[  575.717557] Call Trace:
[  575.717672]  [<ffffffff810b9475>] do_wait+0x245/0x340
[  575.717746]  [<ffffffff810bb436>] sys_wait4+0x86/0x150
[  575.717816]  [<ffffffff810b7860>] ? child_wait_callback+0x0/0xb0
[  575.717888]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[  575.717958] cp            D 0000000100010c27  2816  5010   4998 0x00000000
[  575.718085]  ffff8800b49113d8 0000000000000006 0000000000000000 00000000001d55c0
[  575.718300]  ffff8800b8248000 00000000001d55c0 ffff8800b4911fd8 ffff8800b4911fd8
[  575.718515]  00000000001d55c0 ffff8800b8248368 00000000001d55c0 00000000001d55c0
[  575.718730] Call Trace:
[  575.718797]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.718867]  [<ffffffff815535c3>] get_request_wait+0x103/0x1f0
[  575.718938]  [<ffffffff810e44d0>] ? autoremove_wake_function+0x0/0x60
[  575.719010]  [<ffffffff81554067>] __make_request+0xb7/0x6f0
[  575.719081]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.719152]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[  575.719223]  [<ffffffff81550c8c>] generic_make_request+0x25c/0x6e0
[  575.719295]  [<ffffffff811ca0db>] ? inc_zone_page_state+0x8b/0xf0
[  575.719366]  [<ffffffff8110274b>] ? trace_hardirqs_on+0x1b/0x30
[  575.719437]  [<ffffffff815511a5>] submit_bio+0x95/0x140
[  575.719507]  [<ffffffff811a60df>] ? unlock_page+0x4f/0x70
[  575.719576]  [<ffffffff811e8df7>] swap_writepage+0xa7/0x130
[  575.719647]  [<ffffffff811bc6cb>] shrink_page_list+0x5db/0xdd0
[  575.719719]  [<ffffffff810fec5d>] ? trace_hardirqs_off_caller+0x2d/0x1f0
[  575.719791]  [<ffffffff811bd33f>] shrink_inactive_list+0x11f/0x500
[  575.719862]  [<ffffffff811023e0>] ? mark_held_locks+0x90/0xd0
[  575.719932]  [<ffffffff811bdfdc>] shrink_zone+0x49c/0x610
[  575.720003]  [<ffffffff811be65b>] do_try_to_free_pages+0x13b/0x540
[  575.720074]  [<ffffffff811bec89>] try_to_free_pages+0x99/0x180
[  575.720167]  [<ffffffff810e46ef>] ? finish_wait+0x7f/0xb0
[  575.720241]  [<ffffffff811b1e50>] __alloc_pages_nodemask+0x6f0/0xb50
[  575.720313]  [<ffffffff8133f389>] ? start_this_handle+0x519/0x7b0
[  575.720385]  [<ffffffff811f776b>] alloc_pages_current+0xcb/0x160
[  575.720456]  [<ffffffff811a6456>] __page_cache_alloc+0xb6/0xe0
[  575.720526]  [<ffffffff811a67ed>] grab_cache_page_write_begin+0x9d/0x110
[  575.720598]  [<ffffffff812f6cea>] ext4_da_write_begin+0x17a/0x360
[  575.720671]  [<ffffffff811a4a92>] generic_file_buffered_write+0x132/0x350
[  575.720742]  [<ffffffff811a7e83>] __generic_file_aio_write+0x2e3/0x5d0
[  575.720814]  [<ffffffff81b802ac>] ? mutex_lock_nested+0x37c/0x520
[  575.720885]  [<ffffffff811a81cf>] ? generic_file_aio_write+0x5f/0x110
[  575.720956]  [<ffffffff811a81cf>] ? generic_file_aio_write+0x5f/0x110
[  575.721028]  [<ffffffff811a81e9>] generic_file_aio_write+0x79/0x110
[  575.721099]  [<ffffffff812e9a21>] ext4_file_write+0xa1/0xf0
[  575.721170]  [<ffffffff8121f790>] do_sync_write+0xf0/0x140
[  575.721240]  [<ffffffff811cdc76>] ? might_fault+0xd6/0xf0
[  575.721310]  [<ffffffff81220164>] vfs_write+0xc4/0x240
[  575.721379]  [<ffffffff81220636>] sys_write+0x66/0xb0
[  575.721449]  [<ffffffff8104db72>] system_call_fastpath+0x16/0x1b
[  575.721520] usemem        D 0000000100010e67  3928  5011   5009 0x00000000
[  575.721701]  ffff8800b75b1c28 0000000000000006 ffff880000000000 00000000001d55c0
[  575.721916]  ffff8800b9888000 00000000001d55c0 ffff8800b75b1fd8 ffff8800b75b1fd8
[  575.722131]  00000000001d55c0 ffff8800b9888368 00000000001d55c0 00000000001d55c0
[  575.722347] Call Trace:
[  575.722413]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.722483]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.722552]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.722623]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.722694]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.722764]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.722835]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.722904]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.722975]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.723045]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.723115]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.723185]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.723255]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.723326]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.723395] usemem        D 0000000100010e67  3608  5012   5009 0x00000000
[  575.723527]  ffff8800b4913c28 0000000000000002 ffff880000000000 00000000001d55c0
[  575.723746]  ffff8800b7fca350 00000000001d55c0 ffff8800b4913fd8 ffff8800b4913fd8
[  575.723960]  00000000001d55c0 ffff8800b7fca6b8 00000000001d55c0 00000000001d55c0
[  575.724176] Call Trace:
[  575.724241]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.724311]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.724384]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.724453]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.724524]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.724594]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.724665]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.724735]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.724806]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.724876]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.724946]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.725017]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.725086]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.725157]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.725226] usemem        D 0000000100010e67  3912  5013   5009 0x00000000
[  575.725355]  ffff8800b4915c28 0000000000000006 ffff880000000000 00000000001d55c0
[  575.725569]  ffff8800b939a350 00000000001d55c0 ffff8800b4915fd8 ffff8800b4915fd8
[  575.725836]  00000000001d55c0 ffff8800b939a6b8 00000000001d55c0 00000000001d55c0
[  575.726052] Call Trace:
[  575.726118]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.726191]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.726261]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.726331]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.726402]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.726472]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.726543]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.726613]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.726684]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.726755]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.726825]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.726896]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.726966]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.727037]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.727107] usemem        D 0000000100010e67  3928  5014   5009 0x00000000
[  575.727234]  ffff8800b4919c28 0000000000000006 ffff880000000000 00000000001d55c0
[  575.727449]  ffff8800b8d20000 00000000001d55c0 ffff8800b4919fd8 ffff8800b4919fd8
[  575.727664]  00000000001d55c0 ffff8800b8d20368 00000000001d55c0 00000000001d55c0
[  575.727878] Call Trace:
[  575.727947]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.728016]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.728086]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.728154]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.728223]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.728292]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.728361]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.728433]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.728507]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.728578]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.728648]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.728719]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.728788]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.729430]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.729499] usemem        D 0000000100010e67  4056  5015   5009 0x00000000
[  575.729680]  ffff8800b7dbbc28 0000000000000002 ffff880000000000 00000000001d55c0
[  575.729894]  ffff8800b8d246a0 00000000001d55c0 ffff8800b7dbbfd8 ffff8800b7dbbfd8
[  575.730109]  00000000001d55c0 ffff8800b8d24a08 00000000001d55c0 00000000001d55c0
[  575.730328] Call Trace:
[  575.730394]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.730464]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.730533]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.730782]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.730853]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.730923]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.730994]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.731065]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.731136]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.731206]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.731277]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.731347]  [<ffffffff81b821e7>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[  575.731419]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.731488]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.731560]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.731629] usemem        D 0000000100010e67  3928  5016   5009 0x00000000
[  575.731758]  ffff8800b915bc28 0000000000000006 ffff880000000000 00000000001d55c0
[  575.731973]  ffff8800b4840000 00000000001d55c0 ffff8800b915bfd8 ffff8800b915bfd8
[  575.732188]  00000000001d55c0 ffff8800b4840368 00000000001d55c0 00000000001d55c0
[  575.732402] Call Trace:
[  575.732467]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.732537]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.732607]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.732676]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.732746]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.732816]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.732887]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.732957]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.733028]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.733098]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.733169]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.733239]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.733310]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.733381]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.733449] usemem        D 0000000100010e67  3928  5017   5009 0x00000000
[  575.733627]  ffff8800b4aabc28 0000000000000002 ffff880000000000 00000000001d55c0
[  575.733846]  ffff8800b9aaa350 00000000001d55c0 ffff8800b4aabfd8 ffff8800b4aabfd8
[  575.734069]  00000000001d55c0 ffff8800b9aaa6b8 00000000001d55c0 00000000001d55c0
[  575.734285] Call Trace:
[  575.734351]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.734422]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.734492]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.734561]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.734633]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.734703]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.734773]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.734843]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.734914]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.734985]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.735056]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.735126]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.735196]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.735268]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.735338] usemem        D 0000000100010e67  3928  5018   5009 0x00000000
[  575.735467]  ffff8800b6f5bc28 0000000000000002 ffff880000000000 00000000001d55c0
[  575.735682]  ffff8800b9aac6a0 00000000001d55c0 ffff8800b6f5bfd8 ffff8800b6f5bfd8
[  575.735899]  00000000001d55c0 ffff8800b9aaca08 00000000001d55c0 00000000001d55c0
[  575.736114] Call Trace:
[  575.736179]  [<ffffffff811a5ee0>] ? sync_page+0x0/0xb0
[  575.736249]  [<ffffffff81b7e216>] io_schedule+0x96/0x110
[  575.736319]  [<ffffffff811a5f4f>] sync_page+0x6f/0xb0
[  575.736388]  [<ffffffff81b7ee2d>] __wait_on_bit_lock+0x7d/0x100
[  575.736459]  [<ffffffff811a5ea5>] __lock_page+0x75/0x90
[  575.736528]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.736599]  [<ffffffff811d0e21>] do_swap_page+0x6d1/0x750
[  575.736670]  [<ffffffff811cdff0>] ? do_anonymous_page+0xc0/0x2a0
[  575.736741]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.736811]  [<ffffffff811d2f8b>] handle_mm_fault+0x2fb/0x4d0
[  575.736882]  [<ffffffff81b887c9>] do_page_fault+0x1d9/0x770
[  575.736953]  [<ffffffff81b83f56>] ? error_sti+0x5/0x6
[  575.737022]  [<ffffffff81b82226>] ? trace_hardirqs_off_thunk+0x3a/0x3c
[  575.737093]  [<ffffffff81b83d45>] page_fault+0x25/0x30
[  575.737162] flush-8:0     D 0000000100010c14  2512  5019      2 0x00000000
[  575.737291]  ffff8800b084d650 0000000000000006 ffff8800ffffffff 00000000001d55c0
[  575.737506]  ffff8800b4c7c6a0 00000000001d55c0 ffff8800b084dfd8 ffff8800b084dfd8
[  575.737777]  00000000001d55c0 ffff8800b4c7ca08 00000000001d55c0 00000000001d55c0
[  575.737992] Call Trace:
[  575.738058]  [<ffffffff813417fc>] do_get_write_access+0x3ac/0x780
[  575.738130]  [<ffffffff810e4530>] ? wake_bit_function+0x0/0x70
[  575.738200]  [<ffffffff81341e0f>] jbd2_journal_get_write_access+0x3f/0x70
[  575.738273]  [<ffffffff8131f429>] __ext4_journal_get_write_access+0x69/0xb0
[  575.738346]  [<ffffffff81323841>] ext4_mb_mark_diskspace_used+0x91/0x600
[  575.738418]  [<ffffffff81324010>] ? ext4_mb_use_preallocated+0x40/0x450
[  575.738493]  [<ffffffff8110274b>] ? trace_hardirqs_on+0x1b/0x30
[  575.738564]  [<ffffffff81323e49>] ? ext4_mb_initialize_context+0x99/0x220
[  575.738638]  [<ffffffff8132aabf>] ext4_mb_new_blocks+0x2cf/0x630
[  575.738708]  [<ffffffff8131b902>] ext4_ext_map_blocks+0x5b2/0x2910
[  575.738780]  [<ffffffff811a563e>] ? find_get_pages_tag+0x14e/0x280
[  575.738851]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.738923]  [<ffffffff812f465a>] ? ext4_map_blocks+0xda/0x380
[  575.738993]  [<ffffffff812f47b1>] ext4_map_blocks+0x231/0x380
[  575.739065]  [<ffffffff812f7e2d>] mpage_da_map_blocks+0xbd/0x610
[  575.739136]  [<ffffffff812f8fdb>] ext4_da_writepages+0x50b/0x840
[  575.739208]  [<ffffffff8110747c>] ? lock_release_non_nested+0x16c/0x440
[  575.739280]  [<ffffffff811b4659>] do_writepages+0x29/0x60
[  575.739351]  [<ffffffff81251550>] writeback_single_inode+0xd0/0x3e0
[  575.739423]  [<ffffffff81251e96>] generic_writeback_sb_inodes+0x106/0x230
[  575.739495]  [<ffffffff81251fff>] do_writeback_sb_inodes+0x3f/0x50
[  575.739566]  [<ffffffff81252b99>] writeback_inodes_wb+0x99/0x200
[  575.739637]  [<ffffffff810ee46d>] ? local_clock+0x9d/0xb0
[  575.739707]  [<ffffffff81253042>] wb_writeback+0x342/0x510
[  575.739778]  [<ffffffff810fee3b>] ? trace_hardirqs_off+0x1b/0x30
[  575.739849]  [<ffffffff8125337e>] wb_do_writeback+0xce/0x290
[  575.739920]  [<ffffffff812536ea>] bdi_writeback_thread+0x1aa/0x3e0
[  575.739990]  [<ffffffff81253540>] ? bdi_writeback_thread+0x0/0x3e0
[  575.740062]  [<ffffffff810e3dad>] kthread+0xcd/0xe0
[  575.740131]  [<ffffffff8104e9e4>] kernel_thread_helper+0x4/0x10
[  575.740201]  [<ffffffff81b83b10>] ? restore_args+0x0/0x30
[  575.740271]  [<ffffffff810e3ce0>] ? kthread+0x0/0xe0
[  575.740340]  [<ffffffff8104e9e0>] ? kernel_thread_helper+0x0/0x10
[

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
