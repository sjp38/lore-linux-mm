Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CEFBE440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 19:19:36 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b85so6007247pfj.22
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 16:19:36 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u10si7300325plu.124.2017.11.09.16.19.34
        for <linux-mm@kvack.org>;
        Thu, 09 Nov 2017 16:19:35 -0800 (PST)
Date: Fri, 10 Nov 2017 09:19:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RESEND PATCH] mm, oom_reaper: gather each vma to prevent
 leaking TLB entry
Message-ID: <20171110001933.GA12421@bbox>
References: <20171107095453.179940-1-wangnan0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107095453.179940-1-wangnan0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@kernel.org, will.deacon@arm.com, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Tue, Nov 07, 2017 at 09:54:53AM +0000, Wang Nan wrote:
> tlb_gather_mmu(&tlb, mm, 0, -1) means gathering the whole virtual memory
> space. In this case, tlb->fullmm is true. Some archs like arm64 doesn't
> flush TLB when tlb->fullmm is true:
> 
>   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
> 
> Which makes leaking of tlb entries.

That means soft-dirty which has used tlb_gather_mmu with fullmm could be
broken via losing write-protection bit once it supports arm64 in future?

If so, it would be better to use TASK_SIZE rather than -1 in tlb_gather_mmu.
Of course, it's a off-topic.

However, I want to add a big fat comment in tlb_gather_mmu to warn "TLB
flushing with (0, -1) can be skipped on some architectures" so upcoming
users can care of.

Thanks.

> 
> Will clarifies his patch:
> 
> > Basically, we tag each address space with an ASID (PCID on x86) which
> > is resident in the TLB. This means we can elide TLB invalidation when
> > pulling down a full mm because we won't ever assign that ASID to another mm
> > without doing TLB invalidation elsewhere (which actually just nukes the
> > whole TLB).
> >
> > I think that means that we could potentially not fault on a kernel uaccess,
> > because we could hit in the TLB.
> 
> There could be a window between complete_signal() sending IPI to other
> cores and all threads sharing this mm are really kicked off from cores.
> In this window, the oom reaper may calls tlb_flush_mmu_tlbonly() to flush
> TLB then frees pages. However, due to the above problem, the TLB entries
> are not really flushed on arm64. Other threads are possible to access
> these pages through TLB entries. Moreover, a copy_to_user() can also
> write to these pages without generating page fault, causes use-after-free
> bugs.
> 
> This patch gathers each vma instead of gathering full vm space.
> In this case tlb->fullmm is not true. The behavior of oom reaper become
> similar to munmapping before do_exit, which should be safe for all archs.
> 
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Bob Liu <liubo95@huawei.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Roman Gushchin <guro@fb.com>
> Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/oom_kill.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index dee0f75..18c5b35 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -532,7 +532,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  	 */
>  	set_bit(MMF_UNSTABLE, &mm->flags);
>  
> -	tlb_gather_mmu(&tlb, mm, 0, -1);
>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>  		if (!can_madv_dontneed_vma(vma))
>  			continue;
> @@ -547,11 +546,13 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>  		 * we do not want to block exit_mmap by keeping mm ref
>  		 * count elevated without a good reason.
>  		 */
> -		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> +			tlb_gather_mmu(&tlb, mm, vma->vm_start, vma->vm_end);
>  			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
>  					 NULL);
> +			tlb_finish_mmu(&tlb, vma->vm_start, vma->vm_end);
> +		}
>  	}
> -	tlb_finish_mmu(&tlb, 0, -1);
>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>  			task_pid_nr(tsk), tsk->comm,
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
> -- 
> 2.10.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
