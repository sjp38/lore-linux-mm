Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 12438C04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:51:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A7C512087F
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 06:51:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="c9VxYGjC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A7C512087F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43DE46B0003; Fri,  3 May 2019 02:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3EEE66B0005; Fri,  3 May 2019 02:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28FA36B0007; Fri,  3 May 2019 02:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8D206B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 02:51:14 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b3so4259732wro.7
        for <linux-mm@kvack.org>; Thu, 02 May 2019 23:51:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=GT99LV8Z525zndega9MtAhPQMhcaNvpNWfMKvpkHrw4=;
        b=BqC7uVtDMsNy5VFEv52YatHURZiWxSfhT04pG5Y/BhsKQpMP4HBjDBwSy/boXiEoww
         rxwmttF2dyEGe+KS0LsiidW3veFX/EJtg8HJgqOcOoa1VGHT7jNuzTrqiFdtvRJlvlQM
         iO7HvAAR/qgBCzr+dSefvk0VjcokjgZFHplmFUG2W8/ZJFFk4ChNKL6/227Zhx+gYgrD
         2Kv3rfF9M+21Y2C/oe5RhkMA5nUgntviCfS4zSTLhM5tHy0Hhr8jNsqltfJkOwHpAL9g
         mAtXZaPwHgQgaLKJF9J0em5GyYDxcdlMFALDmwJHUVtYPYwjVbXQv2E4UISdh/2gLGsf
         ay7Q==
X-Gm-Message-State: APjAAAWlqw8Vq4f9mJf1vo5PPgPcBpyzJKa5wfHEJYbi/caZl7gkL5U5
	CCIL6cR9KVzs/vS0Rc8MjTHO0Rn8t6HPUvlJuYdEs/4sXELAGA/MZ19yYtgZMZB8RWDP7z0/fUp
	hMAyI6sECe7MWojAhG5hF+Gnf5eUyO1CHpxHsvDfzbLB8OY3TJuflUYyKBKnCXuwxmw==
X-Received: by 2002:a1c:14:: with SMTP id 20mr5319936wma.66.1556866274143;
        Thu, 02 May 2019 23:51:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFTzhv4PTlRASsvFbKC0DqnQoDvMjrQaZ/yzq80LMhHt39a07vmKqtGucIkFCgj2XevYo5
X-Received: by 2002:a1c:14:: with SMTP id 20mr5319866wma.66.1556866272783;
        Thu, 02 May 2019 23:51:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556866272; cv=none;
        d=google.com; s=arc-20160816;
        b=sqeRsc26RJIb36fOOVoqhAm+jvKjvB2Sm2wUGashaA9U5P0LE8tg8nz5LO6so38iqd
         qpwOdjSvgXRloJ34qbN1ftGntocuTLi9iZwbEWeWuXq3uCCzjzqqUmefBYHSNdEW1s32
         xT+OGjGb2UNoFdmPsrCTNYMyThQN00/zVzjM8wSZAhqyUqgJHxi8YdqSG/C5sbJ8dUDf
         BzrCeQ0oazE7gV09NZ/VzfPymjllCGHqQ5bBvNQAoobIdGvBA77VEVVdmX2nDLZtoL3+
         eGYH/6oX42DOwdAjijbzrPGpanoY5hmOb37+GnxbwlJsoUioQS5ULEXEuDm6mYIBJPT5
         XH/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=GT99LV8Z525zndega9MtAhPQMhcaNvpNWfMKvpkHrw4=;
        b=XbrSVJWILWtD/UTnJXs9ZPWJDl4iG/vyuIxVjRP+uCi9Hw0Aqo7ljAFVe06EH0ooap
         db5NRQigbqEcOWnDI0GqzzGNiS+9adMCpkblV7r+KGWH3tg290TE2XH3Y3dZ73KLd9IE
         R1njH8odCwW/dL+aFw27i5ah3iswLbk42PyAZChGLUejX2dYzrtnd6P6jJwLryBW05yY
         lUoDdxun0GsTv8xDc85KwIMNruhEWoV724AGWXKW6P1uxkOiaWb+SUbxEQjJuXUEDjvW
         HpjtlXYweULmT0qX2DbxUT53abU2jQTMZq6OOFLd80GjPoZ2HzUW7EyFu/FjqZdvTBFh
         vfEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=c9VxYGjC;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id y2si846633wmc.69.2019.05.02.23.51.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 May 2019 23:51:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=c9VxYGjC;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 44wN7z1Y1bz9v0XS;
	Fri,  3 May 2019 08:51:11 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=c9VxYGjC; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id KXN4wYVtsAaN; Fri,  3 May 2019 08:51:11 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 44wN7z0PPJz9tytc;
	Fri,  3 May 2019 08:51:11 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1556866271; bh=GT99LV8Z525zndega9MtAhPQMhcaNvpNWfMKvpkHrw4=;
	h=Subject:From:To:Cc:References:Date:In-Reply-To:From;
	b=c9VxYGjChvPUhpYBgU9n2Hgh5pnx4mHoVQNEpWDY+fYAMWPPzqA6ErSyPUKJ/E16i
	 goUQTw5aglmC/64z4cGWng4mIT86awPl6Rk9GIYjUOHIM+uXCwBVEeRaleaCi39VNg
	 ghVXxGzTx1cpFcdAdndwjEz4mfIF/bDHf/Lf2q/E=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id EFF948B825;
	Fri,  3 May 2019 08:51:11 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id nc1kRj3E7n09; Fri,  3 May 2019 08:51:11 +0200 (CEST)
