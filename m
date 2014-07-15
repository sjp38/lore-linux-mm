Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDA16B0037
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 17:07:19 -0400 (EDT)
Received: by mail-ig0-f172.google.com with SMTP id h15so3392576igd.17
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 14:07:19 -0700 (PDT)
Received: from mail-ig0-x236.google.com (mail-ig0-x236.google.com [2607:f8b0:4001:c05::236])
        by mx.google.com with ESMTPS id t6si19895565igr.26.2014.07.15.14.07.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 14:07:18 -0700 (PDT)
Received: by mail-ig0-f182.google.com with SMTP id c1so114172igq.15
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 14:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140715134206.5d4964569fe0c64e39873416@linux-foundation.org>
References: <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com>
	<20140715115832.18997.90349.stgit@buzz>
	<20140715134206.5d4964569fe0c64e39873416@linux-foundation.org>
Date: Wed, 16 Jul 2014 01:07:18 +0400
Message-ID: <CALYGNiPaRduVSEEWT-0H84ukNhM7WC5aeWHjKW+u+YqNMp5w2g@mail.gmail.com>
Subject: Re: [PATCH] mm: do not call do_fault_around for non-linear fault
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <k.khlebnikov@samsung.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Hugh Dickins <hughd@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Ingo Korb <ingo.korb@tu-dortmund.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dave Jones <davej@redhat.com>, Ning Qu <quning@google.com>

On Wed, Jul 16, 2014 at 12:42 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Tue, 15 Jul 2014 15:58:32 +0400 Konstantin Khlebnikov <k.khlebnikov@samsung.com> wrote:
>
>> From: Konstantin Khlebnikov <koct9i@gmail.com>
>>
>> Faulting around non-linear page-fault has no sense and
>> breaks logic in do_fault_around because pgoff is shifted.
>>
>
> Please be a lot more careful with the changelogs?  This one failed to
> describe the effects of the bug, failed to adequately describe the bug
> itself, failed to describe the offending commits and failed to identify
> which kernel versions need the patch.

Sorry for that. I thought I had already lost that bug-fixing race.

>
> Sigh.  I went back and assembled the necessary information, below.
> Please check it.
>
>
>
> From: Konstantin Khlebnikov <koct9i@gmail.com>
> Subject: mm: do not call do_fault_around for non-linear fault
>
> Ingo Korb reported that "repeated mapping of the same file on tmpfs using
> remap_file_pages sometimes triggers a BUG at mm/filemap.c:202 when the
> process exits".  He bisected the bug to d7c1755179b82d ("mm: implement
> ->map_pages for shmem/tmpfs"), although the bug was actually added by
> 8c6e50b0290c4 ("mm: introduce vm_ops->map_pages()").
>
> Problem is caused by calling do_fault_around for _non-linear_ faiult.  In
> this case pgoff is shifted and might become negative during calculation.
>
> Faulting around non-linear page-fault has no sense and breaks logic in
> do_fault_around because pgoff is shifted.
>
> Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
> Reported-by: "Ingo Korb" <ingo.korb@tu-dortmund.de>
> Tested-by: "Ingo Korb" <ingo.korb@tu-dortmund.de>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Sasha Levin <sasha.levin@oracle.com>
> Cc: Dave Jones <davej@redhat.com>
> Cc: Ning Qu <quning@google.com>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: <stable@vger.kernel.org>    [3.15.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/memory.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff -puN mm/memory.c~mm-do-not-call-do_fault_around-for-non-linear-fault mm/memory.c
> --- a/mm/memory.c~mm-do-not-call-do_fault_around-for-non-linear-fault
> +++ a/mm/memory.c
> @@ -2882,7 +2882,8 @@ static int do_read_fault(struct mm_struc
>          * if page by the offset is not ready to be mapped (cold cache or
>          * something).
>          */
> -       if (vma->vm_ops->map_pages && fault_around_pages() > 1) {
> +       if (vma->vm_ops->map_pages && !(flags & FAULT_FLAG_NONLINEAR) &&
> +           fault_around_pages() > 1) {
>                 pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>                 do_fault_around(vma, address, pte, pgoff, flags);
>                 if (!pte_same(*pte, orig_pte))
> _
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
