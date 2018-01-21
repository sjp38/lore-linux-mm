Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 039096B0003
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 16:04:57 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u16so6986629pfh.7
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 13:04:56 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 204si12682104pgf.94.2018.01.21.13.04.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 13:04:55 -0800 (PST)
Date: Sun, 21 Jan 2018 16:04:41 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v5 0/2] printk: Console owner and waiter logic cleanup
Message-ID: <20180121160441.7ea4b6d9@gandalf.local.home>
In-Reply-To: <20180121141521.GA429@tigerII.localdomain>
References: <20180111203057.5b1a8f8f@gandalf.local.home>
	<20180111215547.2f66a23a@gandalf.local.home>
	<20180116194456.GS3460072@devbig577.frc2.facebook.com>
	<20180117091208.ezvuhumnsarz5thh@pathway.suse.cz>
	<20180117151509.GT3460072@devbig577.frc2.facebook.com>
	<20180117121251.7283a56e@gandalf.local.home>
	<20180117134201.0a9cbbbf@gandalf.local.home>
	<20180119132052.02b89626@gandalf.local.home>
	<20180120071402.GB8371@jagdpanzerIV>
	<20180120104931.1942483e@gandalf.local.home>
	<20180121141521.GA429@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tejun Heo <tj@kernel.org>, Petr Mladek <pmladek@suse.com>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, Byungchul Park <byungchul.park@lge.com>, Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org

On Sun, 21 Jan 2018 23:15:21 +0900
Sergey Senozhatsky <sergey.senozhatsky@gmail.com> wrote:

> so.... fix the console drivers ;)

Totally agree!

> 
> 
> 
> 
> just kidding. ok...

Darn it! ;-)

> the problem is that we flush printk_safe right when console_unlock() printing
> loop enables local IRQs via printk_safe_exit_irqrestore() [given that IRQs
> were enabled in the first place when the CPU went to console_unlock()].
> this forces that CPU to loop in console_unlock() as long as we have
> printk-s coming from call_console_drivers(). but we probably can postpone
> printk_safe flush. basically, we can declare a new rule - we don't flush
> printk_safe buffer as long as console_sem is locked. because this is how
> that printing CPU stuck in the console_unlock() printing loop. printk_safe
> buffer is very important when it comes to storing a non-repetitive stuff, like
> a lockdep splat, which is a single shot event. but the more repetitive the
> message is, like millions of similar kmalloc() dump_stack()-s over and over
> again, the less value in it. we should have printk_safe buffer big enough for
> important info, like a lockdep splat, but millions of similar kmalloc()
> messages are pretty invaluable - one is already enough, we can drop the rest.
> and we should not flush new messages while there is a CPU looping in
> console_unlock(), because it already has messages to print, which were
> log_store()-ed the normal way.

The above is really hard to read without any capitalization. Everything
seems to be a run-on sentence and gives me a head ache. So you lost me
there.

