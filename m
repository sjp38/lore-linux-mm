Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 829C26B005A
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 14:49:18 -0400 (EDT)
Message-ID: <4FE21B21.6070608@jp.fujitsu.com>
Date: Wed, 20 Jun 2012 14:49:05 -0400
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: offlining memory may block forever
References: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
In-Reply-To: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aaditya.kumar.30@gmail.com
Cc: kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, kosaki.motohiro@jp.fujitsu.com, gregkh@linuxfoundation.org, mel@csn.ul.ie, kamezawa.hiroyu@jp.fujitsu.com, minchan@kernel.org, mhocko@suse.cz, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On 6/20/2012 12:23 PM, Aaditya Kumar wrote:
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

Please avoid "---". This is used for a separator between a patch
description and code.

Other than that,
 Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>


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
> 
> ---
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index eeb3bc9..b60691e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -2688,7 +2688,10 @@ static void kswapd_try_to_sleep(pg_data_t
> *pgdat, int order, int classzone_idx)
>  		 * them before going back to sleep.
>  		 */
>  		set_pgdat_percpu_threshold(pgdat, calculate_normal_threshold);
> -		schedule();
> +
> +		if (!kthread_should_stop())
> +			schedule();
> +
>  		set_pgdat_percpu_threshold(pgdat, calculate_pressure_threshold);
>  	} else {
>  		if (remaining)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
