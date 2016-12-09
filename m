From: Borislav Petkov <bp@alien8.de>
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
Date: Fri, 9 Dec 2016 17:33:28 +0100
Message-ID: <20161209163328.wixkda7fqm5rye5h@pd.tnic>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <20161209153233.GA8932@node.shutemov.name>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-arch-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161209153233.GA8932@node.shutemov.name>
Sender: linux-arch-owner@vger.kernel.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Fri, Dec 09, 2016 at 06:32:33PM +0300, Kirill A. Shutemov wrote:
> Something like this?
> 
> diff --git a/arch/x86/boot/cpuflags.c b/arch/x86/boot/cpuflags.c
> index 6687ab953257..366aad972025 100644
> --- a/arch/x86/boot/cpuflags.c
> +++ b/arch/x86/boot/cpuflags.c
> @@ -70,16 +70,22 @@ int has_eflag(unsigned long mask)
>  # define EBX_REG "=b"
>  #endif
> 
> -static inline void cpuid(u32 id, u32 *a, u32 *b, u32 *c, u32 *d)
> +static inline void cpuid_count(u32 id, u32 count,
> +               u32 *a, u32 *b, u32 *c, u32 *d)
>  {
> +       *a = id;
> +       *c = count;
> +
>         asm volatile(".ifnc %%ebx,%3 ; movl  %%ebx,%3 ; .endif  \n\t"
>                      "cpuid                                     \n\t"
>                      ".ifnc %%ebx,%3 ; xchgl %%ebx,%3 ; .endif  \n\t"
>                     : "=a" (*a), "=c" (*c), "=d" (*d), EBX_REG (*b)
> -                   : "a" (id)
> +                   : "a" (id), "c" (count)
>         );
>  }
> 
> +#define cpuid(id, a, b, c, d) cpuid_count(id, 0, a, b, c, d)

LGTM.

Thanks.

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.
