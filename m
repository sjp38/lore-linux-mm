Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8C86B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:03:26 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c85so14572327wmi.6
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:03:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si1707459wmg.135.2017.01.13.03.03.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 03:03:24 -0800 (PST)
Date: Fri, 13 Jan 2017 12:03:23 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113110323.GH14894@pathway.suse.cz>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112141844.GA20462@pathway.suse.cz>
 <20170113022843.GA9360@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113022843.GA9360@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 2017-01-13 11:28:43, Sergey Senozhatsky wrote:
> On (01/12/17 15:18), Petr Mladek wrote:
> > On Mon 2016-12-26 20:34:07, Sergey Senozhatsky wrote:
> > > console_trylock() used to always forbid rescheduling; but it got changed
> > > like a yaer ago.
> > > 
> > > the other thing is... do we really need to console_conditional_schedule()
> > > from fbcon_*()? console_unlock() does cond_resched() after every line it
> > > prints. wouldn't that be enough?
> > > 
> > > so may be we can drop some of console_conditional_schedule()
> > > call sites in fbcon. or update console_conditional_schedule()
> > > function to always return the current preemption value, not the
> > > one we saw in console_trylock().
> > 
> > I was curious if it makes sense to remove
> > console_conditional_schedule() completely.
> 
> I was looking at this option at some point as well.
> 
> > In practice, it never allows rescheduling when the console driver
> > is called via console_unlock(). It is since 2006 and the commit
> > 78944e549d36673eb62 ("vt: printk: Fix framebuffer console
> > triggering might_sleep assertion"). This commit added
> > that
> > 
> > 	console_may_schedule = 0;
> >
> > into console_unlock() before the console drivers are called.
> > 
> > 
> > On the other hand, it seems that the rescheduling was always
> > enabled when some console operations were called via
> > tty_operations. For example:
> > 
> > struct tty_operations con_ops
> > 
> >   con_ops->con_write()
> >   -> do_con_write()  #calls console_lock()
> >    -> do_con_trol()
> >     -> fbcon_scroll()
> >      -> fbcon_redraw_move()
> >       -> console_conditional_schedule()
> > 
> > , where console_lock() sets console_may_schedule = 1;
> > 
> > 
> > A complete console scroll/redraw might take a while. The rescheduling
> > would make sense => IMHO, we should keep console_conditional_schedule()
> > or some alternative in the console drivers as well.
> > 
> > But I am afraid that we could not use the automatic detection.
> > We are not able to detect preemption when CONFIG_PREEMPT_COUNT
> 
> can one actually have a preemptible kernel with !CONFIG_PREEMPT_COUNT?
> how? it's not even possible to change CONFIG_PREEMPT_COUNT in menuconfig.
> the option is automatically selected by PREEMPT. and if PREEMPT is not
> selected then _cond_resched() is just "{ rcu_all_qs(); return 0; }"

CONFIG_PREEMPT_COUNT is always enabled in preemptive kernel. But
we do not mind about preemtible kernel. It reschedules automatically
anywhere in preemptive context.

The problem is non-preemptive kernel. It is able to reschedule
only when someone explicitely calls cond_resched() or schedule().
In this case, we are able to detect the preemtive context
automatically only with CONFIG_PREEMPT_COUNT enabled.
We must not call cond_resched() if we are not sure.

> ...
> > We cannot put the automatic detection into console_conditional_schedule().
> 
> why can't we?

Because it would newer call cond_resched() in non-preemptive kernel
with CONFIG_PREEMPT_COUNT disabled. IMHO, we want to call it,
for example, when we scroll the entire screen from tty_operations.

Or do I miss anything?


> > I am going to prepare a patch for this.
> 
> I'm on it.

Uff, I already have one and am very close to send it.

Sigh, I do not want to race who will prepare and send the patch.
I just do not feel comfortable in the reviewer-only role.
I feel like just searching for problems in other's patches
and annoying them with my complains. I know that it is important
but I also want to produce something.

Also I feel that I still need to improve my coding skills.
And I need some training.

Finally, I would not start writing my patch if your one needed
only small updates. But my investigation pushed me very
different way from your proposal. It looked ugly to push
all coding to your side.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
