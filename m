Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 447176B006E
	for <linux-mm@kvack.org>; Fri,  8 May 2015 18:24:31 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so60469251pab.2
        for <linux-mm@kvack.org>; Fri, 08 May 2015 15:24:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id fx4si8695339pbb.205.2015.05.08.15.24.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 15:24:29 -0700 (PDT)
Date: Fri, 8 May 2015 15:24:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V2 1/2] mm/thp: Split out pmd collpase flush into a
 seperate functions
Message-Id: <20150508152428.4326eaaae99b74fa53c96f23@linux-foundation.org>
In-Reply-To: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1430983408-24924-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: mpe@ellerman.id.au, paulus@samba.org, benh@kernel.crashing.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Thu,  7 May 2015 12:53:27 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> After this patch pmdp_* functions operate only on hugepage pte,
> and not on regular pmd_t values pointing to page table.
> 

The patch looks like a pretty safe no-op for non-powerpc?

> --- a/arch/powerpc/include/asm/pgtable-ppc64.h
> +++ b/arch/powerpc/include/asm/pgtable-ppc64.h
> @@ -576,6 +576,10 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm, unsigned long addr,
>  extern void pmdp_splitting_flush(struct vm_area_struct *vma,
>  				 unsigned long address, pmd_t *pmdp);
>  
> +#define __HAVE_ARCH_PMDP_COLLAPSE_FLUSH
> +extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
> +				 unsigned long address, pmd_t *pmdp);
> +

The fashionable way of doing this is

extern pmd_t pmdp_collapse_flush(struct vm_area_struct *vma,
				 unsigned long address, pmd_t *pmdp);
#define pmdp_collapse_flush pmdp_collapse_flush

then, elsewhere,

#ifndef pmdp_collapse_flush
static inline pmd_t pmdp_collapse_flush(...) {}
#define pmdp_collapse_flush pmdp_collapse_flush
#endif

It avoids introducing a second (ugly) symbol into the kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
