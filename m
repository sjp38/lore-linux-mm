Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id E93486B04CC
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 19:55:24 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g14so132278506pgu.9
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:55:24 -0700 (PDT)
Received: from mail-pg0-x22b.google.com (mail-pg0-x22b.google.com. [2607:f8b0:400e:c05::22b])
        by mx.google.com with ESMTPS id y12si8756113pgr.18.2017.07.10.16.55.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jul 2017 16:55:24 -0700 (PDT)
Received: by mail-pg0-x22b.google.com with SMTP id k14so57287522pgr.0
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 16:55:24 -0700 (PDT)
Date: Mon, 10 Jul 2017 16:55:22 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH] mm, oom: allow oom reaper to race with exit_mmap
In-Reply-To: <20170626130346.26314-1-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1707101652260.54972@chino.kir.corp.google.com>
References: <20170626130346.26314-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Andrea Argangeli <andrea@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Mon, 26 Jun 2017, Michal Hocko wrote:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 3bd5ecd20d4d..253808e716dc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2962,6 +2962,11 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> +	/*
> +	 * oom reaper might race with exit_mmap so make sure we won't free
> +	 * page tables or unmap VMAs under its feet
> +	 */
> +	down_write(&mm->mmap_sem);
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> @@ -2974,7 +2979,9 @@ void exit_mmap(struct mm_struct *mm)
>  			nr_accounted += vma_pages(vma);
>  		vma = remove_vma(vma);
>  	}
> +	mm->mmap = NULL;
>  	vm_unacct_memory(nr_accounted);
> +	up_write(&mm->mmap_sem);
>  }
>  
>  /* Insert vm structure into process list sorted by address
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 0e2c925e7826..5dc0ff22d567 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -472,36 +472,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	struct vm_area_struct *vma;
>  	bool ret = true;
>  
> -	/*
> -	 * We have to make sure to not race with the victim exit path
> -	 * and cause premature new oom victim selection:
> -	 * __oom_reap_task_mm		exit_mm
> -	 *   mmget_not_zero
> -	 *				  mmput
> -	 *				    atomic_dec_and_test
> -	 *				  exit_oom_victim
> -	 *				[...]
> -	 *				out_of_memory
> -	 *				  select_bad_process
> -	 *				    # no TIF_MEMDIE task selects new victim
> -	 *  unmap_page_range # frees some memory
> -	 */
> -	mutex_lock(&oom_lock);
> -
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> -		ret = false;
> -		goto unlock_oom;
> -	}
> -
> -	/*
> -	 * increase mm_users only after we know we will reap something so
> -	 * that the mmput_async is called only when we have reaped something
> -	 * and delayed __mmput doesn't matter that much
> -	 */
> -	if (!mmget_not_zero(mm)) {
> -		up_read(&mm->mmap_sem);
> -		goto unlock_oom;
> -	}
> +	if (!down_read_trylock(&mm->mmap_sem))
> +		return false;

I think this should return true if mm->mmap == NULL here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
