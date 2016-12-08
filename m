From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Thu, 8 Dec 2016 21:05:05 +0100
Message-ID: <20161208200505.c6xiy56oufg6d24m@pd.tnic>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
Sender: linux-arch-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, Dec 08, 2016 at 07:21:37PM +0300, Kirill A. Shutemov wrote:
> 5-level paging support is required from hardware when compiled with
> CONFIG_X86_5LEVEL=y. We may implement runtime switch support later.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

...

> diff --git a/arch/x86/boot/cpuflags.c b/arch/x86/boot/cpuflags.c
> index 6687ab953257..26e9a287805f 100644
> --- a/arch/x86/boot/cpuflags.c
> +++ b/arch/x86/boot/cpuflags.c
> @@ -80,6 +80,17 @@ static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
>  	);
>  }
>  
> +static inline void cpuid_count(u32 id, u32 count,
> +		u32 *a, u32 *b, u32 *c, u32 *d)
> +{
> +	asm volatile(".ifnc %%ebx,%3 ; movl  %%ebx,%3 ; .endif	\n\t"
> +		     "cpuid					\n\t"
> +		     ".ifnc %%ebx,%3 ; xchgl %%ebx,%3 ; .endif	\n\t"
> +		    : "=a" (*a), "=c" (*c), "=d" (*d), EBX_REG (*b)
> +		    : "a" (id), "c" (count)
> +	);
> +}

Pls make those like cpuid() and cpuid_count() in
arch/x86/include/asm/processor.h, which explicitly assign ecx and then
call the underlying helper.

The cpuid() in cpuflags.c doesn't zero ecx which, if we have to be
pedantic, it should do. It calls CPUID now with the ptr value of its 4th
on 64-bit and 3rd arg on 32-bit, respectively, IINM.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
