Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1FDEF6B01D6
	for <linux-mm@kvack.org>; Tue,  8 Jun 2010 15:33:31 -0400 (EDT)
Date: Tue, 8 Jun 2010 12:33:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 01/18] oom: check PF_KTHREAD instead of !mm to skip
 kthreads
Message-Id: <20100608123320.11e501a4.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1006061520520.32225@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1006061521160.32225@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Oleg Nesterov <oleg@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 6 Jun 2010 15:34:00 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> From: Oleg Nesterov <oleg@redhat.com>
> 
> select_bad_process() thinks a kernel thread can't have ->mm != NULL, this
> is not true due to use_mm().
> 
> Change the code to check PF_KTHREAD.
> 
> Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/oom_kill.c |    9 +++------
>  1 files changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -256,14 +256,11 @@ static struct task_struct *select_bad_process(unsigned long *ppoints,
>  	for_each_process(p) {
>  		unsigned long points;
>  
> -		/*
> -		 * skip kernel threads and tasks which have already released
> -		 * their mm.
> -		 */
> +		/* skip tasks that have already released their mm */
>  		if (!p->mm)
>  			continue;
> -		/* skip the init task */
> -		if (is_global_init(p))
> +		/* skip the init task and kthreads */
> +		if (is_global_init(p) || (p->flags & PF_KTHREAD))
>  			continue;
>  		if (mem && !task_in_mem_cgroup(p, mem))
>  			continue;

Applied, thanks.  A minor bugfix.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
