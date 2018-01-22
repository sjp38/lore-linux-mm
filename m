Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54CE7800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 05:29:04 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id x24so8381184pge.13
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 02:29:04 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p25sor1083832pfj.117.2018.01.22.02.29.02
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 22 Jan 2018 02:29:03 -0800 (PST)
Date: Mon, 22 Jan 2018 19:28:57 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180122102857.GC403@jagdpanzerIV>
References: <20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
 <20180117151509.GT3460072@devbig577.frc2.facebook.com>
 <20180117121251.7283a56e@gandalf.local.home>
 <20180117134201.0a9cbbbf@gandalf.local.home>
 <20180119132052.02b89626@gandalf.local.home>
 <20180120071402.GB8371@jagdpanzerIV>
 <20180120104931.1942483e@gandalf.local.home>
 <20180121141521.GA429@tigerII.localdomain>
 <20180121160441.7ea4b6d9@gandalf.local.home>
 <20180122085632.GA403@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180122085632.GA403@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/22/18 17:56), Sergey Senozhatsky wrote:
[..]
> Assume the following,

But more importantly we are missing another huge thing - console_unlock().

Suppose:

	console_lock();
	<< preemption >>
						printk
						printk
						..
						printk
	console_unlock()
	 for (;;) {
		call_console_drivers()
		   dump_stack
		   queue IRQ work

		IRQ work >>
		   flush_printk_safe
		   printk_deferred()
		   ...
		   printk_deferred()
		<< iret
	 }

This should explode: sleepable console_unlock() may reschedule,
printk_safe flush bypasses recursion checks.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
