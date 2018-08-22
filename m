Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id C98D16B26A2
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 18:15:59 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 13-v6so2897462qtt.7
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 15:15:59 -0700 (PDT)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com. [52.95.49.90])
        by mx.google.com with ESMTPS id n3-v6si2468180qvi.279.2018.08.22.15.15.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Aug 2018 15:15:59 -0700 (PDT)
Date: Wed, 22 Aug 2018 15:12:50 -0700
From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: [PATCH 4/4] x86/mm: Only use tlb_remove_table() for paravirt
Message-ID: <20180822221250.GB16015@u40b0340c692b58f6553c.ant.amazon.com>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.877071284@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180822154046.877071284@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hey Peter,

On Wed, Aug 22, 2018 at 05:30:16PM +0200, Peter Zijlstra wrote:
> If we don't use paravirt; don't play unnecessary and complicated games
> to free page-tables.
> 
> Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/x86/Kconfig                      |    2 +-
>  arch/x86/hyperv/mmu.c                 |    2 ++
>  arch/x86/include/asm/paravirt.h       |    5 +++++
>  arch/x86/include/asm/paravirt_types.h |    3 +++
>  arch/x86/include/asm/tlbflush.h       |    3 +++
>  arch/x86/kernel/kvm.c                 |    5 ++++-
>  arch/x86/kernel/paravirt.c            |    2 ++
>  arch/x86/mm/pgtable.c                 |    8 ++++----
>  arch/x86/xen/mmu_pv.c                 |    1 +
>  9 files changed, 25 insertions(+), 6 deletions(-)
> 

<cut>

> --- a/arch/x86/xen/mmu_pv.c
> +++ b/arch/x86/xen/mmu_pv.c
> @@ -2397,6 +2397,7 @@ static const struct pv_mmu_ops xen_mmu_o
>  	.flush_tlb_kernel = xen_flush_tlb,
>  	.flush_tlb_one_user = xen_flush_tlb_one_user,
>  	.flush_tlb_others = xen_flush_tlb_others,
> +	.tlb_remove_table = tlb_remove_table,

I tried compiling the series, and I am getting the following compilation error:

  CC      arch/x86/xen/mmu_pv.o
arch/x86/xen/mmu_pv.c:2400:22: error: a??tlb_remove_tablea?? undeclared here (not in a function); did you mean a??bus_remove_filea???
  .tlb_remove_table = tlb_remove_table,
                      ^~~~~~~~~~~~~~~~
                      bus_remove_file
make[4]: *** [arch/x86/xen/mmu_pv.o] Error 1


which I solved by:
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index a21988ec30d3..3114b7c76970 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -67,6 +67,7 @@
 #include <asm/init.h>
 #include <asm/pat.h>
 #include <asm/smp.h>
+#include <asm/tlb.h>
 
 #include <asm/xen/hypercall.h>
 #include <asm/xen/hypervisor.h>


>  
>  	.pgd_alloc = xen_pgd_alloc,
>  	.pgd_free = xen_pgd_free,
> 
> 
> 

-- 
All the best,
Eduardo Valentin
