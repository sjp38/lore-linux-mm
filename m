Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4E26B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:58:58 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id qh10so34401733pac.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 08:58:58 -0700 (PDT)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id e88si4021631pfj.182.2016.07.12.08.58.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 08:58:57 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com>
	<1468299403-27954-2-git-send-email-zhongjiang@huawei.com>
Date: Tue, 12 Jul 2016 10:46:17 -0500
In-Reply-To: <1468299403-27954-2-git-send-email-zhongjiang@huawei.com>
	(zhongjiang@huawei.com's message of "Tue, 12 Jul 2016 12:56:43 +0800")
Message-ID: <87a8hm3lme.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the page table
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang <zhongjiang@huawei.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kexec@lists.infradead.org

zhongjiang <zhongjiang@huawei.com> writes:

> From: zhong jiang <zhongjiang@huawei.com>
>
> when image is loaded into kernel, we need set up page table for it. and 
> all valid pfn also set up new mapping. it will tend to establish a pmd 
> page table in the form of a large page if pud_present is true. relocate_kernel 
> points to code segment can locate in the pmd huge entry in init_transtion_pgtable. 
> therefore, we need to take the situation into account.

I can see how in theory this might be necessary but when is a kernel virtual
address on x86_64 that is above 0x8000000000000000 in conflict with an
identity mapped physicall address that are all below 0x8000000000000000?

If anything the code could be simplified to always assume those mappings
are unoccupied.

Did you run into an actual failure somewhere?

Eric


> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
> ---
>  arch/x86/kernel/machine_kexec_64.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
>
> diff --git a/arch/x86/kernel/machine_kexec_64.c b/arch/x86/kernel/machine_kexec_64.c
> index 5a294e4..c33e344 100644
> --- a/arch/x86/kernel/machine_kexec_64.c
> +++ b/arch/x86/kernel/machine_kexec_64.c
> @@ -14,6 +14,7 @@
>  #include <linux/gfp.h>
>  #include <linux/reboot.h>
>  #include <linux/numa.h>
> +#include <linux/hugetlb.h>
>  #include <linux/ftrace.h>
>  #include <linux/io.h>
>  #include <linux/suspend.h>
> @@ -34,6 +35,17 @@ static struct kexec_file_ops *kexec_file_loaders[] = {
>  };
>  #endif
>  
> +static void split_pmd(pmd_t *pmd, pte_t *pte)
> +{
> +	unsigned long pfn = pmd_pfn(*pmd);
> +	int i = 0;
> +
> +	do {
> +		set_pte(pte, pfn_pte(pfn, PAGE_KERNEL_EXEC));
> +		pfn++;
> +	} while (pte++, i++, i < PTRS_PER_PTE);
> +}
> +
>  static void free_transition_pgtable(struct kimage *image)
>  {
>  	free_page((unsigned long)image->arch.pud);
> @@ -68,15 +80,19 @@ static int init_transition_pgtable(struct kimage *image, pgd_t *pgd)
>  		set_pud(pud, __pud(__pa(pmd) | _KERNPG_TABLE));
>  	}
>  	pmd = pmd_offset(pud, vaddr);
> -	if (!pmd_present(*pmd)) {
> +	if (!pmd_present(*pmd) || pmd_huge(*pmd)) {
>  		pte = (pte_t *)get_zeroed_page(GFP_KERNEL);
>  		if (!pte)
>  			goto err;
>  		image->arch.pte = pte;
> -		set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
> +		if (pmd_huge(*pmd))
> +			split_pmd(pmd, pte);
> +		else
> +			set_pmd(pmd, __pmd(__pa(pte) | _KERNPG_TABLE));
>  	}
>  	pte = pte_offset_kernel(pmd, vaddr);
>  	set_pte(pte, pfn_pte(paddr >> PAGE_SHIFT, PAGE_KERNEL_EXEC));
> +
>  	return 0;
>  err:
>  	free_transition_pgtable(image);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
