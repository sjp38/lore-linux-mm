Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 417616B0169
	for <linux-mm@kvack.org>; Fri, 19 Aug 2011 19:56:44 -0400 (EDT)
Date: Fri, 19 Aug 2011 16:56:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 3/3]vmscan: cleanup kswapd_try_to_sleep
Message-Id: <20110819165636.460b884e.akpm@linux-foundation.org>
In-Reply-To: <1311840789.15392.409.camel@sli10-conroe>
References: <1311840789.15392.409.camel@sli10-conroe>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: linux-mm <linux-mm@kvack.org>, mgorman@suse.de, Minchan Kim <minchan.kim@gmail.com>

On Thu, 28 Jul 2011 16:13:09 +0800
Shaohua Li <shaohua.li@intel.com> wrote:

> cleanup kswapd_try_to_sleep() a little bit. Sometimes kswapd doesn't
> really sleep. In such case, don't call prepare_to_wait/finish_wait.
> It just wastes CPU.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> ---
>  mm/vmscan.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> Index: linux/mm/vmscan.c
> ===================================================================
> --- linux.orig/mm/vmscan.c	2011-07-28 15:52:35.000000000 +0800
> +++ linux/mm/vmscan.c	2011-07-28 15:55:56.000000000 +0800
> @@ -2709,13 +2709,11 @@ static void kswapd_try_to_sleep(pg_data_
>  	if (freezing(current) || kthread_should_stop())
>  		return;
>  
> -	prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
> -
>  	/* Try to sleep for a short interval */
>  	if (!sleeping_prematurely(pgdat, order, remaining, classzone_idx)) {
> +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  		remaining = schedule_timeout(HZ/10);
>  		finish_wait(&pgdat->kswapd_wait, &wait);
> -		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  	}
>  
>  	/*
> @@ -2734,7 +2732,9 @@ static void kswapd_try_to_sleep(pg_data_
>  		 * them before going back to sleep.
>  		 */
>  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> +		prepare_to_wait(&pgdat->kswapd_wait, &wait, TASK_INTERRUPTIBLE);
>  		schedule();
> +		finish_wait(&pgdat->kswapd_wait, &wait);
>  		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
>  	} else {
>  		if (remaining)
> @@ -2742,7 +2742,6 @@ static void kswapd_try_to_sleep(pg_data_
>  		else
>  			count_vm_event(KSWAPD_HIGH_WMARK_HIT_QUICKLY);
>  	}
> -	finish_wait(&pgdat->kswapd_wait, &wait);
>  }

Well.   Here's some correct waiting code:

	prepare_to_wait(...);
	if (condition)
		schedule();
	finish_wait();

And here's come incorrect waiting code:

	if (condition) {
				<-- if `condition' becomese false here we can
				    sleep incorrectly and even miss a wakeup.
		prepare_to_wait(...);
		schedule();
		finish_wait();
	}

Your patch converts balance_pgdat() from the correct pattern to the
incorrect pattern.  This may be OK given the overall sloppiness of the
vmscan synchronisation.  But I think we need to convince ourselves that
we aren't adding rarely-occurring bugs or inefficiencies, and that this
change won't cause us to accidentally introduce rarely-occurring bugs
or inefficiencies as the code eveolves.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
