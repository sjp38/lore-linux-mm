Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id EB8DD6B0035
	for <linux-mm@kvack.org>; Tue, 22 Apr 2014 03:39:14 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so4574382pdi.35
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 00:39:14 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id w4si22222701paa.485.2014.04.22.00.39.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Apr 2014 00:39:13 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH V2 1/2] mm: move FAULT_AROUND_ORDER to arch/
In-Reply-To: <53456B61.1040901@intel.com>
References: <1396592835-24767-1-git-send-email-maddy@linux.vnet.ibm.com> <1396592835-24767-2-git-send-email-maddy@linux.vnet.ibm.com> <533EDB63.8090909@intel.com> <5344A312.80802@linux.vnet.ibm.com> <53456B61.1040901@intel.com>
Date: Tue, 22 Apr 2014 16:52:17 +0930
Message-ID: <87vbu1hlqu.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Madhavan Srinivasan <maddy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, x86@kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, riel@redhat.com, mgorman@suse.de, ak@linux.intel.com, peterz@infradead.org, mingo@kernel.org

Dave Hansen <dave.hansen@intel.com> writes:
> On 04/08/2014 06:32 PM, Madhavan Srinivasan wrote:
>>> > In mm/Kconfig, put
>>> > 
>>> > 	config FAULT_AROUND_ORDER
>>> > 		int
>>> > 		default 1234 if POWERPC
>>> > 		default 4
>>> > 
>>> > The way you have it now, every single architecture that needs to enable
>>> > this has to go put that in their Kconfig.  That's madness.  This way,
>> I though about it and decided not to do this way because, in future,
>> sub platforms of the architecture may decide to change the values. Also,
>> adding an if line for each architecture with different sub platforms
>> oring to it will look messy.
>
> I'm not sure why I'm trying here any more.  You do seem quite content to
> add as much cruft to ppc and every other architecture as possible.  If
> your theoretical scenario pops up, you simply do this in ppc:
>
> config ARCH_FAULT_AROUND_ORDER
> 	int
> 	default 999
> 	default 888 if OTHER_SILLY_POWERPC_SUBARCH
>
> But *ONLY* in the architectures that care about doing that stuff.  You
> leave every other architecture on the planet alone.  Then, in mm/Kconfig:
>
> config FAULT_AROUND_ORDER
> 	int
> 	default ARCH_FAULT_AROUND_ORDER if ARCH_FAULT_AROUND_ORDER
> 	default 4
>
> Your way still requires going and individually touching every single
> architecture's Kconfig that wants to enable fault around.  That's not an
> acceptable solution.

Why bother with Kconfig at all?  It seems like a weird indirection.

And talking about future tuning seems like a separate issue, if and when
someone does the work.  For the moment, let's keep it simple (as below).

If you really want Kconfig, then just go straight from
ARCH_FAULT_AROUND_ORDER, ie:

        #ifdef CONFIG_ARCH_FAULT_AROUND_ORDER
        #define FAULT_AROUND_ORDER CONFIG_ARCH_FAULT_AROUND_ORDER
        #else
        #define FAULT_AROUND_ORDER 4
        #endif

Then powerpc's Kconfig defines CONFIG_ARCH_FAULT_AROUND_ORDER, and
we're done.

Cheers,
Rusty.

diff --git a/arch/powerpc/include/asm/page.h b/arch/powerpc/include/asm/page.h
index 32e4e212b9c1..b519c5c53cfc 100644
--- a/arch/powerpc/include/asm/page.h
+++ b/arch/powerpc/include/asm/page.h
@@ -412,4 +412,7 @@ typedef struct page *pgtable_t;
 #include <asm-generic/memory_model.h>
 #endif /* __ASSEMBLY__ */
 
+/* Measured on a 4 socket Power7 system (128 Threads and 128GB memory) */
+#define FAULT_AROUND_ORDER 3
+
 #endif /* _ASM_POWERPC_PAGE_H */
diff --git a/mm/memory.c b/mm/memory.c
index d0f0bef3be48..9aa47e9ec7ba 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3382,7 +3382,10 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
+/* Archs can override, but this seems to work for x86. */
+#ifndef FAULT_AROUND_ORDER
 #define FAULT_AROUND_ORDER 4
+#endif
 
 #ifdef CONFIG_DEBUG_FS
 static unsigned int fault_around_order = FAULT_AROUND_ORDER;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
