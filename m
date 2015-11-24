Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9661A6B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 05:21:45 -0500 (EST)
Received: by wmuu63 with SMTP id u63so89577897wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 02:21:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g10si25735468wmi.15.2015.11.24.02.21.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 02:21:44 -0800 (PST)
Date: Tue, 24 Nov 2015 11:21:43 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v3 09/22] kthread: Allow to cancel kthread work
Message-ID: <20151124102143.GG10750@pathway.suse.cz>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-10-git-send-email-pmladek@suse.com>
 <20151123225823.GI19072@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123225823.GI19072@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2015-11-23 17:58:23, Tejun Heo wrote:
> Hello,
> 
> On Wed, Nov 18, 2015 at 02:25:14PM +0100, Petr Mladek wrote:
> > +static int
> > +try_to_cancel_kthread_work(struct kthread_work *work,
> > +				   spinlock_t *lock,
> > +				   unsigned long *flags)
> > +{
> > +	int ret = 0;
> > +
> > +	if (work->timer) {
> > +		/* Try to cancel the timer if pending. */
> > +		if (del_timer(work->timer)) {
> > +			ret = 1;
> > +			goto out;
> > +		}
> > +
> > +		/* Are we racing with the timer callback? */
> > +		if (timer_active(work->timer)) {
> > +			/* Bad luck, need to avoid a deadlock. */
> > +			spin_unlock_irqrestore(lock, *flags);
> > +			del_timer_sync(work->timer);
> > +			ret = -EAGAIN;
> > +			goto out;
> > +		}
> 
> As the timer side is already kinda trylocking anyway, can't the cancel
> path be made simpler?  Sth like
> 
> 	lock(worker);
> 	work->canceling = true;
> 	del_timer_sync(work->timer);
> 	unlock(worker);
> 
> And the timer can do (ignoring the multiple worker support, do we even
> need that?)
> 
> 	while (!trylock(worker)) {
> 		if (work->canceling)
> 			return;
> 		cpu_relax();
> 	}
> 	queue;
> 	unlock(worker);

Why did I not find out this myself ?:-)

Thanks for hint,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
