Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7F9C85F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 15:57:27 -0400 (EDT)
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id n37JwI83007385
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 12:58:19 -0700
Received: from rv-out-0708.google.com (rvbl33.prod.google.com [10.140.88.33])
	by spaceape14.eur.corp.google.com with ESMTP id n37JvbcU011298
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 12:58:16 -0700
Received: by rv-out-0708.google.com with SMTP id l33so2889271rvb.38
        for <linux-mm@kvack.org>; Tue, 07 Apr 2009 12:58:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090407072132.943283183@intel.com>
References: <20090407071729.233579162@intel.com>
	 <20090407072132.943283183@intel.com>
Date: Tue, 7 Apr 2009 12:58:16 -0700
Message-ID: <604427e00904071258y78eea757m6d95d08deec49450@mail.gmail.com>
Subject: Re: [PATCH 02/14] mm: fix major/minor fault accounting on retried
	fault
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 7, 2009 at 12:17 AM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> VM_FAULT_RETRY does make major/minor faults accounting a bit twisted..
>
> Cc: Ying Han <yinghan@google.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  arch/x86/mm/fault.c |    2 ++
>  mm/memory.c         |   22 ++++++++++++++--------
>  2 files changed, 16 insertions(+), 8 deletions(-)
>
> --- mm.orig/arch/x86/mm/fault.c
> +++ mm/arch/x86/mm/fault.c
> @@ -1160,6 +1160,8 @@ good_area:
>        if (fault & VM_FAULT_RETRY) {
>                if (retry_flag) {
>                        retry_flag = 0;
> +                       tsk->maj_flt++;
> +                       tsk->min_flt--;
>                        goto retry;
>                }
>                BUG();
sorry, little bit confuse here. are we assuming the retry path will
return min_flt as always?


> --- mm.orig/mm/memory.c
> +++ mm/mm/memory.c
> @@ -2882,26 +2882,32 @@ int handle_mm_fault(struct mm_struct *mm
>        pud_t *pud;
>        pmd_t *pmd;
>        pte_t *pte;
> +       int ret;
>
>        __set_current_state(TASK_RUNNING);
>
> -       count_vm_event(PGFAULT);
> -
> -       if (unlikely(is_vm_hugetlb_page(vma)))
> -               return hugetlb_fault(mm, vma, address, write_access);
> +       if (unlikely(is_vm_hugetlb_page(vma))) {
> +               ret = hugetlb_fault(mm, vma, address, write_access);
> +               goto out;
> +       }
>
> +       ret = VM_FAULT_OOM;
>        pgd = pgd_offset(mm, address);
>        pud = pud_alloc(mm, pgd, address);
>        if (!pud)
> -               return VM_FAULT_OOM;
> +               goto out;
>        pmd = pmd_alloc(mm, pud, address);
>        if (!pmd)
> -               return VM_FAULT_OOM;
> +               goto out;
>        pte = pte_alloc_map(mm, pmd, address);
>        if (!pte)
> -               return VM_FAULT_OOM;
> +               goto out;
>
> -       return handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +       ret = handle_pte_fault(mm, vma, address, pte, pmd, write_access);
> +out:
> +       if (!(ret & VM_FAULT_RETRY))
> +               count_vm_event(PGFAULT);
> +       return ret;
>  }
>
>  #ifndef __PAGETABLE_PUD_FOLDED
>
> --
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
