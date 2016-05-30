Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2528C6B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 14:18:21 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id e93so323498444qgf.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 11:18:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z35si509019qge.18.2016.05.30.11.18.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 11:18:20 -0700 (PDT)
Date: Mon, 30 May 2016 20:18:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 5/6] mm, oom: kill all tasks sharing the mm
Message-ID: <20160530181816.GA25480@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-6-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464613556-16708-6-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/30, Michal Hocko wrote:
>
> @@ -852,8 +852,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
> -		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
>  			/*
>  			 * We cannot use oom_reaper for the mm shared by this
>  			 * process because it wouldn't get killed and so the
> @@ -862,6 +861,11 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			can_oom_reap = false;
>  			continue;
>  		}
> +		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
> +			pr_warn("%s pid=%d shares mm with oom disabled %s pid=%d. Seems like misconfiguration, killing anyway!"
> +					" Report at linux-mm@kvack.org\n",
> +					victim->comm, task_pid_nr(victim),
> +					p->comm, task_pid_nr(p));

Oh, yes, I personally do agree ;)

perhaps the is_global_init() == T case needs a warning too? the previous changes
take care about vfork() from /sbin/init, so the only reason we can see it true
is that /sbin/init shares the memory with a memory hog... Nevermind, forget.

This is a bit off-topic, but perhaps we can also change the PF_KTHREAD check later.
Of course we should not try to kill this kthread, but can_oom_reap can be true in
this case. A kernel thread which does use_mm() should handle the errors correctly
if (say) get_user() fails because we unmap the memory.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
