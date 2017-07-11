Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 80DCD6810B5
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 14:11:55 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id z10so5366pff.1
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 11:11:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id x7si435168plm.234.2017.07.11.11.11.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 11:11:54 -0700 (PDT)
Subject: Re: [RFC v5 11/38] mm: introduce an additional vma bit for powerpc
 pkey
References: <1499289735-14220-1-git-send-email-linuxram@us.ibm.com>
 <1499289735-14220-12-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <290636b0-aafd-9bcd-d309-4cff41ce923c@intel.com>
Date: Tue, 11 Jul 2017 11:10:46 -0700
MIME-Version: 1.0
In-Reply-To: <1499289735-14220-12-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On 07/05/2017 02:21 PM, Ram Pai wrote:
> Currently there are only 4bits in the vma flags to support 16 keys
> on x86.  powerpc supports 32 keys, which needs 5bits. This patch
> introduces an addition bit in the vma flags.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  fs/proc/task_mmu.c |    6 +++++-
>  include/linux/mm.h |   18 +++++++++++++-----
>  2 files changed, 18 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index f0c8b33..2ddc298 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -666,12 +666,16 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
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
> +#endif /* CONFIG_ARCH_HAS_PKEYS */
> +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> +		/* Additional bit in ProtectionKey: */
> +		[ilog2(VM_PKEY_BIT4)]	= "",
>  #endif

I'd probably just leave the #ifdef out and eat the byte or whatever of
storage that this costs us on x86.

>  	};
>  	size_t i;
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 7cb17c6..3d35bcc 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -208,21 +208,29 @@ extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
>  #define VM_HIGH_ARCH_BIT_1	33	/* bit only usable on 64-bit architectures */
>  #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
>  #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
> +#define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit arch */

Please just copy the above lines.

>  #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
>  #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
>  #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
>  #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
> +#define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
>  #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
>  
> -#if defined(CONFIG_X86)
> -# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
> -#if defined (CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS)
> +#ifdef CONFIG_ARCH_HAS_PKEYS
>  # define VM_PKEY_SHIFT	VM_HIGH_ARCH_BIT_0
> -# define VM_PKEY_BIT0	VM_HIGH_ARCH_0	/* A protection key is a 4-bit value */
> +# define VM_PKEY_BIT0	VM_HIGH_ARCH_0
>  # define VM_PKEY_BIT1	VM_HIGH_ARCH_1
>  # define VM_PKEY_BIT2	VM_HIGH_ARCH_2
>  # define VM_PKEY_BIT3	VM_HIGH_ARCH_3
> -#endif
> +#endif /* CONFIG_ARCH_HAS_PKEYS */

We have the space here, so can we just say that it's 4-bits on x86 and 5
on ppc?

> +#if defined(CONFIG_PPC64_MEMORY_PROTECTION_KEYS)
> +# define VM_PKEY_BIT4	VM_HIGH_ARCH_4 /* additional key bit used on ppc64 */
> +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */

Why bother #ifdef'ing a #define?

> +#if defined(CONFIG_X86)
> +# define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
>  #elif defined(CONFIG_PPC)
>  # define VM_SAO		VM_ARCH_1	/* Strong Access Ordering (powerpc) */
>  #elif defined(CONFIG_PARISC)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
