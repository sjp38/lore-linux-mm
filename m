Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id CA9DA6B02F4
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:05:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g7so24795789pgp.1
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 23:05:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 95si1075418plc.40.2017.07.19.23.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 23:05:34 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K64iC4144615
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:05:34 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btp4jsp75-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:05:33 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 16:05:31 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K65LKE23527484
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:05:29 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K64WuO011408
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 16:04:33 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 11/62] powerpc: initial pkey plumbing
In-Reply-To: <1500177424-13695-12-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-12-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 11:34:10 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87shhrprtx.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> basic setup to initialize the pkey system. Only 64K kernel in HPT
> mode, enables the pkey system.
>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/Kconfig                   |   16 ++++++++++
>  arch/powerpc/include/asm/mmu_context.h |    5 +++
>  arch/powerpc/include/asm/pkeys.h       |   51 ++++++++++++++++++++++++++++++++
>  arch/powerpc/kernel/setup_64.c         |    4 ++
>  arch/powerpc/mm/Makefile               |    1 +
>  arch/powerpc/mm/hash_utils_64.c        |    1 +
>  arch/powerpc/mm/pkeys.c                |   18 +++++++++++
>  7 files changed, 96 insertions(+), 0 deletions(-)
>  create mode 100644 arch/powerpc/include/asm/pkeys.h
>  create mode 100644 arch/powerpc/mm/pkeys.c
>
> diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
> index bf4391d..5c60fd6 100644
> --- a/arch/powerpc/Kconfig
> +++ b/arch/powerpc/Kconfig
> @@ -855,6 +855,22 @@ config SECCOMP
>
>  	  If unsure, say Y. Only embedded should say N here.
>
> +config PPC64_MEMORY_PROTECTION_KEYS
> +	prompt "PowerPC Memory Protection Keys"
> +	def_bool y
> +	# Note: only available in 64-bit mode
> +	depends on PPC64 && PPC_64K_PAGES
> +	select ARCH_USES_HIGH_VMA_FLAGS
> +	select ARCH_HAS_PKEYS
> +	---help---
> +	  Memory Protection Keys provides a mechanism for enforcing
> +	  page-based protections, but without requiring modification of the
> +	  page tables when an application changes protection domains.
> +
> +	  For details, see Documentation/vm/protection-keys.txt
> +
> +	  If unsure, say y.
> +
>  endmenu


Shouldn't this come as the last patch ? Or can we enable this config by
this patch ? If so what does it do ? Did you test boot each of this
patch to make sure we don't break git bisect ?

>
>  config ISA_DMA_API
> diff --git a/arch/powerpc/include/asm/mmu_context.h b/arch/powerpc/include/asm/mmu_context.h
> index da7e943..4b93547 100644
> --- a/arch/powerpc/include/asm/mmu_context.h
> +++ b/arch/powerpc/include/asm/mmu_context.h
> @@ -181,5 +181,10 @@ static inline bool arch_vma_access_permitted(struct vm_area_struct *vma,
>  	/* by default, allow everything */


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
