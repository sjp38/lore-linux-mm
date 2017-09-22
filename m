Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BBCAB6B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 02:03:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 6so406186pgh.0
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 23:03:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g2sor1617715plt.28.2017.09.21.23.03.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 21 Sep 2017 23:03:00 -0700 (PDT)
Date: Fri, 22 Sep 2017 16:02:49 +1000
From: Balbir Singh <bsingharora@gmail.com>
Subject: Re: [PATCH 3/6] mm: display pkey in smaps if arch_pkeys_enabled()
 is true
Message-ID: <20170922160249.73b36922@firefly.ozlabs.ibm.com>
In-Reply-To: <1505524870-4783-4-git-send-email-linuxram@us.ibm.com>
References: <1505524870-4783-1-git-send-email-linuxram@us.ibm.com>
	<1505524870-4783-4-git-send-email-linuxram@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com

On Fri, 15 Sep 2017 18:21:07 -0700
Ram Pai <linuxram@us.ibm.com> wrote:

> Currently the  architecture  specific code is expected to
> display  the  protection  keys  in  smap  for a given vma.
> This can lead to redundant code and possibly to divergent
> formats in which the key gets displayed.
> 
> This  patch  changes  the implementation. It displays the
> pkey only if the architecture support pkeys.
> 
> x86 arch_show_smap() function is not needed anymore.
> Delete it.
> 
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/x86/kernel/setup.c |    8 --------
>  fs/proc/task_mmu.c      |   11 ++++++-----
>  2 files changed, 6 insertions(+), 13 deletions(-)
> 
> diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
> index 3486d04..1953bce 100644
> --- a/arch/x86/kernel/setup.c
> +++ b/arch/x86/kernel/setup.c
> @@ -1340,11 +1340,3 @@ static int __init register_kernel_offset_dumper(void)
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
> index cf25306..667d44a 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -16,6 +16,7 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/page_idle.h>
>  #include <linux/shmem_fs.h>
> +#include <linux/pkeys.h>
>  
>  #include <asm/elf.h>
>  #include <linux/uaccess.h>
> @@ -714,10 +715,6 @@ static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
>  }
>  #endif /* HUGETLB_PAGE */
>  
> -void __weak arch_show_smap(struct seq_file *m, struct vm_area_struct *vma)
> -{
> -}
> -
>  static int show_smap(struct seq_file *m, void *v, int is_pid)
>  {
>  	struct vm_area_struct *vma = v;
> @@ -803,7 +800,11 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
>  		   (vma->vm_flags & VM_LOCKED) ?
>  			(unsigned long)(mss.pss >> (10 + PSS_SHIFT)) : 0);
>  
> -	arch_show_smap(m, vma);
> +#ifdef CONFIG_ARCH_HAS_PKEYS
> +	if (arch_pkeys_enabled())
> +		seq_printf(m, "ProtectionKey:  %8u\n", vma_pkey(vma));
> +#endif

Can CONFIG_ARCH_HAS_PKEYS be true, but the kernel compiled without
support for them or it's just not enabled? I think the
earlier per_arch function was better

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
