Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 06CE56B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 21:28:33 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id z128so93249343pfb.4
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:28:32 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id o6si11122706pfi.109.2017.01.12.18.28.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 18:28:31 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id f144so5968342pfa.2
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:28:31 -0800 (PST)
Date: Fri, 13 Jan 2017 11:28:43 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113022843.GA9360@jagdpanzerIV.localdomain>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112141844.GA20462@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112141844.GA20462@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (01/12/17 15:18), Petr Mladek wrote:
> On Mon 2016-12-26 20:34:07, Sergey Senozhatsky wrote:
> > console_trylock() used to always forbid rescheduling; but it got changed
> > like a yaer ago.
> > 
> > the other thing is... do we really need to console_conditional_schedule()
> > from fbcon_*()? console_unlock() does cond_resched() after every line it
> > prints. wouldn't that be enough?
> > 
> > so may be we can drop some of console_conditional_schedule()
> > call sites in fbcon. or update console_conditional_schedule()
> > function to always return the current preemption value, not the
> > one we saw in console_trylock().
> 
> I was curious if it makes sense to remove
> console_conditional_schedule() completely.

I was looking at this option at some point as well.

> In practice, it never allows rescheduling when the console driver
> is called via console_unlock(). It is since 2006 and the commit
> 78944e549d36673eb62 ("vt: printk: Fix framebuffer console
> triggering might_sleep assertion"). This commit added
> that
> 
> 	console_may_schedule = 0;
>
> into console_unlock() before the console drivers are called.
> 
> 
> On the other hand, it seems that the rescheduling was always
> enabled when some console operations were called via
> tty_operations. For example:
> 
> struct tty_operations con_ops
> 
>   con_ops->con_write()
>   -> do_con_write()  #calls console_lock()
>    -> do_con_trol()
>     -> fbcon_scroll()
>      -> fbcon_redraw_move()
>       -> console_conditional_schedule()
> 
> , where console_lock() sets console_may_schedule = 1;
> 
> 
> A complete console scroll/redraw might take a while. The rescheduling
> would make sense => IMHO, we should keep console_conditional_schedule()
> or some alternative in the console drivers as well.
> 
> But I am afraid that we could not use the automatic detection.
> We are not able to detect preemption when CONFIG_PREEMPT_COUNT

can one actually have a preemptible kernel with !CONFIG_PREEMPT_COUNT?
how? it's not even possible to change CONFIG_PREEMPT_COUNT in menuconfig.
the option is automatically selected by PREEMPT. and if PREEMPT is not
selected then _cond_resched() is just "{ rcu_all_qs(); return 0; }"

...
> We cannot put the automatic detection into console_conditional_schedule().

why can't we?


> I am going to prepare a patch for this.

I'm on it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
