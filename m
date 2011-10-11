Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E86816B002D
	for <linux-mm@kvack.org>; Tue, 11 Oct 2011 15:19:59 -0400 (EDT)
Date: Tue, 11 Oct 2011 21:16:03 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [patch resend] oom: thaw threads if oom killed thread is
	frozen before deferring
Message-ID: <20111011191603.GA12751@redhat.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

I guess this patch doesn't need my ack, but just in case, I think it is
fine. Even if (perhaps) we can do something better later, with the upcoming
changes in refrigerator.

David. Could you also resend you patches which remove the (imho really
annoying) mm->oom_disable_count? Feel free to add my ack or reviewed-by.

Oleg.

On 10/07, David Rientjes wrote:
>
> If a thread has been oom killed and is frozen, thaw it before returning
> to the page allocator.  Otherwise, it can stay frozen indefinitely and
> no memory will be freed.
>
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -318,8 +318,11 @@ static struct task_struct *select_bad_process(unsigned int *ppoints,
>  		 * blocked waiting for another task which itself is waiting
>  		 * for memory. Is there a better alternative?
>  		 */
> -		if (test_tsk_thread_flag(p, TIF_MEMDIE))
> +		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
> +			if (unlikely(frozen(p)))
> +				thaw_process(p);
>  			return ERR_PTR(-1UL);
> +		}
>  		if (!p->mm)
>  			continue;
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
