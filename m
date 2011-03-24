Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 38D8C8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 11:28:16 -0400 (EDT)
Received: by iyf13 with SMTP id 13so105381iyf.14
        for <linux-mm@kvack.org>; Thu, 24 Mar 2011 08:28:11 -0700 (PDT)
Date: Fri, 25 Mar 2011 00:27:57 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 2/5] Revert "oom: give the dying task a higher priority"
Message-ID: <20110324152757.GC1938@barrios-desktop>
References: <20110315153801.3526.A69D9226@jp.fujitsu.com>
 <20110322194721.B05E.A69D9226@jp.fujitsu.com>
 <20110322200657.B064.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110322200657.B064.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm <linux-mm@kvack.org>, Andrey Vagin <avagin@openvz.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Mar 22, 2011 at 08:06:48PM +0900, KOSAKI Motohiro wrote:
> This reverts commit 93b43fa55088fe977503a156d1097cc2055449a2.
> 
> The commit dramatically improve oom killer logic when fork-bomb
> occur. But, I've found it has nasty corner case. Now cpu cgroup
> has strange default RT runtime. It's 0! That said, if a process
> under cpu cgroup promote RT scheduling class, the process never
> run at all.
> 
> Eventually, kernel may hang up when oom kill occur.
> 
> The author need to resubmit it as adding knob and disabled
> by default if he really need this feature.
> 
> Cc: Luis Claudio R. Goncalves <lclaudio@uudg.org>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Just a comment below.

> ---
>  mm/oom_kill.c |   27 ---------------------------
>  1 files changed, 0 insertions(+), 27 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 3100bc5..739dee4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -84,24 +84,6 @@ static bool has_intersects_mems_allowed(struct task_struct *tsk,
>  #endif /* CONFIG_NUMA */
>  
>  /*
> - * If this is a system OOM (not a memcg OOM) and the task selected to be
> - * killed is not already running at high (RT) priorities, speed up the
> - * recovery by boosting the dying task to the lowest FIFO priority.
> - * That helps with the recovery and avoids interfering with RT tasks.
> - */
> -static void boost_dying_task_prio(struct task_struct *p,
> -				  struct mem_cgroup *mem)
> -{
> -	struct sched_param param = { .sched_priority = 1 };
> -
> -	if (mem)
> -		return;
> -
> -	if (!rt_task(p))
> -		sched_setscheduler_nocheck(p, SCHED_FIFO, &param);
> -}
> -
> -/*
>   * The process p may have detached its own ->mm while exiting or through
>   * use_mm(), but one or more of its subthreads may still have a valid
>   * pointer.  Return p, or any of its subthreads with a valid ->mm, with
> @@ -452,13 +434,6 @@ static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
>  	set_tsk_thread_flag(p, TIF_MEMDIE);
>  	force_sig(SIGKILL, p);
>  
> -	/*
> -	 * We give our sacrificial lamb high priority and access to
> -	 * all the memory it needs. That way it should be able to
> -	 * exit() and clear out its resources quickly...
> -	 */
> -	boost_dying_task_prio(p, mem);
> -

Before merging 93b43fa5508, we had a following routine.

+static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
        p = find_lock_task_mm(p);
        if (!p) {
@@ -434,9 +452,17 @@ static int oom_kill_task(struct task_struct *p)
                K(get_mm_counter(p->mm, MM_FILEPAGES)));
        task_unlock(p);
 
-       p->rt.time_slice = HZ; <<---- THIS
+
        set_tsk_thread_flag(p, TIF_MEMDIE);
        force_sig(SIGKILL, p);
+
+       /*
+        * We give our sacrificial lamb high priority and access to
+        * all the memory it needs. That way it should be able to
+        * exit() and clear out its resources quickly...
+        */
+       boost_dying_task_prio(p, mem);
+
        return 0;
 }

At that time, I thought that routine is meaningless in non-RT scheduler.
So I Cced Peter but don't get the answer.
I just want to confirm it.

Do you still think it's meaningless? 
so you remove it when you revert 93b43fa5508?
Then, this isn't just revert patch but revert + killing meaningless code patch.


- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
