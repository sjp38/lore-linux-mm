Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id D7D886B004D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 21:37:36 -0400 (EDT)
Message-ID: <4FE27AE8.2080906@kernel.org>
Date: Thu, 21 Jun 2012 10:37:44 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: offlining memory may block forever
References: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
In-Reply-To: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, kosaki.motohiro@jp.fujitsu.com, gregkh@linuxfoundation.org, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On 06/21/2012 01:23 AM, Aaditya Kumar wrote:

> Offlining memory may block forever, waiting for kswapd() to wake up because
> kswapd() does not check the event kthread->should_stop before sleeping.

> 

> The proper pattern, from Documentation/memory-barriers.txt, is:
>    ---  waker  ---
>    event_indicated = 1;
>    wake_up_process(event_daemon);
> 
>    ---  sleeper  ---
>    for (;;) {
>       set_current_state(TASK_UNINTERRUPTIBLE);
>       if (event_indicated)
>          break;
>       schedule();
>    }
> 
>    set_current_state() may be wrapped by:
>       prepare_to_wait();
> 
> In the kswapd() case, event_indicated is kthread->should_stop.
> ---  offlining memory (waker)  ---
>    kswapd_stop()
>       kthread_stop()
>          kthread->should_stop = 1
>          wake_up_process()
>          wait_for_completion()
> 
> 
> ---  kswapd_try_to_sleep (sleeper)  ---
>    kswapd_try_to_sleep()
>       prepare_to_wait()
>            .
>            .
>       schedule()
>            .
>            .
>       finish_wait()
> 
>    The schedule() needs to be protected by a test of kthread->should_stop,
>    which is wrapped by kthread_should_stop().
> 
> Reproducer:
>    Do heavy file I/O in background.
>    Do a memory offline/online in a tight loop
> 
> 
> Signed-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>

Reviewed-by: Minchan Kim <minchan@kernel.org>

Nitpick: We can remove kthread_should_stop check earlier in kswapd_try_to_sleep.
         But it's no biggie. And I hope you change patch title 
	 
	 Title : Fix loss of kswapd wakeup in kswapd_stop
	 Description: Offlining memory may block forever because blah, blah, blah.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
