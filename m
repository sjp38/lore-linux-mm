Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 732426B025E
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:35:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r63so1233208wmb.9
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:35:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p16si5108096wmf.1.2017.12.15.08.35.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Dec 2017 08:35:37 -0800 (PST)
Date: Fri, 15 Dec 2017 17:35:34 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v2 2/2] mm, oom: avoid reaping only for mm's with
 blockable invalidate callbacks
Message-ID: <20171215163534.GB16951@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141329500.74052@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1712141330120.74052@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1712141330120.74052@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 14-12-17 13:31:00, David Rientjes wrote:
> This uses the new annotation to determine if an mm has mmu notifiers with
> blockable invalidate range callbacks to avoid oom reaping.  Otherwise, the
> callbacks are used around unmap_page_range().

Do you have any example where this helped? KVM guest oom killed I guess?

> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/oom_kill.c | 21 +++++++++++----------
>  1 file changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -514,15 +514,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	}
>  
>  	/*
> -	 * If the mm has notifiers then we would need to invalidate them around
> -	 * unmap_page_range and that is risky because notifiers can sleep and
> -	 * what they do is basically undeterministic.  So let's have a short
> +	 * If the mm has invalidate_{start,end}() notifiers that could block,
>  	 * sleep to give the oom victim some more time.
>  	 * TODO: we really want to get rid of this ugly hack and make sure that
> -	 * notifiers cannot block for unbounded amount of time and add
> -	 * mmu_notifier_invalidate_range_{start,end} around unmap_page_range
> +	 * notifiers cannot block for unbounded amount of time
>  	 */
> -	if (mm_has_notifiers(mm)) {
> +	if (mm_has_blockable_invalidate_notifiers(mm)) {
>  		up_read(&mm->mmap_sem);
>  		schedule_timeout_idle(HZ);
>  		goto unlock_oom;
> @@ -565,10 +562,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  		 * count elevated without a good reason.
>  		 */
>  		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> -			tlb_gather_mmu(&tlb, mm, vma->vm_start, vma->vm_end);
> -			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> -					 NULL);
> -			tlb_finish_mmu(&tlb, vma->vm_start, vma->vm_end);
> +			const unsigned long start = vma->vm_start;
> +			const unsigned long end = vma->vm_end;
> +
> +			tlb_gather_mmu(&tlb, mm, start, end);
> +			mmu_notifier_invalidate_range_start(mm, start, end);
> +			unmap_page_range(&tlb, vma, start, end, NULL);
> +			mmu_notifier_invalidate_range_end(mm, start, end);
> +			tlb_finish_mmu(&tlb, start, end);
>  		}
>  	}
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
