Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id C01EE6B002B
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 08:47:38 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so3747519vcb.14
        for <linux-mm@kvack.org>; Sat, 25 Aug 2012 05:47:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120823171854.580076595@de.ibm.com>
References: <20120823171733.595087166@de.ibm.com>
	<20120823171854.580076595@de.ibm.com>
Date: Sat, 25 Aug 2012 20:47:37 +0800
Message-ID: <CAJd=RBBJa934R53AHYVhkxE+2e=RiKU1zJXsLMCBFw_NHZE0oQ@mail.gmail.com>
Subject: Re: [RFC patch 3/7] thp: make MADV_HUGEPAGE check for mm->def_flags
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: akpm@linux-foundation.org, aarcange@redhat.com, linux-mm@kvack.org, ak@linux.intel.com, hughd@google.com, linux-kernel@vger.kernel.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com

On Fri, Aug 24, 2012 at 1:17 AM, Gerald Schaefer
<gerald.schaefer@de.ibm.com> wrote:
> This adds a check to hugepage_madvise(), to refuse MADV_HUGEPAGE
> if VM_NOHUGEPAGE is set in mm->def_flags. On System z, the VM_NOHUGEPAGE
> flag will be set in mm->def_flags for kvm processes, to prevent any
> future thp mappings. In order to also prevent MADV_HUGEPAGE on such an
> mm, hugepage_madvise() should check mm->def_flags.
>
> Signed-off-by: Gerald Schaefer <gerald.schaefer@de.ibm.com>
> ---
>  mm/huge_memory.c |    4 ++++
>  1 file changed, 4 insertions(+)
>
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1464,6 +1464,8 @@ out:
>  int hugepage_madvise(struct vm_area_struct *vma,
>                      unsigned long *vm_flags, int advice)
>  {
> +       struct mm_struct *mm = vma->vm_mm;
> +
>         switch (advice) {
>         case MADV_HUGEPAGE:
>                 /*
> @@ -1471,6 +1473,8 @@ int hugepage_madvise(struct vm_area_stru
>                  */
>                 if (*vm_flags & (VM_HUGEPAGE | VM_NO_THP))
>                         return -EINVAL;
> +               if (mm->def_flags & VM_NOHUGEPAGE)
> +                       return -EINVAL;

Looks ifdefinery needed for s390 to wrap the added check, and
a brief comment?

>                 *vm_flags &= ~VM_NOHUGEPAGE;
>                 *vm_flags |= VM_HUGEPAGE;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
