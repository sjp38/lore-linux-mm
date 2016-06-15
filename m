Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f70.google.com (mail-qg0-f70.google.com [209.85.192.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9DB8F6B0253
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 10:37:13 -0400 (EDT)
Received: by mail-qg0-f70.google.com with SMTP id 78so47544409qgt.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 07:37:13 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x14si22389319qkb.231.2016.06.15.07.37.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 07:37:08 -0700 (PDT)
Date: Wed, 15 Jun 2016 16:37:01 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 10/10] mm, oom: hide mm which is shared with kthread or
 global init
Message-ID: <20160615143701.GA7944@redhat.com>
References: <1465473137-22531-1-git-send-email-mhocko@kernel.org>
 <1465473137-22531-11-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465473137-22531-11-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

Michal,

I am going to ack the whole series, but send some nits/questions,

On 06/09, Michal Hocko wrote:
>
> @@ -283,10 +283,22 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
>  
>  	/*
>  	 * This task already has access to memory reserves and is being killed.
> -	 * Don't allow any other task to have access to the reserves.
> +	 * Don't allow any other task to have access to the reserves unless
> +	 * the task has MMF_OOM_REAPED because chances that it would release
> +	 * any memory is quite low.
>  	 */
> -	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
> -		return OOM_SCAN_ABORT;
> +	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
> +		struct task_struct *p = find_lock_task_mm(task);
> +		enum oom_scan_t ret = OOM_SCAN_ABORT;
> +
> +		if (p) {
> +			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
> +				ret = OOM_SCAN_CONTINUE;
> +			task_unlock(p);

OK, but perhaps it would be beter to change oom_badness() to return zero if
MMF_OOM_REAPED is set?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
