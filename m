Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A0786B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 00:16:27 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o16so1196358pgv.3
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 21:16:27 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 189sor272222pge.298.2018.01.15.21.16.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Jan 2018 21:16:26 -0800 (PST)
Date: Tue, 16 Jan 2018 14:16:22 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116051622.GB13731@jagdpanzerIV>
References: <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
 <20180113073100.GB1701@tigerII.localdomain>
 <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On (01/15/18 09:51), Petr Mladek wrote:
> On Sat 2018-01-13 16:31:00, Sergey Senozhatsky wrote:
> > On (01/12/18 13:55), Petr Mladek wrote:
> > [..]
> > > > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > > > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > > > PREEMPT kernels than !PREEMPT ones.
> > > 
> > > I would say that the patch improves also console_unlock() but only in
> > > non-preemttive context.
> > > 
> > > By other words, it makes console_unlock() finite in preemptible context
> > > (limited by buffer size). It might still be unlimited in
> > > non-preemtible context.
> > 
> > could you elaborate a bit?
> 
> Ah, I am sorry, I swapped the conditions. I meant that
> console_unlock() is finite in non-preemptible context.

by the way. just for the record,

probably there is a way for us to have a task printing more than
O(logbuf) even in non-preemptible context.

	CPU0

	vprintk_emit()
	 preempt_disable()
	  console_unlock()
	  {
	   for (;;) {
                printk_safe_enter_irqsave()
	        call_console_drivers();
	        printk_safe_exit_irqrestore()

	<< IRQ >>
		dump_stack()
		 printk()->log_store()
		 ....
		 printk()->log_store()
	<< iret >>
	   }
	  }
	 preempt_enable()

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
