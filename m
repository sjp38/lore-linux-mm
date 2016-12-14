Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 595896B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:47:06 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so8555455wjc.2
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:47:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i12si7039926wmd.76.2016.12.14.04.47.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 04:47:05 -0800 (PST)
Date: Wed, 14 Dec 2016 13:47:04 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214124703.GF16064@pathway.suse.cz>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <20161214102028.GA2462@jagdpanzerIV.localdomain>
 <20161214110127.GD16064@pathway.suse.cz>
 <20161214122313.GB2883@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214122313.GB2883@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org

On Wed 2016-12-14 21:23:13, Sergey Senozhatsky wrote:
> On (12/14/16 12:01), Petr Mladek wrote:
> > On Wed 2016-12-14 19:20:28, Sergey Senozhatsky wrote:
> > > On (12/14/16 10:37), Petr Mladek wrote:
> > > [..]
> > > > > ----------
> > > > > [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> > > > > [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> > > > > [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > > [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> > > > > [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > > > > [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > > > > (...snipped...)
> > > > > [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > > > > [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > > > > ----------
> > > > > 
> > > > > Although it is fine to make warn_alloc() less verbose, this is not
> > > > > a problem which can be avoided by simply reducing printk(). Unless
> > > > > we give enough CPU time to the OOM killer and OOM victims, it is
> > > > > trivial to lockup the system.
> > > > 
> > > > You could try to use printk_deferred() in warn_alloc(). It will not
> > > > handle console. It will help to be sure that the blocked printk()
> > > > is the main problem.
> > > 
> > > I thought about deferred printk, but I'm afraid in the given
> > > conditions this has great chances to badly lockup the system.
> > 
> > I am just curious. Do you have any particular scenario in mind?
> > 
> > AFAIK, the current problem is the classic softlockup in
> > console_unlock(). Other CPUs are producing a flood of printk
> > messages and the victim is blocked in console_unlock() "forever".
> > I do not see any deadlock with logbuf_lock.
> 
> well, printk_deferred moves console_unlock() to IRQ context. so
> we still have a classic lockup, other CPUs still can add messages
> to logbuf, expect that now we are doing printing from IRQ (assuming
> that IRQ work acquired the console sem). lockup in IRQ is worth
> than softlockup. (well, just saying)

You are right. The current printk_deferred() will not solve anything.
It defers the work to IRQ context. If the IRQ interrupts OOM killer,
we are in the same livelock situation.

The only solution is the async printk patchset that allows to deffer
the console flushing to a kthread.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
