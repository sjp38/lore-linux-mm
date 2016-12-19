Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4D0956B028B
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 06:25:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so159563437pgn.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 03:25:18 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z26si18053255pfk.57.2016.12.19.03.25.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Dec 2016 03:25:16 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
	<20161214124231.GI25573@dhcp22.suse.cz>
	<201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
	<20161214181850.GC16763@dhcp22.suse.cz>
	<201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
In-Reply-To: <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
Message-Id: <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
Date: Mon, 19 Dec 2016 20:25:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Tetsuo Handa wrote:
> I think that the oom_lock stall problem is essentially independent with
> printk() from warn_alloc(). I can trigger lockups even if I use one-liner
> stall report per each second like below.
> 
> --------------------
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 6de9440..dc7f6be 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3657,10 +3657,14 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>  
>  	/* Make sure we know about allocations which stall for too long */
>  	if (time_after(jiffies, alloc_start + stall_timeout)) {
> -		warn_alloc(gfp_mask,
> -			"page allocation stalls for %ums, order:%u",
> -			jiffies_to_msecs(jiffies-alloc_start), order);
> -		stall_timeout += 10 * HZ;
> +		static DEFINE_RATELIMIT_STATE(stall_rs, HZ, 1);
> +
> +		if (__ratelimit(&stall_rs)) {
> +			pr_warn("%s(%u): page allocation stalls for %ums, order:%u mode:%#x(%pGg)\n",
> +				current->comm, current->pid, jiffies_to_msecs(jiffies - alloc_start),
> +				order, gfp_mask, &gfp_mask);
> +			stall_timeout += 10 * HZ;
> +		}
>  	}
>  
>  	if (should_reclaim_retry(gfp_mask, order, ac, alloc_flags,
> --------------------
>
> This stall lasted with only two kernel messages per a second. I wonder we
> have room for tuning warn_alloc() unless the trigger is identified and fixed.

I retested using netconsole for recording clock time without delays. It seems to me
that once the system reaches some threshold, even ratelimiting to two kernel messages
per a second does not help flushing printk buffer. CPU time for flushing printk buffer
is definitely insufficient because direct reclaimers waiting for oom_lock continued
almost-busy looping.

The first OOM killer was on 16:14:24 and a lot of OOM messages are scheduled for
printk(). As of 16:17:00, the flushing was delaying for 40 seconds (clock time
elapsed is 156 seconds but printk time elapsed is only 116 seconds).

I pressed SysRq-H on 16:17:05 and the message by SysRq-H was printed on 16:20:03.
The delay was getting larger (clock time since first OOM killer is 219 seconds but
printk time elapsed is only 161 seconds).

Then, I waited for a while whether ratelimiting to two kernel messages per a
second helps flushing printk buffer. But it did not help because only two
kernel messages are printed per a second or two seconds.

I pressed SysRq-E on 16:23:15 and flushing became as fast as possible because
some threads which terminated immediately helped solving the OOM situation and
helped direct reclaimers not to consume CPU time by pointless direct reclaim loop.
As of 16:23:18, all printk buffer was flushed and the delay was completely solved
(clock time since first OOM killer is 534 seconds and printk elapsed time is 531
seconds).

Complete log is http://I-love.SAKURA.ne.jp/tmp/netconsole-20161219.txt.xz .
----------------------------------------
2016-12-19 16:14:24 192.168.186.128:6666 [   61.383922] kworker/0:0 invoked oom-killer: gfp_mask=0x26040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=0, order=0, oom_score_adj=0
(...snipped...)
2016-12-19 16:17:00 192.168.186.128:6666 [  177.731850] __alloc_pages_slowpath: 86652 callbacks suppressed
2016-12-19 16:17:08 192.168.186.128:6666 [  177.731852] a.out(4225): page allocation stalls for 47748ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
(...snipped...)
2016-12-19 16:20:03 192.168.186.128:6666 [  222.241385] sysrq: SysRq : HELP : loglevel(0-9) reboot(b) crash(c) show-all-locks(d) terminate-all-tasks(e) memory-full-oom-kill(f) kill-all-tasks(i) thaw-filesystems(j) sak(k) show-backtrace-all-active-cpus(l) show-memory-usage(m) nice-all-RT-tasks(n) poweroff(o) show-registers(p) show-all-timers(q) unraw(r) sync(s) show-task-states(t) unmount(u) show-blocked-tasks(w) dump-ftrace-buffer(z)
(...snipped...)
2016-12-19 16:23:01 192.168.186.128:6666 [  279.848855] __alloc_pages_slowpath: 90002 callbacks suppressed
2016-12-19 16:23:02 192.168.186.128:6666 [  279.848857] a.out(4195): page allocation stalls for 150144ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:04 192.168.186.128:6666 [  280.849909] __alloc_pages_slowpath: 90381 callbacks suppressed
2016-12-19 16:23:05 192.168.186.128:6666 [  280.849913] a.out(4242): page allocation stalls for 151122ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:05 192.168.186.128:6666 [  281.850976] __alloc_pages_slowpath: 90292 callbacks suppressed
2016-12-19 16:23:08 192.168.186.128:6666 [  281.850979] a.out(4329): page allocation stalls for 151818ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:10 192.168.186.128:6666 [  282.852029] __alloc_pages_slowpath: 89988 callbacks suppressed
2016-12-19 16:23:10 192.168.186.128:6666 [  282.852032] a.out(3981): page allocation stalls for 152873ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:12 192.168.186.128:6666 [  283.852585] __alloc_pages_slowpath: 90468 callbacks suppressed
2016-12-19 16:23:13 192.168.186.128:6666 [  283.852589] a.out(3854): page allocation stalls for 154167ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
2016-12-19 16:23:15 192.168.186.128:6666 [  284.853651] __alloc_pages_slowpath: 90091 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  284.853654] a.out(4011): page allocation stalls for 154625ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:15 192.168.186.128:6666 [  285.854709] __alloc_pages_slowpath: 90481 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  285.854712] mysqld(2467): page allocation stalls for 155635ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:15 192.168.186.128:6666 [  286.855765] __alloc_pages_slowpath: 90363 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  286.855768] mysqld(2467): page allocation stalls for 156636ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:15 192.168.186.128:6666 [  287.856871] __alloc_pages_slowpath: 90794 callbacks suppressed
(...snipped...)
2016-12-19 16:23:15 192.168.186.128:6666 [  330.899814] __alloc_pages_slowpath: 85298 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  330.899817] a.out(3937): page allocation stalls for 201204ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
2016-12-19 16:23:15 192.168.186.128:6666 [  331.900876] __alloc_pages_slowpath: 88338 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  331.900879] tuned(2414): page allocation stalls for 201869ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:15 192.168.186.128:6666 [  332.901929] __alloc_pages_slowpath: 86052 callbacks suppressed
2016-12-19 16:23:15 192.168.186.128:6666 [  332.901932] a.out(4252): page allocation stalls for 203197ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:16 192.168.186.128:6666 [  333.902994] __alloc_pages_slowpath: 88699 callbacks suppressed
2016-12-19 16:23:16 192.168.186.128:6666 [  333.902997] mysqld(2464): page allocation stalls for 203684ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:16 192.168.186.128:6666 [  334.904057] __alloc_pages_slowpath: 88382 callbacks suppressed
2016-12-19 16:23:16 192.168.186.128:6666 [  334.904059] systemd(1): page allocation stalls for 165774ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
(...snipped...)
2016-12-19 16:23:16 192.168.186.128:6666 [  425.006012] __alloc_pages_slowpath: 88655 callbacks suppressed
2016-12-19 16:23:16 192.168.186.128:6666 [  425.006014] systemd(1): page allocation stalls for 255876ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:16 192.168.186.128:6666 [  426.007042] __alloc_pages_slowpath: 86528 callbacks suppressed
2016-12-19 16:23:16 192.168.186.128:6666 [  426.007046] a.out(4062): page allocation stalls for 296298ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:16 192.168.186.128:6666 [  427.007621] __alloc_pages_slowpath: 82527 callbacks suppressed
2016-12-19 16:23:17 192.168.186.128:6666 [  427.007624] postgres(2416): page allocation stalls for 296946ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:17 192.168.186.128:6666 [  428.008697] __alloc_pages_slowpath: 86985 callbacks suppressed
2016-12-19 16:23:17 192.168.186.128:6666 [  428.008700] a.out(3841): page allocation stalls for 298293ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
(...snipped...)
2016-12-19 16:23:17 192.168.186.128:6666 [  522.135752] __alloc_pages_slowpath: 90737 callbacks suppressed
2016-12-19 16:23:17 192.168.186.128:6666 [  522.135755] a.out(4563): page allocation stalls for 392427ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:17 192.168.186.128:6666 [  523.136816] __alloc_pages_slowpath: 90260 callbacks suppressed
2016-12-19 16:23:17 192.168.186.128:6666 [  523.136819] a.out(4443): page allocation stalls for 393420ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:17 192.168.186.128:6666 [  524.137890] __alloc_pages_slowpath: 86161 callbacks suppressed
2016-12-19 16:23:18 192.168.186.128:6666 [  524.137892] a.out(4048): page allocation stalls for 394432ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:18 192.168.186.128:6666 [  525.138932] __alloc_pages_slowpath: 90421 callbacks suppressed
2016-12-19 16:23:18 192.168.186.128:6666 [  525.138934] a.out(4051): page allocation stalls for 395440ms, order:0 mode:0x342004a(GFP_NOFS|__GFP_HIGHMEM|__GFP_HARDWALL|__GFP_MOVABLE|__GFP_WRITE)
(...snipped...)
2016-12-19 16:23:18 192.168.186.128:6666 [  589.260793] __alloc_pages_slowpath: 90260 callbacks suppressed
2016-12-19 16:23:18 192.168.186.128:6666 [  589.260797] a.out(3772): page allocation stalls for 459277ms, order:0 mode:0x26042c0(GFP_KERNEL|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:18 192.168.186.128:6666 [  590.261875] __alloc_pages_slowpath: 89716 callbacks suppressed
2016-12-19 16:23:18 192.168.186.128:6666 [  590.261878] kworker/0:5(4629): page allocation stalls for 459918ms, order:0 mode:0x2604240(GFP_NOFS|__GFP_NOWARN|__GFP_COMP|__GFP_NOTRACK)
2016-12-19 16:23:18 192.168.186.128:6666 [  591.262660] __alloc_pages_slowpath: 89555 callbacks suppressed
2016-12-19 16:23:18 192.168.186.128:6666 [  591.262663] postgres(2415): page allocation stalls for 255434ms, order:0 mode:0x24201ca(GFP_HIGHUSER_MOVABLE|__GFP_COLD)
2016-12-19 16:23:18 192.168.186.128:6666 [  592.094337] sysrq: SysRq : Terminate All Tasks
2016-12-19 16:23:18 192.168.186.128:6666 [  592.900136] systemd-journald[377]: Received SIGTERM.
----------------------------------------

So, I'd like to check whether async printk() can prevent the system from reaching
the threshold. Though, I guess async printk() won't help for preemption outside
printk() (i.e. CONFIG_PREEMPT=y and/or longer sleep by schedule_timeout_killable(1)
after returning from oom_kill_process()).

Sergey, will you share your async printk() patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
