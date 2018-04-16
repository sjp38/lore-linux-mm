Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id CCC106B0003
	for <linux-mm@kvack.org>; Mon, 16 Apr 2018 00:25:59 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id i8-v6so1171678plt.8
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 21:25:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id g19sor3068803pfb.70.2018.04.15.21.25.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 15 Apr 2018 21:25:58 -0700 (PDT)
Date: Mon, 16 Apr 2018 13:25:53 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180416042553.GA555@jagdpanzerIV>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180416014729.GB1034@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/16/18 10:47), Sergey Senozhatsky wrote:
> On (04/14/18 11:35), Sergey Senozhatsky wrote:
> > On (04/13/18 10:12), Steven Rostedt wrote:
> > > 
> > > > The interval is set to one hour. It is rather arbitrary selected time.
> > > > It is supposed to be a compromise between never print these messages,
> > > > do not lockup the machine, do not fill the entire buffer too quickly,
> > > > and get information if something changes over time.
> > > 
> > > 
> > > I think an hour is incredibly long. We only allow 100 lines per hour for
> > > printks happening inside another printk?
> > > 
> > > I think 5 minutes (at most) would probably be plenty. One minute may be
> > > good enough.
> > 
> > Besides 100 lines is absolutely not enough for any real lockdep splat.
> > My call would be - up to 1000 lines in a 1 minute interval.
> 
> Well, if we want to basically turn printk_safe() into printk_safe_ratelimited().
> I'm not so sure about it.
> 
> Besides the patch also rate limits printk_nmi->logbuf - the logbuf
> PRINTK_NMI_DEFERRED_CONTEXT_MASK bypass, which is way too important
> to rate limit it - for no reason.
> 
> Dunno, can we keep printk_safe() the way it is and introduce a new
> printk_safe_ratelimited() specifically for call_console_drivers()?
> 
> Lockdep splat is a one time event, if we lose half of it - we, most
> like, lose the entire report. And call_console_drivers() is not the
> one and only source of warnings/errors/etc. So if we turn printk_safe
> into printk_safe_ratelimited() [not sure we want to do it] for all
> then I want restrictions to be as low as possible, IOW to log_store()
> as many lines as possible.

One more thing,
I'd really prefer to rate limit the function which flushes per-CPU
printk_safe buffers; not the function that appends new messages to
the per-CPU printk_safe buffers. There is a significant difference.

printk_safe does not help us when we are dealing with any external
locks - and call_console_drivers() is precisely that type of case.
The very next thing to happen after lockdep splat, or spin_lock
debugging report, etc. can be an actual deadlock->panic(). Thus I
want to have the entire report in per-CPU buffer [if possible],
so we can flush_on_panic() per-CPU buffers, or at least move the
data to the logbuf and make it accessible in vmcore. If we rate
limit the function that appends data to the per-CPU buffer then we
may simply suppress [rate limit] the report, so there will be
nothing to flush_on_panic().

	-ss
