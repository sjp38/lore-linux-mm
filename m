Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0DC256B0033
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 10:34:23 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id r23so10804044qte.13
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 07:34:23 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id v92si530817qtd.339.2018.01.21.07.34.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 07:34:22 -0800 (PST)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0LFYJMU024999
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 10:34:21 -0500
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fmm96p21y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 21 Jan 2018 10:34:20 -0500
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 21 Jan 2018 15:34:15 -0000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH v10 01/27] mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS is enabled
In-Reply-To: <1516326648-22775-2-git-send-email-linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com> <1516326648-22775-2-git-send-email-linuxram@us.ibm.com>
Date: Sun, 21 Jan 2018 21:04:02 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87mv17rzth.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, corbet@lwn.net, arnd@arndb.de
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

Ram Pai <linuxram@us.ibm.com> writes:

> VM_PKEY_BITx are defined only if CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> is enabled. Powerpc also needs these bits. Hence lets define the
> VM_PKEY_BITx bits for any architecture that enables
> CONFIG_ARCH_HAS_PKEYS.
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  fs/proc/task_mmu.c |    4 ++--
>  include/linux/mm.h |    9 +++++----
>  2 files changed, 7 insertions(+), 6 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 339e4c1..b139617 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -674,13 +674,13 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  		[ilog2(VM_MERGEABLE)]	= "mg",
>  		[ilog2(VM_UFFD_MISSING)]= "um",
>  		[ilog2(VM_UFFD_WP)]	= "uw",
> -#ifdef CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> +#ifdef CONFIG_ARCH_HAS_PKEYS
>  		/* These come out via ProtectionKey: */
>  		[ilog2(VM_PKEY_BIT0)]	= "",
>  		[ilog2(VM_PKEY_BIT1)]	= "",
>  		[ilog2(VM_PKEY_BIT2)]	= "",
>  		[ilog2(VM_PKEY_BIT3)]	= "",
> -#endif
> +#endif /* CONFIG_ARCH_HAS_PKEYS */
>  	};
>  	size_t i;
>  
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ea818ff..01381d3 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -228,15 +228,16 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
>  #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
>  #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
>  
> -#if defined(CONFIG_X86)
> -# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
> -#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
> +#ifdef CONFIG_ARCH_HAS_PKEYS
>  # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
>  # define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
>  # define VM_PKEY_BIT1	VM_HIGH_ARCH_1
>  # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
>  # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
> -#endif
> +#endif /* CONFIG_ARCH_HAS_PKEYS */
> +
> +#if defined(CONFIG_X86)
> +# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
>  #elif defined(CONFIG_PPC)
>  # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
>  #elif defined(CONFIG_PARISC)
> -- 
> 1.7.1
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
