Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6601D6B0062
	for <linux-mm@kvack.org>; Mon, 18 Jun 2012 22:53:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 9BC9D3EE0BC
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:53:39 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E8C745DE58
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:53:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 64D6645DE56
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:53:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 503CC1DB803F
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:53:39 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0260AE18008
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 11:53:39 +0900 (JST)
Message-ID: <4FDFE935.6080804@jp.fujitsu.com>
Date: Tue, 19 Jun 2012 11:51:33 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch v2] mm, oom: do not schedule if current has been killed
References: <alpine.DEB.2.00.1206181807060.13281@chino.kir.corp.google.com> <4FDFDCA7.8060607@jp.fujitsu.com> <alpine.DEB.2.00.1206181918390.13293@chino.kir.corp.google.com> <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206181930550.13293@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org

(2012/06/19 11:31), David Rientjes wrote:
> The oom killer currently schedules away from current in an
> uninterruptible sleep if it does not have access to memory reserves.
> It's possible that current was killed because it shares memory with the
> oom killed thread or because it was killed by the user in the interim,
> however.
>
> This patch only schedules away from current if it does not have a pending
> kill, i.e. if it does not share memory with the oom killed thread, or is
> already exiting.  It's possible that it will immediately retry its memory
> allocation and fail, but it will immediately be given access to memory
> reserves if it calls the oom killer again.
>
> This prevents the delay of memory freeing when threads that share memory
> with the oom killed thread get unnecessarily scheduled.
>
> Signed-off-by: David Rientjes<rientjes@google.com>

seems good to me.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   mm/oom_kill.c |    7 ++++---
>   1 file changed, 4 insertions(+), 3 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -746,10 +746,11 @@ out:
>   	read_unlock(&tasklist_lock);
>
>   	/*
> -	 * Give "p" a good chance of killing itself before we
> +	 * Give "p" a good chance of exiting before we
>   	 * retry to allocate memory unless "p" is current
>   	 */
> -	if (killed&&  !test_thread_flag(TIF_MEMDIE))
> +	if (killed&&  !fatal_signal_pending(current)&&
> +		      !(current->flags&  PF_EXITING))
>   		schedule_timeout_uninterruptible(1);
>   }
>
> @@ -765,6 +766,6 @@ void pagefault_out_of_memory(void)
>   		out_of_memory(NULL, 0, 0, NULL, false);
>   		clear_system_oom();
>   	}
> -	if (!test_thread_flag(TIF_MEMDIE))
> +	if (!fatal_signal_pending(current)&&  !(current->flags&  PF_EXITING))
>   		schedule_timeout_uninterruptible(1);
>   }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
