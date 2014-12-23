Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id CF7596B0032
	for <linux-mm@kvack.org>; Tue, 23 Dec 2014 04:52:02 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so12635648wiv.4
        for <linux-mm@kvack.org>; Tue, 23 Dec 2014 01:52:02 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mn7si37799331wjc.31.2014.12.23.01.52.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 23 Dec 2014 01:52:01 -0800 (PST)
Date: Tue, 23 Dec 2014 10:51:59 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC PATCH] oom: Don't count on mm-less current process.
Message-ID: <20141223095159.GA28549@dhcp22.suse.cz>
References: <201412192107.IGJ09885.OFHSMJtLFFOVQO@I-love.SAKURA.ne.jp>
 <20141219124903.GB18397@dhcp22.suse.cz>
 <201412201813.JJF95860.VSLOQOFHFJOFtM@I-love.SAKURA.ne.jp>
 <201412202042.ECJ64551.FHOOJOQLFFtVMS@I-love.SAKURA.ne.jp>
 <20141222202511.GA9485@dhcp22.suse.cz>
 <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201412231000.AFG78139.SJMtOOLFVFFQOH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com

On Tue 23-12-14 10:00:00, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OOM killer tries to exlude tasks which do not have mm_struct associated
> s/exlude/exclude/

Fixed

> > Fix this by checking task->mm and setting TIF_MEMDIE flag under task_lock
> > which will serialize the OOM killer with exit_mm which sets task->mm to
> > NULL.
> Nice idea.
> 
> By the way, find_lock_task_mm(victim) may succeed if victim->mm == NULL and
> one of threads in victim thread-group has non-NULL mm. That case is handled
> by victim != p branch below. But where was p->signal->oom_score_adj !=
> OOM_SCORE_ADJ_MIN checked?
>
> (In other words, don't we need to check like
> t->mm && t->signal->oom_score_adj != OOM_SCORE_ADJ_MIN at find_lock_task_mm()
> for OOM-kill case?)

oom_score_adj is shared between threads.

> Also, why not to call set_tsk_thread_flag() and do_send_sig_info() together
> like below

What would be an advantage? I am not really sure whether the two locks
might nest as well.

>  	p = find_lock_task_mm(victim);
>  	if (!p) {
>  		put_task_struct(victim);
>  		return;
>  	} else if (victim != p) {
>  		get_task_struct(p);
>  		put_task_struct(victim);
>  		victim = p;
>  	}
>  
>  	/* mm cannot safely be dereferenced after task_unlock(victim) */
>  	mm = victim->mm;
> +	set_tsk_thread_flag(victim, TIF_MEMDIE);
> +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>  		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
>  	task_unlock(victim);
> 
> than wait for for_each_process() loop in case current task went to sleep
> immediately after task_unlock(victim)? Or is there a reason we had been
> setting TIF_MEMDIE after the for_each_process() loop? If the reason was
> to minimize the duration of OOM killer being disabled due to TIF_MEMDIE,
> shouldn't we do like below?

No, global parallel OOM killer is disabled by oom zonelist lock at this
moment for most paths so TIF_MEMDIE setting little bit earlier doesn't
make any difference.

>  	rcu_read_unlock();
>  
> -	set_tsk_thread_flag(victim, TIF_MEMDIE);
> +	task_lock(victim);
> +	if (victim->mm)
> +		set_tsk_thread_flag(victim, TIF_MEMDIE);
> +	task_unlock(victim);
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>  	put_task_struct(victim);

This would work as well but I am not sure it is much more nicer. It is
the find_lock_task_mm() part which tells the final victim so setting
TIF_MEMDIE is logical there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
