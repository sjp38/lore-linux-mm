Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id D6A506B0068
	for <linux-mm@kvack.org>; Thu, 18 Oct 2012 06:21:12 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id u3so5902239wey.14
        for <linux-mm@kvack.org>; Thu, 18 Oct 2012 03:21:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350555140-11030-3-git-send-email-lliubbo@gmail.com>
References: <1350555140-11030-1-git-send-email-lliubbo@gmail.com>
	<1350555140-11030-3-git-send-email-lliubbo@gmail.com>
Date: Thu, 18 Oct 2012 18:21:11 +0800
Message-ID: <CAA_GA1eEF2t2M62U1XCE8KKwvYQvkKGvd-BPSwS4wAOrfncL5Q@mail.gmail.com>
Subject: Re: [PATCH 3/4] thp: introduce hugepage_vma_check()
From: Bob Liu <lliubbo@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, xiaoguangrong@linux.vnet.ibm.com, hughd@google.com, rientjes@google.com, kirill.shutemov@linux.intel.com, Bob Liu <lliubbo@gmail.com>, Linux-MM <linux-mm@kvack.org>

On Thu, Oct 18, 2012 at 6:12 PM, Bob Liu <lliubbo@gmail.com> wrote:
> Multi place do the same check.
>
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/huge_memory.c |   38 +++++++++++++++++---------------------
>  1 file changed, 17 insertions(+), 21 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index e575b29..3588fec 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1913,6 +1913,20 @@ static struct page
>  }
>  #endif
>
> +static bool hugepage_vma_check(struct vm_area_struct *vma)
> +{
> +       if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> +           (vma->vm_flags & VM_NOHUGEPAGE))
> +               return false;
> +
> +       if (!vma->anon_vma || vma->vm_ops)
> +               return false;
> +       if (is_vma_temporary_stack(vma))
> +               return false;
> +       VM_BUG_ON(vma->vm_flags & VM_NO_THP);
> +       return true;
> +}
> +
>  static void collapse_huge_page(struct mm_struct *mm,
>                                    unsigned long address,
>                                    struct page **hpage,
> @@ -1953,17 +1967,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>         hend = vma->vm_end & HPAGE_PMD_MASK;
>         if (address < hstart || address + HPAGE_PMD_SIZE > hend)
>                 goto out;
> -
> -       if ((!(vma->vm_flags & VM_HUGEPAGE) && !khugepaged_always()) ||
> -           (vma->vm_flags & VM_NOHUGEPAGE))
> -               goto out;
> -
> -       if (!vma->anon_vma || vma->vm_ops)
> -               goto out;
> -       if (is_vma_temporary_stack(vma))
> +       if (!hugepage_vma_check(vma))
>                 goto out;
> -       VM_BUG_ON(vma->vm_flags & VM_NO_THP);
> -
>         pmd = hugepage_get_pmd(mm, address);
>         if (!pmd)
>                 goto out;
> @@ -2171,20 +2176,11 @@ static unsigned int khugepaged_scan_mm_slot(unsigned int pages,
>                         progress++;
>                         break;
>                 }
> -
> -               if ((!(vma->vm_flags & VM_HUGEPAGE) &&
> -                    !khugepaged_always()) ||
> -                   (vma->vm_flags & VM_NOHUGEPAGE)) {
> -               skip:
> +               if (!hugepage_vma_check(vma)) {
> +skip:
>                         progress++;
>                         continue;
>                 }
> -               if (!vma->anon_vma || vma->vm_ops)
> -                       goto skip;
> -               if (is_vma_temporary_stack(vma))
> -                       goto skip;
> -               VM_BUG_ON(vma->vm_flags & VM_NO_THP);
> -
>                 hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>                 hend = vma->vm_end & HPAGE_PMD_MASK;
>                 if (hstart >= hend)
> --
> 1.7.9.5
>
>



-- 
Regards,
--Bob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
