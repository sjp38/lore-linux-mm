Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C872A6B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 12:06:31 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id i131so26328398wmf.3
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 09:06:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x3si50123064wjs.193.2016.12.13.09.06.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 13 Dec 2016 09:06:30 -0800 (PST)
Date: Tue, 13 Dec 2016 18:06:28 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161213170628.GC18362@dhcp22.suse.cz>
References: <201612102024.CBB26549.SJFOOtOVMFFQHL@I-love.SAKURA.ne.jp>
 <20161212090702.GD18163@dhcp22.suse.cz>
 <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
 <20161212125535.GA3185@dhcp22.suse.cz>
 <20161212131910.GC3185@dhcp22.suse.cz>
 <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On Tue 13-12-16 21:06:57, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 12-12-16 13:55:35, Michal Hocko wrote:
> > > On Mon 12-12-16 21:12:06, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > [...]
> > > > > > I think this warn_alloc() is too much noise. When something went
> > > > > > wrong, multiple instances of Thread-2 tend to call warn_alloc()
> > > > > > concurrently. We don't need to report similar memory information.
> > > > > 
> > > > > That is why we have ratelimitting. It is needs a better tunning then
> > > > > just let's do it.
> > > > 
> > > > I think that calling show_mem() once per a series of warn_alloc() threads is
> > > > sufficient. Since the amount of output by dump_stack() and that by show_mem()
> > > > are nearly equals, we can save nearly 50% of output if we manage to avoid
> > > > the same show_mem() calls.
> > > 
> > > I do not mind such an update. Again, that is what we have the
> > > ratelimitting for. The fact that it doesn't throttle properly means that
> > > we should tune its parameters.
> > 
> > What about the following? Does this help?
> 
> I don't think it made much difference.

Because I am an idiot. The condition is wrong.
	if (!should_suppress_show_mem() || __ratelimit(&nopage_rs))
		show_mem(filter);
	
it should read
	if (!should_suppress_show_mem() && __ratelimit(&nopage_rs))
		show_mem(filter);

so there was throttling at all. :/ Sorry about that!
 
> I noticed that one of triggers which cause a lot of
> "** XXX printk messages dropped **" is show_all_locks() added by
> commit b2d4c2edb2e4f89a ("locking/hung_task: Show all locks"). When there are
> a lot of threads being blocked on fs locks, show_all_locks() on each blocked
> thread generates incredible amount of messages periodically. Therefore,
> I temporarily set /proc/sys/kernel/hung_task_timeout_secs to 0 to disable
> hung task warnings for testing this patch.
> 
> http://I-love.SAKURA.ne.jp/tmp/serial-20161213.txt.xz is a console log with
> this patch applied. Due to hung task warnings disabled, amount of messages
> are significantly reduced.
> 
> Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> Since there are some "** XXX printk messages dropped **" messages, I can't
> tell whether the OOM killer was able to make forward progress. But guessing
>  from the result that there is no corresponding "Killed process" line for
> "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> I think it is OK to say that the system got stuck because the OOM killer was
> not able to make forward progress.

The oom situation certainly didn't get resolved. I would be really
curious whether we can rule out the printk out of the picture, though. I
am still not sure we can rule out some obscure OOM killer bug at this
stage.

What if we lower the loglevel as much as possible to only see KERN_ERR
should be sufficient to see few oom killer messages while suppressing
most of the other noise. Unfortunatelly, even messages with level >
loglevel get stored into the ringbuffer (as I've just learned) so
console_unlock() has to crawl through them just to drop them (Meh) but
at least it doesn't have to go to the serial console drivers and spend
even more time there. An alternative would be to tweak printk to not
even store those messaes. Something like the below

diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index f7a55e9ff2f7..197f2b9fb703 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1865,6 +1865,15 @@ asmlinkage int vprintk_emit(int facility, int level,
 				lflags |= LOG_CONT;
 			}
 
+			if (suppress_message_printing(kern_level)) {
+				logbuf_cpu = UINT_MAX;
+				raw_spin_unlock(&logbuf_lock);
+				lockdep_on();
+				local_irq_restore(flags);
+				return 0;
+			}
+
+
 			text_len -= 2;
 			text += 2;
 		}

So it would be really great if you could
	1) test with the fixed throttling
	2) loglevel=4 on the kernel command line
	3) try the above with the same loglevel

ideally 1) would be sufficient and that would make the most sense from
the warn_alloc point of view. If this is 2 or 3 then we are hitting a
more generic problem and I would be quite careful to hack it around.
 
> ----------
> [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> (...snipped...)
> [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> ----------
> 
> Although it is fine to make warn_alloc() less verbose, this is not
> a problem which can be avoided by simply reducing printk(). Unless
> we give enough CPU time to the OOM killer and OOM victims, it is
> trivial to lockup the system.

This is simply hard if there are way too many tasks runnable...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
