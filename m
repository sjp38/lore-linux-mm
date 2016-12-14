Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3947A6B0038
	for <linux-mm@kvack.org>; Wed, 14 Dec 2016 06:37:17 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 83so22715223pfx.1
        for <linux-mm@kvack.org>; Wed, 14 Dec 2016 03:37:17 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d2si52433241pli.33.2016.12.14.03.37.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Dec 2016 03:37:16 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612122112.IBI64512.FOVOFQFLMJHOtS@I-love.SAKURA.ne.jp>
	<20161212125535.GA3185@dhcp22.suse.cz>
	<20161212131910.GC3185@dhcp22.suse.cz>
	<201612132106.IJH12421.LJStOQMVHFOFOF@I-love.SAKURA.ne.jp>
	<20161213170628.GC18362@dhcp22.suse.cz>
In-Reply-To: <20161213170628.GC18362@dhcp22.suse.cz>
Message-Id: <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
Date: Wed, 14 Dec 2016 20:37:07 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

Michal Hocko wrote:
> On Tue 13-12-16 21:06:57, Tetsuo Handa wrote:
> > http://I-love.SAKURA.ne.jp/tmp/serial-20161213.txt.xz is a console log with
> > this patch applied. Due to hung task warnings disabled, amount of messages
> > are significantly reduced.
> > 
> > Uptime > 400 are testcases where the stresser was invoked via "taskset -c 0".
> > Since there are some "** XXX printk messages dropped **" messages, I can't
> > tell whether the OOM killer was able to make forward progress. But guessing
> >  from the result that there is no corresponding "Killed process" line for
> > "Out of memory: " line at uptime = 450 and the duration of PID 14622 stalled,
> > I think it is OK to say that the system got stuck because the OOM killer was
> > not able to make forward progress.
> 
> The oom situation certainly didn't get resolved. I would be really
> curious whether we can rule out the printk out of the picture, though. I
> am still not sure we can rule out some obscure OOM killer bug at this
> stage.
> 
> What if we lower the loglevel as much as possible to only see KERN_ERR
> should be sufficient to see few oom killer messages while suppressing
> most of the other noise. Unfortunatelly, even messages with level >
> loglevel get stored into the ringbuffer (as I've just learned) so
> console_unlock() has to crawl through them just to drop them (Meh) but
> at least it doesn't have to go to the serial console drivers and spend
> even more time there. An alternative would be to tweak printk to not
> even store those messaes. Something like the below

Changing loglevel is not a option for me. Under OOM, syslog cannot work.
Only messages sent to serial console / netconsole are available for
understanding something went wrong. And serial consoles may be very slow.
We need to try to avoid uncontrolled printk().

> 
> diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
> index f7a55e9ff2f7..197f2b9fb703 100644
> --- a/kernel/printk/printk.c
> +++ b/kernel/printk/printk.c
> @@ -1865,6 +1865,15 @@ asmlinkage int vprintk_emit(int facility, int level,
>  				lflags |= LOG_CONT;
>  			}
>  
> +			if (suppress_message_printing(kern_level)) {
> +				logbuf_cpu = UINT_MAX;
> +				raw_spin_unlock(&logbuf_lock);
> +				lockdep_on();
> +				local_irq_restore(flags);
> +				return 0;
> +			}
> +
> +
>  			text_len -= 2;
>  			text += 2;
>  		}
> 
> So it would be really great if you could
> 	1) test with the fixed throttling
> 	2) loglevel=4 on the kernel command line
> 	3) try the above with the same loglevel
> 
> ideally 1) would be sufficient and that would make the most sense from
> the warn_alloc point of view. If this is 2 or 3 then we are hitting a
> more generic problem and I would be quite careful to hack it around.

Thus, I don't think I can do these.

>  
> > ----------
> > [  450.767693] Out of memory: Kill process 14642 (a.out) score 999 or sacrifice child
> > [  450.769974] Killed process 14642 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.776538] oom_reaper: reaped process 14642 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.781170] Out of memory: Kill process 14643 (a.out) score 999 or sacrifice child
> > [  450.783469] Killed process 14643 (a.out) total-vm:4168kB, anon-rss:84kB, file-rss:0kB, shmem-rss:0kB
> > [  450.787912] oom_reaper: reaped process 14643 (a.out), now anon-rss:0kB, file-rss:0kB, shmem-rss:0kB
> > [  450.792630] Out of memory: Kill process 14644 (a.out) score 999 or sacrifice child
> > [  450.964031] a.out: page allocation stalls for 10014ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  450.964033] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > (...snipped...)
> > [  740.984902] a.out: page allocation stalls for 300003ms, order:0, mode:0x24280ca(GFP_HIGHUSER_MOVABLE|__GFP_ZERO)
> > [  740.984905] CPU: 0 PID: 14622 Comm: a.out Tainted: G        W       4.9.0+ #99
> > ----------
> > 
> > Although it is fine to make warn_alloc() less verbose, this is not
> > a problem which can be avoided by simply reducing printk(). Unless
> > we give enough CPU time to the OOM killer and OOM victims, it is
> > trivial to lockup the system.
> 
> This is simply hard if there are way too many tasks runnable...

Runnable threads which do not involve page allocation do not harm.
Only runnable threads which are almost-busy-looping with direct reclaim
are problematic. mutex_lock_killable(&oom_lock) is the simplest approach
for eliminating such threads and prevent such threads from calling
warn_alloc() uncontrolledly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
