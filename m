Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 4BAD56B0031
	for <linux-mm@kvack.org>; Mon, 23 Jun 2014 15:49:11 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so6254902pad.37
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 12:49:11 -0700 (PDT)
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
        by mx.google.com with ESMTPS id ba10si23317382pbd.48.2014.06.23.12.49.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Jun 2014 12:49:10 -0700 (PDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so6065611pde.31
        for <linux-mm@kvack.org>; Mon, 23 Jun 2014 12:49:09 -0700 (PDT)
From: Andy Lutomirski <luto@amacapital.net>
Message-ID: <53A884B2.5070702@mit.edu>
Date: Mon, 23 Jun 2014 12:49:06 -0700
MIME-Version: 1.0
Subject: Re: [PATCH v6 02/10] x86, mpx: add MPX specific mmap interface
References: <1403084656-27284-1-git-send-email-qiaowei.ren@intel.com> <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com>
In-Reply-To: <1403084656-27284-3-git-send-email-qiaowei.ren@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Qiaowei Ren <qiaowei.ren@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Dave Hansen <dave.hansen@intel.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On 06/18/2014 02:44 AM, Qiaowei Ren wrote:
> This patch adds one MPX specific mmap interface, which only handles
> mpx related maps, including bounds table and bounds directory.
> 
> In order to track MPX specific memory usage, this interface is added
> to stick new vm_flag VM_MPX in the vma_area_struct when create a
> bounds table or bounds directory.

I imagine the linux-mm people would want to think about any new vm flag.
 Why is this needed?

> 
> Signed-off-by: Qiaowei Ren <qiaowei.ren@intel.com>
> ---
>  arch/x86/Kconfig           |    4 +++
>  arch/x86/include/asm/mpx.h |   38 ++++++++++++++++++++++++++++
>  arch/x86/mm/Makefile       |    2 +
>  arch/x86/mm/mpx.c          |   58 ++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 102 insertions(+), 0 deletions(-)
>  create mode 100644 arch/x86/include/asm/mpx.h
>  create mode 100644 arch/x86/mm/mpx.c
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 25d2c6f..0194790 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -237,6 +237,10 @@ config HAVE_INTEL_TXT
>  	def_bool y
>  	depends on INTEL_IOMMU && ACPI
>  
> +config X86_INTEL_MPX
> +	def_bool y
> +	depends on CPU_SUP_INTEL
> +
>  config X86_32_SMP
>  	def_bool y
>  	depends on X86_32 && SMP
> diff --git a/arch/x86/include/asm/mpx.h b/arch/x86/include/asm/mpx.h
> new file mode 100644
> index 0000000..5725ac4
> --- /dev/null
> +++ b/arch/x86/include/asm/mpx.h
> @@ -0,0 +1,38 @@
> +#ifndef _ASM_X86_MPX_H
> +#define _ASM_X86_MPX_H
> +
> +#include <linux/types.h>
> +#include <asm/ptrace.h>
> +
> +#ifdef CONFIG_X86_64
> +
> +/* upper 28 bits [47:20] of the virtual address in 64-bit used to
> + * index into bounds directory (BD).
> + */
> +#define MPX_BD_ENTRY_OFFSET	28
> +#define MPX_BD_ENTRY_SHIFT	3
> +/* bits [19:3] of the virtual address in 64-bit used to index into
> + * bounds table (BT).
> + */
> +#define MPX_BT_ENTRY_OFFSET	17
> +#define MPX_BT_ENTRY_SHIFT	5
> +#define MPX_IGN_BITS		3
> +
> +#else
> +
> +#define MPX_BD_ENTRY_OFFSET	20
> +#define MPX_BD_ENTRY_SHIFT	2
> +#define MPX_BT_ENTRY_OFFSET	10
> +#define MPX_BT_ENTRY_SHIFT	4
> +#define MPX_IGN_BITS		2
> +
> +#endif
> +
> +#define MPX_BD_SIZE_BYTES (1UL<<(MPX_BD_ENTRY_OFFSET+MPX_BD_ENTRY_SHIFT))
> +#define MPX_BT_SIZE_BYTES (1UL<<(MPX_BT_ENTRY_OFFSET+MPX_BT_ENTRY_SHIFT))
> +
> +#define MPX_BNDSTA_ERROR_CODE	0x3
> +
> +unsigned long mpx_mmap(unsigned long len);
> +
> +#endif /* _ASM_X86_MPX_H */
> diff --git a/arch/x86/mm/Makefile b/arch/x86/mm/Makefile
> index 6a19ad9..ecfdc46 100644
> --- a/arch/x86/mm/Makefile
> +++ b/arch/x86/mm/Makefile
> @@ -30,3 +30,5 @@ obj-$(CONFIG_ACPI_NUMA)		+= srat.o
>  obj-$(CONFIG_NUMA_EMU)		+= numa_emulation.o
>  
>  obj-$(CONFIG_MEMTEST)		+= memtest.o
> +
> +obj-$(CONFIG_X86_INTEL_MPX)	+= mpx.o
> diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
> new file mode 100644
> index 0000000..546c5d1
> --- /dev/null
> +++ b/arch/x86/mm/mpx.c
> @@ -0,0 +1,58 @@
> +#include <linux/kernel.h>
> +#include <linux/syscalls.h>
> +#include <asm/mpx.h>
> +#include <asm/mman.h>
> +#include <linux/sched/sysctl.h>
> +
> +/*
> + * this is really a simplified "vm_mmap". it only handles mpx
> + * related maps, including bounds table and bounds directory.
> + *
> + * here we can stick new vm_flag VM_MPX in the vma_area_struct
> + * when create a bounds table or bounds directory, in order to
> + * track MPX specific memory.
> + */
> +unsigned long mpx_mmap(unsigned long len)
> +{
> +	unsigned long ret;
> +	unsigned long addr, pgoff;
> +	struct mm_struct *mm = current->mm;
> +	vm_flags_t vm_flags;
> +
> +	/* Only bounds table and bounds directory can be allocated here */
> +	if (len != MPX_BD_SIZE_BYTES && len != MPX_BT_SIZE_BYTES)
> +		return -EINVAL;
> +
> +	down_write(&mm->mmap_sem);
> +
> +	/* Too many mappings? */
> +	if (mm->map_count > sysctl_max_map_count) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	/* Obtain the address to map to. we verify (or select) it and ensure
> +	 * that it represents a valid section of the address space.
> +	 */
> +	addr = get_unmapped_area(NULL, 0, len, 0, MAP_ANONYMOUS | MAP_PRIVATE);
> +	if (addr & ~PAGE_MASK) {
> +		ret = addr;
> +		goto out;
> +	}
> +
> +	vm_flags = VM_READ | VM_WRITE | VM_MPX |
> +			mm->def_flags | VM_MAYREAD | VM_MAYWRITE | VM_MAYEXEC;
> +
> +	/* Make bounds tables and bouds directory unlocked. */
> +	if (vm_flags & VM_LOCKED)
> +		vm_flags &= ~VM_LOCKED;

Why?  I would expect MCL_FUTURE to lock these.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
