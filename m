Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id C17ED828F6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 16:11:44 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id 128so184448537wmz.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 13:11:44 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id m8si15324914wmb.66.2016.02.03.13.11.43
        for <linux-mm@kvack.org>;
        Wed, 03 Feb 2016 13:11:43 -0800 (PST)
Date: Wed, 3 Feb 2016 22:11:38 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v9 1/4] x86: Expand exception table to allow new handling
 options
Message-ID: <20160203211137.GC20682@pd.tnic>
References: <cover.1454455138.git.tony.luck@intel.com>
 <c825688875c358f6f39a295a02091452b666947d.1454455138.git.tony.luck@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c825688875c358f6f39a295a02091452b666947d.1454455138.git.tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Luck <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Fri, Jan 08, 2016 at 12:49:38PM -0800, Tony Luck wrote:
> Huge amounts of help from  Andy Lutomirski and Borislav Petkov to
> produce this. Andy provided the inspiration to add classes to the
> exception table with a clever bit-squeezing trick, Boris pointed
> out how much cleaner it would all be if we just had a new field.
> 
> Linus Torvalds blessed the expansion with:
>   I'd rather not be clever in order to save just a tiny amount of space
>   in the exception table, which isn't really criticial for anybody.
> 
> The third field is another relative function pointer, this one to a
> handler that executes the actions.
> 
> We start out with three handlers:
> 
> 1: Legacy - just jumps the to fixup IP
> 2: Fault - provide the trap number in %ax to the fixup code
> 3: Cleaned up legacy for the uaccess error hack
> 
> Signed-off-by: Tony Luck <tony.luck@intel.com>
> ---
>  Documentation/x86/exception-tables.txt |  33 +++++++++++
>  arch/x86/include/asm/asm.h             |  40 +++++++------
>  arch/x86/include/asm/uaccess.h         |  16 +++---
>  arch/x86/kernel/kprobes/core.c         |   2 +-
>  arch/x86/kernel/traps.c                |   6 +-
>  arch/x86/mm/extable.c                  | 100 ++++++++++++++++++++++++---------
>  arch/x86/mm/fault.c                    |   2 +-
>  scripts/sortextable.c                  |  32 +++++++++++
>  8 files changed, 174 insertions(+), 57 deletions(-)
> 
> diff --git a/Documentation/x86/exception-tables.txt b/Documentation/x86/exception-tables.txt
> index 32901aa36f0a..d4ca5f8b22ff 100644
> --- a/Documentation/x86/exception-tables.txt
> +++ b/Documentation/x86/exception-tables.txt
> @@ -290,3 +290,36 @@ Due to the way that the exception table is built and needs to be ordered,
>  only use exceptions for code in the .text section.  Any other section
>  will cause the exception table to not be sorted correctly, and the
>  exceptions will fail.
> +
> +Things changed when 64-bit support was added to x86 Linux. Rather than
> +double the size of the exception table by expanding the two entries
> +from 32-bits to 64 bits, a clever trick was used to store addreesses

s/addreesses/addresses/

> +as relative offsets from the table itself. The assembly code changed
> +from:
> +	.long 1b,3b
> +to:
> +        .long (from) - .
> +        .long (to) - .

\n here

> +and the C-code that uses these values converts back to absolute addresses
> +like this:

<-- and here

