Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 116B66B0069
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 00:42:58 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id m3so1862716pgd.20
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 21:42:58 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p13sor2053659plo.99.2018.01.17.21.42.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 21:42:56 -0800 (PST)
Date: Thu, 18 Jan 2018 14:42:51 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180118054251.GB6529@jagdpanzerIV>
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
Cc: Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/17/18 12:12), Steven Rostedt wrote:
[..]
>  /*
>   * Can we actually use the console at this time on this cpu?
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
>  
>  		printk_safe_exit_irqrestore(flags);
		^^^^^^^^^^^^^^^^

but we call console drivers in printk_safe.
printk -> console_drivers -> printk will be
redirected to this-CPU printk_safe buffer.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
