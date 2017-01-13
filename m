Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7286D6B0033
	for <linux-mm@kvack.org>; Thu, 12 Jan 2017 21:52:43 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so89764460pfg.5
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:52:43 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id d9si11150452pgg.146.2017.01.12.18.52.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jan 2017 18:52:42 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id b22so6037855pfd.3
        for <linux-mm@kvack.org>; Thu, 12 Jan 2017 18:52:42 -0800 (PST)
Date: Fri, 13 Jan 2017 11:52:55 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113025212.GB9360@jagdpanzerIV.localdomain>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112131017.GF14894@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170112131017.GF14894@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On (01/12/17 14:10), Petr Mladek wrote:
[..]
> >  /**
> >   * console_lock - lock the console system for exclusive use.
> >   *
> > @@ -2316,7 +2321,7 @@ EXPORT_SYMBOL(console_unlock);
> >   */
> >  void __sched console_conditional_schedule(void)
> >  {
> > -	if (console_may_schedule)
> > +	if (get_console_may_schedule())
> 
> Note that console_may_schedule should be zero when
> the console drivers are called. See the following lines in
> console_unlock():
> 
> 	/*
> 	 * Console drivers are called under logbuf_lock, so
> 	 * @console_may_schedule should be cleared before; however, we may
> 	 * end up dumping a lot of lines, for example, if called from
> 	 * console registration path, and should invoke cond_resched()
> 	 * between lines if allowable.  Not doing so can cause a very long
> 	 * scheduling stall on a slow console leading to RCU stall and
> 	 * softlockup warnings which exacerbate the issue with more
> 	 * messages practically incapacitating the system.
> 	 */
> 	do_cond_resched = console_may_schedule;
> 	console_may_schedule = 0;



console drivers are never-ever-ever getting called under logbuf lock.
never. with disabled local IRQs - yes. under logbuf lock - no. that
would soft lockup systems in really bad ways, otherwise.

the reason why we set console_may_schedule to zero in
console_unlock() is.... VT. and lf() function in particular.

commit 78944e549d36673eb6265a2411574e79c28e23dc
Author: Antonino A. Daplas XXXX
Date:   Sat Aug 5 12:14:16 2006 -0700

    [PATCH] vt: printk: Fix framebuffer console triggering might_sleep assertion
    
    Reported by: Dave Jones
    
    Whilst printk'ing to both console and serial console, I got this...
    (2.6.18rc1)
    
    BUG: sleeping function called from invalid context at kernel/sched.c:4438
    in_atomic():0, irqs_disabled():1
    
    Call Trace:
     [<ffffffff80271db8>] show_trace+0xaa/0x23d
     [<ffffffff80271f60>] dump_stack+0x15/0x17
     [<ffffffff8020b9f8>] __might_sleep+0xb2/0xb4
     [<ffffffff8029232e>] __cond_resched+0x15/0x55
     [<ffffffff80267eb8>] cond_resched+0x3b/0x42
     [<ffffffff80268c64>] console_conditional_schedule+0x12/0x14
     [<ffffffff80368159>] fbcon_redraw+0xf6/0x160
     [<ffffffff80369c58>] fbcon_scroll+0x5d9/0xb52
     [<ffffffff803a43c4>] scrup+0x6b/0xd6
     [<ffffffff803a4453>] lf+0x24/0x44
     [<ffffffff803a7ff8>] vt_console_print+0x166/0x23d
     [<ffffffff80295528>] __call_console_drivers+0x65/0x76
     [<ffffffff80295597>] _call_console_drivers+0x5e/0x62
     [<ffffffff80217e3f>] release_console_sem+0x14b/0x232
     [<ffffffff8036acd6>] fb_flashcursor+0x279/0x2a6
     [<ffffffff80251e3f>] run_workqueue+0xa8/0xfb
     [<ffffffff8024e5e0>] worker_thread+0xef/0x122
     [<ffffffff8023660f>] kthread+0x100/0x136
     [<ffffffff8026419e>] child_rip+0x8/0x12


and we really don't want to cond_resched() when we are in panic.
that's why console_flush_on_panic() sets it to zero explicitly.

console_trylock() checks oops_in_progress, so re-taking the semaphore
when we are in

	panic()
	 console_flush_on_panic()
          console_unlock()
           console_trylock()

should be OK. as well as doing get_console_conditional_schedule() somewhere
in console driver code.


I still don't understand why do you guys think we can't simply do
get_console_conditional_schedule() and get the actual value.


[..]

> Sergey, if you agree with the above paragraph. Do you want to prepare
> the patch or should I do so?

I'm on it.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
