Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 9E7EC6B0002
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 01:37:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id AF7853EE0AE
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:37:53 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94D1845DE5D
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:37:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7AF1C45DE5A
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:37:53 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B8FD1DB8053
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:37:53 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 20A2F1DB8047
	for <linux-mm@kvack.org>; Mon,  1 Apr 2013 14:37:53 +0900 (JST)
Message-ID: <51591D21.8090401@jp.fujitsu.com>
Date: Mon, 01 Apr 2013 14:37:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [patch] mm, memcg: give exiting processes access to memory reserves
References: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1303271821120.5005@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2013/03/28 10:22), David Rientjes wrote:
> A memcg may livelock when oom if the process that grabs the hierarchy's
> oom lock is never the first process with PF_EXITING set in the memcg's
> task iteration.
>
> The oom killer, both global and memcg, will defer if it finds an eligible
> process that is in the process of exiting and it is not being ptraced.
> The idea is to allow it to exit without using memory reserves before
> needlessly killing another process.
>
> This normally works fine except in the memcg case with a large number of
> threads attached to the oom memcg.  In this case, the memcg oom killer
> only gets called for the process that grabs the hierarchy's oom lock; all
> others end up blocked on the memcg's oom waitqueue.  Thus, if the process
> that grabs the hierarchy's oom lock is never the first PF_EXITING process
> in the memcg's task iteration, the oom killer is constantly deferred
> without anything making progress.
>
> The fix is to give PF_EXITING processes access to memory reserves so that
> we've marked them as oom killed without any iteration.  This allows
> __mem_cgroup_try_charge() to succeed so that the process may exit.  This
> makes the memcg oom killer exemption for TIF_MEMDIE tasks, now
> immediately granted for processes with pending SIGKILLs and those in the
> exit path, to be equivalent to what is done for the global oom killer.
>
> Signed-off-by: David Rientjes <rientjes@google.com>


Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   mm/memcontrol.c | 8 ++++----
>   1 file changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1686,11 +1686,11 @@ static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
>   	struct task_struct *chosen = NULL;
>
>   	/*
> -	 * If current has a pending SIGKILL, then automatically select it.  The
> -	 * goal is to allow it to allocate so that it may quickly exit and free
> -	 * its memory.
> +	 * If current has a pending SIGKILL or is exiting, then automatically
> +	 * select it.  The goal is to allow it to allocate so that it may
> +	 * quickly exit and free its memory.
>   	 */
> -	if (fatal_signal_pending(current)) {
> +	if (fatal_signal_pending(current) || current->flags & PF_EXITING) {
>   		set_thread_flag(TIF_MEMDIE);
>   		return;
>   	}
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
