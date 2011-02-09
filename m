Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8B6C78D003A
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 04:51:30 -0500 (EST)
Date: Wed, 9 Feb 2011 10:51:22 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH][BUGFIX] memcg: fix leak of accounting at failure path of
 hugepage collapsing.
Message-ID: <20110209095122.GG27110@cmpxchg.org>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
 <20110209162324.ea7e2e52.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110209162324.ea7e2e52.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

On Wed, Feb 09, 2011 at 04:23:24PM +0900, KAMEZAWA Hiroyuki wrote:
> There was a big bug. Anyway, thank you for adding new bad_page for memcg.

That check is really awesome :-)

> mem_cgroup_uncharge_page() should be called in all failure case
> after mem_cgroup_charge_newpage() is called in 
> huge_memory.c::collapse_huge_page()
>
>  [ 4209.076861] BUG: Bad page state in process khugepaged  pfn:1e9800
>  [ 4209.077601] page:ffffea0006b14000 count:0 mapcount:0 mapping:          (null) index:0x2800
>  [ 4209.078674] page flags: 0x40000000004000(head)
>  [ 4209.079294] pc:ffff880214a30000 pc->flags:2146246697418756 pc->mem_cgroup:ffffc9000177a000
>  [ 4209.082177] (/A)
>  [ 4209.082500] Pid: 31, comm: khugepaged Not tainted 2.6.38-rc3-mm1 #1
>  [ 4209.083412] Call Trace:
>  [ 4209.083678]  [<ffffffff810f4454>] ? bad_page+0xe4/0x140
>  [ 4209.084240]  [<ffffffff810f53e6>] ? free_pages_prepare+0xd6/0x120
>  [ 4209.084837]  [<ffffffff8155621d>] ? rwsem_down_failed_common+0xbd/0x150
>  [ 4209.085509]  [<ffffffff810f5462>] ? __free_pages_ok+0x32/0xe0
>  [ 4209.086110]  [<ffffffff810f552b>] ? free_compound_page+0x1b/0x20
>  [ 4209.086699]  [<ffffffff810fad6c>] ? __put_compound_page+0x1c/0x30
>  [ 4209.087333]  [<ffffffff810fae1d>] ? put_compound_page+0x4d/0x200
>  [ 4209.087935]  [<ffffffff810fb015>] ? put_page+0x45/0x50
>  [ 4209.097361]  [<ffffffff8113f779>] ? khugepaged+0x9e9/0x1430
>  [ 4209.098364]  [<ffffffff8107c870>] ? autoremove_wake_function+0x0/0x40
>  [ 4209.099121]  [<ffffffff8113ed90>] ? khugepaged+0x0/0x1430
>  [ 4209.099780]  [<ffffffff8107c236>] ? kthread+0x96/0xa0
>  [ 4209.100452]  [<ffffffff8100dda4>] ? kernel_thread_helper+0x4/0x10
>  [ 4209.101214]  [<ffffffff8107c1a0>] ? kthread+0x0/0xa0
>  [ 4209.101842]  [<ffffffff8100dda0>] ? kernel_thread_helper+0x0/0x10
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

Thanks for debugging this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
