Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D3C76B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:14:52 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l2so14876055wml.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:14:52 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z14si1733403wmh.161.2017.01.13.03.14.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 03:14:50 -0800 (PST)
Date: Fri, 13 Jan 2017 12:14:49 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113111449.GI14894@pathway.suse.cz>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112131017.GF14894@pathway.suse.cz>
 <20170113025212.GB9360@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113025212.GB9360@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 2017-01-13 11:52:55, Sergey Senozhatsky wrote:
> On (01/12/17 14:10), Petr Mladek wrote:
> [..]
> > >  /**
> > >   * console_lock - lock the console system for exclusive use.
> > >   *
> > > @@ -2316,7 +2321,7 @@ EXPORT_SYMBOL(console_unlock);
> > >   */
> > >  void __sched console_conditional_schedule(void)
> > >  {
> > > -	if (console_may_schedule)
> > > +	if (get_console_may_schedule())
> > 
> > Note that console_may_schedule should be zero when
> > the console drivers are called. See the following lines in
> > console_unlock():
> > 
> > 	/*
> > 	 * Console drivers are called under logbuf_lock, so
> > 	 * @console_may_schedule should be cleared before; however, we may
> > 	 * end up dumping a lot of lines, for example, if called from
> > 	 * console registration path, and should invoke cond_resched()
> > 	 * between lines if allowable.  Not doing so can cause a very long
> > 	 * scheduling stall on a slow console leading to RCU stall and
> > 	 * softlockup warnings which exacerbate the issue with more
> > 	 * messages practically incapacitating the system.
> > 	 */
> > 	do_cond_resched = console_may_schedule;
> > 	console_may_schedule = 0;
> 
> 
> 
> console drivers are never-ever-ever getting called under logbuf lock.
> never. with disabled local IRQs - yes. under logbuf lock - no. that
> would soft lockup systems in really bad ways, otherwise.

Sure. It is just a misleading comment that someone wrote. I have
already fixed this in my patch.


> the reason why we set console_may_schedule to zero in
> console_unlock() is.... VT. and lf() function in particular.
> 
> commit 78944e549d36673eb6265a2411574e79c28e23dc
> Author: Antonino A. Daplas XXXX
> Date:   Sat Aug 5 12:14:16 2006 -0700
> 
>     [PATCH] vt: printk: Fix framebuffer console triggering might_sleep assertion
>     
>     Reported by: Dave Jones
>     
>     Whilst printk'ing to both console and serial console, I got this...
>     (2.6.18rc1)
>     
>     BUG: sleeping function called from invalid context at kernel/sched.c:4438
>     in_atomic():0, irqs_disabled():1

This is basically the same problem that Testuo has. This commit added
the line

	console_may_schedule = 0;

Tetsuo found that we did not clear it when going back
via the "again:" goto target.


> and we really don't want to cond_resched() when we are in panic.
> that's why console_flush_on_panic() sets it to zero explicitly.

This actually works even with the bug. console_flush_on_panic()
is called with interrupts disabled in panic(). Therefore
console_trylock would disable cond_resched.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
