Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id CE5366B0253
	for <linux-mm@kvack.org>; Sat, 12 Dec 2015 05:11:46 -0500 (EST)
Received: by wmnn186 with SMTP id n186so62431708wmn.0
        for <linux-mm@kvack.org>; Sat, 12 Dec 2015 02:11:46 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id y72si9145667wmd.20.2015.12.12.02.11.45
        for <linux-mm@kvack.org>;
        Sat, 12 Dec 2015 02:11:45 -0800 (PST)
Date: Sat, 12 Dec 2015 11:11:42 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151212101142.GA3867@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Thu, Dec 10, 2015 at 01:58:04PM -0800, Tony Luck wrote:
> Copy the existing page fault fixup mechanisms to create a new table
> to be used when fixing machine checks. Note:
> 1) At this time we only provide a macro to annotate assembly code
> 2) We assume all fixups will in code builtin to the kernel.
> 3) Only for x86_64
> 4) New code under CONFIG_MCE_KERNEL_RECOVERY
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  arch/x86/Kconfig                  |  4 ++++
>  arch/x86/include/asm/asm.h        | 10 ++++++++--
>  arch/x86/include/asm/uaccess.h    |  8 ++++++++
>  arch/x86/mm/extable.c             | 19 +++++++++++++++++++
>  include/asm-generic/vmlinux.lds.h |  6 ++++++
>  include/linux/module.h            |  1 +
>  kernel/extable.c                  | 20 ++++++++++++++++++++
>  7 files changed, 66 insertions(+), 2 deletions(-)
> 
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 96d058a87100..db5c6e1d6e37 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -1001,6 +1001,10 @@ config X86_MCE_INJECT
>  	  If you don't know what a machine check is and you don't do kernel
>  	  QA it is safe to say n.
>  
> +config MCE_KERNEL_RECOVERY
> +	depends on X86_MCE && X86_64
> +	def_bool y

Shouldn't that depend on NVDIMM or whatnot? Looks too generic now.