> 
> this is where the "postpone thing" jumps in. so how do we postpone printk_safe
> flush.
> 
> we can't console_trylock()/console_unlock() in printk_safe flush code.
> but there is a `console_locked' flag and is_console_locked() function which
> tell us if the console_sem is locked. as long as we are in console_unlock()
> printing loop that flag is set, even if we enabled local IRQs and printk_safe
> flush work arrived. so now printk_safe flush does extra check and does
> not flush printk_safe buffer content as long as someone is currently
> printing or soon will start printing. but we need to take extra step and
> to re-queue flush on CPUs that did postpone it [console_unlock() can
> reschedule]. so now we flush only when printing CPU printed all pending
> logbuf messages, hit the "console_seq == log_next_seq" and up()
> console_sem. this sets a boundary -- no matter how many times during the
> current printing loop we called console drivers and how many times those
> drivers caused printk recursion, we will flush only SAFE_LOG_BUF_LEN chars.

Another big paragraph with no capitals (besides macros and CPU ;-)

I guess this is what it is like when people listen to me talk too fast.


> 
> 
> IOW, what we have now, looks like this:
> 
> a) printk_safe is for important stuff, we don't guarantee that a flood
>    of messages will be preserved.
> 
> b) we extend the previously existing "will flush messages later on from
>    a safer context" and now we also consider console_unlock() printing loop
>    as unsafe context. so the unsafe context it's not only the one that can
>    deadlock, but also the one that can lockup CPU in a printing loop because
>    of recursive printk messages.

Sure.

> 
> 
> so this
> 
>  printk
>   console_unlock
>   {
>    for (;;) {
>      call_console_drivers
>       net_console
>        printk
>         printk_save -> irq_work queue
> 
> 	   IRQ work
> 	     prink_safe_flush
> 	       printk_deferred -> log_store()
>            iret
>     }
>     up();
>   }
> 
> 
>    // which can never break out, because we can always append new messages
>    // from prink_safe_flush.
> 
> becomes this
> 
> printk
>   console_unlock
>   {
>    for (;;) {
>      call_console_drivers
>       net_console
>        printk
>         printk_save -> irq_work queue
> 
>     }
>     up();
> 
>   IRQ work
>    prink_safe_flush
>     printk_deferred -> log_store()
>   iret
> }

But we do eventually send this data out to the consoles, and if the
consoles cause more printks, wouldn't this still never end?

> 
> 
> 
> something completely untested, sketchy and ugly.
> 
> ---
> 
>  kernel/printk/internal.h    |  2 ++
>  kernel/printk/printk.c      |  1 +
>  kernel/printk/printk_safe.c | 37 +++++++++++++++++++++++++++++++++++--
>  3 files changed, 38 insertions(+), 2 deletions(-)
> 
> diff --git a/kernel/printk/internal.h b/kernel/printk/internal.h
> index 2a7d04049af4..e85517818a49 100644
> --- a/kernel/printk/internal.h
> +++ b/kernel/printk/internal.h
> @@ -30,6 +30,8 @@ __printf(1, 0) int vprintk_func(const char *fmt, va_list args);
>  void __printk_safe_enter(void);
>  void __printk_safe_exit(void);
>  
> +void printk_safe_requeue_flushing(void);
> +
>  #define printk_safe_enter_irqsave(flags)	\
>  	do {					\
>  		local_irq_save(flags);		\
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index 9cb943c90d98..7aca23e8d7b2 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2428,6 +2428,7 @@ void console_unlock(void)
>  	raw_spin_lock(&logbuf_lock);
>  	retry = console_seq != log_next_seq;
>  	raw_spin_unlock(&logbuf_lock);
> +	printk_safe_requeue_flushing();
>  	printk_safe_exit_irqrestore(flags);
>  
>  	if (retry && console_trylock())
> diff --git a/kernel/printk/printk_safe.c b/kernel/printk/printk_safe.c
> index 3e3c2004bb23..45d5b292d7e1 100644
> --- a/kernel/printk/printk_safe.c
> +++ b/kernel/printk/printk_safe.c
> @@ -22,6 +22,7 @@
>  #include <linux/cpumask.h>
>  #include <linux/irq_work.h>
>  #include <linux/printk.h>
> +#include <linux/console.h>
>  
>  #include "internal.h"
>  
> @@ -51,6 +52,7 @@ struct printk_safe_seq_buf {
>  	atomic_t		message_lost;
>  	struct irq_work		work;	/* IRQ work that flushes the buffer */
>  	unsigned char		buffer[SAFE_LOG_BUF_LEN];
> +	bool			need_requeue;
>  };
>  
>  static DEFINE_PER_CPU(struct printk_safe_seq_buf, safe_print_seq);
> @@ -196,6 +198,7 @@ static void __printk_safe_flush(struct irq_work *work)
>  	size_t len;
>  	int i;
>  
> +	s->need_requeue = false;
>  	/*
>  	 * The lock has two functions. First, one reader has to flush all
>  	 * available message to make the lockless synchronization with
> @@ -243,6 +246,36 @@ static void __printk_safe_flush(struct irq_work *work)
>  	raw_spin_unlock_irqrestore(&read_lock, flags);
>  }
>  
> +/* NMI buffers are always flushed */
> +static void flush_nmi_buffer(struct irq_work *work)
> +{
> +	__printk_safe_flush(work);
> +}
> +
> +/* printk_safe buffers flushing, on the contrary, can be postponed */
> +static void flush_printk_safe_buffer(struct irq_work *work)
> +{
> +	struct printk_safe_seq_buf *s =
> +		container_of(work, struct printk_safe_seq_buf, work);
> +
> +	if (is_console_locked()) {
> +		s->need_requeue = true;
> +		return;
> +	}
> +
> +	__printk_safe_flush(work);
> +}
> +
> +void printk_safe_requeue_flushing(void)
> +{
> +	int cpu;
> +
> +	for_each_possible_cpu(cpu) {
> +		if (per_cpu(safe_print_seq, cpu).need_requeue)
> +			queue_flush_work(&per_cpu(safe_print_seq, cpu));
> +	}
> +}
> +
>  /**
>   * printk_safe_flush - flush all per-cpu nmi buffers.
>   *
> @@ -387,11 +420,11 @@ void __init printk_safe_init(void)
>  		struct printk_safe_seq_buf *s;
>  
>  		s = &per_cpu(safe_print_seq, cpu);
> -		init_irq_work(&s->work, __printk_safe_flush);
> +		init_irq_work(&s->work, flush_printk_safe_buffer);
>  
>  #ifdef CONFIG_PRINTK_NMI
>  		s = &per_cpu(nmi_print_seq, cpu);
> -		init_irq_work(&s->work, __printk_safe_flush);
> +		init_irq_work(&s->work, flush_nmi_buffer);
>  #endif
>  	}
>  
> ---
> 
> 
> 
> > > lose all of them now? then we can do a much simpler thing - steal one
> > > bit from `printk_context' and use if for a new PRINTK_NOOP_CONTEXT, which
> > > will be set around call_console_drivers(). vprintk_func() would redirect
> > > printks to vprintk_noop(fmt, args), which will do nothing.  
> > 
> > Not sure what you mean here. Have some pseudo code to demonstrate with?  
> 
> sure, I meant that if we want to disable printk recursion from
> call_console_drivers(), then we can add another printk_safe section, say
> printk_noop_begin()/printk_noop_end(), which would set a PRINTK_NOOP
> bit of `printk_context', so when we have printk() under PRINTK_NOOP
> then vprintk_func() goes to a special vprintk_noop(fmt, args), which
> simply drops the message [does not store any in the per-cpu printk
> safe buffer, so we don't flush it and don't add new messages to the
> logbuf]. and we annotate call_console_drivers() as a pintk_noop
> function. but that a no-brainer and I'd prefer to have another solution.
> 

Another big paragraph without caps, but I figured it out.

I say we try that solution and see if it fixes the current issues.
Because right now, the bug I see Tejun presented was if something in
printk causes printks, it will start a printk bomb and lock up the
system. The only reasonable answer I see to that is to throttle printk
in such a case.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
