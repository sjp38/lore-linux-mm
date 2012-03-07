Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id A93026B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 01:39:05 -0500 (EST)
Received: by vbbey12 with SMTP id ey12so6743175vbb.14
        for <linux-mm@kvack.org>; Tue, 06 Mar 2012 22:39:04 -0800 (PST)
Message-ID: <4F570286.8020704@gmail.com>
Date: Wed, 07 Mar 2012 01:39:02 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, oom: allow exiting tasks to have access to memory
 reserves
References: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1203061824280.9015@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, kosaki.motohiro@gmail.com

(3/6/12 9:25 PM), David Rientjes wrote:
> The tasklist iteration only checks processes and avoids individual
> threads so it is possible that threads that are currently exiting may not
> appropriately being selected for oom kill.  This can lead to negative
> results such as an innocent process being killed in the interim or, in
> the worst case, the machine panicking because there is nothing else to kill.
>
> We automatically select PF_EXITING threads during the tasklist iteration,
> so this saves time and prevents threads that haven't yet exited (although
> their parent has been oom killed) from getting missed.
>
> Note that by doing this we aren't actually oom killing an exiting thread
> but rather giving it full access to memory reserves so it may quickly
> exit and free its memory.
>
> Signed-off-by: David Rientjes<rientjes@google.com>

As far as I remembered, this idea was sometimes NAKed and you don't bring new idea here.
When exiting a process which have plenty threads, this patch allow to eat all of reserve memory
and bring us new serious failure.

Moreover, creating new thread isn't needed root privilege, then this trick can be used by attacker.

- kosaki


> ---
>   mm/oom_kill.c |   16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -568,11 +568,11 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask)
>   	struct task_struct *p;
>
>   	/*
> -	 * If current has a pending SIGKILL, then automatically select it.  The
> -	 * goal is to allow it to allocate so that it may quickly exit and free
> -	 * its memory.
> +	 * If current is exiting (or going to exit), then automatically select
> +	 * it.  The goal is to allow it to allocate so that it may quickly exit
> +	 * and free its memory.
>   	 */
> -	if (fatal_signal_pending(current)) {
> +	if (fatal_signal_pending(current) || (current->flags&  PF_EXITING)) {
>   		set_thread_flag(TIF_MEMDIE);
>   		return;
>   	}
> @@ -723,11 +723,11 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
>   		return;
>
>   	/*
> -	 * If current has a pending SIGKILL, then automatically select it.  The
> -	 * goal is to allow it to allocate so that it may quickly exit and free
> -	 * its memory.
> +	 * If current is exiting (or going to exit), then automatically select
> +	 * it.  The goal is to allow it to allocate so that it may quickly exit
> +	 * and free its memory.
>   	 */
> -	if (fatal_signal_pending(current)) {
> +	if (fatal_signal_pending(current) || (current->flags&  PF_EXITING)) {
>   		set_thread_flag(TIF_MEMDIE);
>   		return;
>   	}
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
