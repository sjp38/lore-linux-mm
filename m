Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C8FA76B0038
	for <linux-mm@kvack.org>; Mon,  6 Nov 2017 02:04:41 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n33so20790710ioi.7
        for <linux-mm@kvack.org>; Sun, 05 Nov 2017 23:04:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j91sor6208950iod.276.2017.11.05.23.04.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 05 Nov 2017 23:04:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171106033651.172368-1-wangnan0@huawei.com>
References: <20171106033651.172368-1-wangnan0@huawei.com>
From: Bob Liu <lliubbo@gmail.com>
Date: Mon, 6 Nov 2017 15:04:40 +0800
Message-ID: <CAA_GA1dZebSLTEX2W85svWW6O_9RqXDnD7oFW+tMqg+HX5XbPA@mail.gmail.com>
Subject: Re: [RFC PATCH] mm, oom_reaper: gather each vma to prevent leaking
 TLB entry
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wang Nan <wangnan0@huawei.com>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Bob Liu <liubo95@huawei.com>, Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>, will.deacon@arm.com

On Mon, Nov 6, 2017 at 11:36 AM, Wang Nan <wangnan0@huawei.com> wrote:
> tlb_gather_mmu(&tlb, mm, 0, -1) means gathering all virtual memory space.
> In this case, tlb->fullmm is true. Some archs like arm64 doesn't flush
> TLB when tlb->fullmm is true:
>
>   commit 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1").
>

CC'ed Will Deacon.

> Which makes leaking of tlb entries. For example, when oom_reaper
> selects a task and reaps its virtual memory space, another thread
> in this task group may still running on another core and access
> these already freed memory through tlb entries.
>
> This patch gather each vma instead of gathering full vm space,
> tlb->fullmm is not true. The behavior of oom reaper become similar
> to munmapping before do_exit, which should be safe for all archs.
>
> Signed-off-by: Wang Nan <wangnan0@huawei.com>
> Cc: Bob Liu <liubo95@huawei.com>
> Cc: Michal Hocko <mhocko@suse.com>
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
>          */
>         set_bit(MMF_UNSTABLE, &mm->flags);
>
> -       tlb_gather_mmu(&tlb, mm, 0, -1);
>         for (vma = mm->mmap ; vma; vma = vma->vm_next) {
>                 if (!can_madv_dontneed_vma(vma))
>                         continue;
> @@ -547,11 +546,13 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
>                  * we do not want to block exit_mmap by keeping mm ref
>                  * count elevated without a good reason.
>                  */
> -               if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> +               if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED)) {
> +                       tlb_gather_mmu(&tlb, mm, vma->vm_start, vma->vm_end);
>                         unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
>                                          NULL);
> +                       tlb_finish_mmu(&tlb, vma->vm_start, vma->vm_end);
> +               }
>         }
> -       tlb_finish_mmu(&tlb, 0, -1);
>         pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
>                         task_pid_nr(tsk), tsk->comm,
>                         K(get_mm_counter(mm, MM_ANONPAGES)),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
