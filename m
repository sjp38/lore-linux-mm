Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 46EC26B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 09:00:31 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id r20so5890639wrg.23
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 06:00:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i77si1258972wme.39.2017.12.08.06.00.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 06:00:26 -0800 (PST)
Date: Fri, 8 Dec 2017 15:00:22 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to load
 balance console writes
Message-ID: <20171208140022.uln4t5e5drrhnvvt@pathway.suse.cz>
References: <20171108102723.602216b1@gandalf.local.home>
 <20171124152857.ahnapnwmmsricunz@pathway.suse.cz>
 <20171124155816.pxp345ch4gevjqjm@pathway.suse.cz>
 <20171128014229.GA2899@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171128014229.GA2899@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, akpm@linux-foundation.org, linux-mm@kvack.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rostedt@home.goodmis.org, kernel-team@lge.com

Hello,

thanks a lot for help. I am sorry for the late response. I wanted to
handle this mail with a clean head.

On Tue 2017-11-28 10:42:29, Byungchul Park wrote:
> On Fri, Nov 24, 2017 at 04:58:16PM +0100, Petr Mladek wrote:
> > @@ -1797,13 +1797,6 @@ asmlinkage int vprintk_emit(int facility, int level,
> >  				spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> >  				printk_safe_exit_irqrestore(flags);
> >  
> > -				/*
> > -				 * The owner passed the console lock to us.
> > -				 * Since we did not spin on console lock, annotate
> > -				 * this as a trylock. Otherwise lockdep will
> > -				 * complain.
> > -				 */
> > -				mutex_acquire(&console_lock_dep_map, 0, 1, _THIS_IP_);
> 
> Hello Petr,
> 
> IMHO, it would get unbalanced if you only remove this mutex_acquire().
> 
> >  				console_unlock();
> >  				printk_safe_enter_irqsave(flags);
> >  			}
> > @@ -2334,10 +2327,10 @@ void console_unlock(void)
> >  		/* The waiter is now free to continue */
> >  		spin_release(&console_owner_dep_map, 1, _THIS_IP_);
> >  		/*
> > -		 * Hand off console_lock to waiter. The waiter will perform
> > -		 * the up(). After this, the waiter is the console_lock owner.
> > +		 * Hand off console_lock to waiter. After this, the waiter
> > +		 * is the console_lock owner.
> >  		 */
> > -		mutex_release(&console_lock_dep_map, 1, _THIS_IP_);
> 
> IMHO, this release() should be moved to somewhere properly.
> 
> > +		lock_commit_crosslock((struct lockdep_map *)&console_lock_dep_map);
> >  		printk_safe_exit_irqrestore(flags);
> >  		/* Note, if waiter is set, logbuf_lock is not held */
> >  		return;
> 
> However, now that cross-release was introduces, lockdep can be applied
> to semaphore operations. Actually, I have a plan to do that. I think it
> would be better to make semaphore tracked with lockdep and remove all
> these manual acquire() and release() here. What do you think about it?

IMHO, it would be great to add lockdep annotations into semaphore
operations.

Well, I am not sure if this would be enough in this case. I think
that the locking dependency in this Steven's patch is special.
The semaphore is passed from one owner to another one without
unlocking. Both sides wait for each other using a busy loop.

The busy loop/waiting is activated only when the current owner
is not sleeping to avoid softlockup. I think that it is
a kind of conditional cross-release or something even
more special.

Sigh, I wish I was able to clean my head even more to be
able to think about this.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
