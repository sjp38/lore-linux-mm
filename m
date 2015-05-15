Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 20E286B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 11:54:54 -0400 (EDT)
Received: by padbw4 with SMTP id bw4so15854157pad.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 08:54:53 -0700 (PDT)
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com. [122.248.162.2])
        by mx.google.com with ESMTPS id ob8si3142556pdb.146.2015.05.15.08.54.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=AES128-SHA bits=128/128);
        Fri, 15 May 2015 08:54:53 -0700 (PDT)
Received: from /spool/local
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 15 May 2015 21:24:49 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C55DA394004E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:24:47 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id t4FFsj9t65339522
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:24:45 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id t4FFshn9017655
	for <linux-mm@kvack.org>; Fri, 15 May 2015 21:24:45 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V5 1/3] mm/thp: Split out pmd collpase flush into a separate functions
In-Reply-To: <1431704550-19937-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431704550-19937-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1431704550-19937-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Date: Fri, 15 May 2015 21:24:43 +0530
Message-ID: <871tihn8e4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org


 diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
> index 39f1d6a2b04d..acdcaac77d93 100644
> --- a/include/asm-generic/pgtable.h
> +++ b/include/asm-generic/pgtable.h
> @@ -189,6 +189,28 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  #endif
>
> +#ifndef pmdp_collapse_flush
> +#define pmdp_collapse_flush pmdp_collapse_flush
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +					unsigned long address,
> +					pmd_t *pmdp)


extra pmdp_collapse_flush #define here

> +{
> +	return pmdp_clear_flush(vma, address, pmdp);
> +}
> +#define pmdp_collapse_flush pmdp_collapse_flush
> +#else
> +static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +					unsigned long address,
> +					pmd_t *pmdp)
> +{
> +	BUILD_BUG();
> +	return *pmdp;
> +}
> +#define pmdp_collapse_flush pmdp_collapse_flush
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */
> +#endif
> +
>  #ifndef __HAVE_ARCH_PGTABLE_DEPOSIT
>  extern void pgtable_trans_huge_deposit(struct mm_struct *mm, pmd_t *pmdp,
>  				       pgtable_t pgtable);

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index acdcaac77d93..2c3ca89e9aee 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -190,7 +190,6 @@ extern void pmdp_splitting_flush(struct vm_area_struct *vma,
 #endif
 
 #ifndef pmdp_collapse_flush
-#define pmdp_collapse_flush pmdp_collapse_flush
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 static inline pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
 					unsigned long address,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
