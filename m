Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f43.google.com (mail-qa0-f43.google.com [209.85.216.43])
	by kanga.kvack.org (Postfix) with ESMTP id A49AA6B0070
	for <linux-mm@kvack.org>; Wed, 22 Oct 2014 10:01:01 -0400 (EDT)
Received: by mail-qa0-f43.google.com with SMTP id j7so2433154qaq.16
        for <linux-mm@kvack.org>; Wed, 22 Oct 2014 07:01:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i65si18345187qge.20.2014.10.22.07.00.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Oct 2014 07:00:57 -0700 (PDT)
Message-ID: <5447B859.4040001@redhat.com>
Date: Wed, 22 Oct 2014 15:59:53 +0200
From: Paolo Bonzini <pbonzini@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: introduce mm_forbids_zeropage function
References: <1413976170-42501-1-git-send-email-dingel@linux.vnet.ibm.com> <1413976170-42501-3-git-send-email-dingel@linux.vnet.ibm.com>
In-Reply-To: <1413976170-42501-3-git-send-email-dingel@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Gleb Natapov <gleb@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "H. Peter Anvin" <hpa@linux.intel.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Jianyu Zhan <nasa4836@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, kvm@vger.kernel.org, linux390@de.ibm.com, linux-kernel@vger.kernel.org, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Sasha Levin <sasha.levin@oracle.com>

Reviewed-by: Paolo Bonzini <pbonzini@redhat.com>

On 10/22/2014 01:09 PM, Dominik Dingel wrote:
> Add a new function stub to allow architectures to disable for
> an mm_structthe backing of non-present, anonymous pages with
> read-only empty zero pages.
> 
> Signed-off-by: Dominik Dingel <dingel@linux.vnet.ibm.com>
> ---
>  include/linux/mm.h | 4 ++++
>  mm/huge_memory.c   | 2 +-
>  mm/memory.c        | 2 +-
>  3 files changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index cd33ae2..0a2022e 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -56,6 +56,10 @@ extern int sysctl_legacy_va_layout;
>  #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
>  #endif
>  
> +#ifndef mm_forbids_zeropage
> +#define mm_forbids_zeropage(X)  (0)
> +#endif
> +
>  extern unsigned long sysctl_user_reserve_kbytes;
>  extern unsigned long sysctl_admin_reserve_kbytes;
>  
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index de98415..357a381 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -805,7 +805,7 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_OOM;
>  	if (unlikely(khugepaged_enter(vma, vma->vm_flags)))
>  		return VM_FAULT_OOM;
> -	if (!(flags & FAULT_FLAG_WRITE) &&
> +	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm) &&
>  			transparent_hugepage_use_zero_page()) {
>  		spinlock_t *ptl;
>  		pgtable_t pgtable;
> diff --git a/mm/memory.c b/mm/memory.c
> index 64f82aa..f275a9d 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2640,7 +2640,7 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
>  		return VM_FAULT_SIGBUS;
>  
>  	/* Use the zero-page for reads */
> -	if (!(flags & FAULT_FLAG_WRITE)) {
> +	if (!(flags & FAULT_FLAG_WRITE) && !mm_forbids_zeropage(mm)) {
>  		entry = pte_mkspecial(pfn_pte(my_zero_pfn(address),
>  						vma->vm_page_prot));
>  		page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
