Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 25FC89003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 10:17:39 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so16769039wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:17:38 -0700 (PDT)
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com. [209.85.212.174])
        by mx.google.com with ESMTPS id x6si39123055wjx.11.2015.08.25.07.17.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Aug 2015 07:17:37 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so16768305wic.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:17:37 -0700 (PDT)
Date: Tue, 25 Aug 2015 16:17:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150825141735.GD6285@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
 <20150824094718.GF17078@dhcp22.suse.cz>
 <201508252106.JIE81718.FHOOFSJFMQLtOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508252106.JIE81718.FHOOFSJFMQLtOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Tue 25-08-15 21:06:36, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > index 5249e7e..c0a5a69 100644
> > > --- a/mm/oom_kill.c
> > > +++ b/mm/oom_kill.c
> > > @@ -555,12 +555,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> > >  	/* Get a reference to safely compare mm after task_unlock(victim) */
> > >  	mm = victim->mm;
> > >  	atomic_inc(&mm->mm_users);
> > > -	mark_oom_victim(victim);
> > >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
> > >  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> > >  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
> > >  		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
> > >  	task_unlock(victim);
> > > +	/* Send SIGKILL before setting TIF_MEMDIE. */
> > > +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> > > +	task_lock(victim);
> > > +	if (victim->mm)
> > > +		mark_oom_victim(victim);
> > > +	task_unlock(victim);
> > 
> > Why cannot you simply move do_send_sig_info without touching
> > mark_oom_victim? Are you still able to trigger the issue if you just
> > kill before crawling through all the tasks sharing the mm?
> 
> If you meant
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 1ecc0bc..ea578fb 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -560,6 +560,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>                 K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>                 K(get_mm_counter(victim->mm, MM_FILEPAGES)));
>         task_unlock(victim);
> +       do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> 
>         /*
>          * Kill all user processes sharing victim->mm in other thread groups, if
> @@ -585,7 +586,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>                 }
>         rcu_read_unlock();
> 
> -       do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
>         put_task_struct(victim);
>  }
>  #undef K
> 
> then yes I still can trigger the issue under very limited condition (i.e.
> ran as root user for polling kernel messages with realtime priority, after
> killing all processes using SysRq-i).

Yes, that's why I also said that preempt_{enable,disable} around could
be used:

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1ecc0bcaecc5..331c8ac23cc6 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -542,8 +542,15 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
+	/*
+	 * Make sure that nobody will preempt us between the victim gets access
+	 * to memory reserves and it gets killed. It could depleat the memory
+	 * reserves otherwise.
+	 */
+	preempt_disable();
 	p = find_lock_task_mm(victim);
 	if (!p) {
+		preempt_enable();
 		put_task_struct(victim);
 		return;
 	} else if (victim != p) {
@@ -560,6 +567,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
 		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
 	task_unlock(victim);
+	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
+	preempt_enable();
 
 	/*
 	 * Kill all user processes sharing victim->mm in other thread groups, if
@@ -585,7 +594,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		}
 	rcu_read_unlock();
 
-	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	put_task_struct(victim);
 }
 #undef K

[...]

> > The code would be easier then and the race window much smaller. If we
> > really needed to prevent from preemption then preempt_{enable,disable}
> > aournd the whole task_lock region + do_send_sig_info would be still
> > easier to follow than re-taking task_lock.
> 
> What's wrong with re-taking task_lock? It seems to me that re-taking
> task_lock is more straightforward and easier to follow.

I dunno it looks more awkward to me. You have to re-check the victim->mm
after retaking the lock because situation might have changed while the
lock was dropped. If the mark_oom_victim & do_send_sig_info are in the
same preempt region then nothing like that is needed. But this is
probably a matter of taste. I find the above more readable but let's see
what others think.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
