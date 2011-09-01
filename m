Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 506106B016A
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 17:33:40 -0400 (EDT)
Date: Thu, 1 Sep 2011 14:33:33 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] mm/backing-dev.c: Call del_timer_sync instead of
 del_timer
Message-Id: <20110901143333.51baf4ae.akpm@linux-foundation.org>
In-Reply-To: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
References: <1314892622-18267-1-git-send-email-consul.kautuk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Jens Axboe <jaxboe@fusionio.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Dave Chinner <dchinner@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu,  1 Sep 2011 21:27:02 +0530
Kautuk Consul <consul.kautuk@gmail.com> wrote:

> This is important for SMP scenario, to check whether the timer
> callback is executing on another CPU when we are deleting the
> timer.
> 

I don't see why?

> index d6edf8d..754b35a 100644
> --- a/mm/backing-dev.c
> +++ b/mm/backing-dev.c
> @@ -385,7 +385,7 @@ static int bdi_forker_thread(void *ptr)
>  		 * dirty data on the default backing_dev_info
>  		 */
>  		if (wb_has_dirty_io(me) || !list_empty(&me->bdi->work_list)) {
> -			del_timer(&me->wakeup_timer);
> +			del_timer_sync(&me->wakeup_timer);
>  			wb_do_writeback(me, 0);
>  		}

It isn't a use-after-free fix: bdi_unregister() safely shoots down any
running timer.

Please completely explain what you believe the problem is here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
