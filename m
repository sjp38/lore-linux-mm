Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 11B646B0038
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 00:35:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 65so116121355pgi.7
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 21:35:29 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id t70si9474043pgd.291.2017.03.02.21.35.26
        for <linux-mm@kvack.org>;
        Thu, 02 Mar 2017 21:35:28 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170302151034.27829-1-kirill.shutemov@linux.intel.com> <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170302151034.27829-4-kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 3/4] thp: fix MADV_DONTNEED vs. MADV_FREE race
Date: Fri, 03 Mar 2017 13:35:11 +0800
Message-ID: <07b101d293df$ed8c9850$c8a5c8f0$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Minchan Kim' <minchan@kernel.org>


On March 02, 2017 11:11 PM Kirill A. Shutemov wrote: 
> 
> Basically the same race as with numa balancing in change_huge_pmd(), but
> a bit simpler to mitigate: we don't need to preserve dirty/young flags
> here due to MADV_FREE functionality.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> ---
>  mm/huge_memory.c | 2 --
>  1 file changed, 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index bb2b3646bd78..324217c31ec9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1566,8 +1566,6 @@ bool madvise_free_huge_pmd(struct mmu_gather *tlb, struct vm_area_struct *vma,
>  		deactivate_page(page);
> 
>  	if (pmd_young(orig_pmd) || pmd_dirty(orig_pmd)) {
> -		orig_pmd = pmdp_huge_get_and_clear_full(tlb->mm, addr, pmd,
> -			tlb->fullmm);
>  		orig_pmd = pmd_mkold(orig_pmd);
>  		orig_pmd = pmd_mkclean(orig_pmd);
> 
$ grep -n set_pmd_at  linux-4.10/arch/powerpc/mm/pgtable-book3s64.c

/*
 * set a new huge pmd. We should not be called for updating
 * an existing pmd entry. That should go via pmd_hugepage_update.
 */
void set_pmd_at(struct mm_struct *mm, unsigned long addr,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
