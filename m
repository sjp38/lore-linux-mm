Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D78C76B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 22:00:02 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 285493EE0BD
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:00:01 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0CD4B45DEB2
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:00:01 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E8D3745DEA6
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:00:00 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1EDE1DB803C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:00:00 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 833F31DB8040
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:00:00 +0900 (JST)
Message-ID: <4FDFDCA7.8060607@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 10:57:59 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, oom: do not schedule if current has been killed
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

(2012/06/19 10:08), David Rientjes wrote:
> The oom killer currently schedules away from current in an
> uninterruptible sleep if it does not have access to memory reserves.
> It's possible that current was killed because it shares memory with the
> oom killed thread or because it was killed by the user in the interim,
> however.
>
> This patch only schedules away from current if it does not have a pending
> kill, i.e. if it does not share memory with the oom killed thread.  It's
> possible that it will immediately retry its memory allocation and fail,
> but it will immediately be given access to memory reserves if it calls
> the oom killer again.
>
> This prevents the delay of memory freeing when threads that share memory
> with the oom killed thread get unnecessarily scheduled.
>
> Signed-off-by: David Rientjes<rientjes@google.com>

fatal_signal_pending() == false if test_thread_flag(TIF_MEMDIE)==false ?

I'll check memcg code..

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



> ---
>   mm/oom_kill.c |    4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -749,7 +749,7 @@ out:
>   	 * Give "p" a good chance of killing itself before we
>   	 * retry to allocate memory unless "p" is current
>   	 */
> -	if (killed&&  !test_thread_flag(TIF_MEMDIE))
> +	if (killed&&  !fatal_signal_pending(current))
>   		schedule_timeout_uninterruptible(1);
>   }
>
> @@ -765,6 +765,6 @@ void pagefault_out_of_memory(void)
>   		out_of_memory(NULL, 0, 0, NULL, false);
>   		clear_system_oom();
>   	}
> -	if (!test_thread_flag(TIF_MEMDIE))
> +	if (!fatal_signal_pending(current))
>   		schedule_timeout_uninterruptible(1);
>   }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
