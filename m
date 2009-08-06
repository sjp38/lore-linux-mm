Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6D1646B005A
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 21:38:12 -0400 (EDT)
Date: Thu, 6 Aug 2009 03:34:44 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/4] oom: move oom_adj to signal_struct
Message-ID: <20090806013444.GA22095@redhat.com>
References: <20090804191031.6A3D.A69D9226@jp.fujitsu.com> <20090804192514.6A40.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090804192514.6A40.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Sorry for late reply. And sorry, I didn't read these patches carefully yet,
probably missed something...

On 08/04, KOSAKI Motohiro wrote:
>
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -34,6 +34,31 @@ int sysctl_oom_dump_tasks;
>  static DEFINE_SPINLOCK(zone_scan_lock);
>  /* #define DEBUG */
>
> +int get_oom_adj(struct task_struct *tsk)

is it used outside oom_kill.c ?

> +{
> +	unsigned long flags;
> +	int oom_adj = OOM_DISABLE;
> +
> +	if (tsk->mm && lock_task_sighand(tsk, &flags)) {

Minor nit. _Afaics_, unlike proc, oom_kill.c never needs lock_task_sighand()
to access ->signal->oom_adj.

If the task was found under tasklist_lock by for_each_process/do_each_thread
it must have the valid ->signal != NULL and it can't go away.


With these patches I think mm-introduce-proc-pid-oom_adj_child.patch should
be dropped. This is good ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
