Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2E90C6B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 03:41:57 -0400 (EDT)
Received: from hpaq14.eem.corp.google.com (hpaq14.eem.corp.google.com [10.3.21.14])
	by smtp-out.google.com with ESMTP id o317fq9n018066
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 09:41:52 +0200
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by hpaq14.eem.corp.google.com with ESMTP id o317fnM5025669
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 09:41:51 +0200
Received: by pwi8 with SMTP id 8so40431pwi.15
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 00:41:49 -0700 (PDT)
Date: Thu, 1 Apr 2010 00:41:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] oom: fix the unsafe proc_oom_score()->badness() call
In-Reply-To: <20100331201746.GC11635@redhat.com>
Message-ID: <alpine.DEB.2.00.1004010029260.6285@chino.kir.corp.google.com>
References: <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com>
 <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com> <20100330163909.GA16884@redhat.com> <alpine.DEB.2.00.1003301331110.5234@chino.kir.corp.google.com> <20100331091628.GA11438@redhat.com> <20100331201746.GC11635@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 31 Mar 2010, Oleg Nesterov wrote:

> But. Oh well. David, oom-badness-heuristic-rewrite.patch changed badness()
> to consult p->signal->oom_score_adj. Until recently this was wrong when it
> is called from proc_oom_score().
> 
> This means oom-badness-heuristic-rewrite.patch depends on
> signals-make-task_struct-signal-immutable-refcountable.patch, or we
> need the pid_alive() check again.
> 

oom-badness-heuristic-rewrite.patch didn't change anything, Linus' tree 
currently dereferences p->signal->oom_adj which is no different from 
dereferencing p->signal->oom_score_adj without a refcount on the 
signal_struct in -mm.  oom_adj was moved to struct signal_struct in 
2.6.32, see 28b83c5.

> oom_badness() gets the new argument, long totalpages, and the callers
> were updated. However, long uptime is not used any longer, probably
> it make sense to kill this arg and simplify the callers? Unless you
> are going to take run-time into account later.
> 
> So, I think -mm needs the patch below, but I have no idea how to
> write the changelog ;)
> 
> Oleg.
> 
> --- x/fs/proc/base.c
> +++ x/fs/proc/base.c
> @@ -430,12 +430,13 @@ static const struct file_operations proc
>  /* The badness from the OOM killer */
>  static int proc_oom_score(struct task_struct *task, char *buffer)
>  {
> -	unsigned long points;
> +	unsigned long points = 0;
>  	struct timespec uptime;
>  
>  	do_posix_clock_monotonic_gettime(&uptime);
>  	read_lock(&tasklist_lock);
> -	points = oom_badness(task->group_leader,
> +	if (pid_alive(task))
> +		points = oom_badness(task,
>  				global_page_state(NR_INACTIVE_ANON) +
>  				global_page_state(NR_ACTIVE_ANON) +
>  				global_page_state(NR_INACTIVE_FILE) +

This should be protected by the get_proc_task() on the inode before 
this function is called from proc_info_read().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
