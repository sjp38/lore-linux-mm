Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 3885C8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 17:59:09 -0400 (EDT)
Date: Mon, 11 Apr 2011 14:58:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/4] remove boost_dying_task_prio()
Message-Id: <20110411145832.ae133cf8.akpm@linux-foundation.org>
In-Reply-To: <20110411143215.0074.A69D9226@jp.fujitsu.com>
References: <20110411142949.006C.A69D9226@jp.fujitsu.com>
	<20110411143215.0074.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrey Vagin <avagin@openvz.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon, 11 Apr 2011 14:31:18 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> This is a almost revert commit 93b43fa (oom: give the dying
> task a higher priority).
> 
> The commit dramatically improve oom killer logic when fork-bomb
> occur. But, I've found it has nasty corner case. Now cpu cgroup
> has strange default RT runtime. It's 0! That said, if a process
> under cpu cgroup promote RT scheduling class, the process never
> run at all.

hm.  How did that happen?  I thought that sched_setscheduler() modifies
only a single thread, and that thread is in the process of exiting?

> Eventually, kernel may hang up when oom kill occur.
> I and Luis who original author agreed to disable this logic at
> once.
> 
> ...
>
> index 6a819d1..83fb72c1 100644
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

I'm rather glad to see that code go away though - SCHED_FIFO is
dangerous...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
