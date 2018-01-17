Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76CB66B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 15:06:01 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h32so10822170qtb.9
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 12:06:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t186sor3540609qkf.156.2018.01.17.12.06.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 12:06:00 -0800 (PST)
Date: Wed, 17 Jan 2018 12:05:51 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180117200551.GW3460072@devbig577.frc2.facebook.com>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180111203057.5b1a8f8f@gandalf.local.home>
 <20180111215547.2f66a23a@gandalf.local.home>
 <20180116194456.GS3460072@devbig577.frc2.facebook.com>
 <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117121251.7283a56e@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

Hello, Steven.

On Wed, Jan 17, 2018 at 12:12:51PM -0500, Steven Rostedt wrote:
> From what I gathered, you said an OOM would trigger, and then the
> network console would not be able to allocate memory and it would
> trigger a printk too, and cause an infinite amount of printks.

Yeah, it falls into back-and-forth loop between the OOM code and
netconsole path.

> This could very well be a great place to force offloading. If a printk
> is called from within a printk, at the same context (normal, softirq,
> irq or NMI), then we should trigger the offloading.

I was thinking more of a timeout based approach (ie. if stuck for
longer than X or X messages, offload), but if local feedback loop is
the only thing we're missing after your improvements, detecting that
specific condition definitely works and is likely a better approach in
terms of message delivery guarantee.

> +static void kick_offload_thread(void)
> +{
> +	/*
> +	 * Consoles are triggering printks, offload the printks
> +	 * to another CPU to hopefully avoid a lockup.
> +	 */
> +}
...
> @@ -2333,6 +2390,7 @@ void console_unlock(void)
>  
>  	for (;;) {
>  		struct printk_log *msg;
> +		bool offload;
>  		size_t ext_len = 0;
>  		size_t len;
>  
> @@ -2393,15 +2451,20 @@ void console_unlock(void)
>  		 * waiter waiting to take over.
>  		 */
>  		console_lock_spinning_enable();
> +		offload = recursion_check_start();
>  
>  		stop_critical_timings();	/* don't trace print latency */
>  		call_console_drivers(ext_text, ext_len, text, len);
>  		start_critical_timings();
>  
> +		recursion_check_finish(offload);
> +
>  		if (console_lock_spinning_disable_and_check()) {
>  			printk_safe_exit_irqrestore(flags);
>  			return;
>  		}
> +		if (offload)
> +			kick_offload_thread();

Yeah, something like this would definitely work.

Thanks a lot.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
