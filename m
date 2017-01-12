Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D66B6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 09:18:47 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r144so4476629wme.0
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 06:18:47 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11si7379593wra.299.2017.01.12.06.18.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Jan 2017 06:18:46 -0800 (PST)
Date: Thu, 12 Jan 2017 15:18:44 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170112141844.GA20462@pathway.suse.cz>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161226113407.GA515@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Mon 2016-12-26 20:34:07, Sergey Senozhatsky wrote:
> console_trylock() used to always forbid rescheduling; but it got changed
> like a yaer ago.
> 
> the other thing is... do we really need to console_conditional_schedule()
> from fbcon_*()? console_unlock() does cond_resched() after every line it
> prints. wouldn't that be enough?
> 
> so may be we can drop some of console_conditional_schedule()
> call sites in fbcon. or update console_conditional_schedule()
> function to always return the current preemption value, not the
> one we saw in console_trylock().

I was curious if it makes sense to remove
console_conditional_schedule() completely.

In practice, it never allows rescheduling when the console driver
is called via console_unlock(). It is since 2006 and the commit
78944e549d36673eb62 ("vt: printk: Fix framebuffer console
triggering might_sleep assertion"). This commit added
that

	console_may_schedule = 0;

into console_unlock() before the console drivers are called.


On the other hand, it seems that the rescheduling was always
enabled when some console operations were called via
tty_operations. For example:

struct tty_operations con_ops

  con_ops->con_write()
  -> do_con_write()  #calls console_lock()
   -> do_con_trol()
    -> fbcon_scroll()
     -> fbcon_redraw_move()
      -> console_conditional_schedule()

, where console_lock() sets console_may_schedule = 1;


A complete console scroll/redraw might take a while. The rescheduling
would make sense => IMHO, we should keep console_conditional_schedule()
or some alternative in the console drivers as well.

But I am afraid that we could not use the automatic detection.
We are not able to detect preemption when CONFIG_PREEMPT_COUNT
is disabled. But we still would like to enable rescheduling
when called from the tty code (guarded by console_lock()).


As a result. We should keep console_may_schedule as a global
variable. We cannot put the automatic detection into
console_conditional_schedule(). Instead, we need to
fix handling of the global variable in console_unlock().

I am going to prepare a patch for this.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
