Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36A506B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 05:11:16 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id j10so33364001wjb.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:11:16 -0800 (PST)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id b5si6320346wjw.261.2016.12.16.02.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 02:11:14 -0800 (PST)
Received: by mail-wm0-f66.google.com with SMTP id m203so4335991wma.3
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 02:11:14 -0800 (PST)
Date: Fri, 16 Dec 2016 11:11:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: crash during oom reaper (was: Re: [PATCH 4/4] [RFC!] mm: 'struct
 mm_struct' reference counting debugging)
Message-ID: <20161216101113.GE13940@dhcp22.suse.cz>
References: <20161216082202.21044-1-vegard.nossum@oracle.com>
 <20161216082202.21044-4-vegard.nossum@oracle.com>
 <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Fri 16-12-16 10:43:52, Vegard Nossum wrote:
[...]
> I don't think it's a bug in the OOM reaper itself, but either of the
> following two patches will fix the problem (without my understand how or
> why):
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d4f094..37b14b2e2af4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -485,7 +485,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> struct mm_struct *mm)
>  	 */
>  	mutex_lock(&oom_lock);
> 
> -	if (!down_read_trylock(&mm->mmap_sem)) {
> +	if (!down_write_trylock(&mm->mmap_sem)) {

__oom_reap_task_mm is basically the same thing as MADV_DONTNEED and that
doesn't require the exlusive mmap_sem. So this looks correct to me.
[...]

> --OR--
> 
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index ec9f11d4f094..559aec0acd21 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -508,6 +508,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> struct mm_struct *mm)
>  	 */
>  	set_bit(MMF_UNSTABLE, &mm->flags);
> 
> +#if 0
>  	tlb_gather_mmu(&tlb, mm, 0, -1);
>  	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>  		if (is_vm_hugetlb_page(vma))
> @@ -535,6 +536,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk,
> struct mm_struct *mm)
>  					 &details);
>  	}
>  	tlb_finish_mmu(&tlb, 0, -1);
> +#endif

same here, nothing different from the madvise... Well, except for the
MMF_UNSTABLE part which will force any page fault on this mm to SEGV.

>  	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB,
> file-rss:%lukB, shmem-rss:%lukB\n",
>  			task_pid_nr(tsk), tsk->comm,
>  			K(get_mm_counter(mm, MM_ANONPAGES)),
> 
> Maybe it's just the fact that we're not releasing the memory and so some
> other bit of code is not able to make enough progress to trigger the
> bug, although curiously, if I just move the #if 0..#endif inside
> tlb_gather_mmu()..tlb_finish_mmu() itself (so just calling tlb_*()
> without doing the for-loop), it still reproduces the crash.

What is the atual crash?

> Another clue, although it might just be a coincidence, is that it seems
> the VMA/file in question is always a mapping for the exe file itself
> (the reason I think this might be a coincidence is that the exe file
> mapping is the first one and we usually traverse VMAs starting with this
> one, that doesn't mean the other VMAs aren't affected by the same
> problem, just that we never hit them).

You can experiment a bit and exclude PROT_EXEC vmas...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
