Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 40CF86B0007
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 08:34:24 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id c142so2296395wmh.4
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 05:34:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b203si11057582wmh.154.2018.01.31.05.34.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 Jan 2018 05:34:22 -0800 (PST)
Date: Wed, 31 Jan 2018 14:34:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v11 3/3] mm, x86: display pkey in smaps only if arch
 supports pkeys
Message-ID: <20180131133415.GV21609@dhcp22.suse.cz>
References: <1517341452-11924-1-git-send-email-linuxram@us.ibm.com>
 <1517341452-11924-4-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1517341452-11924-4-git-send-email-linuxram@us.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, mingo@redhat.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On Tue 30-01-18 11:44:12, Ram Pai wrote:
> Currently the  architecture  specific code is expected to
> display  the  protection  keys  in  smap  for a given vma.
> This can lead to redundant code and possibly to divergent
> formats in which the key gets displayed.
> 
> This  patch  changes  the implementation. It displays the
> pkey only if the architecture support pkeys, i.e
> arch_pkeys_enabled() returns true.  This patch
> provides x86 implementation for arch_pkeys_enabled().
> 
> x86 arch_show_smap() function is not needed anymore.
> Deleting it.

Thanks for reworking this patch. Looks good to me.

> Signed-off-by: Ram Pai <linuxram@us.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  arch/x86/include/asm/pkeys.h |    1 +
>  arch/x86/kernel/fpu/xstate.c |    5 +++++
>  arch/x86/kernel/setup.c      |    8 --------
>  fs/proc/task_mmu.c           |    9 ++++-----
>  include/linux/pkeys.h        |    6 ++++++
>  5 files changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/x86/include/asm/pkeys.h b/arch/x86/include/asm/pkeys.h
> index a0ba1ff..f6c287b 100644
> --- a/arch/x86/include/asm/pkeys.h
> +++ b/arch/x86/include/asm/pkeys.h
> @@ -6,6 +6,7 @@
>  
>  extern int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  		unsigned long init_val);
> +extern bool arch_pkeys_enabled(void);
>  
>  /*
>   * Try to dedicate one of the protection keys to be used as an
> diff --git a/arch/x86/kernel/fpu/xstate.c b/arch/x86/kernel/fpu/xstate.c
> index 87a57b7..4f566e9 100644
> --- a/arch/x86/kernel/fpu/xstate.c
> +++ b/arch/x86/kernel/fpu/xstate.c
> @@ -945,6 +945,11 @@ int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  
>  	return 0;
>  }
> +
> +bool arch_pkeys_enabled(void)
> +{
> +	return boot_cpu_has(X86_FEATURE_OSPKE);
> +}
>  #endif /* ! CONFIG_ARCH_HAS_PKEYS */
>  
>  /*
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 8af2e8d..ddf945a 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1326,11 +1326,3 @@ static int __init register_kernel_offset_dumper(void)
>  	return 0;
>  }
>  __initcall(register_kernel_offset_dumper);
> -
> -void arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> -{
> -	if (!boot_cpu_has(X86_FEATURE_OSPKE))
> -		return;
> -
> -	seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> -}
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 0edd4da..6f9fbde 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -18,6 +18,7 @@
>  #include <linux/page_idle.h>
>  #include <linux/shmem_fs.h>
>  #include <linux/uaccess.h>
> +#include <linux/pkeys.h>
>  
>  #include <asm/elf.h>
>  #include <asm/tlb.h>
> @@ -728,10 +729,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  }
>  #endif /* HUGETLB_PAGE */
>  
> -void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> -{
> -}
> -
>  static int show_smap(struct seq_file *m, void *v, int is_pid)
>  {
>  	struct proc_maps_private *priv = m->private;
> @@ -851,9 +848,11 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  			   (unsigned long)(mss->pss >> (10 + PSS_SHIFT)));
>  
>  	if (!rollup_mode) {
> -		arch_show_smap(m, vma);
> +		if (arch_pkeys_enabled())
> +			seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
>  		show_smap_vma_flags(m, vma);
>  	}
> +
>  	m_cache_vma(m, vma);
>  	return ret;
>  }
> diff --git a/include/linux/pkeys.h b/include/linux/pkeys.h
> index 0794ca7..dfdc609 100644
> --- a/include/linux/pkeys.h
> +++ b/include/linux/pkeys.h
> @@ -13,6 +13,7 @@
>  #define arch_override_mprotect_pkey(vma, prot, pkey) (0)
>  #define PKEY_DEDICATED_EXECUTE_ONLY 0
>  #define ARCH_VM_PKEY_FLAGS 0
> +#define vma_pkey(vma) 0
>  
>  static inline bool mm_pkey_is_allocated(struct mm_struct *mm, int pkey)
>  {
> @@ -35,6 +36,11 @@ static inline int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
>  	return 0;
>  }
>  
> +static inline bool arch_pkeys_enabled(void)
> +{
> +	return false;
> +}
> +
>  static inline void copy_init_pkru_to_fpregs(void)
>  {
>  }
> -- 
> 1.7.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
