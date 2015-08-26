Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9388B6B0038
	for <linux-mm@kvack.org>; Wed, 26 Aug 2015 10:12:37 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so45999951wic.1
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:12:37 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ev15si5386957wjd.117.2015.08.26.07.12.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Aug 2015 07:12:36 -0700 (PDT)
Received: by wijn1 with SMTP id n1so25850616wij.0
        for <linux-mm@kvack.org>; Wed, 26 Aug 2015 07:12:35 -0700 (PDT)
Date: Wed, 26 Aug 2015 16:12:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [REPOST] [PATCH 2/2] mm,oom: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150826141233.GI25196@dhcp22.suse.cz>
References: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508231619.CGF82826.MJtVLSHOFFQOOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

Hi Oleg,

On Sun 23-08-15 16:19:38, Tetsuo Handa wrote:
[...]
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5249e7e..c0a5a69 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -555,12 +555,17 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	atomic_inc(&mm->mm_users);
> -	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
>  		K(get_mm_counter(victim->mm, MM_ANONPAGES)),
>  		K(get_mm_counter(victim->mm, MM_FILEPAGES)));
>  	task_unlock(victim);
> +	/* Send SIGKILL before setting TIF_MEMDIE. */
> +	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> +	task_lock(victim);
> +	if (victim->mm)
> +		mark_oom_victim(victim);
> +	task_unlock(victim);

I cannot seem to find any explicit note about task_lock vs. signal
nesting nor task_lock() anywhere in kernel/signal.c so I rather ask. Can
we call do_send_sig_info with task_lock held?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
