Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 434196B0031
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 04:54:07 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so2891902pab.30
        for <linux-mm@kvack.org>; Sat, 14 Jun 2014 01:54:06 -0700 (PDT)
Received: from e28smtp09.in.ibm.com (e28smtp09.in.ibm.com. [122.248.162.9])
        by mx.google.com with ESMTPS id lu5si7332369pab.154.2014.06.14.01.54.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 14 Jun 2014 01:54:06 -0700 (PDT)
Received: from /spool/local
	by e28smtp09.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 14 Jun 2014 14:24:02 +0530
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id EA7AA3940048
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 14:24:00 +0530 (IST)
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s5E8swf953149906
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 14:24:58 +0530
Received: from d28av04.in.ibm.com (localhost [127.0.0.1])
	by d28av04.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s5E8rxxk024953
	for <linux-mm@kvack.org>; Sat, 14 Jun 2014 14:24:00 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 07/10] PPC, KVM, CMA: use general CMA reserved area management framework
In-Reply-To: <1402543307-29800-8-git-send-email-iamjoonsoo.kim@lge.com>
References: <1402543307-29800-1-git-send-email-iamjoonsoo.kim@lge.com> <1402543307-29800-8-git-send-email-iamjoonsoo.kim@lge.com>
Date: Sat, 14 Jun 2014 14:23:59 +0530
Message-ID: <87mwdfg9co.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>
Cc: Minchan Kim <minchan@kernel.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Gleb Natapov <gleb@kernel.org>, Alexander Graf <agraf@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, kvm@vger.kernel.org, kvm-ppc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> Now, we have general CMA reserved area management framework,
> so use it for future maintainabilty. There is no functional change.
>
> Acked-by: Michal Nazarewicz <mina86@mina86.com>
> Acked-by: Paolo Bonzini <pbonzini@redhat.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Need this. We may want to keep the VM_BUG_ON by moving
KVM_CMA_CHUNK_ORDER around.

diff --git a/arch/powerpc/kvm/book3s_64_mmu_hv.c b/arch/powerpc/kvm/book3s_64_mmu_hv.c
index 8056107..1932e0e 100644
--- a/arch/powerpc/kvm/book3s_64_mmu_hv.c
+++ b/arch/powerpc/kvm/book3s_64_mmu_hv.c
@@ -37,8 +37,6 @@
 #include <asm/ppc-opcode.h>
 #include <asm/cputable.h>
 
-#include "book3s_hv_cma.h"
-
 /* POWER7 has 10-bit LPIDs, PPC970 has 6-bit LPIDs */
 #define MAX_LPID_970   63
 
@@ -64,7 +62,6 @@ long kvmppc_alloc_hpt(struct kvm *kvm, u32 *htab_orderp)
        }
 
        kvm->arch.hpt_cma_alloc = 0;
-       VM_BUG_ON(order < KVM_CMA_CHUNK_ORDER);
        page = kvm_alloc_hpt(1 << (order - PAGE_SHIFT));
        if (page) {
                hpt = (unsigned long)pfn_to_kaddr(page_to_pfn(page));



-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
