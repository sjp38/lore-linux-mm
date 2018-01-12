Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6A01B6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 10:37:59 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id w7so5325119pfd.4
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 07:37:59 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id r1si15805957plb.581.2018.01.12.07.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jan 2018 07:37:58 -0800 (PST)
Date: Fri, 12 Jan 2018 10:37:54 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 2/2] printk: Hide console waiter logic into helpers
Message-ID: <20180112103754.1916a1e2@gandalf.local.home>
In-Reply-To: <20180111120341.GB24419@linux.suse>
References: <20180110132418.7080-1-pmladek@suse.com>
	<20180110132418.7080-3-pmladek@suse.com>
	<20180110125220.69f5f930@vmware.local.home>
	<20180111120341.GB24419@linux.suse>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Thu, 11 Jan 2018 13:03:41 +0100
Petr Mladek <pmladek@suse.com> wrote:

> > > +static DEFINE_RAW_SPINLOCK(console_owner_lock);
> > > +static struct task_struct *console_owner;
> > > +static bool console_waiter;
> > > +
> > > +/**
> > > + * console_lock_spinning_enable - mark beginning of code where another
> > > + *	thread might safely busy wait
> > > + *
> > > + * This might be called in sections where the current console_lock owner  
> > 
> > 
> > "might be"? It has to be called in sections where the current
> > console_lock owner can not sleep. It's basically saying "console lock is
> > now acting like a spinlock".  
> 
> I am afraid that both explanations are confusing. Your one sounds like
> it must be called every time we enter non-preemptive context in
> console_unlock. What about the following?
> 
>  * This is basically saying that "console lock is now acting like
>  * a spinlock". It can be called _only_ in sections where the current
>  * console_lock owner could not sleep. Also it must be ready to hand
>  * over the lock at the end of the section.

I would reword the above:

   * This basically converts console_lock into a spinlock. This marks
   * the section where the console_lock owner can not sleep, because
   * there may be a waiter spinning (like a spinlock). Also it must be
   * ready to hand over the lock at the end of the section.

> 
> > > + * cannot sleep. It is a signal that another thread might start busy
> > > + * waiting for console_lock.
> > > + */  
> 
> All the other changes look good to me. I will use them in the next version.

Great.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