> +
>  config X86_THERMAL_VECTOR
>  	def_bool y
>  	depends on X86_MCE_INTEL
> diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
> index 189679aba703..a5d483ac11fa 100644
> --- a/arch/x86/include/asm/asm.h
> +++ b/arch/x86/include/asm/asm.h
> @@ -44,13 +44,19 @@
>  
>  /* Exception table entry */
>  #ifdef __ASSEMBLY__
> -# define _ASM_EXTABLE(from,to)					\
> -	.pushsection "__ex_table","a" ;				\
> +# define __ASM_EXTABLE(from, to, table)				\
> +	.pushsection table, "a" ;				\
>  	.balign 8 ;						\
>  	.long (from) - . ;					\
>  	.long (to) - . ;					\
>  	.popsection
>  
> +# define _ASM_EXTABLE(from, to)					\
> +	__ASM_EXTABLE(from, to, "__ex_table")
> +
> +# define _ASM_MCEXTABLE(from, to)				\
> +	__ASM_EXTABLE(from, to, "__mcex_table")
> +
>  # define _ASM_EXTABLE_EX(from,to)				\
>  	.pushsection "__ex_table","a" ;				\
>  	.balign 8 ;						\
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index a8df874f3e88..7b02ca1991b4 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -111,6 +111,14 @@ struct exception_table_entry {
>  #define ARCH_HAS_SEARCH_EXTABLE
>  
>  extern int fixup_exception(struct pt_regs *regs);
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +extern int fixup_mcexception(struct pt_regs *regs, u64 addr);
> +#else
> +static inline int fixup_mcexception(struct pt_regs *regs, u64 addr)
> +{
> +	return 0;
> +}
> +#endif
>  extern int early_fixup_exception(unsigned long *ip);

No need for "extern"

>  
>  /*
> diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
> index 903ec1e9c326..a461c4212758 100644
> --- a/arch/x86/mm/extable.c
> +++ b/arch/x86/mm/extable.c
> @@ -49,6 +49,25 @@ int fixup_exception(struct pt_regs *regs)
>  	return 0;
>  }
>  
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +int fixup_mcexception(struct pt_regs *regs, u64 addr)
> +{

If you move the #ifdef here, you can save yourself the ifdeffery in the
header above.

> +	const struct exception_table_entry *fixup;
> +	unsigned long new_ip;
> +
> +	fixup = search_mcexception_tables(regs->ip);
> +	if (fixup) {
> +		new_ip = ex_fixup_addr(fixup);
> +
> +		regs->ip = new_ip;
> +		regs->ax = BIT(63) | addr;
> +		return 1;
> +	}
> +
> +	return 0;
> +}
> +#endif
> +
>  /* Restricted version used during very early boot */
>  int __init early_fixup_exception(unsigned long *ip)
>  {
> diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
> index 1781e54ea6d3..21bb20d1172a 100644
> --- a/include/asm-generic/vmlinux.lds.h
> +++ b/include/asm-generic/vmlinux.lds.h
> @@ -473,6 +473,12 @@
>  		VMLINUX_SYMBOL(__start___ex_table) = .;			\
>  		*(__ex_table)						\
>  		VMLINUX_SYMBOL(__stop___ex_table) = .;			\
> +	}								\
> +	. = ALIGN(align);						\
> +	__mcex_table : AT(ADDR(__mcex_table) - LOAD_OFFSET) {		\
> +		VMLINUX_SYMBOL(__start___mcex_table) = .;		\
> +		*(__mcex_table)						\
> +		VMLINUX_SYMBOL(__stop___mcex_table) = .;		\

Of all the places, this one is missing #ifdef CONFIG_MCE_KERNEL_RECOVERY.

>  	}
>  
>  /*
> diff --git a/include/linux/module.h b/include/linux/module.h
> index 3a19c79918e0..ffecbfcc462c 100644
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -270,6 +270,7 @@ extern const typeof(name) __mod_##type##__##name##_device_table		\
>  
>  /* Given an address, look for it in the exception tables */
>  const struct exception_table_entry *search_exception_tables(unsigned long add);
> +const struct exception_table_entry *search_mcexception_tables(unsigned long a);
>  
>  struct notifier_block;
>  
> diff --git a/kernel/extable.c b/kernel/extable.c
> index e820ccee9846..7b224fbcb708 100644
> --- a/kernel/extable.c
> +++ b/kernel/extable.c
> @@ -34,6 +34,10 @@ DEFINE_MUTEX(text_mutex);
>  
>  extern struct exception_table_entry __start___ex_table[];
>  extern struct exception_table_entry __stop___ex_table[];
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +extern struct exception_table_entry __start___mcex_table[];
> +extern struct exception_table_entry __stop___mcex_table[];
> +#endif
>  
>  /* Cleared by build time tools if the table is already sorted. */
>  u32 __initdata __visible main_extable_sort_needed = 1;
> @@ -45,6 +49,10 @@ void __init sort_main_extable(void)
>  		pr_notice("Sorting __ex_table...\n");
>  		sort_extable(__start___ex_table, __stop___ex_table);
>  	}
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +	if (__stop___mcex_table > __start___mcex_table)
> +		sort_extable(__start___mcex_table, __stop___mcex_table);
> +#endif
>  }
>  
>  /* Given an address, look for it in the exception tables. */
> @@ -58,6 +66,18 @@ const struct exception_table_entry *search_exception_tables(unsigned long addr)
>  	return e;
>  }
>  
> +#ifdef CONFIG_MCE_KERNEL_RECOVERY
> +/* Given an address, look for it in the machine check exception tables. */
> +const struct exception_table_entry *search_mcexception_tables(
> +				    unsigned long addr)
> +{
> +	const struct exception_table_entry *e;
> +
> +	e = search_extable(__start___mcex_table, __stop___mcex_table-1, addr);
> +	return e;
> +}
> +#endif

You can make this one a bit more readable by doing:

/* Given an address, look for it in the machine check exception tables. */
const struct exception_table_entry *
search_mcexception_tables(unsigned long addr)
{
#ifdef CONFIG_MCE_KERNEL_RECOVERY
        return search_extable(__start___mcex_table,
                               __stop___mcex_table - 1, addr);
#endif
}

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
