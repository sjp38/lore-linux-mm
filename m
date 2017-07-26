Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id A46236B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:35:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v62so175167905pfd.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 21:35:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id i5si9210597pgk.54.2017.07.25.21.35.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 21:35:56 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6Q4YAaA038429
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:35:56 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bxm0kgcnc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 00:35:55 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Jul 2017 14:35:53 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6Q4ZpQC28573716
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:35:51 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6Q4Znoa004729
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:35:49 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [ltc-interlock] [PATCH] hugetlb: Fix hot remove for PowerVM
In-Reply-To: <1500997831-19173-1-git-send-email-diegodo@linux.vnet.ibm.com>
References: <1500997831-19173-1-git-send-email-diegodo@linux.vnet.ibm.com>
Date: Wed, 26 Jul 2017 10:05:42 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87r2x324td.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Diego Domingos <diegodo@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: ltc-interlock@lists.linux.ibm.com, linuxppc-dev@lists.ozlabs.org

Diego Domingos <diegodo@linux.vnet.ibm.com> writes:

> PowerVM has support for 16G huge pages, so the function
> gigantic_page_supported needs to check if the running system
> is a pseries and check if there are some gigantic page
> registered. Then, we must return true - avoiding Segmentation
> Fault when hot removing memory sections within huge pages.

That is not correct. Those pages are not in zone/buddy. What
gigantic_page_supported checks is whether we can allocate pages runtime.
We scan the zones, check if we have the range that we are looking for
free for allocation, if so we do runtime allocation of those pages. This
may include page migration too. But these pages comes from buddy. We
don't do buddy allocator directly here, because the order of allocation
we are looking is more than max order.

>
> Signed-off-by: Diego Domingos <diegodo@linux.vnet.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hugetlb.h | 14 +++++++++++++-
>  1 file changed, 13 insertions(+), 1 deletion(-)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> index 5c28bd6..49e43dd 100644
> --- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
> +++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
> @@ -1,3 +1,5 @@
> +#include <asm/machdep.h>
> +
>  #ifndef _ASM_POWERPC_BOOK3S_64_HUGETLB_H
>  #define _ASM_POWERPC_BOOK3S_64_HUGETLB_H
>  /*
> @@ -54,9 +56,19 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
>  #ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
>  static inline bool gigantic_page_supported(void)
>  {
> +        struct hstate *h;
> +
>  	if (radix_enabled())
>  		return true;
> -	return false;
> +
> +        /* PowerVM can support 16GB hugepages (requested at boot time) */
> +        if(machine_is(pseries))
> +            for_each_hstate(h) {
> +                if (hstate_get_psize(h) == MMU_PAGE_16G)
> +                    return true;
> +            }
> +        
> +        return false;
>  }
>  #endif
>
> -- 
> 1.8.3.1
>
> _______________________________________________________
> ltc-interlock mailing list <ltc-interlock@lists.linux.ibm.com>
> To unsubscribe from the list, change your list options
> or if you have forgotten your list password visit:
> https://w3-01.ibm.com/stg/linux/ltc/mailinglists/listinfo/ltc-interlock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
