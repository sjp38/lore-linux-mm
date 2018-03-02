Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A6C36B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 04:36:35 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c5so5037015pfn.17
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 01:36:35 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id o1-v6si4556811pld.259.2018.03.02.01.36.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 02 Mar 2018 01:36:33 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH v3 1/3] mm, powerpc: use vma_kernel_pagesize() in vma_mmu_pagesize()
In-Reply-To: <151996254179.27922.2213728278535578744.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com> <151996254179.27922.2213728278535578744.stgit@dwillia2-desk3.amr.corp.intel.com>
Date: Fri, 02 Mar 2018 20:36:26 +1100
Message-ID: <87lgfa95ut.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Dan Williams <dan.j.williams@intel.com> writes:

> The current powerpc definition of vma_mmu_pagesize() open codes looking
> up the page size via hstate. It is identical to the generic
> vma_kernel_pagesize() implementation.
>
> Now, vma_kernel_pagesize() is growing support for determining the
> page size of Device-DAX vmas in addition to the existing Hugetlbfs page
> size determination.
>
> Ideally, if the powerpc vma_mmu_pagesize() used vma_kernel_pagesize() it
> would automatically benefit from any new vma-type support that is added
> to vma_kernel_pagesize(). However, the powerpc vma_mmu_pagesize() is
> prevented from calling vma_kernel_pagesize() due to a circular header
> dependency that requires vma_mmu_pagesize() to be defined before
> including <linux/hugetlb.h>.
>
> Break this circular dependency by defining the default
> vma_mmu_pagesize() as a __weak symbol to be overridden by the powerpc
> version.
>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/powerpc/include/asm/hugetlb.h |    6 ------
>  arch/powerpc/mm/hugetlbpage.c      |    5 +----
>  mm/hugetlb.c                       |    8 +++-----
>  3 files changed, 4 insertions(+), 15 deletions(-)

This looks OK to me. I was worried switching to a weak symbol would mean
it doesn't get inlined, but it's not inlined today anyway!

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
