From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2 1/3] x86/mm: Add INVPCID helpers
Date: Fri, 29 Jan 2016 12:19:37 +0100
Message-ID: <20160129111937.GB10187@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org>
 <f0bdec49dc0e2c7ec745408e0478bed5f6789f20.1453746505.git.luto@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f0bdec49dc0e2c7ec745408e0478bed5f6789f20.1453746505.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andy Lutomirski <luto@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>
List-Id: linux-mm.kvack.org

On Mon, Jan 25, 2016 at 10:37:42AM -0800, Andy Lutomirski wrote:
> This adds helpers for each of the four currently-specified INVPCID
> modes.
> 
> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> ---
>  arch/x86/include/asm/tlbflush.h | 41 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 41 insertions(+)
> 
> diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
> index 6df2029405a3..20fc38d8478a 100644
> --- a/arch/x86/include/asm/tlbflush.h
> +++ b/arch/x86/include/asm/tlbflush.h
> @@ -7,6 +7,47 @@
>  #include <asm/processor.h>
>  #include <asm/special_insns.h>
>  
> +static inline void __invpcid(unsigned long pcid, unsigned long addr,
> +			     unsigned long type)
> +{
> +	u64 desc[2] = { pcid, addr };
> +
> +	/*
> +	 * The memory clobber is because the whole point is to invalidate
> +	 * stale TLB entries and, especially if we're flushing global
> +	 * mappings, we don't want the compiler to reorder any subsequent
> +	 * memory accesses before the TLB flush.
> +	 */
> +	asm volatile (

Yeah, no need for that linebreak here:

	asm volatile (".byte 0x66, 0x0f, 0x38, 0x82, 0x01"

reads fine too.

> +		".byte 0x66, 0x0f, 0x38, 0x82, 0x01"	/* invpcid (%cx), %ax */
> +		: : "m" (desc), "a" (type), "c" (desc) : "memory");
> +}
> +

Please add defines for the invalidation types:

#define INVPCID_TYPE_INDIVIDUAL         0
#define INVPCID_TYPE_SINGLE_CTXT        1
#define INVPCID_TYPE_ALL                2
#define INVPCID_TYPE_ALL_NON_GLOBAL     3

and add macros:

#define invpcid_flush_one(pcid, addr)	__invpcid(pcid, addr, INVPCID_TYPE_INDIVIDUAL)
...

and so on.

Oh, and the "flush everything" macro I'd call invpcid_flush_all() like
tlb_flush_all().

Thanks.

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
