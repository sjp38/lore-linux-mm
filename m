Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C73086B0038
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 04:08:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id z12so9028622pgv.6
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 01:08:50 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r19si1308588pgn.85.2018.01.16.01.08.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 01:08:49 -0800 (PST)
Date: Tue, 16 Jan 2018 10:08:44 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180116090844.mblgmfubxhk77anv@pathway.suse.cz>
References: <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
 <20180113073100.GB1701@tigerII.localdomain>
 <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
 <20180116051622.GB13731@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180116051622.GB13731@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Tue 2018-01-16 14:16:22, Sergey Senozhatsky wrote:
> On (01/15/18 09:51), Petr Mladek wrote:
> > On Sat 2018-01-13 16:31:00, Sergey Senozhatsky wrote:
> > > On (01/12/18 13:55), Petr Mladek wrote:
> > > [..]
> > > > > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > > > > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > > > > PREEMPT kernels than !PREEMPT ones.
> > > > 
> > > > I would say that the patch improves also console_unlock() but only in
> > > > non-preemttive context.
> > > > 
> > > > By other words, it makes console_unlock() finite in preemptible context
> > > > (limited by buffer size). It might still be unlimited in
> > > > non-preemtible context.
> > > 
> > > could you elaborate a bit?
> > 
> > Ah, I am sorry, I swapped the conditions. I meant that
> > console_unlock() is finite in non-preemptible context.
> 
> by the way. just for the record,
> 
> probably there is a way for us to have a task printing more than
> O(logbuf) even in non-preemptible context.
> 
> 	CPU0
> 
> 	vprintk_emit()
> 	 preempt_disable()
> 	  console_unlock()
> 	  {
> 	   for (;;) {
>                 printk_safe_enter_irqsave()
> 	        call_console_drivers();
> 	        printk_safe_exit_irqrestore()
> 
> 	<< IRQ >>
> 		dump_stack()
> 		 printk()->log_store()
> 		 ....
> 		 printk()->log_store()
> 	<< iret >>
> 	   }
> 	  }
> 	 preempt_enable()

Great catch! And good to know about it when designing further
improvements.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
