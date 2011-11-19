Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CB4F36B0069
	for <linux-mm@kvack.org>; Sat, 19 Nov 2011 16:54:38 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH v3] PM/Memory-hotplug: Avoid task freezing failures
Date: Sat, 19 Nov 2011 22:57:19 +0100
References: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
In-Reply-To: <20111117083042.11419.19871.stgit@srivatsabhat.in.ibm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201111192257.19763.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>
Cc: pavel@ucw.cz, lenb@kernel.org, ak@linux.intel.com, tj@kernel.org, linux-kernel@vger.kernel.org, linux-pm@vger.kernel.org, linux-mm@kvack.org

On Thursday, November 17, 2011, Srivatsa S. Bhat wrote:
> The lock_system_sleep() function is used in the memory hotplug code at
> several places in order to implement mutual exclusion with hibernation.
> However, this function tries to acquire the 'pm_mutex' lock using
> mutex_lock() and hence blocks in TASK_UNINTERRUPTIBLE state if it doesn't
> get the lock. This would lead to task freezing failures and hence
> hibernation failure as a consequence, even though the hibernation call path
> successfully acquired the lock.
> 
> This patch fixes this issue by modifying lock_system_sleep() to use
> mutex_trylock() in a loop until the lock is acquired, instead of using
> mutex_lock(), in order to avoid going to uninterruptible sleep.
> Also, we use msleep() to avoid busy looping and breaking expectations
> that we go to sleep when we fail to acquire the lock.
> And we also call try_to_freeze() in order to cooperate with the freezer,
> without which we would end up in almost the same situation as mutex_lock(),
> due to uninterruptible sleep caused by msleep().
> 
> v3: Tejun suggested avoiding busy-looping by adding an msleep() since
>     it is not guaranteed that we will get frozen immediately.
> 
> v2: Tejun pointed problems with using mutex_lock_interruptible() in a
>     while loop, when signals not related to freezing are involved.
>     So, replaced it with mutex_trylock().
> 
> Signed-off-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> ---
> 
>  include/linux/suspend.h |   37 ++++++++++++++++++++++++++++++++++++-
>  1 files changed, 36 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/suspend.h b/include/linux/suspend.h
> index 57a6924..0af3048 100644
> --- a/include/linux/suspend.h
> +++ b/include/linux/suspend.h
> @@ -5,6 +5,8 @@
>  #include <linux/notifier.h>
>  #include <linux/init.h>
>  #include <linux/pm.h>
> +#include <linux/freezer.h>
> +#include <linux/delay.h>
>  #include <linux/mm.h>
>  #include <asm/errno.h>
>  
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

The number here seems to be somewhat arbitrary.  Is there any reason not to
use 100 or any other number?

> +	}
>  }
>  
>  static inline void unlock_system_sleep(void)

Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
