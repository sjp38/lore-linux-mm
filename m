Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 796166B0038
	for <linux-mm@kvack.org>; Mon, 15 Jan 2018 03:51:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id d7so8078062wre.15
        for <linux-mm@kvack.org>; Mon, 15 Jan 2018 00:51:20 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x13si20771533wre.270.2018.01.15.00.51.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jan 2018 00:51:18 -0800 (PST)
Date: Mon, 15 Jan 2018 09:51:15 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180115085115.h73vimlyuuj56be7@pathway.suse.cz>
References: <20180111045817.GA494@jagdpanzerIV>
 <20180111093435.GA24497@linux.suse>
 <20180111103845.GB477@jagdpanzerIV>
 <20180111112908.50de440a@vmware.local.home>
 <20180112025612.GB6419@jagdpanzerIV>
 <20180111222140.7fd89d52@gandalf.local.home>
 <20180112100544.GA441@jagdpanzerIV>
 <20180112072123.33bb567d@gandalf.local.home>
 <20180112125536.GC24497@linux.suse>
 <20180113073100.GB1701@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180113073100.GB1701@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Sat 2018-01-13 16:31:00, Sergey Senozhatsky wrote:
> On (01/12/18 13:55), Petr Mladek wrote:
> [..]
> > > I'm not fixing console_unlock(), I'm fixing printk(). BTW, all my
> > > kernels are CONFIG_PREEMPT (I'm a RT guy), my mind thinks more about
> > > PREEMPT kernels than !PREEMPT ones.
> > 
> > I would say that the patch improves also console_unlock() but only in
> > non-preemttive context.
> > 
> > By other words, it makes console_unlock() finite in preemptible context
> > (limited by buffer size). It might still be unlimited in
> > non-preemtible context.
> 
> could you elaborate a bit?

Ah, I am sorry, I swapped the conditions. I meant that
console_unlock() is finite in non-preemptible context.

There are two possibilities if console_unlock() is in atomic context
and never sleeps. First, if there are new printk() callers, they could
take over the job. Second. if they are no more callers, the
current owner will release the lock after processing the existing
messages. In both situations, the current owner will not handle more
than the entire buffer. Therefore it is limited. We might argue
if it is enough. But the point is that it is limited which is
a step forward. And I think that you already agreed that this
was a step forward.

The chance of taking over the lock is lower when console_unlock()
owner could sleep. But then there is not a danger of a softlockup.
In each case, this patch did not make it worse. Could we agree
on this, please?

All in all, this patch improved one scenario and did not make
worse another one. We know that it does not fix everything.
But it is a step forward. Could we agree on this, please?

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
