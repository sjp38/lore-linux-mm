Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 142E86B0007
	for <linux-mm@kvack.org>; Sun, 15 Apr 2018 21:47:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id x81so2299704pgx.21
        for <linux-mm@kvack.org>; Sun, 15 Apr 2018 18:47:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g184sor2181807pgc.119.2018.04.15.18.47.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 15 Apr 2018 18:47:34 -0700 (PDT)
Date: Mon, 16 Apr 2018 10:47:29 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] printk: Ratelimit messages printed by console drivers
Message-ID: <20180416014729.GB1034@jagdpanzerIV>
References: <20180413124704.19335-1-pmladek@suse.com>
 <20180413101233.0792ebf0@gandalf.local.home>
 <20180414023516.GA17806@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180414023516.GA17806@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>, Petr Mladek <pmladek@suse.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Jan Kara <jack@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (04/14/18 11:35), Sergey Senozhatsky wrote:
> On (04/13/18 10:12), Steven Rostedt wrote:
> > 
> > > The interval is set to one hour. It is rather arbitrary selected time.
> > > It is supposed to be a compromise between never print these messages,
> > > do not lockup the machine, do not fill the entire buffer too quickly,
> > > and get information if something changes over time.
> > 
> > 
> > I think an hour is incredibly long. We only allow 100 lines per hour for
> > printks happening inside another printk?
> > 
> > I think 5 minutes (at most) would probably be plenty. One minute may be
> > good enough.
> 
> Besides 100 lines is absolutely not enough for any real lockdep splat.
> My call would be - up to 1000 lines in a 1 minute interval.

Well, if we want to basically turn printk_safe() into printk_safe_ratelimited().
I'm not so sure about it.

Besides the patch also rate limits printk_nmi->logbuf - the logbuf
PRINTK_NMI_DEFERRED_CONTEXT_MASK bypass, which is way too important
to rate limit it - for no reason.

Dunno, can we keep printk_safe() the way it is and introduce a new
printk_safe_ratelimited() specifically for call_console_drivers()?

Lockdep splat is a one time event, if we lose half of it - we, most
like, lose the entire report. And call_console_drivers() is not the
one and only source of warnings/errors/etc. So if we turn printk_safe
into printk_safe_ratelimited() [not sure we want to do it] for all
then I want restrictions to be as low as possible, IOW to log_store()
as many lines as possible.

Chatty console drivers is not exactly the case which printk_safe() was
meant to fix. I'm pretty sure I put call_console_drivers() under printk_safe
just because we call console_drivers with local IRQs disabled anyway and I
was too lazy to do something like this

---

@@ -2377,6 +2377,7 @@ void console_unlock(void)
 		console_idx = log_next(console_idx);
 		console_seq++;
 		raw_spin_unlock(&logbuf_lock);
+		__printk_safe_exit();
 
 		/*
 		 * While actively printing out messages, if another printk()
@@ -2390,6 +2391,7 @@ void console_unlock(void)
 		call_console_drivers(ext_text, ext_len, text, len);
 		start_critical_timings();
 
+		__printk_safe_enter();
 		if (console_lock_spinning_disable_and_check()) {
 			printk_safe_exit_irqrestore(flags);
 			return;

---

But, in general, I don't think there are real reasons for us to call
console drivers from printk_safe section: call_console_drivers()->printk()
will not deadlock, because vprintk_emit()->console_trylock_spinning() will
always fail.

	-ss
