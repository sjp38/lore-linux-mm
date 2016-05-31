Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id EC70C6B0005
	for <linux-mm@kvack.org>; Tue, 31 May 2016 18:29:37 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id l14so6100368qke.2
        for <linux-mm@kvack.org>; Tue, 31 May 2016 15:29:37 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y190si20542604qhb.111.2016.05.31.15.29.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 May 2016 15:29:37 -0700 (PDT)
Date: Wed, 1 Jun 2016 00:29:33 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 6/6] mm, oom: fortify task_will_free_mem
Message-ID: <20160531222933.GD26582@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-7-git-send-email-mhocko@kernel.org>
 <20160530173505.GA25287@redhat.com>
 <20160531074624.GE26128@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160531074624.GE26128@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

On 05/31, Michal Hocko wrote:
>
> On Mon 30-05-16 19:35:05, Oleg Nesterov wrote:
> >
> > Well, let me suggest this again. I think it should do
> >
> >
> > 	if (SIGNAL_GROUP_COREDUMP)
> > 		return false;
> >
> > 	if (SIGNAL_GROUP_EXIT)
> > 		return true;
> >
> > 	if (thread_group_empty() && PF_EXITING)
> > 		return true;
> >
> > 	return false;
> >
> > we do not need fatal_signal_pending(), in this case SIGNAL_GROUP_EXIT should
> > be set (ignoring some bugs with sub-namespaces which we need to fix anyway).
>
> OK, so we shouldn't care about race when the fatal_signal is set on the
> task until it reaches do_group_exit?

if fatal_signal() is true then (ignoring exec and coredump) SIGNAL_GROUP_EXIT
is already set (again, ignoring the bugs with sub-namespace inits).

At the same time, SIGKILL can be already dequeued when the task exits, so
fatal_signal_pending() can be "false negative".

> > And. I think this needs smp_rmb() at the end of the loop (assuming we have the
> > process_shares_mm() check here). We need it to ensure that we read p->mm before
> > we read next_task(), to avoid the race with exit() + clone(CLONE_VM).
>
> Why don't we need the same barrier in oom_kill_process?

Because it calls do_send_sig_info() which takes ->siglock and copy_process()
takes the same lock. Not a barrier, but acts the same way.

> Which barrier it
> would pair with?

With the barrier implied by list_add_tail_rcu(&p->tasks, &init_task.tasks).

> Anyway I think this would deserve it's own patch.
> Barriers are always tricky and it is better to have them in a small
> patch with a full explanation.

OK, agreed.


I am not sure I can read the new patch correctly, it depends on the previous
changes... but afaics it looks good.

Cosmetic/subjective nit, feel free to ignore,

> +bool task_will_free_mem(struct task_struct *task)
> +{
> +	struct mm_struct *mm = NULL;

unnecessary initialization ;)

> +	struct task_struct *p;
> +	bool ret;
> +
> +	/*
> +	 * If the process has passed exit_mm we have to skip it because
> +	 * we have lost a link to other tasks sharing this mm, we do not
> +	 * have anything to reap and the task might then get stuck waiting
> +	 * for parent as zombie and we do not want it to hold TIF_MEMDIE
> +	 */
> +	p = find_lock_task_mm(task);
> +	if (!p)
> +		return false;
> +
> +	if (!__task_will_free_mem(p)) {
> +		task_unlock(p);
> +		return false;
> +	}

We can call the 1st __task_will_free_mem(p) before find_lock_task_mm(). In the
likely case (I think) it should return false.

And since __task_will_free_mem() has no other callers perhaps it should go into
oom_kill.c too.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
