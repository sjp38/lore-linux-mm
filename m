Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6812E6B025E
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 06:49:07 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id o3so24005447wjo.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 03:49:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j13si27975367wmf.109.2016.12.12.03.49.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Dec 2016 03:49:06 -0800 (PST)
Date: Mon, 12 Dec 2016 12:49:03 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161212114903.GM3506@pathway.suse.cz>
References: <20161207081555.GB17136@dhcp22.suse.cz>
 <201612080029.IBD55588.OSOFOtHVMLQFFJ@I-love.SAKURA.ne.jp>
 <20161208132714.GA26530@dhcp22.suse.cz>
 <201612092323.BGC65668.QJFVLtFFOOMOSH@I-love.SAKURA.ne.jp>
 <20161209144624.GB4334@dhcp22.suse.cz>
 <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212090702.GD18163@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Mon 2016-12-12 10:07:03, Michal Hocko wrote:
> On Sat 10-12-16 20:24:57, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Fri 09-12-16 23:23:10, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Thu 08-12-16 00:29:26, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > On Tue 06-12-16 19:33:59, Tetsuo Handa wrote:
> > > > > > > > If the OOM killer is invoked when many threads are looping inside the
> > > > > > > > page allocator, it is possible that the OOM killer is preempted by other
> > > > > > > > threads.
> > > > > > > 
> > > > > > > Hmm, the only way I can see this would happen is when the task which
> > > > > > > actually manages to take the lock is not invoking the OOM killer for
> > > > > > > whatever reason. Is this what happens in your case? Are you able to
> > > > > > > trigger this reliably?
> > > > > > 
> > > > > > Regarding http://I-love.SAKURA.ne.jp/tmp/serial-20161206.txt.xz ,
> > > > > > somebody called oom_kill_process() and reached
> > > > > > 
> > > > > >   pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
> > > > > > 
> > > > > > line but did not reach
> > > > > > 
> > > > > >   pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
> > > > > > 
> > > > > > line within tolerable delay.
> > > > > 
> > > > > I would be really interested in that. This can happen only if
> > > > > find_lock_task_mm fails. This would mean that either we are selecting a
> > > > > child without mm or the selected victim has no mm anymore. Both cases
> > > > > should be ephemeral because oom_badness will rule those tasks on the
> > > > > next round. So the primary question here is why no other task has hit
> > > > > out_of_memory.
> > > > 
> > > > This can also happen due to AB-BA livelock (oom_lock v.s. console_sem).
> > > 
> > > Care to explain how would that livelock look like?
> > 
> > Two types of threads (Thread-1 which is holding oom_lock, Thread-2 which is not
> > holding oom_lock) are doing memory allocation. Since oom_lock is a mutex, there
> > can be only 1 instance for Thread-1. But there can be multiple instances for
> > Thread-2.
> > 
> > (1) Thread-1 enters out_of_memory() because it is holding oom_lock.
> > (2) Thread-1 enters printk() due to
> > 
> >     pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n", ...);
> > 
> >     in oom_kill_process().
> > 
> > (3) vprintk_func() is mapped to vprintk_default() because Thread-1 is not
> >     inside NMI handler.
> > 
> > (4) In vprintk_emit(), in_sched == false because loglevel for pr_err()
> >     is not LOGLEVEL_SCHED.
> > 
> > (5) Thread-1 calls log_store() via log_output() from vprintk_emit().
> > 
> > (6) Thread-1 calls console_trylock() because in_sched == false.
> > 
> > (7) Thread-1 acquires console_sem via down_trylock_console_sem().
> > 
> > (8) In console_trylock(), console_may_schedule is set to true because
> >     Thread-1 is in sleepable context.
> > 
> > (9) Thread-1 calls console_unlock() because console_trylock() succeeded.
> > 
> > (9) In console_unlock(), pending data stored by log_store() are printed
> >     to consoles. Since there may be slow consoles, cond_resched() is called
> >     if possible. And since console_may_schedule == true because Thread-1 is
> >     in sleepable context, Thread-1 may be scheduled at console_unlock().
> > 
> > (10) Thread-2 tries to acquire oom_lock but it fails because Thread-1 is
> >      holding oom_lock.
> > 
> > (11) Thread-2 enters warn_alloc() because it is waiting for Thread-1 to
> >      return from oom_kill_process().
> > 
> > (12) Thread-2 enters printk() due to
> > 
> >      warn_alloc(gfp_mask, "page allocation stalls for %ums, order:%u", ...);
> > 
> >      in __alloc_pages_slowpath().
> > 
> > (13) vprintk_func() is mapped to vprintk_default() because Thread-2 is not
> >      inside NMI handler.
> > 
> > (14) In vprintk_emit(), in_sched == false because loglevel for pr_err()
> >      is not LOGLEVEL_SCHED.
> > 
> > (15) Thread-2 calls log_store() via log_output() from vprintk_emit().
> > 
> > (16) Thread-2 calls console_trylock() because in_sched == false.
> > 
> > (17) Thread-2 fails to acquire console_sem via down_trylock_console_sem().
> > 
> > (18) Thread-2 returns from vprintk_emit().
> > 
> > (19) Thread-2 leaves warn_alloc().
> > 
> > (20) When Thread-1 is waken up, it finds new data appended by Thread-2.
> > 
> > (21) Thread-1 remains inside console_unlock() with oom_lock still held
> >      because there is data which should be printed to consoles.
> > 
> > (22) Thread-2 remains failing to acquire oom_lock, periodically appending
> >      new data via warn_alloc(), and failing to acquire oom_lock.
> > 
> > (23) The user visible result is that Thread-1 is unable to return from
> > 
> >      pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n", ...);
> > 
> >      in oom_kill_process().
> 
> OK, I see. This is not a new problem though and people are trying to
> solve it in the printk proper. CCed some people, I do not have links
> to those threads handy. And if this is really the problem here then we
> definitely shouldn't put hacks into the page allocator path to handle
> it because there might be other sources of the printk flood might be
> arbitrary.

Yup, this is exactly the type of the problem that we want to solve
by the async printk.


> > The introduction of uncontrolled
> > 
> >   warn_alloc(gfp_mask, "page allocation stalls for %ums, order:%u", ...);

I am just curious that there would be so many messages.
If I get it correctly, this warning is printed
once every 10 second. Or am I wrong?

Well, you might want to consider using

		stall_timeout *= 2;

instead of adding the constant 10 * HZ.

Of course, a better would be some global throttling of
this message.


Best Regards,
Petr

PS: I am not mm expert and did not read this thread. Just ignore this
if I missed the point. Anyway, it sounds weird to linearize all
allocation request in OOM situation. It is much harder to unblock
a high-order requests than a low-order ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
