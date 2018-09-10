Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id C8F0E8E0001
	for <linux-mm@kvack.org>; Mon, 10 Sep 2018 10:59:39 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u195-v6so3058563ith.2
        for <linux-mm@kvack.org>; Mon, 10 Sep 2018 07:59:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id h185-v6si11871439itg.43.2018.09.10.07.59.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Sep 2018 07:59:32 -0700 (PDT)
Subject: Re: [RFC PATCH 0/3] rework mmap-exit vs. oom_reaper handover
References: <1536382452-3443-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180910125513.311-1-mhocko@kernel.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <cc772297-5aeb-8410-d902-c224f4717514@i-love.sakura.ne.jp>
Date: Mon, 10 Sep 2018 23:59:02 +0900
MIME-Version: 1.0
In-Reply-To: <20180910125513.311-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>

Thank you for proposing a patch.

On 2018/09/10 21:55, Michal Hocko wrote:
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 5f2b2b1..99bb9ce 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3091,7 +3081,31 @@ void exit_mmap(struct mm_struct *mm)
>  	/* update_hiwater_rss(mm) here? but nobody should be looking */
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);

unmap_vmas() might involve hugepage path. Is it safe to race with the OOM reaper?

  i_mmap_lock_write(vma->vm_file->f_mapping);
  __unmap_hugepage_range_final(tlb, vma, start, end, NULL);
  i_mmap_unlock_write(vma->vm_file->f_mapping);

> -	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
> +
> +	/* oom_reaper cannot race with the page tables teardown */
> +	if (oom)
> +		down_write(&mm->mmap_sem);
> +	/*
> +	 * Hide vma from rmap and truncate_pagecache before freeing
> +	 * pgtables
> +	 */
> +	while (vma) {
> +		unlink_anon_vmas(vma);
> +		unlink_file_vma(vma);
> +		vma = vma->vm_next;
> +	}
> +	vma = mm->mmap;
> +	if (oom) {
> +		/*
> +		 * the exit path is guaranteed to finish without any unbound
> +		 * blocking at this stage so make it clear to the caller.
> +		 */
> +		mm->mmap = NULL;
> +		up_write(&mm->mmap_sem);
> +	}
> +
> +	free_pgd_range(&tlb, vma->vm_start, vma->vm_prev->vm_end,
> +			FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);

Are you trying to inline free_pgtables() here? But some architectures are
using hugetlb_free_pgd_range() which does more than free_pgd_range(). Are
they really safe (with regard to memory allocation dependency and flags
manipulation) ?

>  	tlb_finish_mmu(&tlb, 0, -1);
>  
>  	/*

Also, how do you plan to give this thread enough CPU resources, for this thread might
be SCHED_IDLE priority? Since this thread might not be a thread which is exiting
(because this is merely a thread which invoked __mmput()), we can't use boosting
approach. CPU resource might be given eventually unless schedule_timeout_*() is used,
but it might be deadly slow if allocating threads keep wasting CPU resources.

Also, why MMF_OOM_SKIP will not be set if the OOM reaper handed over?
