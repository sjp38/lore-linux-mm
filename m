Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6ABCD800D8
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:37:26 -0500 (EST)
Received: by mail-qt0-f197.google.com with SMTP id z37so18547202qtz.16
        for <linux-mm@kvack.org>; Mon, 22 Jan 2018 22:37:26 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y4si156443qtk.193.2018.01.22.22.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Jan 2018 22:37:25 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w0N6alw1049085
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:37:24 -0500
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fnyqxge18-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 01:37:24 -0500
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Tue, 23 Jan 2018 06:37:20 -0000
Date: Mon, 22 Jan 2018 22:37:03 -0800
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH v10 01/27] mm, powerpc, x86: define VM_PKEY_BITx bits if
 CONFIG_ARCH_HAS_PKEYS is enabled
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1516326648-22775-1-git-send-email-linuxram@us.ibm.com>
 <1516326648-22775-2-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1516326648-22775-2-git-send-email-linuxram@us.ibm.com>
Message-Id: <20180123063703.GA5661@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, mpe@ellerman.id.au, mingo@redhat.com, corbet@lwn.net, arnd@arndb.de

Andrew,

	Please apply the following two patches to your tree.

[PATCH v10 01/27] mm, powerpc, x86: define VM_PKEY_BITx bits if CONFIG_ARCH_HAS_PKEYS is enabled
[PATCH v10 02/27] mm, powerpc, x86: introduce an additional vma bit for powerpc pkey

	I have not heard any complaints on these changes. 
	Dave Hansen had comments/suggestions in the initial revisions, which have been incorporated.

	Michael Ellermen has accepted the rest of the powerpc related patches in this series.

Thanks,
RP




On Thu, Jan 18, 2018 at 05:50:22PM -0800, Ram Pai wrote:
> VM_PKEY_BITx are defined only if CONFIG_X86_INTEL_MEMORY_PROTECTION_KEYS
> is enabled. Powerpc also needs these bits. Hence lets define the
> VM_PKEY_BITx bits for any architecture that enables
> CONFIG_ARCH_HAS_PKEYS.
> 
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
> see: https://urldefense.proofpoint.com/v2/url?u=http-3A__www.linux-2Dmm.org_&d=DwIBAg&c=jf_iaSHvJObTbx-siA1ZOg&r=m-UrKChQVkZtnPpjbF6YY99NbT8FBByQ-E-ygV8luxw&m=PsCrC-HVeq8M98fNireZs4GUBJvMwNZme7wZ1YdjMqs&s=V90akzFmL1g-sNEcgmcUn_XJgJ8EaYmmsAS3AcVYScw&e= .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Ram Pai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
