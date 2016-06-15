Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C40186B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:48:45 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id z142so59425535qkb.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:48:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o92si22436781qte.124.2016.06.15.07.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 07:48:44 -0700 (PDT)
Date: Wed, 15 Jun 2016 16:48:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 09/10] mm, oom_reaper: do not attempt to reap a task more
 than twice
Message-ID: <20160615144835.GB7944@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-10-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-10-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 06/09, Michal Hocko wrote:
>
> @@ -556,8 +556,27 @@ static void oom_reap_task(struct task_struct *tsk)
>  		schedule_timeout_idle(HZ/10);
>  
>  	if (attempts > MAX_OOM_REAP_RETRIES) {
> +		struct task_struct *p;
> +
>  		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
>  				task_pid_nr(tsk), tsk->comm);
> +
> +		/*
> +		 * If we've already tried to reap this task in the past and
> +		 * failed it probably doesn't make much sense to try yet again
> +		 * so hide the mm from the oom killer so that it can move on
> +		 * to another task with a different mm struct.
> +		 */
> +		p = find_lock_task_mm(tsk);
> +		if (p) {
> +			if (test_and_set_bit(MMF_OOM_NOT_REAPABLE, &p->mm->flags)) {
> +				pr_info("oom_reaper: giving up pid:%d (%s)\n",
> +						task_pid_nr(tsk), tsk->comm);
> +				set_bit(MMF_OOM_REAPED, &p->mm->flags);

But why do we need MMF_OOM_NOT_REAPABLE? We set MMF_OOM_REAPED, oom_reap_task()
should not see this task again, at least too often.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
