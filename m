Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 846F36B0003
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 12:35:17 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id q63so206314590pfb.0
        for <linux-mm@kvack.org>; Wed, 06 Jan 2016 09:35:17 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id x69si27054409pfi.0.2016.01.06.09.35.16
        for <linux-mm@kvack.org>;
        Wed, 06 Jan 2016 09:35:16 -0800 (PST)
Date: Wed, 6 Jan 2016 09:35:15 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Message-ID: <20160106173515.GA25980@agluck-desk.sc.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160106123346.GC19507@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, torvalds@linuxfoundation.org, hpa@zytor.com, mingo@kernel.org, tglx@linutronix.de
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Wed, Jan 06, 2016 at 01:33:46PM +0100, Borislav Petkov wrote:
> On Wed, Dec 30, 2015 at 09:59:29AM -0800, Tony Luck wrote:
> > Starting with a patch from Andy Lutomirski <luto@amacapital.net>
> > that used linker relocation trickery to free up a couple of bits
> > in the "fixup" field of the exception table (and generalized the
> > uaccess_err hack to use one of the classes).
> 
> So I still think that the other idea Andy gave with putting the handler
> in the exception table is much cleaner and straightforward.
> 
> Here's a totally untested patch which at least builds here. I think this
> approach is much more extensible and simpler for the price of a couple
> of KBs of __ex_table size.

On my config (based on an enterprise distro config) the vmlinux
ex_table would grow from 8k to 12k.  There are a handful of modules
that would also see 50% expansion (the size is the first hex field after
the __ex_table):

arch/x86/kernel/test_nx.ko 4 __ex_table 00000008 0000000000000000 0000000000000000 000002a8 2**3
arch/x86/kvm/kvm-intel.ko 7 __ex_table 000009b8 0000000000000000 0000000000000000 0001ff60 2**3
arch/x86/kvm/kvm-amd.ko 6 __ex_table 00000070 0000000000000000 0000000000000000 0000a1e0 2**3
arch/x86/kvm/kvm.ko 23 __ex_table 00000080 0000000000000000 0000000000000000 00059940 2**3
drivers/char/ipmi/ipmi_devintf.ko 9 __ex_table 00000098 0000000000000000 0000000000000000 000017f0 2**3
drivers/gpu/drm/i915/i915.ko 20 __ex_table 00000060 0000000000000000 0000000000000000 000f8f10 2**3
drivers/gpu/drm/radeon/radeon.ko 19 __ex_table 000001d0 0000000000000000 0000000000000000 00145c88 2**3
drivers/gpu/drm/drm.ko 24 __ex_table 00000400 0000000000000000 0000000000000000 0003b688 2**3
drivers/media/usb/uvc/uvcvideo.ko 15 __ex_table 00000030 0000000000000000 0000000000000000 0000f100 2**3
drivers/scsi/sg.ko 12 __ex_table 00000060 0000000000000000 0000000000000000 00006548 2**3
drivers/vhost/vhost.ko 12 __ex_table 00000068 0000000000000000 0000000000000000 00003360 2**3
drivers/xen/xen-privcmd.ko 11 __ex_table 00000010 0000000000000000 0000000000000000 00000f70 2**3
net/sunrpc/sunrpc.ko 24 __ex_table 00000008 0000000000000000 0000000000000000 000321b0 2**3
sound/core/snd-pcm.ko 19 __ex_table 00000040 0000000000000000 0000000000000000 000108f0 2**3

Linus, Peter, Ingo, Thomas: Can we head this direction? The code is cleaner
and more flexible. Or should we stick with Andy's clever way to squeeze a
couple of "class" bits into the fixup field of the exception table?

-Tony

