Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1574D6B0038
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 01:29:59 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so3514091pab.32
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:29:58 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id lf13si12383146pab.199.2014.06.15.22.29.56
        for <linux-mm@kvack.org>;
        Sun, 15 Jun 2014 22:29:58 -0700 (PDT)
Date: Mon, 16 Jun 2014 14:34:08 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 07/10] PPC, KVM, CMA: use general CMA reserved area
 management framework
Message-ID: <20140616053408.GH23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1402543307-29800-8-git-send-email-iamjoonsoo.kim@lge.com>
 <87mwdfg9co.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mwdfg9co.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

On Sat, Jun 14, 2014 at 02:23:59PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > Now, we have general CMA reserved area management framework,
> > so use it for future maintainabilty. There is no functional change.
> >
> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
> > Acked-by: Paolo Bonzini <pbonzini@redhat.com>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Need this. We may want to keep the VM_BUG_ON by moving
> KVM_CMA_CHUNK_ORDER around.
> 
> diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
> index 8056107..1932e0e 100644
> --- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
> +++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
> @@ -37,8 +37,6 @@
>  #include <asm/ppc-opcode.h>
>  #include <asm/cputable.h>
>  
> -#include "book3s_hv_cma.h"
> -
>  /* POWER7 has 10-bit LPIDs, PPC970 has 6-bit LPIDs */
>  #define MAX_LPID_970   63
>  
> @@ -64,7 +62,6 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
>         }
>  
>         kvm->arch.hpt_cma_alloc = 0;
> -       VM_BUG_ON(order < KVM_CMA_CHUNK_ORDER);
>         page = kvm_alloc_hpt(1 << (order - PAGE_SHIFT));
>         if (page) {
>                 hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));
> 
> 
> 
> -aneesh

Okay.
So do you also want this?

@@ -131,16 +135,18 @@ struct page *kvm_alloc_hpt(unsigned long nr_pages)
 {
        unsigned long align_pages = HPT_ALIGN_PAGES;
 
+       VM_BUG_ON(get_order(nr_pages) < KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
+
        /* Old CPUs require HPT aligned on a multiple of its size */
        if (!cpu_has_feature(CPU_FTR_ARCH_206))
                align_pages = nr_pages;
-       return kvm_alloc_cma(nr_pages, align_pages);
+       return cma_alloc(kvm_cma, nr_pages, get_order(align_pages));
 }

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
