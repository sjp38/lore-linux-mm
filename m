Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id E791F6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:58:27 -0500 (EST)
Received: by ykdr82 with SMTP id r82so254936521ykd.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:58:27 -0800 (PST)
Received: from mail-yk0-x22c.google.com (mail-yk0-x22c.google.com. [2607:f8b0:4002:c07::22c])
        by mx.google.com with ESMTPS id e4si9067751ywd.29.2015.11.23.14.58.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Nov 2015 14:58:27 -0800 (PST)
Received: by ykba77 with SMTP id a77so255483708ykb.2
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 14:58:27 -0800 (PST)
Date: Mon, 23 Nov 2015 17:58:23 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 09/22] kthread: Allow to cancel kthread work
Message-ID: <20151123225823.GI19072@mtj.duckdns.org>
References: <1447853127-3461-1-git-send-email-pmladek@suse.com>
 <1447853127-3461-10-git-send-email-pmladek@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1447853127-3461-10-git-send-email-pmladek@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

Hello,

On Wed, Nov 18, 2015 at 02:25:14PM +0100, Petr Mladek wrote:
> +static int
> +try_to_cancel_kthread_work(struct kthread_work *work,
> +				   spinlock_t *lock,
> +				   unsigned long *flags)
> +{
> +	int ret = 0;
> +
> +	if (work->timer) {
> +		/* Try to cancel the timer if pending. */
> +		if (del_timer(work->timer)) {
> +			ret = 1;
> +			goto out;
> +		}
> +
> +		/* Are we racing with the timer callback? */
> +		if (timer_active(work->timer)) {
> +			/* Bad luck, need to avoid a deadlock. */
> +			spin_unlock_irqrestore(lock, *flags);
> +			del_timer_sync(work->timer);
> +			ret = -EAGAIN;
> +			goto out;
> +		}

As the timer side is already kinda trylocking anyway, can't the cancel
path be made simpler?  Sth like

	lock(worker);
	work->canceling = true;
	del_timer_sync(work->timer);
	unlock(worker);

And the timer can do (ignoring the multiple worker support, do we even
need that?)

	while (!trylock(worker)) {
		if (work->canceling)
			return;
		cpu_relax();
	}
	queue;
	unlock(worker);

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