> 
> ---
> diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
> index 189679aba703..43b509c88b13 100644
> --- a/arch/x86/include/asm/asm.h
> +++ b/arch/x86/include/asm/asm.h
> @@ -44,18 +44,20 @@
>  
>  /* Exception table entry */
>  #ifdef __ASSEMBLY__
> -# define _ASM_EXTABLE(from,to)					\
> +# define _ASM_EXTABLE(from,to)				\
>  	.pushsection "__ex_table","a" ;				\
>  	.balign 8 ;						\
>  	.long (from) - . ;					\
>  	.long (to) - . ;					\
> +	.long 0 - .;						\
>  	.popsection
>  
>  # define _ASM_EXTABLE_EX(from,to)				\
>  	.pushsection "__ex_table","a" ;				\
>  	.balign 8 ;						\
>  	.long (from) - . ;					\
> -	.long (to) - . + 0x7ffffff0 ;				\
> +	.long (to) - . ;					\
> +	.long ex_handler_ext - . ;				\
>  	.popsection
>  
>  # define _ASM_NOKPROBE(entry)					\
> @@ -94,13 +96,14 @@
>  	" .balign 8\n"						\
>  	" .long (" #from ") - .\n"				\
>  	" .long (" #to ") - .\n"				\
> +	" .long 0 - .\n"					\
>  	" .popsection\n"
>  
>  # define _ASM_EXTABLE_EX(from,to)				\
>  	" .pushsection \"__ex_table\",\"a\"\n"			\
>  	" .balign 8\n"						\
>  	" .long (" #from ") - .\n"				\
> -	" .long (" #to ") - . + 0x7ffffff0\n"			\
> +	" .long ex_handler_ext - .\n"				\
>  	" .popsection\n"
>  /* For C file, we already have NOKPROBE_SYMBOL macro */
>  #endif
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index 09b1b0ab94b7..22b49c3b311a 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -104,13 +104,13 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
>   */
>  
>  struct exception_table_entry {
> -	int insn, fixup;
> +	int insn, fixup, handler;
>  };
>  /* This is not the generic standard exception_table_entry format */
>  #define ARCH_HAS_SORT_EXTABLE
>  #define ARCH_HAS_SEARCH_EXTABLE
>  
> -extern int fixup_exception(struct pt_regs *regs);
> +extern int fixup_exception(struct pt_regs *regs, int trapnr);
>  extern int early_fixup_exception(unsigned long *ip);
>  
>  /*
> diff --git a/arch/x86/kernel/kprobes/core.c b/arch/x86/kernel/kprobes/core.c
> index 1deffe6cc873..0f05deeff5ce 100644
> --- a/arch/x86/kernel/kprobes/core.c
> +++ b/arch/x86/kernel/kprobes/core.c
> @@ -988,7 +988,7 @@ int kprobe_fault_handler(struct pt_regs *regs, int trapnr)
>  		 * In case the user-specified fault handler returned
>  		 * zero, try to fix up.
>  		 */
> -		if (fixup_exception(regs))
> +		if (fixup_exception(regs, trapnr))
>  			return 1;
>  
>  		/*
> diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
> index ade185a46b1d..211c11c7bba4 100644
> --- a/arch/x86/kernel/traps.c
> +++ b/arch/x86/kernel/traps.c
> @@ -199,7 +199,7 @@ do_trap_no_signal(struct task_struct *tsk, int trapnr, char *str,
>  	}
>  
>  	if (!user_mode(regs)) {
> -		if (!fixup_exception(regs)) {
> +		if (!fixup_exception(regs, trapnr)) {
>  			tsk->thread.error_code = error_code;
>  			tsk->thread.trap_nr = trapnr;
>  			die(str, regs, error_code);
> @@ -453,7 +453,7 @@ do_general_protection(struct pt_regs *regs, long error_code)
>  
>  	tsk = current;
>  	if (!user_mode(regs)) {
> -		if (fixup_exception(regs))
> +		if (fixup_exception(regs, X86_TRAP_GP))
>  			return;
>  
>  		tsk->thread.error_code = error_code;
> @@ -699,7 +699,7 @@ static void math_error(struct pt_regs *regs, int error_code, int trapnr)
>  	conditional_sti(regs);
>  
>  	if (!user_mode(regs)) {
> -		if (!fixup_exception(regs)) {
> +		if (!fixup_exception(regs, trapnr)) {
>  			task->thread.error_code = error_code;
>  			task->thread.trap_nr = trapnr;
>  			die(str, regs, error_code);
> diff --git a/arch/x86/mm/extable.c b/arch/x86/mm/extable.c
> index 903ec1e9c326..191f4b7d1d2d 100644
> --- a/arch/x86/mm/extable.c
> +++ b/arch/x86/mm/extable.c
> @@ -3,6 +3,8 @@
>  #include <linux/sort.h>
>  #include <asm/uaccess.h>
>  
> +typedef int (*ex_handler_t)(const struct exception_table_entry *, struct pt_regs *, int);
> +
>  static inline unsigned long
>  ex_insn_addr(const struct exception_table_entry *x)
>  {
> @@ -14,10 +16,39 @@ ex_fixup_addr(const struct exception_table_entry *x)
>  	return (unsigned long)&x->fixup + x->fixup;
>  }
>  
> -int fixup_exception(struct pt_regs *regs)
> +inline ex_handler_t ex_fixup_handler(const struct exception_table_entry *x)
> +{
> +	return (ex_handler_t)&x->handler + x->handler;
> +}
> +
> +int ex_handler_default(const struct exception_table_entry *fixup,
> +		       struct pt_regs *regs, int trapnr)
> +{
> +	regs->ip = ex_fixup_addr(fixup);
> +	return 1;
> +}
> +
> +int ex_handler_fault(const struct exception_table_entry *fixup,
> +		     struct pt_regs *regs, int trapnr)
> +{
> +	regs->ip = ex_fixup_addr(fixup);
> +	regs->ax = trapnr;
> +	return 1;
> +}
> +int ex_handler_ext(const struct exception_table_entry *fixup,
> +		   struct pt_regs *regs, int trapnr)
>  {
> -	const struct exception_table_entry *fixup;
> +	/* Special hack for uaccess_err */
> +	current_thread_info()->uaccess_err = 1;
> +	regs->ip = ex_fixup_addr(fixup);
> +	return 1;
> +}
> +
> +int fixup_exception(struct pt_regs *regs, int trapnr)
> +{
> +	const struct exception_table_entry *e;
>  	unsigned long new_ip;
> +	ex_handler_t handler;
>  
>  #ifdef CONFIG_PNPBIOS
>  	if (unlikely(SEGMENT_IS_PNP_CODE(regs->cs))) {
> @@ -33,42 +64,40 @@ int fixup_exception(struct pt_regs *regs)
>  	}
>  #endif
>  
> -	fixup = search_exception_tables(regs->ip);
> -	if (fixup) {
> -		new_ip = ex_fixup_addr(fixup);
> -
> -		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
> -			/* Special hack for uaccess_err */
> -			current_thread_info()->uaccess_err = 1;
> -			new_ip -= 0x7ffffff0;
> -		}
> -		regs->ip = new_ip;
> -		return 1;
> -	}
> +	e = search_exception_tables(regs->ip);
> +	if (!e)
> +		return 0;
> +
> +	new_ip  = ex_fixup_addr(e);
> +	handler = ex_fixup_handler(e);
> +
> +	if (!handler)
> +		handler = ex_handler_default;
> +
> +	return handler(e, regs, trapnr);
>  
> -	return 0;
>  }
>  
>  /* Restricted version used during very early boot */
>  int __init early_fixup_exception(unsigned long *ip)
>  {
> -	const struct exception_table_entry *fixup;
> +	const struct exception_table_entry *e;
>  	unsigned long new_ip;
> +	ex_handler_t handler;
>  
> -	fixup = search_exception_tables(*ip);
> -	if (fixup) {
> -		new_ip = ex_fixup_addr(fixup);
> +	e = search_exception_tables(*ip);
> +	if (!e)
> +		return 0;
>  
> -		if (fixup->fixup - fixup->insn >= 0x7ffffff0 - 4) {
> -			/* uaccess handling not supported during early boot */
> -			return 0;
> -		}
> +	new_ip  = ex_fixup_addr(e);
> +	handler = ex_fixup_handler(e);
>  
> -		*ip = new_ip;
> -		return 1;
> -	}
> +	/* uaccess handling not supported during early boot */
> +	if (handler && handler == ex_handler_ext)
> +		return 0;
>  
> -	return 0;
> +	*ip = new_ip;
> +	return 1;
>  }
>  
>  /*
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index eef44d9a3f77..495946c3f9dd 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -656,7 +656,7 @@ no_context(struct pt_regs *regs, unsigned long error_code,
>  	int sig;
>  
>  	/* Are we prepared to handle this kernel fault? */
> -	if (fixup_exception(regs)) {
> +	if (fixup_exception(regs, X86_TRAP_PF)) {
>  		/*
>  		 * Any interrupt that takes a fault gets the fixup. This makes
>  		 * the below recursive fault logic only apply to a faults from
> 
> -- 
> Regards/Gruss,
>     Boris.
> 
> ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
