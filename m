Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 746256B0072
	for <linux-mm@kvack.org>; Tue, 28 May 2013 17:51:25 -0400 (EDT)
Message-ID: <51A526D9.3020803@sr71.net>
Date: Tue, 28 May 2013 14:51:21 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: mmotm-2013-05-22: Bad page state
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>

I was rebasing my mapping->radix_tree lock batching patches on top of
Mel's stuff.  It looks like something is jumping the gun and freeing a
page before it has been written out.  Somebody probably did an extra
put_page() or something.

I'm running 3.10.0-rc2-mm1-00322-g8d4c612 from

	git://git.cmpxchg.org/linux-mmotm.git

This is pretty reproducible.  I'll go try and test plain 3.10-rc2 next
to make sure it's not coming from Linus's stuff.

> [ 1628.443800] BUG: Bad page state in process kswapd0  pfn:1fc86c9
> [ 1628.449781] page:ffffea007f21b240 count:0 mapcount:0 mapping:          (null) index:0x1c15
> [ 1628.458214] page flags: 0x400000000c2008(uptodate|writeback|reclaim|swapbacked)
> [ 1628.465624] Modules linked in:
> [ 1628.468721] CPU: 5 PID: 68 Comm: kswapd0 Tainted: G        W    3.10.0-rc2-mm1-00322-g8d4c612-dirty #183
> [ 1628.478400] Hardware name: FUJITSU-SV PRIMEQUEST 1800E2/SB, BIOS PRIMEQUEST 1000 Series BIOS Version 1.24 09/14/2011
> [ 1628.489149]  0000000000000001 ffff881fd22498c8 ffffffff819163f2 0000000000005d42
> [ 1628.496646]  ffffea007f21b240 ffff881fd22498e8 ffffffff811e2bd5 ffffea007f21b240
> [ 1628.504159]  ffffea007f21b240 ffff881fd2249928 ffffffff811e3a7b ffff881fd2249948
> [ 1628.511668] Call Trace:
> [ 1628.514170]  [<ffffffff819163f2>] dump_stack+0x86/0xc3
> [ 1628.519376]  [<ffffffff811e2bd5>] bad_page+0x145/0x180
> [ 1628.524589]  [<ffffffff811e3a7b>] free_pages_prepare+0x1bb/0x1d0
> [ 1628.530696]  [<ffffffff811e4658>] free_hot_cold_page+0x48/0x200
> [ 1628.536701]  [<ffffffff811e4d8e>] free_hot_cold_page_list+0x6e/0x150
> [ 1628.543154]  [<ffffffff811f32d5>] shrink_page_list+0x575/0xfc0
> [ 1628.549065]  [<ffffffff811f3ef7>] shrink_inactive_list+0x1d7/0x730
> [ 1628.555340]  [<ffffffff811f48a4>] shrink_lruvec+0x454/0x8b0
> [ 1628.561002]  [<ffffffff8125b5d1>] ? __mem_cgroup_largest_soft_limit_node+0x31/0x160
> [ 1628.568825]  [<ffffffff8125b5d1>] ? __mem_cgroup_largest_soft_limit_node+0x31/0x160
> [ 1628.576659]  [<ffffffff811f4fe6>] shrink_zone+0x86/0x280
> [ 1628.582038]  [<ffffffff811f5c67>] balance_pgdat+0x697/0x940
> [ 1628.587694]  [<ffffffff811f6116>] kswapd+0x206/0x6e0
> [ 1628.592732]  [<ffffffff8191de75>] ? __schedule+0x3e5/0xc10
> [ 1628.598306]  [<ffffffff811015f0>] ? wake_up_bit+0x50/0x50
> [ 1628.603779]  [<ffffffff811f5f10>] ? balance_pgdat+0x940/0x940
> [ 1628.609614]  [<ffffffff8110033b>] kthread+0xcb/0xe0
> [ 1628.614559]  [<ffffffff81100270>] ? __kthread_parkme+0xc0/0xc0
> [ 1628.620481]  [<ffffffff8192cf5c>] ret_from_fork+0x7c/0xb0
> [ 1628.625966]  [<ffffffff81100270>] ? __kthread_parkme+0xc0/0xc0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
