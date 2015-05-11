Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 2D69F6B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 18:40:18 -0400 (EDT)
Received: by pabsx10 with SMTP id sx10so120763906pab.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 15:40:17 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a3si19567167pbu.253.2015.05.11.15.40.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 15:40:17 -0700 (PDT)
Date: Mon, 11 May 2015 15:40:15 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3] mm/thp: Split out pmd collpase flush into a separate
 functions
Message-Id: <20150511154015.956459466f1ca96fc84723b7@linux-foundation.org>
In-Reply-To: <1431326370-24247-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1431326370-24247-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, kirill.shutemov@linux.intel.com, aarcange@redhat.com, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 11 May 2015 12:09:30 +0530 "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> wrote:

> Architectures like ppc64 [1] need to do special things while clearing
> pmd before a collapse. For them this operation is largely different
> from a normal hugepage pte clear. Hence add a separate function
> to clear pmd before collapse. After this patch pmdp_* functions
> operate only on hugepage pte, and not on regular pmd_t values
> pointing to page table.
> 
> [1] ppc64 needs to invalidate all the normal page pte mappings we
> already have inserted in the hardware hash page table. But before
> doing that we need to make sure there are no parallel hash page
> table insert going on. So we need to do a kick_all_cpus_sync()
> before flushing the older hash table entries. By moving this to
> a separate function we capture these details and mention how it
> is different from a hugepage pte clear.
> 
> This patch is a cleanup and only does code movement for clarity.
> There should not be any change in functionality.
> 
> ...
>
> +#ifndef pmd_collapse_flush
> +#ifdef CONFIG_TRANSPARENT_HUGEPAGE
> +static inline pmd_t pmd_collapse_flush(struct vm_area_struct *vma,
> +				       unsigned long address,
> +				       pmd_t *pmdp)
> +{
> +	return pmdp_clear_flush(vma, address, pmdp);
> +}
> +#else
> +static inline pmd_t pmd_collapse_flush(struct vm_area_struct *vma,
> +				       unsigned long address,
> +				       pmd_t *pmdp)
> +{
> +	BUILD_BUG();
> +	return __pmd(0);
> +}
> +#endif /* CONFIG_TRANSPARENT_HUGEPAGE */

You want

#define pmd_collapse_flush pmd_collapse_flush

here, just in case a later header file performs the same test.

> +#endif
> +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