> +	ex_insn_addr(const struct exception_table_entry *x)
> +	{
> +		return (unsigned long)&x->insn + x->insn;
> +	}
> +
> +In v4.5 the exception table entry was given a new field "handler".
> +This is also 32-bits wide and contains a third relative function
> +pointer which points to one of:
> +
> +1) int ex_handler_default(const struct exception_table_entry *fixup,
									^
					closing brace ------------------|


> +   This is legacy case that just jumps to the fixup code
> +2) int ex_handler_fault(const struct exception_table_entry *fixup,

Ditto.

> +   This case provides the fault number of the trap that occurred at
> +   entry->insn. It is used to distinguish page faults from machine
> +   check.
> +3) int ex_handler_ext(const struct exception_table_entry *fixup,

Ditto.

> +   This case is used to for uaccess_err ... we need to set a flag

s/to //

> +   in the task structure. Before the handler functions existed this
> +   case was handled by adding a large offset to the fixup to tag
> +   it as special.
> +More functions can easily be added.
> diff --git a/arch/x86/include/asm/asm.h b/arch/x86/include/asm/asm.h
> index 189679aba703..f5063b6659eb 100644
> --- a/arch/x86/include/asm/asm.h
> +++ b/arch/x86/include/asm/asm.h
> @@ -44,19 +44,22 @@
>  
>  /* Exception table entry */
>  #ifdef __ASSEMBLY__
> -# define _ASM_EXTABLE(from,to)					\
> +# define _ASM_EXTABLE_HANDLE(from, to, handler)			\
>  	.pushsection "__ex_table","a" ;				\
> -	.balign 8 ;						\
> +	.balign 4 ;						\
>  	.long (from) - . ;					\
>  	.long (to) - . ;					\
> +	.long (handler) - . ;					\
>  	.popsection
>  
> -# define _ASM_EXTABLE_EX(from,to)				\
> -	.pushsection "__ex_table","a" ;				\
> -	.balign 8 ;						\
> -	.long (from) - . ;					\
> -	.long (to) - . + 0x7ffffff0 ;				\
> -	.popsection
> +# define _ASM_EXTABLE(from, to)					\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_default)
> +
> +# define _ASM_EXTABLE_FAULT(from, to)				\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_fault)
> +
> +# define _ASM_EXTABLE_EX(from, to)				\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_ext)
>  
>  # define _ASM_NOKPROBE(entry)					\
>  	.pushsection "_kprobe_blacklist","aw" ;			\
> @@ -89,19 +92,24 @@
>  	.endm
>  
>  #else
> -# define _ASM_EXTABLE(from,to)					\
> +# define _EXPAND_EXTABLE_HANDLE(x) #x
> +# define _ASM_EXTABLE_HANDLE(from, to, handler)			\
>  	" .pushsection \"__ex_table\",\"a\"\n"			\
> -	" .balign 8\n"						\
> +	" .balign 4\n"						\
>  	" .long (" #from ") - .\n"				\
>  	" .long (" #to ") - .\n"				\
> +	" .long (" _EXPAND_EXTABLE_HANDLE(handler) ") - .\n"	\
>  	" .popsection\n"
>  
> -# define _ASM_EXTABLE_EX(from,to)				\
> -	" .pushsection \"__ex_table\",\"a\"\n"			\
> -	" .balign 8\n"						\
> -	" .long (" #from ") - .\n"				\
> -	" .long (" #to ") - . + 0x7ffffff0\n"			\
> -	" .popsection\n"
> +# define _ASM_EXTABLE(from, to)					\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_default)
> +
> +# define _ASM_EXTABLE_FAULT(from, to)				\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_fault)
> +
> +# define _ASM_EXTABLE_EX(from, to)				\
> +	_ASM_EXTABLE_HANDLE(from, to, ex_handler_ext)
> +
>  /* For C file, we already have NOKPROBE_SYMBOL macro */
>  #endif
>  
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index a4a30e4b2d34..cbcc3b3e034c 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -90,12 +90,11 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
>  	likely(!__range_not_ok(addr, size, user_addr_max()))
>  
>  /*
> - * The exception table consists of pairs of addresses relative to the
> - * exception table enty itself: the first is the address of an
> - * instruction that is allowed to fault, and the second is the address
> - * at which the program should continue.  No registers are modified,
> - * so it is entirely up to the continuation code to figure out what to
> - * do.
> + * The exception table consists of triples of addresses relative to the
> + * exception table enty itself. The first address is of an instruction

s/enty/entry/

> + * that is allowed to fault, the second is the target at which the program
> + * should continue. The third is a handler function to deal with the fault
> + * referenced by the instruction in the first field.a

s/referenced/caused/ i better, methinks. And the "a" at the end can go - I do
those too, btw. Lemme guess: vim user?

:-)

The rest looks good.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
