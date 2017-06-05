Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 562E86B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 11:02:37 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id l6so146843323iti.0
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 08:02:37 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 37si31455754iol.60.2017.06.05.08.02.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 08:02:34 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170602125944.b35575ccb960e467596cf880@linux-foundation.org>
	<20170603073221.GB21524@dhcp22.suse.cz>
	<201706031736.DHB82306.QOOHtVFFSJFOLM@I-love.SAKURA.ne.jp>
	<20170605071053.GA471@jagdpanzerIV.localdomain>
	<20170605093632.GA565@jagdpanzerIV.localdomain>
In-Reply-To: <20170605093632.GA565@jagdpanzerIV.localdomain>
Message-Id: <201706060002.FCD65614.OFFLOVQtHSJFOM@I-love.SAKURA.ne.jp>
Date: Tue, 6 Jun 2017 00:02:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky.work@gmail.com
Cc: mhocko@suse.com, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz, sergey.senozhatsky@gmail.com, pmladek@suse.com

Thank you for explanation, Sergey.

Sergey Senozhatsky wrote:
> Hello,
>
> On (06/03/17 17:36), Tetsuo Handa wrote:
> [..]
> > > Tetsuo is arguing that the locking will throttle warn_alloc callers and
> > > that can help other processes to move on. I would call it papering over
> > > a real issue which might be somewhere else and that is why I push back so
> > > hard. The initial report is far from complete and seeing 30+ seconds
> > > stalls without any indication that this is just a repeating stall after
> > > 10s and 20s suggests that we got stuck somewhere in the reclaim path.
> >
> > That timestamp jump is caused by the fact that log_buf writers are consuming
> > more CPU times than log_buf readers can consume. If I leave that situation
> > more, printk() just starts printing "** %u printk messages dropped ** " line.
>
> hhmm... sorry, not sure I see how printk() would affect timer ticks. unless
> you do printing from timer IRQs, or always in deferred printk() mode, which
> runs from timer IRQ... timestamps are assigned at the moment we add a new
> message to the logbuf, not when we print it. so slow serial console really
> should not affect it. unless I'm missing something.

All printk() are from warn_alloc(). I retested using stop watch, and confirmed
that console is printing pending output at full speed during the timestamp jump.
Thus, it seems that this timestamp jump was caused by simply log_buf reader had
been busy, and the OOM killer processing resumed after all pending output was
consumed by log_buf reader.

> I don't think vprintk_emit() was spinning on logbuf_lock_irqsave(),
> you would have seen spinlock lockup reports otherwise. in console_unlock()
> logbuf lock is acquired only to pick the first pending messages and,
> basically, do memcpy() to a static buffer. we don't call "slow console
> drivers" with the logbuf lock taken. so other CPUs are free/welcome to
> append new messages to the logbuf in the meantime (and read accurate
> local_clock()).

Yes. The local_clock() value seems to be correct.

>
> so if you see spikes in messages' timestamps it's most likely because
> there was something between printk() calls that kept the CPU busy.
>

Flooding of warn_alloc() from __alloc_pages_slowpath() kept log_buf
reader busy enough to block resuming processing of the OOM killer.
If warn_alloc() refrained from flooding, log_buf reader will be able to
consume pending output more quickly, and we won't observe slowdown nor
timestamp jump.

> does it make any difference if you disable preemption in console_unlock()?
> something like below... just curious...

Yes, this change reduces stalls a lot. But I don't think changing printk()
side for this problem is correct.

>
> ---
>
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index a1aecf44ab07..25fe408cb994 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -2204,6 +2204,8 @@ void console_unlock(void)
>          return;
>      }
> 
> +    preempt_disable();
> +
>      for (;;) {
>          struct printk_log *msg;
>          size_t ext_len = 0;
> @@ -2260,9 +2262,6 @@ void console_unlock(void)
>          call_console_drivers(ext_text, ext_len, text, len);
>          start_critical_timings();
>          printk_safe_exit_irqrestore(flags);
> -
> -        if (do_cond_resched)
> -            cond_resched();
>      }
>      console_locked = 0;
> 
> @@ -2274,6 +2273,8 @@ void console_unlock(void)
> 
>      up_console_sem();
> 
> +    preempt_enable();
> +
>      /*
>       * Someone could have filled up the buffer again, so re-check if there's
>       * something to flush. In case we cannot trylock the console_sem again,

This change is a subset of enclosing whole oom_kill_process() steps
with preempt_disable()/preempt_enable(), which was already rejected.

Regarding the OOM killer preempted by console_unlock() from printk()
problem, it will be mitigated by offloading to the printk kernel thread.
But offloading solves only the OOM killer preempted by console_unlock()
case. The OOM killer can still be preempted by schedule_timeout_killable(1).

Also, Cong Wang's case was (presumably) unable to invoke the OOM killer case.
When the OOM killer can make forward progress, accelerating log_buf readers
instead of throttling log_buf writers might make sense. But when the OOM killer
cannot make forward progress, we need to make sure that log_buf writer (i.e.
warn_alloc()) is slower than log_buf reader (i.e. printk kernel thread).

So, coming back to warn_alloc(). I don't think that current ratelimit
choice is enough to give log_buf reader enough CPU time. Users won't be
happy with randomly filtered, otherwise flooded/mixed warn_alloc() output.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
