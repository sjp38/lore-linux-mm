Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9936B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 12:22:28 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id m9so198414038qte.1
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 09:22:28 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q62si3198848qka.114.2016.10.04.09.22.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Oct 2016 09:22:27 -0700 (PDT)
Date: Tue, 4 Oct 2016 18:21:14 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/4] mm, oom: do not rely on TIF_MEMDIE for
	exit_oom_victim
Message-ID: <20161004162114.GB32428@redhat.com>
References: <20161004090009.7974-1-mhocko@kernel.org> <20161004090009.7974-4-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004090009.7974-4-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Al Viro <viro@zeniv.linux.org.uk>

On 10/04, Michal Hocko wrote:
>
> -void release_task(struct task_struct *p)
> +bool release_task(struct task_struct *p)
>  {
>  	struct task_struct *leader;
>  	int zap_leader;
> +	bool last = false;
>  repeat:
>  	/* don't need to get the RCU readlock here - the process is dead and
>  	 * can't be modifying its own credentials. But shut RCU-lockdep up */
> @@ -197,8 +198,10 @@ void release_task(struct task_struct *p)
>  		 * then we are the one who should release the leader.
>  		 */
>  		zap_leader = do_notify_parent(leader, leader->exit_signal);
> -		if (zap_leader)
> +		if (zap_leader) {
>  			leader->exit_state = EXIT_DEAD;
> +			last = true;
> +		}
>  	}

This looks strange... it won't return true if "p" is the group leader.

> @@ -584,12 +587,15 @@ static void forget_original_parent(struct task_struct *father,
>  /*
>   * Send signals to all our closest relatives so that they know
>   * to properly mourn us..
> + *
> + * Returns true if this is the last thread from the thread group
>   */
> -static void exit_notify(struct task_struct *tsk, int group_dead)
> +static bool exit_notify(struct task_struct *tsk, int group_dead)
>  {
>  	bool autoreap;
>  	struct task_struct *p, *n;
>  	LIST_HEAD(dead);
> +	bool last = false;
>  
>  	write_lock_irq(&tasklist_lock);
>  	forget_original_parent(tsk, &dead);
> @@ -606,6 +612,7 @@ static void exit_notify(struct task_struct *tsk, int group_dead)
>  	} else if (thread_group_leader(tsk)) {
>  		autoreap = thread_group_empty(tsk) &&
>  			do_notify_parent(tsk, tsk->exit_signal);
> +		last = thread_group_empty(tsk);

so this can't detect the multi-threaded group exit, and ...

>  	list_for_each_entry_safe(p, n, &dead, ptrace_entry) {
>  		list_del_init(&p->ptrace_entry);
> -		release_task(p);
> +		if (release_task(p) && p == tsk)
> +			last = true;

this can only happen if this process auto-reaps itself. Not to mention
that exit_notify() will never return true if traced.

No, this doesn't look right.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