Received: from PO15451 (po15451.idsi0.si.c-s.fr [172.25.231.6])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id B404E8B819;
	Fri,  3 May 2019 08:51:11 +0200 (CEST)
Subject: Re: [PATCH v11 10/13] powerpc/32: Add KASAN support
From: Christophe Leroy <christophe.leroy@c-s.fr>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 Nicholas Piggin <npiggin@gmail.com>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrey Ryabinin <aryabinin@virtuozzo.com>,
 Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>,
 Daniel Axtens <dja@axtens.net>
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org,
 linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com
References: <cover.1556295459.git.christophe.leroy@c-s.fr>
 <c08fe3fee59343ebf76fd7ea0de11f4ad07a1d6e.1556295461.git.christophe.leroy@c-s.fr>
Message-ID: <e3b1f65f-6b3b-1ae8-3a3c-13b750bcc810@c-s.fr>
Date: Fri, 3 May 2019 08:51:11 +0200
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <c08fe3fee59343ebf76fd7ea0de11f4ad07a1d6e.1556295461.git.christophe.leroy@c-s.fr>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



Le 26/04/2019 à 18:23, Christophe Leroy a écrit :
> This patch adds KASAN support for PPC32. The following patch
> will add an early activation of hash table for book3s. Until
> then, a warning will be raised if trying to use KASAN on an
> hash 6xx.
> 
> To support KASAN, this patch initialises that MMU mapings for
> accessing to the KASAN shadow area defined in a previous patch.
> 
> An early mapping is set as soon as the kernel code has been
> relocated at its definitive place.
> 
> Then the definitive mapping is set once paging is initialised.
> 
> For modules, the shadow area is allocated at module_alloc().
> 
> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
> ---
>   arch/powerpc/Kconfig                  |   1 +
>   arch/powerpc/include/asm/kasan.h      |   9 ++
>   arch/powerpc/kernel/head_32.S         |   3 +
>   arch/powerpc/kernel/head_40x.S        |   3 +
>   arch/powerpc/kernel/head_44x.S        |   3 +
>   arch/powerpc/kernel/head_8xx.S        |   3 +
>   arch/powerpc/kernel/head_fsl_booke.S  |   3 +
>   arch/powerpc/kernel/setup-common.c    |   3 +
>   arch/powerpc/mm/Makefile              |   1 +
>   arch/powerpc/mm/init_32.c             |   3 +
>   arch/powerpc/mm/kasan/Makefile        |   5 ++

Looks like the above Makefile is missing in powerpc/next ???

Christophe

