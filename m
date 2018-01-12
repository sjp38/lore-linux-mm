Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 770A36B0038
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 20:31:03 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b75so1830045pfk.22
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 17:31:03 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id n76si1569565pfi.56.2018.01.11.17.31.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jan 2018 17:31:01 -0800 (PST)
Date: Thu, 11 Jan 2018 20:30:57 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180111203057.5b1a8f8f@gandalf.local.home>
In-Reply-To: <20180111112908.50de440a@vmware.local.home>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110140547.GZ3668920@devbig577.frc2.facebook.com>
	<20180110130517.6ff91716@vmware.local.home>
	<20180111045817.GA494@jagdpanzerIV>
	<20180111093435.GA24497@linux.suse>
	<20180111103845.GB477@jagdpanzerIV>
	<20180111112908.50de440a@vmware.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Petr Mladek <pmladek@suse.com>, Tejun Heo <tj@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 11:29:08 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> > claiming that for any given A, B, C the following is always true
> > 
> > 				A * B < C
> > 
> > where
> > 	A is the amount of data to print in the worst case
> > 	B the time call_console_drivers() needs to print a single
> > 	  char to all registered and enabled consoles
> > 	C the watchdog's threshold
> > 
> > is not really a step forward.  
> 
> It's no different than what we have, except that we currently have A
> being infinite. My patch makes A no longer infinite, but a constant.
> Yes that constant is mutable, but it's still a constant, and
> controlled by the user. That to me is definitely a BIG step forward.

I have to say that your analysis here really does point out the benefit
of my patch.

Today, printk() can print for a time of A * B, where, as you state
above:

   A is the amount of data to print in the worst case
   B the time call_console_drivers() needs to print a single
	  char to all registered and enabled consoles

In the worse case, the current approach is A is infinite. That is,
printk() never stops, as long as there is a printk happening on another
CPU before B can finish. A will keep growing. The call to printk() will
never return. The more CPUs you have, the more likely this will occur.
All it takes is a few CPUs doing periodic printks. If there is a slow
console, where the periodic printk on other CPUs occur quicker than the
first can finish, the first one will be stuck forever. Doesn't take
much to have this happen.

With my patch, A is fixed to the size of the buffer. A single printk()
can never print more than that. If another CPU comes in and does a
printk, then it will take over the task of printing, and release the
first printk.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
