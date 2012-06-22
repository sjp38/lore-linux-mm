Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id AE18E6B025F
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 17:06:43 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5071633pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 14:06:43 -0700 (PDT)
Date: Fri, 22 Jun 2012 14:06:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2] mm, thp: print useful information when mmap_sem is
 unlocked in zap_pmd_range
In-Reply-To: <alpine.DEB.2.00.1206110214150.6843@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206221405430.20954@chino.kir.corp.google.com>
References: <20120606165330.GA27744@redhat.com> <alpine.DEB.2.00.1206091904030.7832@chino.kir.corp.google.com> <alpine.DEB.2.00.1206110214150.6843@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>

On Mon, 11 Jun 2012, David Rientjes wrote:

> diff --git a/mm/memory.c b/mm/memory.c
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1225,7 +1225,15 @@ static inline unsigned long zap_pmd_range(struct mmu_gather *tlb,
>  		next = pmd_addr_end(addr, end);
>  		if (pmd_trans_huge(*pmd)) {
>  			if (next - addr != HPAGE_PMD_SIZE) {
> -				VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
> +#ifdef CONFIG_DEBUG_VM
> +				if (!rwsem_is_locked(&tlb->mm->mmap_sem)) {
> +					pr_err("%s: mmap_sem is unlocked! addr=0x%lx end=0x%lx vma->vm_start=0x%lx vma->vm_end=0x%lx\n",
> +						__func__, addr, end,
> +						vma->vm_start,
> +						vma->vm_end);
> +					BUG();
> +				}
> +#endif
>  				split_huge_page_pmd(vma->vm_mm, pmd);
>  			} else if (zap_huge_pmd(tlb, vma, pmd, addr))
>  				goto next;

This patch is now in Linus' tree so if you are able to hit this issue and 
capture it again, we should be able to get much more useful information.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
