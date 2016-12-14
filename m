Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id C76866B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 07:23:25 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so25097145pgq.7
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:23:25 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id 75si52586411pfx.116.2016.12.14.04.23.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Dec 2016 04:23:24 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id x23so2337005pgx.3
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 04:23:24 -0800 (PST)
Date: Wed, 14 Dec 2016 21:23:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161214122313.GB2883@tigerII.localdomain>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
 <20161214093706.GA16064@pathway.suse.cz>
 <20161214102028.GA2462@jagdpanzerIV.localdomain>
 <20161214110127.GD16064@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161214110127.GD16064@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, sergey.senozhatsky@gmail.com

On (12/14/16 12:01), Petr Mladek wrote:
> On Wed 2016-12-14 19:20:28, Sergey Senozhatsky wrote:
> > On (12/14/16 10:37), Petr Mladek wrote:
> > [..]
> > > > ----------
> > > > [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> > > > [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> > > > [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > > > [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > > > [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> > > > [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > > > [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > > > (...snipped...)
> > > > [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > > > [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > > > ----------
> > > > 
> > > > Although it is fine to make warn_alloc() less verbose, this is not
> > > > a problem which can be avoided by simply reducing printk(). Unless
> > > > we give enough CPU time to the OOM killer and OOM victims, it is
> > > > trivial to lockup the system.
> > > 
> > > You could try to use printk_deferred() in warn_alloc(). It will not
> > > handle console. It will help to be sure that the blocked printk()
> > > is the main problem.
> > 
> > I thought about deferred printk, but I'm afraid in the given
> > conditions this has great chances to badly lockup the system.
> 
> I am just curious. Do you have any particular scenario in mind?
> 
> AFAIK, the current problem is the classic softlockup in
> console_unlock(). Other CPUs are producing a flood of printk
> messages and the victim is blocked in console_unlock() "forever".
> I do not see any deadlock with logbuf_lock.

well, printk_deferred moves console_unlock() to IRQ context. so
we still have a classic lockup, other CPUs still can add messages
to logbuf, expect that now we are doing printing from IRQ (assuming
that IRQ work acquired the console sem). lockup in IRQ is worth
than softlockup. (well, just saying)


static void wake_up_klogd_work_func(struct irq_work *irq_work)
{
	if (console_trylock())
		console_unlock();
}

static DEFINE_PER_CPU(struct irq_work, wake_up_klogd_work) = {
	.func = wake_up_klogd_work_func,
	.flags = IRQ_WORK_LAZY,
};



> This is where async printk should help. And printk_deferred()
> is the way to use async printk for a particular printk call.

yes, with a difference that async printk does not work from IRQ.
I'm a bit lost here, sorry. do you mean async-printk/deferred
patch set from my tree or the current printk_deferred()?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
