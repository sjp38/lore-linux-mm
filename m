Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA2946B0009
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 09:00:09 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a6so10471355pfn.3
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:00:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 101-v6sor4067562ple.72.2018.04.23.06.00.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 06:00:08 -0700 (PDT)
Date: Mon, 23 Apr 2018 22:00:02 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180423130002.GA465@tigerII.localdomain>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
 <20180416014729.GB1034@jagdpanzerIV>
 <20180416042553.GA555@jagdpanzerIV>
 <20180419125353.lawdc3xna5oqlq7k@pathway.suse.cz>
 <20180420021511.GB6397@jagdpanzerIV>
 <20180420091224.cotxcfycmtt2hm4m@pathway.suse.cz>
 <20180423052133.GA3643@jagdpanzerIV>
 <20180423122600.sozmrytiasd32bhc@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180423122600.sozmrytiasd32bhc@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/23/18 14:26), Petr Mladek wrote:
> need to see the problems and be able to debug them. BTW: I wrote
> this in the patch description.
> 
> > A very quick googling:
> 
> Nice collection. Just note that the useful (ratelimited) information
> always fits into the first 100 lines in all these examples:

I'm *very and really* sorry to ask that, but are you serious now?
Apologies if I'm not getting a joke here, or something.

[..]
> > Throttling down that error mechanism to 100 lines
> > per hour, or 1000 lines per hour is unlikely will be welcomed.
> 
> I wonder if you have bigger problems with the number of lines
> or with the length of the period.
> 
> We simply _must_ limit the number of lines. Otherwise we would
> never be able to break an _infinite_ loop.

Give me examples of such messages, and please do explain why you were
not able to rate-limit them and instead decided to introduce a system
wide printk() rate-limit.

> > Among all the patches and proposal that we saw so far, one stands out - it's
> > the original Tejun's patch [offloading to work queue]. Because it has zero
> > interference with the existing call_console_drivers()->printk()
> > channels.
> 
> The only problem is that it does not solve the infinite loop.

Same as above. I'm not kidding. I really want to know what unfixable&endless
messages you are talking about? May I take look at the backtraces?

> > What is so special about this case that we decided to screw up printk()
> > instead?
> 
> Also messages from console drivers are about printk debugging. There must
> be some limitations by definition.

No. Check the links that I found after _literally_ 5 seconds of googling.
Tons of messages are coming from core kernel code. Nothing to do with
the debugging. It *is* a valid and widely used error reporting channel.
End of story.


SERIOUSLY. PLEASE (!) - don't turn printk() into rate-limited printk().
Don't introduce that HUGE regression. Let's handle it the same way as we
always do - let's look at the logs, and rate-limit misbehaving code.


> > diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> > index 247808333ba4..484c456c095a 100644
> > --- a/kernel/printk/printk.c
> > +++ b/kernel/printk/printk.c
> > @@ -2385,9 +2385,11 @@ void console_unlock(void)
> >  		 */
> >  		console_lock_spinning_enable();
> >  
> > +		__printk_safe_exit();
> >  		stop_critical_timings();	/* don't trace print latency */
> >  		call_console_drivers(ext_text, ext_len, text, len);
> >  		start_critical_timings();
> > +		__printk_safe_enter();
> 
> Is this by intention? What is the reason to call
> console_lock_spinning_disable_and_check() in printk_safe() context, please?

Yes, it is. console_lock_spinning_enable() is touching console_owner_lock:
an `internal' printk lock -- which we also touch in vprintk_emit(). As such
[internal printk lock] it must be accessed under printk_safe(), by definition.

> >  		if (console_lock_spinning_disable_and_check()) {
> >  			printk_safe_exit_irqrestore(flags);

	-ss
