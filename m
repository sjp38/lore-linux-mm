Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id D3D686B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 11:39:06 -0500 (EST)
Received: by wmuu63 with SMTP id u63so61573572wmu.0
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 08:39:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fa15si49331062wjc.132.2015.11.27.08.39.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 08:39:05 -0800 (PST)
Date: Fri, 27 Nov 2015 16:39:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH -v2] mm, oom: introduce oom reaper
Message-ID: <20151127163900.GY19677@suse.de>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <1448640772-30147-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1448640772-30147-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Fri, Nov 27, 2015 at 05:12:52PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
> 
> <SNIP>
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Other than a few small issues below, I didn't spot anything out of the
ordinary so

Acked-by: Mel Gorman <mgorman@suse.de>

> +	tlb_gather_mmu(&tlb, mm, 0, -1);
> +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> +		if (is_vm_hugetlb_page(vma))
> +			continue;
> +
> +		/*
> +		 * Only anonymous pages have a good chance to be dropped
> +		 * without additional steps which we cannot afford as we
> +		 * are OOM already.
> +		 */
> +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> +					 &details);
> +	}

Care to add a comment why clean file pages should not be discarded? I'm
assuming it's because you assume they were discarded already by normal
reclaim before OOM. There is a slightly possibility they are been kept
alive because the OOM victim is constantly referencing them so they get
activated or that there might be additional work to discard buffers but
I'm not 100% sure that's your logic.

> @@ -421,6 +528,7 @@ void mark_oom_victim(struct task_struct *tsk)
>  	/* OOM killer might race with memcg OOM */
>  	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
>  		return;
> +
>  	/*
>  	 * Make sure that the task is woken up from uninterruptible sleep
>  	 * if it is frozen because OOM killer wouldn't be able to free

Unnecessary whitespace change.

> @@ -607,15 +716,23 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  			continue;
>  		if (same_thread_group(p, victim))
>  			continue;
> -		if (unlikely(p->flags & PF_KTHREAD))
> -			continue;
> -		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> +		if (unlikely(p->flags & PF_KTHREAD) ||
> +		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
> +			/*
> +			 * We cannot usee oom_reaper for the mm shared by this process
> +			 * because it wouldn't get killed and so the memory might be
> +			 * still used.
> +			 */
> +			can_oom_reap = false;
>  			continue;

s/usee/use/

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
