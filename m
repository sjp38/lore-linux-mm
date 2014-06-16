Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 368B76B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 03:02:44 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so1574689pbc.30
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 00:02:43 -0700 (PDT)
Received: from e28smtp08.in.ibm.com (e28smtp08.in.ibm.com. [122.248.162.8])
        by mx.google.com with ESMTPS id ew3si9883833pbb.184.2014.06.16.00.02.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 00:02:43 -0700 (PDT)
Received: from /spool/local
	by e28smtp08.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 16 Jun 2014 12:32:39 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id D8703125805E
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:32:00 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5G72l2H59047992
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:32:47 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5G72WsQ000909
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 12:32:33 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 07/10] PPC, KVM, CMA: use general CMA reserved area management framework
In-Reply-To: <20140616053408.GH23210@js1304-P5Q-DELUXE>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-8-git-send-email-iamjoonsoo.kim@lge.com> <87mwdfg9co.fsf@linux.vnet.ibm.com> <20140616053408.GH23210@js1304-P5Q-DELUXE>
Date: Mon, 16 Jun 2014 12:32:24 +0530
Message-ID: <87wqchcp6n.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Sat, Jun 14, 2014 at 02:23:59PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> > Now, we have general CMA reserved area management framework,
>> > so use it for future maintainabilty. There is no functional change.
>> >
>> > Acked-by: Michal Nazarewicz <mina86@mina86.com>
>> > Acked-by: Paolo Bonzini <pbonzini@redhat.com>
>> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> 
>> Need this. We may want to keep the VM_BUG_ON by moving
>> KVM_CMA_CHUNK_ORDER around.
>> 
>> diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
>> index 8056107..1932e0e 100644
>> --- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
>> +++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
>> @@ -37,8 +37,6 @@
>>  #include <asm/ppc-opcode.h>
>>  #include <asm/cputable.h>
>>  
>> -#include "book3s_hv_cma.h"
>> -
>>  /* POWER7 has 10-bit LPIDs, PPC970 has 6-bit LPIDs */
>>  #define MAX_LPID_970   63
>>  
>> @@ -64,7 +62,6 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
>>         }
>>  
>>         kvm->arch.hpt_cma_alloc = 0;
>> -       VM_BUG_ON(order < KVM_CMA_CHUNK_ORDER);
>>         page = kvm_alloc_hpt(1 << (order - PAGE_SHIFT));
>>         if (page) {
>>                 hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));
>> 
>> 
>> 
>> -aneesh
>
> Okay.
> So do you also want this?
>
> @@ -131,16 +135,18 @@ struct page *kvm_alloc_hpt(unsigned long nr_pages)
>  {
>         unsigned long align_pages = HPT_ALIGN_PAGES;
>
> +       VM_BUG_ON(get_order(nr_pages) < KVM_CMA_CHUNK_ORDER - PAGE_SHIFT);
> +
>         /* Old CPUs require HPT aligned on a multiple of its size */
>         if (!cpu_has_feature(CPU_FTR_ARCH_206))
>                 align_pages = nr_pages;
> -       return kvm_alloc_cma(nr_pages, align_pages);
> +       return cma_alloc(kvm_cma, nr_pages, get_order(align_pages));
>  }

That would also work.

Thanks
-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
