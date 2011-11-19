Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 052A76B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 13:32:48 -0500 (EST)
Received: by iaek3 with SMTP id k3so6865451iae.14
        for <linux-mm@kvack.org>; Sat, 19 Nov 2011 10:32:46 -0800 (PST)
Date: Sat, 19 Nov 2011 10:32:40 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
Message-ID: <20111119183240.GA17252@google.com>
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

Hello, Srivatsa.

On Thu, Nov 17, 2011 at 02:00:50PM +0530, Srivatsa S. Bhat wrote:
> @@ -380,7 +382,40 @@ static inline void unlock_system_sleep(void) {}
>  
>  static inline void lock_system_sleep(void)
>  {
> -	mutex_lock(&pm_mutex);
> +	/*
> +	 * "To sleep, or not to sleep, that is the question!"
> +	 *
> +	 * We should not use mutex_lock() here because, in case we fail to
> +	 * acquire the lock, it would put us to sleep in TASK_UNINTERRUPTIBLE
> +	 * state, which would lead to task freezing failures. As a
> +	 * consequence, hibernation would fail (even though it had acquired
> +	 * the 'pm_mutex' lock).
> +	 * Using mutex_lock_interruptible() in a loop is not a good idea,
> +	 * because we could end up treating non-freezing signals badly.
> +	 * So we use mutex_trylock() in a loop instead.
> +	 *
> +	 * Also, we add try_to_freeze() to the loop, to co-operate with the
> +	 * freezer, to avoid task freezing failures due to busy-looping.
> +	 *
> +	 * But then, since it is not guaranteed that we will get frozen
> +	 * rightaway, we could keep spinning for some time, breaking the
> +	 * expectation that we go to sleep when we fail to acquire the lock.
> +	 * So we add an msleep() to the loop, to dampen the spin (but we are
> +	 * careful enough not to sleep for too long at a stretch, lest the
> +	 * freezer whine and give up again!).
> +	 *
> +	 * Now that we no longer busy-loop, try_to_freeze() becomes all the
> +	 * more important, due to a subtle reason: if we don't cooperate with
> +	 * the freezer at this point, we could end up in a situation very
> +	 * similar to mutex_lock() due to the usage of msleep() (which sleeps
> +	 * uninterruptibly).
> +	 *
> +	 * Phew! What a delicate balance!
> +	 */
> +	while (!mutex_trylock(&pm_mutex)) {
> +		try_to_freeze();
> +		msleep(10);
> +	}

I tried to think about a better way to do it but couldn't, so I
suppose this is what we should go with for now.  That said, I think
the comment is a bit too umm.... verbose.  What we want here is
freezable but !interruptible mutex_lock() and while I do appreciate
the detailed comment, I think it makes it look a lot more complex than
it actually is.  Other than that,

 Acked-by: Tejun Heo <tj@kernel.org>

Thank you very much.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
