Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5F06B0253
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 17:50:53 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id e9so4041759pgc.5
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 14:50:53 -0800 (PST)
Received: from mail.zytor.com (torg.zytor.com. [2001:1868:205::12])
        by mx.google.com with ESMTPS id 1si49592890pgy.294.2016.12.13.14.50.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 14:50:52 -0800 (PST)
Subject: Re: [RFC, PATCHv1 15/28] x86: detect 5-level paging support
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
 <20161208162150.148763-17-kirill.shutemov@linux.intel.com>
 <20161208200505.c6xiy56oufg6d24m@pd.tnic>
 <20161209153233.GA8932@node.shutemov.name>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <6bfc923e-baa6-7743-8da8-57d1ddf0f390@zytor.com>
Date: Tue, 13 Dec 2016 14:50:21 -0800
MIME-Version: 1.0
In-Reply-To: <20161209153233.GA8932@node.shutemov.name>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Borislav Petkov <bp@alien8.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/09/16 07:32, Kirill A. Shutemov wrote:
> 
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

These two lines are wrong, remove them.

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
> +

Other than that, it's correct.

That being said, the claim that ECX ought to be zeroed on a
non-subleaf-equipped CPUID leaf is spurious, in my opinion.  That being
said, it also doesn't do any harm and might avoid problems in the
opposite direction, e.g. someone thinking that leaf 7 doesn't have
subleaves.

It might also be better to have something like:

#define SAVE_EBX(x) ".ifnc %%ebx," x "; movl %%ebx," x "; .endif"
#define SWAP_EBX(x) ".ifnc %%ebx," x "; xchgl %%ebx," x "; .endif"

... but if it is only used once it might just be more confusion.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
