Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6802D6B0007
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 23:22:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id j6so4411408pgn.7
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 20:22:59 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 31-v6sor3718977plg.44.2018.04.21.20.22.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 20:22:58 -0700 (PDT)
Date: Sat, 21 Apr 2018 20:22:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper
 unmap
In-Reply-To: <20180420124044.GA17484@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.21.1804212019400.84222@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1804171545460.53786@chino.kir.corp.google.com> <201804180057.w3I0vieV034949@www262.sakura.ne.jp> <alpine.DEB.2.21.1804171928040.100886@chino.kir.corp.google.com> <alpine.DEB.2.21.1804171951440.105401@chino.kir.corp.google.com>
 <20180418075051.GO17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804181159020.227784@chino.kir.corp.google.com> <20180419063556.GK17484@dhcp22.suse.cz> <alpine.DEB.2.21.1804191214130.157851@chino.kir.corp.google.com> <20180420082349.GW17484@dhcp22.suse.cz>
 <20180420124044.GA17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, Roman Gushchin <guro@fb.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 20 Apr 2018, Michal Hocko wrote:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index faf85699f1a1..216efa6d9f61 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -3004,10 +3004,21 @@ void exit_mmap(struct mm_struct *mm)
>  	struct mmu_gather tlb;
>  	struct vm_area_struct *vma;
>  	unsigned long nr_accounted = 0;
> +	bool locked = false;
>  
>  	/* mm's last user has gone, and its about to be pulled down */
>  	mmu_notifier_release(mm);
>  
> +	/*
> +	 * The mm is not accessible for anybody except for the oom reaper
> +	 * which cannot race with munlocking so make sure we exclude the
> +	 * two.
> +	 */
> +	if (unlikely(mm_is_oom_victim(mm))) {
> +		down_write(&mm->mmap_sem);
> +		locked = true;
> +	}
> +
>  	if (mm->locked_vm) {
>  		vma = mm->mmap;
>  		while (vma) {
> @@ -3021,7 +3032,7 @@ void exit_mmap(struct mm_struct *mm)
>  
>  	vma = mm->mmap;
>  	if (!vma)	/* Can happen if dup_mmap() received an OOM */
> -		return;
> +		goto out_unlock;
>  
>  	lru_add_drain();
>  	flush_cache_mm(mm);
> @@ -3030,23 +3041,6 @@ void exit_mmap(struct mm_struct *mm)
>  	/* Use -1 here to ensure all VMAs in the mm are unmapped */
>  	unmap_vmas(&tlb, vma, 0, -1);
>  
> -	if (unlikely(mm_is_oom_victim(mm))) {
> -		/*
> -		 * Wait for oom_reap_task() to stop working on this
> -		 * mm. Because MMF_OOM_SKIP is already set before
> -		 * calling down_read(), oom_reap_task() will not run
> -		 * on this "mm" post up_write().
> -		 *
> -		 * mm_is_oom_victim() cannot be set from under us
> -		 * either because victim->mm is already set to NULL
> -		 * under task_lock before calling mmput and oom_mm is
> -		 * set not NULL by the OOM killer only if victim->mm
> -		 * is found not NULL while holding the task_lock.
> -		 */
> -		set_bit(MMF_OOM_SKIP, &mm->flags);
> -		down_write(&mm->mmap_sem);
> -		up_write(&mm->mmap_sem);
> -	}
>  	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>  	tlb_finish_mmu(&tlb, 0, -1);
>  
> @@ -3060,6 +3054,12 @@ void exit_mmap(struct mm_struct *mm)
>  		vma = remove_vma(vma);
>  	}
>  	vm_unacct_memory(nr_accounted);
> +
> +out_unlock:
> +	if (unlikely(locked)) {
> +		set_bit(MMF_OOM_SKIP, &mm->flags);
> +		up_write(&mm->mmap_sem);
> +	}
>  }
>  
>  /* Insert vm structure into process list sorted by address

How have you tested this?

I'm wondering why you do not see oom killing of many processes if the 
victim is a very large process that takes a long time to free memory in 
exit_mmap() as I do because the oom reaper gives up trying to acquire 
mm->mmap_sem and just sets MMF_OOM_SKIP itself.
