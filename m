Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 04A546B007E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 15:29:02 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f190so180201973qke.0
        for <linux-mm@kvack.org>; Mon, 30 May 2016 12:29:02 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e14si23509623qkj.71.2016.05.30.12.29.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 12:29:01 -0700 (PDT)
Date: Mon, 30 May 2016 21:28:57 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160530192856.GA25696@redhat.com>
References: <1464613556-16708-1-git-send-email-mhocko@kernel.org>
 <1464613556-16708-5-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464613556-16708-5-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 05/30, Michal Hocko wrote:
>
> Make sure to not select vforked task as an oom victim by checking
> vfork_done in oom_badness.

I agree, this look like a good change to me... But.

> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -176,11 +176,13 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
>  
>  	/*
>  	 * Do not even consider tasks which are explicitly marked oom
> -	 * unkillable or have been already oom reaped.
> +	 * unkillable or have been already oom reaped or the are in
> +	 * the middle of vfork
>  	 */
>  	adj = (long)p->signal->oom_score_adj;
>  	if (adj == OOM_SCORE_ADJ_MIN ||
> -			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
> +			test_bit(MMF_OOM_REAPED, &p->mm->flags) ||
> +			p->vfork_done) {

I don't think we can trust vfork_done != NULL.

copy_process() doesn't disallow CLONE_VFORK without CLONE_VM, so with this patch
it would be trivial to make the exploit which hides a memory hog from oom-killer.

So perhaps we need something like

		bool in_vfork(p)
		{
			return	p->vfork_done &&
				p->real_parent->mm == mm;

			
		}

task_lock() is not enough if CLONE_VM was used along with CLONE_PARENT... so this
also needs rcu_read_lock() to access ->real_parent.

Or I am totally confused?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
