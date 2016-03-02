Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2465B828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:56:21 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id p65so81516397wmp.0
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:56:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a88si5272163wmi.58.2016.03.02.06.56.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Mar 2016 06:56:20 -0800 (PST)
Date: Wed, 2 Mar 2016 15:56:18 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: How to avoid printk() delay caused by cond_resched() ?
Message-ID: <20160302145618.GD22171@pathway.suse.cz>
References: <201603022101.CAH73907.OVOOMFHFFtQJSL@I-love.SAKURA.ne.jp>
 <20160302133810.GB22171@pathway.suse.cz>
 <20160302143415.GB614@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302143415.GB614@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, jack@suse.com, tj@kernel.org, kyle@kernel.org, davej@codemonkey.org.uk, calvinowens@fb.com, akpm@linux-foundation.org, linux-mm@kvack.org, mhocko@kernel.org

On Wed 2016-03-02 23:34:15, Sergey Senozhatsky wrote:
> On (03/02/16 14:38), Petr Mladek wrote:
> [..]
> > > 
> > > CONFIG_PREEMPT_NONE=y
> > > # CONFIG_PREEMPT_VOLUNTARY is not set
> > > # CONFIG_PREEMPT is not set
> > > CONFIG_PREEMPT_COUNT=y
> > 
> > preempt_disable() / preempt_enable() would do the job.
> > The question is where to put it. If you are concerned about
> > the delay, you might want to disable preemption around
> > the whole locked area, so that it works reasonable also
> > in the preemptive kernel.
> 
> another question is why cond_resched() is suddenly so expensive?

My guess is that nobody called cond_resched() in this OOM path on
non-preemptible kernel before.

> my guess is because of OOM, so we switch to tasks that potentially
> do direct reclaims, etc. if so, then even offloaded printk will take
> a significant amount of time to print the logs to the consoles; just
> because it does cond_resched() after every call_console_drivers().

IMHO, calling cond_resched() is just an offer that the process
is ready to get rescheduled at this point. It will reschedule only
if the process is over its dedicated time slot or if a higher
priority task appeared in the run queue. IMHO, it is perfectly fine
to call is often.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
