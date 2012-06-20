Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3292C6B005D
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 13:13:43 -0400 (EDT)
Received: by dakp5 with SMTP id p5so12714325dak.14
        for <linux-mm@kvack.org>; Wed, 20 Jun 2012 10:13:42 -0700 (PDT)
Date: Wed, 20 Jun 2012 10:13:37 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH] mm: offlining memory may block forever
Message-ID: <20120620171337.GA10287@kroah.com>
References: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEtiSau6dRYVOSD4-QUWkYZ8p7z1ATLHZY9v871VS=o0LduU_Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org, kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, tim.bird@am.sony.com, frank.rowand@am.sony.com, takuzo.ohara@ap.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

On Wed, Jun 20, 2012 at 09:53:31PM +0530, Aaditya Kumar wrote:
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

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
