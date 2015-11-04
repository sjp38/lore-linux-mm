Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5726B0253
	for <linux-mm@kvack.org>; Tue,  3 Nov 2015 22:41:56 -0500 (EST)
Received: by obdgf3 with SMTP id gf3so29905672obd.3
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 19:41:55 -0800 (PST)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com. [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id bp4si1197976obb.28.2015.11.03.19.41.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 19:41:55 -0800 (PST)
Received: by obbww6 with SMTP id ww6so3730926obb.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 19:41:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1446600367-7976-2-git-send-email-minchan@kernel.org>
References: <1446600367-7976-1-git-send-email-minchan@kernel.org> <1446600367-7976-2-git-send-email-minchan@kernel.org>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 3 Nov 2015 19:41:35 -0800
Message-ID: <CALCETrUuNs=26UQtkU88cKPomx_Bik9mbgUUF9q7Nmh1pQJ4qg@mail.gmail.com>
Subject: Re: [PATCH v2 01/13] mm: support madvise(MADV_FREE)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux API <linux-api@vger.kernel.org>, Jason Evans <je@fb.com>, Shaohua Li <shli@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, yalin.wang2010@gmail.com, Daniel Micay <danielmicay@gmail.com>, Mel Gorman <mgorman@suse.de>

On Nov 3, 2015 5:30 PM, "Minchan Kim" <minchan@kernel.org> wrote:
>
> Linux doesn't have an ability to free pages lazy while other OS already
> have been supported that named by madvise(MADV_FREE).
>
> The gain is clear that kernel can discard freed pages rather than swapping
> out or OOM if memory pressure happens.
>
> Without memory pressure, freed pages would be reused by userspace without
> another additional overhead(ex, page fault + allocation + zeroing).
>

[...]

>
> How it works:
>
> When madvise syscall is called, VM clears dirty bit of ptes of the range.
> If memory pressure happens, VM checks dirty bit of page table and if it
> found still "clean", it means it's a "lazyfree pages" so VM could discard
> the page instead of swapping out.  Once there was store operation for the
> page before VM peek a page to reclaim, dirty bit is set so VM can swap out
> the page instead of discarding.

What happens if you MADV_FREE something that's MAP_SHARED or isn't
ordinary anonymous memory?  There's a long history of MADV_DONTNEED on
such mappings causing exploitable problems, and I think it would be
nice if MADV_FREE were obviously safe.

Does this set the write protect bit?

What happens on architectures without hardware dirty tracking?  For
that matter, even on architecture with hardware dirty tracking, what
happens in multithreaded processes that have the dirty TLB state
cached in a different CPU's TLB?

Using the dirty bit for these semantics scares me.  This API creates a
page that can have visible nonzero contents and then can
asynchronously and magically zero itself thereafter.  That makes me
nervous.  Could we use the accessed bit instead?  Then the observable
semantics would be equivalent to having MADV_FREE either zero the page
or do nothing, except that it doesn't make up its mind until the next
read.

> +                       ptent = pte_mkold(ptent);
> +                       ptent = pte_mkclean(ptent);
> +                       set_pte_at(mm, addr, pte, ptent);
> +                       tlb_remove_tlb_entry(tlb, pte, addr);

It looks like you are flushing the TLB.  In a multithreaded program,
that's rather expensive.  Potentially silly question: would it be
better to just zero the page immediately in a multithreaded program
and then, when swapping out, check the page is zeroed and, if so, skip
swapping it out?  That could be done without forcing an IPI.

> +static int madvise_free_single_vma(struct vm_area_struct *vma,
> +                       unsigned long start_addr, unsigned long end_addr)
> +{
> +       unsigned long start, end;
> +       struct mm_struct *mm = vma->vm_mm;
> +       struct mmu_gather tlb;
> +
> +       if (vma->vm_flags & (VM_LOCKED|VM_HUGETLB|VM_PFNMAP))
> +               return -EINVAL;
> +
> +       /* MADV_FREE works for only anon vma at the moment */
> +       if (!vma_is_anonymous(vma))
> +               return -EINVAL;

Does anything weird happen if it's shared?

> +               if (!PageDirty(page) && (flags & TTU_FREE)) {
> +                       /* It's a freeable page by MADV_FREE */
> +                       dec_mm_counter(mm, MM_ANONPAGES);
> +                       goto discard;
> +               }

Does something clear TTU_FREE the next time the page gets marked clean?

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