>   arch/powerpc/mm/kasan/kasan_init_32.c | 156 ++++++++++++++++++++++++++++++++++
>   12 files changed, 193 insertions(+)
>   create mode 100644 arch/powerpc/mm/kasan/Makefile
>   create mode 100644 arch/powerpc/mm/kasan/kasan_init_32.c
> 
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index a7c80f2b08b5..1a2fb50126b2 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -173,6 +173,7 @@ config PPC
>   	select GENERIC_TIME_VSYSCALL
>   	select HAVE_ARCH_AUDITSYSCALL
>   	select HAVE_ARCH_JUMP_LABEL
> +	select HAVE_ARCH_KASAN			if PPC32
>   	select HAVE_ARCH_KGDB
>   	select HAVE_ARCH_MMAP_RND_BITS
>   	select HAVE_ARCH_MMAP_RND_COMPAT_BITS	if COMPAT
> diff --git a/arch/powerpc/include/asm/kasan.h b/arch/powerpc/include/asm/kasan.h
> index 05274dea3109..296e51c2f066 100644
> --- a/arch/powerpc/include/asm/kasan.h
> +++ b/arch/powerpc/include/asm/kasan.h
> @@ -27,5 +27,14 @@
>   
>   #define KASAN_SHADOW_SIZE	(KASAN_SHADOW_END - KASAN_SHADOW_START)
>   
> +#ifdef CONFIG_KASAN
> +void kasan_early_init(void);
> +void kasan_mmu_init(void);
> +void kasan_init(void);
> +#else
> +static inline void kasan_init(void) { }
> +static inline void kasan_mmu_init(void) { }
> +#endif
> +
>   #endif /* __ASSEMBLY */
>   #endif
> diff --git a/arch/powerpc/kernel/head_32.S b/arch/powerpc/kernel/head_32.S
> index 40aec3f00a05..6e85171e513c 100644
> --- a/arch/powerpc/kernel/head_32.S
> +++ b/arch/powerpc/kernel/head_32.S
> @@ -969,6 +969,9 @@ start_here:
>    * Do early platform-specific initialization,
>    * and set up the MMU.
>    */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>   	li	r3,0
>   	mr	r4,r31
>   	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_40x.S b/arch/powerpc/kernel/head_40x.S
> index a9c934f2319b..efa219d2136e 100644
> --- a/arch/powerpc/kernel/head_40x.S
> +++ b/arch/powerpc/kernel/head_40x.S
> @@ -848,6 +848,9 @@ start_here:
>   /*
>    * Decide what sort of machine this is and initialize the MMU.
>    */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>   	li	r3,0
>   	mr	r4,r31
>   	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_44x.S b/arch/powerpc/kernel/head_44x.S
> index 37117ab11584..34a5df827b38 100644
> --- a/arch/powerpc/kernel/head_44x.S
> +++ b/arch/powerpc/kernel/head_44x.S
> @@ -203,6 +203,9 @@ _ENTRY(_start);
>   /*
>    * Decide what sort of machine this is and initialize the MMU.
>    */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>   	li	r3,0
>   	mr	r4,r31
>   	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_8xx.S b/arch/powerpc/kernel/head_8xx.S
> index 03c73b4c6435..d25adb6ef235 100644
> --- a/arch/powerpc/kernel/head_8xx.S
> +++ b/arch/powerpc/kernel/head_8xx.S
> @@ -853,6 +853,9 @@ start_here:
>   /*
>    * Decide what sort of machine this is and initialize the MMU.
>    */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>   	li	r3,0
>   	mr	r4,r31
>   	bl	machine_init
> diff --git a/arch/powerpc/kernel/head_fsl_booke.S b/arch/powerpc/kernel/head_fsl_booke.S
> index 32332e24e421..567e0ed45ca8 100644
> --- a/arch/powerpc/kernel/head_fsl_booke.S
> +++ b/arch/powerpc/kernel/head_fsl_booke.S
> @@ -268,6 +268,9 @@ set_ivor:
>   /*
>    * Decide what sort of machine this is and initialize the MMU.
>    */
> +#ifdef CONFIG_KASAN
> +	bl	kasan_early_init
> +#endif
>   	mr	r3,r30
>   	mr	r4,r31
>   	bl	machine_init
> diff --git a/arch/powerpc/kernel/setup-common.c b/arch/powerpc/kernel/setup-common.c
> index 1729bf409562..15afb01b4374 100644
> --- a/arch/powerpc/kernel/setup-common.c
> +++ b/arch/powerpc/kernel/setup-common.c
> @@ -67,6 +67,7 @@
>   #include <asm/livepatch.h>
>   #include <asm/mmu_context.h>
>   #include <asm/cpu_has_feature.h>
> +#include <asm/kasan.h>
>   
>   #include "setup.h"
>   
> @@ -871,6 +872,8 @@ static void smp_setup_pacas(void)
>    */
>   void __init setup_arch(char **cmdline_p)
>   {
> +	kasan_init();
> +
>   	*cmdline_p = boot_command_line;
>   
>   	/* Set a half-reasonable default so udelay does something sensible */
> diff --git a/arch/powerpc/mm/Makefile b/arch/powerpc/mm/Makefile
> index dd945ca869b2..01afb10a7b33 100644
> --- a/arch/powerpc/mm/Makefile
> +++ b/arch/powerpc/mm/Makefile
> @@ -53,6 +53,7 @@ obj-$(CONFIG_PPC_COPRO_BASE)	+= copro_fault.o
>   obj-$(CONFIG_SPAPR_TCE_IOMMU)	+= mmu_context_iommu.o
>   obj-$(CONFIG_PPC_PTDUMP)	+= ptdump/
>   obj-$(CONFIG_PPC_MEM_KEYS)	+= pkeys.o
> +obj-$(CONFIG_KASAN)		+= kasan/
>   
>   # Disable kcov instrumentation on sensitive code
>   # This is necessary for booting with kcov enabled on book3e machines
> diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
> index 80cc97cd8878..5b61673e7eed 100644
> --- a/arch/powerpc/mm/init_32.c
> +++ b/arch/powerpc/mm/init_32.c
> @@ -46,6 +46,7 @@
>   #include <asm/sections.h>
>   #include <asm/hugetlb.h>
>   #include <asm/kup.h>
> +#include <asm/kasan.h>
>   
>   #include "mmu_decl.h"
>   
> @@ -179,6 +180,8 @@ void __init MMU_init(void)
>   	btext_unmap();
>   #endif
>   
> +	kasan_mmu_init();
> +
>   	setup_kup();
>   
>   	/* Shortly after that, the entire linear mapping will be available */
> diff --git a/arch/powerpc/mm/kasan/Makefile b/arch/powerpc/mm/kasan/Makefile
> new file mode 100644
> index 000000000000..6577897673dd
> --- /dev/null
> +++ b/arch/powerpc/mm/kasan/Makefile
> @@ -0,0 +1,5 @@
> +# SPDX-License-Identifier: GPL-2.0
> +
> +KASAN_SANITIZE := n
> +
> +obj-$(CONFIG_PPC32)           += kasan_init_32.o
> diff --git a/arch/powerpc/mm/kasan/kasan_init_32.c b/arch/powerpc/mm/kasan/kasan_init_32.c
> new file mode 100644
> index 000000000000..42617fcad828
> --- /dev/null
> +++ b/arch/powerpc/mm/kasan/kasan_init_32.c
> @@ -0,0 +1,156 @@
> +// SPDX-License-Identifier: GPL-2.0
> +
> +#define DISABLE_BRANCH_PROFILING
> +
> +#include <linux/kasan.h>
> +#include <linux/printk.h>
> +#include <linux/memblock.h>
> +#include <linux/sched/task.h>
> +#include <linux/vmalloc.h>
> +#include <asm/pgalloc.h>
> +#include <asm/code-patching.h>
> +#include <mm/mmu_decl.h>
> +
> +static void kasan_populate_pte(pte_t *ptep, pgprot_t prot)
> +{
> +	unsigned long va = (unsigned long)kasan_early_shadow_page;
> +	phys_addr_t pa = __pa(kasan_early_shadow_page);
> +	int i;
> +
> +	for (i = 0; i < PTRS_PER_PTE; i++, ptep++)
> +		__set_pte_at(&init_mm, va, ptep, pfn_pte(PHYS_PFN(pa), prot), 0);
> +}
> +
> +static int kasan_init_shadow_page_tables(unsigned long k_start, unsigned long k_end)
> +{
> +	pmd_t *pmd;
> +	unsigned long k_cur, k_next;
> +
> +	pmd = pmd_offset(pud_offset(pgd_offset_k(k_start), k_start), k_start);
> +
> +	for (k_cur = k_start; k_cur != k_end; k_cur = k_next, pmd++) {
> +		pte_t *new;
> +
> +		k_next = pgd_addr_end(k_cur, k_end);
> +		if ((void *)pmd_page_vaddr(*pmd) != kasan_early_shadow_pte)
> +			continue;
> +
> +		new = pte_alloc_one_kernel(&init_mm);
> +
> +		if (!new)
> +			return -ENOMEM;
> +		kasan_populate_pte(new, PAGE_KERNEL_RO);
> +		pmd_populate_kernel(&init_mm, pmd, new);
> +	}
> +	return 0;
> +}
> +
> +static void __ref *kasan_get_one_page(void)
> +{
> +	if (slab_is_available())
> +		return (void *)__get_free_page(GFP_KERNEL | __GFP_ZERO);
> +
> +	return memblock_alloc(PAGE_SIZE, PAGE_SIZE);
> +}
> +
> +static int __ref kasan_init_region(void *start, size_t size)
> +{
> +	unsigned long k_start = (unsigned long)kasan_mem_to_shadow(start);
> +	unsigned long k_end = (unsigned long)kasan_mem_to_shadow(start + size);
> +	unsigned long k_cur;
> +	int ret;
> +	void *block = NULL;
> +
> +	ret = kasan_init_shadow_page_tables(k_start, k_end);
> +	if (ret)
> +		return ret;
> +
> +	if (!slab_is_available())
> +		block = memblock_alloc(k_end - k_start, PAGE_SIZE);
> +
> +	for (k_cur = k_start; k_cur < k_end; k_cur += PAGE_SIZE) {
> +		pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(k_cur), k_cur), k_cur);
> +		void *va = block ? block + k_cur - k_start : kasan_get_one_page();
> +		pte_t pte = pfn_pte(PHYS_PFN(__pa(va)), PAGE_KERNEL);
> +
> +		if (!va)
> +			return -ENOMEM;
> +
> +		__set_pte_at(&init_mm, k_cur, pte_offset_kernel(pmd, k_cur), pte, 0);
> +	}
> +	flush_tlb_kernel_range(k_start, k_end);
> +	return 0;
> +}
> +
> +static void __init kasan_remap_early_shadow_ro(void)
> +{
> +	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL_RO);
> +
> +	flush_tlb_kernel_range(KASAN_SHADOW_START, KASAN_SHADOW_END);
> +}
> +
> +void __init kasan_mmu_init(void)
> +{
> +	int ret;
> +	struct memblock_region *reg;
> +
> +	for_each_memblock(memory, reg) {
> +		phys_addr_t base = reg->base;
> +		phys_addr_t top = min(base + reg->size, total_lowmem);
> +
> +		if (base >= top)
> +			continue;
> +
> +		ret = kasan_init_region(__va(base), top - base);
> +		if (ret)
> +			panic("kasan: kasan_init_region() failed");
> +	}
> +}
> +
> +void __init kasan_init(void)
> +{
> +	kasan_remap_early_shadow_ro();
> +
> +	clear_page(kasan_early_shadow_page);
> +
> +	/* At this point kasan is fully initialized. Enable error messages */
> +	init_task.kasan_depth = 0;
> +	pr_info("KASAN init done\n");
> +}
> +
> +#ifdef CONFIG_MODULES
> +void *module_alloc(unsigned long size)
> +{
> +	void *base = vmalloc_exec(size);
> +
> +	if (!base)
> +		return NULL;
> +
> +	if (!kasan_init_region(base, size))
> +		return base;
> +
> +	vfree(base);
> +
> +	return NULL;
> +}
> +#endif
> +
> +void __init kasan_early_init(void)
> +{
> +	unsigned long addr = KASAN_SHADOW_START;
> +	unsigned long end = KASAN_SHADOW_END;
> +	unsigned long next;
> +	pmd_t *pmd = pmd_offset(pud_offset(pgd_offset_k(addr), addr), addr);
> +
> +	BUILD_BUG_ON(KASAN_SHADOW_START & ~PGDIR_MASK);
> +
> +	kasan_populate_pte(kasan_early_shadow_pte, PAGE_KERNEL);
> +
> +	do {
> +		next = pgd_addr_end(addr, end);
> +		pmd_populate_kernel(&init_mm, pmd, kasan_early_shadow_pte);
> +	} while (pmd++, addr = next, addr != end);
> +
> +	if (early_mmu_has_feature(MMU_FTR_HPTE_TABLE))
> +		WARN(true, "KASAN not supported on hash 6xx");
> +}
> 

