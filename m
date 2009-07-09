Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 476916B009B
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 22:39:21 -0400 (EDT)
Date: Thu, 9 Jul 2009 10:47:10 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH 1/2] vmscan don't isolate too many pages in a zone
Message-ID: <20090709024710.GA16783@localhost>
References: <20090707182947.0C6D.A69D9226@jp.fujitsu.com> <20090707184034.0C70.A69D9226@jp.fujitsu.com> <4A539B11.5020803@redhat.com> <20090708031901.GA9924@localhost> <20090708215105.5016c929@bree.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090708215105.5016c929@bree.surriel.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 09, 2009 at 09:51:05AM +0800, Rik van Riel wrote:
> When way too many processes go into direct reclaim, it is possible
> for all of the pages to be taken off the LRU.  One result of this
> is that the next process in the page reclaim code thinks there are
> no reclaimable pages left and triggers an out of memory kill.
> 
> One solution to this problem is to never let so many processes into
> the page reclaim path that the entire LRU is emptied.  Limiting the
> system to only having half of each inactive list isolated for
> reclaim should be safe.
> 
> Signed-off-by: Rik van Riel <riel@redhat.com>
> ---
> On Wed, 8 Jul 2009 11:19:01 +0800
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
> > > I guess I should mail out my (ugly) approach, so we can
> > > compare the two :)
> > 
> > And it helps to be aware of all the alternatives, now and future :)
> 
> Here is the per-zone alternative to Kosaki's patch.
> 
> I believe Kosaki's patch will result in better performance
> and is more elegant overall, but here it is :)
> 
>  mm/vmscan.c |   25 +++++++++++++++++++++++++
>  1 file changed, 25 insertions(+)
> 
> Index: mmotm/mm/vmscan.c
> ===================================================================
> --- mmotm.orig/mm/vmscan.c	2009-07-08 21:37:01.000000000 -0400
> +++ mmotm/mm/vmscan.c	2009-07-08 21:39:02.000000000 -0400
> @@ -1035,6 +1035,27 @@ int isolate_lru_page(struct page *page)
>  }
>  
>  /*
> + * Are there way too many processes in the direct reclaim path already?
> + */
> +static int too_many_isolated(struct zone *zone, int file)
> +{
> +	unsigned long inactive, isolated;
> +
> +	if (current_is_kswapd())
> +		return 0;
> +
> +	if (file) {
> +		inactive = zone_page_state(zone, NR_INACTIVE_FILE);
> +		isolated = zone_page_state(zone, NR_ISOLATED_FILE);
> +	} else {
> +		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
> +		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
> +	}
> +
> +	return isolated > inactive;
> +}
> +
> +/*
>   * shrink_inactive_list() is a helper for shrink_zone().  It returns the number
>   * of reclaimed pages
>   */
> @@ -1049,6 +1070,10 @@ static unsigned long shrink_inactive_lis
>  	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
>  	int lumpy_reclaim = 0;
>  
> +	while (unlikely(too_many_isolated(zone, file))) {
> +		schedule_timeout_interruptible(HZ/10);
> +	}
> +
>  	/*
>  	 * If we need a large contiguous chunk of memory, or have
>  	 * trouble getting a small set of contiguous pages, we

It survives 5 runs. The first 4 runs are relatively smooth. The 5th run is much
slower, and the 6th run triggered a soft-lockup warning. Anyway this record seems
better than KOSAKI's patch, which triggered soft-lockup at the first run yesterday.

        Last login: Wed Jul  8 11:10:06 2009 from 192.168.2.1
1)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
2)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
3)      wfg@hp ~% /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
4)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
        /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  3.38s user 52.90s system 191% cpu 29.399 total
5)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
        /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  4.54s user 488.33s system 129% cpu 6:19.14 total
6)      wfg@hp ~% time /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11
        msgctl11    0  INFO  :  Using upto 16300 pids
        msgctl11    1  PASS  :  msgctl11 ran successfully!
        /cc/ltp/ltp-full-20090531/./testcases/kernel/syscalls/ipc/msgctl/msgctl11  4.62s user 778.82s system 149% cpu 8:43.85 total


[ 1440.932891] INFO: task msgctl11:30739 blocked for more than 120 seconds.
[ 1440.935108] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1440.937857] msgctl11      D ffffffff8180f650  5992 30739  26108 0x00000000
[ 1440.940491]  ffff880035d9bdd8 0000000000000046 0000000000000000 0000000000000046
[ 1440.943174]  ffff880035d9bd48 00000000001d2d80 000000000000cec8 ffff8800308a0000
[ 1440.946854]  ffff8800140ba280 ffff8800308a0380 0000000135d9bd88 ffffffff8107d5d8
[ 1440.949513] Call Trace:
[ 1440.951006]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1440.953274]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1440.955519]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1440.957084]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1440.958426]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1440.960642]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1440.961813]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1440.963110]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1440.965340]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1440.967504]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1440.968734]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1440.971005]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1440.973433]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1440.975958]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1440.978280] 1 lock held by msgctl11/30739:
[ 1440.980199]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1440.984155] INFO: task msgctl11:30751 blocked for more than 120 seconds.
[ 1440.985763] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1440.988407] msgctl11      D ffffffff8180f650  5992 30751  26108 0x00000000
[ 1440.991030]  ffff880011917dd8 0000000000000046 0000000000000000 0000000000000046
[ 1440.993476]  ffff880011917d48 00000000001d2d80 000000000000cec8 ffff88000b82c500
[ 1440.997447]  ffff8800104e8000 ffff88000b82c880 0000000111917d88 ffffffff8107d5d8
[ 1441.001098] Call Trace:
[ 1441.001657]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.004954]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.007229]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.009664]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.012093]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.013202]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.014389]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.015637]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.017001]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.018256]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.020376]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.022552]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.024070]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.025494]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.026933] 1 lock held by msgctl11/30751:
[ 1441.027855]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.032825] INFO: task msgctl11:30765 blocked for more than 120 seconds.
[ 1441.034316] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.037090] msgctl11      D ffffffff8180f650  5992 30765  26108 0x00000000
[ 1441.038633]  ffff8800175e1dd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.042420]  ffff8800175e1d48 00000000001d2d80 000000000000cec8 ffff880026b54500
[ 1441.046070]  ffff88003ff74500 ffff880026b54880 00000001175e1d88 000000010003abf8
[ 1441.049564] Call Trace:
[ 1441.050349]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.052493]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.055100]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.057366]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.058529]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.060741]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.063105]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.065298]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.067490]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.069609]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.070947]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.072394]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.074809]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.076236] 1 lock held by msgctl11/30765:
[ 1441.077146]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.081127] INFO: task msgctl11:30767 blocked for more than 120 seconds.
[ 1441.082590] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.085415] msgctl11      D ffffffff8180f650  5992 30767  26108 0x00000000
[ 1441.086987]  ffff88003671bdd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.089704]  ffff88003671bd48 00000000001d2d80 000000000000cec8 ffff880037e22280
[ 1441.092409]  ffff88000aacc500 ffff880037e22600 000000013671bd88 ffffffff8107d5d8
[ 1441.096056] Call Trace:
[ 1441.096604]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.098759]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.100328]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.102622]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.104030]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.105198]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.107339]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.109589]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.111046]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.113119]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.114270]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.115482]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.117045]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.118482]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.121630] 1 lock held by msgctl11/30767:
[ 1441.122735]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.126682] INFO: task msgctl11:30778 blocked for more than 120 seconds.
[ 1441.129232] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.132064] msgctl11      D ffffffff8180f650  5992 30778  26108 0x00000000
[ 1441.134534]  ffff880015085dd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.137341]  ffff880015085d48 00000000001d2d80 000000000000cec8 ffff880024190000
[ 1441.139971]  ffff88001e6fa280 ffff880024190380 0000000115085d88 ffffffff8107d5d8
[ 1441.143691] Call Trace:
[ 1441.145193]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.147441]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.148737]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.152295]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.154582]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.156767]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.157843]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.159290]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.160587]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.162714]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.164849]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.167166]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.169578]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.171147]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.172447] 1 lock held by msgctl11/30778:
[ 1441.173391]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.177342] INFO: task msgctl11:30779 blocked for more than 120 seconds.
[ 1441.178802] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.181607] msgctl11      D ffffffff8180f650  5992 30779  26108 0x00000000
[ 1441.184220]  ffff8800141bddd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.186951]  ffff8800141bdd48 00000000001d2d80 000000000000cec8 ffff880024194500
[ 1441.190716]  ffff88003ff74500 ffff880024194880 00000001141bdd88 000000010003ad99
[ 1441.194288] Call Trace:
[ 1441.194855]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.196988]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.198579]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.201039]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.203022]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.204322]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.206599]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.208802]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.209990]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.212208]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.213447]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.215947]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.218461]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.220860] 1 lock held by msgctl11/30779:
[ 1441.222667]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.226674] INFO: task msgctl11:30781 blocked for more than 120 seconds.
[ 1441.228079] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.231064] msgctl11      D ffffffff8180f650  5992 30781  26108 0x00000000
[ 1441.234493]  ffff88001d955dd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.236997]  ffff88001d955d48 00000000001d2d80 000000000000cec8 ffff88001896a280
[ 1441.238927]  ffff880039554500 ffff88001896a600 000000011d955d88 ffffffff8107d5d8
[ 1441.242591] Call Trace:
[ 1441.243146]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.245393]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.246704]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.249133]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.252552]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.253690]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.254861]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.257165]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.259506]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.260715]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.262789]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.265018]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.266554]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.267990]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.269422] 1 lock held by msgctl11/30781:
[ 1441.271342]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.275352] INFO: task msgctl11:30782 blocked for more than 120 seconds.
[ 1441.278605] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.280612] msgctl11      D ffffffff8180f650  6168 30782  26108 0x00000000
[ 1441.283112]  ffff8800141b5dd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.285893]  ffff8800141b5d48 00000000001d2d80 000000000000cec8 ffff8800232d0000
[ 1441.289531]  ffff88003ff82280 ffff8800232d0380 00000001141b5d88 ffffffff8107d5d8
[ 1441.292220] Call Trace:
[ 1441.293698]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.296193]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.298242]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.299805]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.302286]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.304316]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.306543]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.308789]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.310067]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.312322]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.314468]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.315669]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.317154]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.319681]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.320988] 1 lock held by msgctl11/30782:
[ 1441.322917]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.326888] INFO: task msgctl11:30783 blocked for more than 120 seconds.
[ 1441.329309] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.332241] msgctl11      D ffffffff8180f650  5992 30783  26108 0x00000000
[ 1441.335720]  ffff880017ffddd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.338168]  ffff880017ffdd48 00000000001d2d80 000000000000cec8 ffff8800232d2280
[ 1441.341925]  ffff880025a92280 ffff8800232d2600 0000000117ffdd88 ffffffff8107d5d8
[ 1441.345809] Call Trace:
[ 1441.346389]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.348624]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.350996]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.353383]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.354782]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.355940]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.357084]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.358357]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.359733]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.360854]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.362108]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.364234]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.365787]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.367227]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.370663] 1 lock held by msgctl11/30783:
[ 1441.371584]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.374517] INFO: task msgctl11:30784 blocked for more than 120 seconds.
[ 1441.376004] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1441.378807] msgctl11      D ffffffff8180f650  6024 30784  26108 0x00000000
[ 1441.380338]  ffff880013e13dd8 0000000000000046 0000000000000000 0000000000000046
[ 1441.383118]  ffff880013e13d48 00000000001d2d80 000000000000cec8 ffff880032408000
[ 1441.386763]  ffff88003ff82280 ffff880032408380 0000000113e13d88 ffffffff8107d5d8
[ 1441.390296] Call Trace:
[ 1441.390944]  [<ffffffff8107d5d8>] ? mark_held_locks+0x68/0x90
[ 1441.392288]  [<ffffffff8158e020>] ? _spin_unlock_irq+0x30/0x40
[ 1441.394469]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.397020]  [<ffffffff8158d9f5>] __down_write_nested+0x85/0xc0
[ 1441.398316]  [<ffffffff8158da3b>] __down_write+0xb/0x10
[ 1441.399907]  [<ffffffff8158cc2d>] down_write+0x6d/0x90
[ 1441.401881]  [<ffffffff8126dc0d>] ? ipcctl_pre_down+0x3d/0x150
[ 1441.404015]  [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150
[ 1441.405272]  [<ffffffff8126f3ce>] sys_msgctl+0xbe/0x5a0
[ 1441.407434]  [<ffffffff8106e74b>] ? up_read+0x2b/0x40
[ 1441.409661]  [<ffffffff8100cc35>] ? retint_swapgs+0x13/0x1b
[ 1441.410959]  [<ffffffff8107d915>] ? trace_hardirqs_on_caller+0x155/0x1a0
[ 1441.413347]  [<ffffffff8158db2e>] ? trace_hardirqs_on_thunk+0x3a/0x3f
[ 1441.414874]  [<ffffffff8100c0f2>] system_call_fastpath+0x16/0x1b
[ 1441.417228] 1 lock held by msgctl11/30784:
[ 1441.419163]  #0:  (&ids->rw_mutex){+++++.}, at: [<ffffffff8126dc0d>] ipcctl_pre_down+0x3d/0x150

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
