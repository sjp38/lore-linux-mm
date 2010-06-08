Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 20EA16B01DE
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 16:17:39 -0400 (EDT)
Date: Tue, 8 Jun 2010 13:17:19 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 06/18] oom: avoid sending exiting tasks a SIGKILL
Message-Id: <20100608131719.226b62ef.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061524190.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:22 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's unnecessary to SIGKILL a task that is already PF_EXITING and can
> actually cause a NULL pointer dereference of the sighand if it has already
> been detached.  Instead, simply set TIF_MEMDIE so it has access to memory
> reserves and can quickly exit as the comment implies.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -458,7 +458,7 @@ static int oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
>  	 * its children or threads, just set TIF_MEMDIE so it can die quickly
>  	 */
>  	if (p->flags & PF_EXITING) {
> -		__oom_kill_task(p, 0);
> +		set_tsk_thread_flag(p, TIF_MEMDIE);
>  		return 0;
>  	}

Well, we lose a lot of other stuff here.  We can set TIF_MEMDIE on the
is_global_init() task (how can that get PF_EXITING?).  We don't print
the "Killed process %d" info.  We don't bump the task's timeslice.

These are unchangelogged alterations and I for one can't tell whether
or not they were deliberate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
