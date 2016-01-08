From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Date: Fri, 8 Jan 2016 11:41:20 +0100
Message-ID: <20160108104120.GD12132@pd.tnic>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
 <20160107121131.GB23768@pd.tnic>
 <20160108053028.GA1833@agluck-desk.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160108053028.GA1833@agluck-desk.sc.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>
List-Id: linux-mm.kvack.org

On Thu, Jan 07, 2016 at 09:30:29PM -0800, Luck, Tony wrote:
> Also need some comment and Documentation/ changes:
> 
> 
> diff --git a/Documentation/x86/exception-tables.txt b/Documentation/x86/exception-tables.txt
> index 32901aa36f0a..ae47b9f64b8a 100644
> --- a/Documentation/x86/exception-tables.txt
> +++ b/Documentation/x86/exception-tables.txt
> @@ -290,3 +290,37 @@ Due to the way that the exception table is built and needs to be ordered,
>  only use exceptions for code in the .text section.  Any other section
>  will cause the exception table to not be sorted correctly, and the
>  exceptions will fail.
> +
> +Things changed when 64-bit support was added to x86 Linux. Rather than
> +double the size of the exception table by expanding the two entries
> +from 32-bits to 64 bits, a clever trick was used to store addreesses
> +as relative offsets from the table itself. The assembly code changed
> +from:
> +	.long 1b,3b
> +to:
> +        .long (from) - .
> +        .long (to) - .
> +and the C-code that uses these values converts back to absolute addresses
> +like this:
> +	ex_insn_addr(const struct exception_table_entry *x)
> +	{
> +		return (unsigned long)&x->insn + x->insn;
> +	}
> +
> +In v4.5 the exception table entry was given a new field "handler".
> +This is also 32-bits wide and contains a table entry relative address
> +of a handler function that can perform specific operations in addition
> +to re-writing the instruction pointer to jump to the fixup location.
> +Initially there are three such functions:
> +
> +1) int ex_handler_default(const struct exception_table_entry *fixup,
> +   This is legacy case that just jumps to the fixup code
> +2) int ex_handler_fault(const struct exception_table_entry *fixup,
> +   This case provides the fault number of the trap that occured at
> +   entry->insn. It is used to distinguish page faults from machine
> +   check.
> +3) int ex_handler_ext(const struct exception_table_entry *fixup,
> +   This case is used to for uaccess_err ... we need to set a flag
> +   in the task structure. Before the handler functions existed this
> +   case was handled by adding a large offset to the fixup to tag
> +   it as special.
> diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
> index b8f6f7545679..563443870915 100644
> --- a/arch/x86/include/asm/uaccess.h
> +++ b/arch/x86/include/asm/uaccess.h
> @@ -90,12 +90,12 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
>  	likely(!__range_not_ok(addr, size, user_addr_max()))
>  
>  /*
> - * The exception table consists of pairs of addresses relative to the
> + * The exception table consists of triples of addresses relative to the
>   * exception table enty itself: the first is the address of an
> - * instruction that is allowed to fault, and the second is the address
> - * at which the program should continue.  No registers are modified,
> - * so it is entirely up to the continuation code to figure out what to
> - * do.
> + * instruction that is allowed to fault, the second is the address
> + * at which the program should continue, the last is the address of
> + * a handler function to deal with the fault referenced by the instruction
> + * in the first field.
>   *
>   * All the routines below use bits of fixup code that are out of line
>   * with the main instruction path.  This means when everything is well,

Looks good. /me always likes patches adding more sensible documentation:

Acked-by: Borislav Petkov <bp@suse.de>

> diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
> index f057718d8d15..195ff0144152 100644
> --- a/arch/x86/lib/memcpy_64.S
> +++ b/arch/x86/lib/memcpy_64.S
> @@ -310,4 +310,3 @@ ENTRY(__mcsafe_copy)
>  	_ASM_EXTABLE_FAULT(12b,38b)
>  	_ASM_EXTABLE_FAULT(18b,39b)
>  	_ASM_EXTABLE_FAULT(21b,40b)
> -#endif

This looks like a stray change.

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
