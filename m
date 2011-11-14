Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 45A606B002D
	for <linux-mm@kvack.org>; Mon, 14 Nov 2011 15:05:16 -0500 (EST)
Received: by pzk1 with SMTP id 1so11729827pzk.6
        for <linux-mm@kvack.org>; Mon, 14 Nov 2011 12:05:13 -0800 (PST)
Date: Mon, 14 Nov 2011 12:05:06 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111114200506.GE30922@google.com>
References: <20111110163825.4321.56320.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111110163825.4321.56320.stgit@srivatsabhat.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello,

On Thu, Nov 10, 2011 at 10:12:43PM +0530, Srivatsa S. Bhat wrote:
> The lock_system_sleep() function is used in the memory hotplug code at
> several places in order to implement mutual exclusion with hibernation.
> However, this function tries to acquire the 'pm_mutex' lock using
> mutex_lock() and hence blocks in TASK_UNINTERRUPTIBLE state if it doesn't
> get the lock. This would lead to task freezing failures and hence
> hibernation failure as a consequence, even though the hibernation call path
> successfully acquired the lock.
> 
> This patch fixes this issue by modifying lock_system_sleep() to use
> mutex_lock_interruptible() instead of mutex_lock(), so that it blocks in the
> TASK_INTERRUPTIBLE state. This would allow the freezer to freeze the blocked
> task. Also, since the freezer could use signals to freeze tasks, it is quite
> likely that mutex_lock_interruptible() returns -EINTR (and fails to acquire
> the lock). Hence we keep retrying in a loop until we acquire the lock. Also,
> we call try_to_freeze() within the loop, so that we don't cause freezing
> failures due to busy looping.
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
...
>  static inline void lock_system_sleep(void)
>  {
> -	mutex_lock(&pm_mutex);
> +	/*
> +	 * We should not use mutex_lock() here because, in case we fail to
> +	 * acquire the lock, it would put us to sleep in TASK_UNINTERRUPTIBLE
> +	 * state, which would lead to task freezing failures. As a
> +	 * consequence, hibernation would fail (even though it had acquired
> +	 * the 'pm_mutex' lock).
> +	 *
> +	 * Note that mutex_lock_interruptible() returns -EINTR if we happen
> +	 * to get a signal when we are waiting to acquire the lock (and this
> +	 * is very likely here because the freezer could use signals to freeze
> +	 * tasks). Hence we have to keep retrying until we get the lock. But
> +	 * we have to use try_to_freeze() in the loop, so that we don't cause
> +	 * freezing failures due to busy looping.
> +	 */
> +	while (mutex_lock_interruptible(&pm_mutex))
> +		try_to_freeze();

Hmmm... is this a problem that we need to worry about?  If not, I'm
not sure this is a good idea.  What if the task calling
lock_system_sleep() is a userland one and has actual outstanding
signal?  It would busy spin until it acquire pm_mutex.  Maybe that's
okay too given how pm_mutex is used but it's still nasty.  If this
isn't a real problem, maybe leave this alone for now?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
