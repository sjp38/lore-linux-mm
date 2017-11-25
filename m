Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3AFCE6B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 20:23:11 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 4so23708095pge.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 17:23:11 -0800 (PST)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com. [207.171.190.10])
        by mx.google.com with ESMTPS id b3si19227461pgr.683.2017.11.24.17.23.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Nov 2017 17:23:10 -0800 (PST)
Date: Fri, 24 Nov 2017 17:23:02 -0800
From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: [PATCH 20/23] x86, kaiser: add a function to check for KAISER
 being enabled
Message-ID: <20171125012302.GD2017@u40b0340c692b58f6553c.ant.amazon.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <20171123003518.B7D81B14@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171123003518.B7D81B14@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, aliguori@amazon.com

On Wed, Nov 22, 2017 at 04:35:18PM -0800, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Currently, all of the checks for KAISER are compile-time checks.
> 
> Runtime checks are needed for turning it on/off at runtime.
> 
> Add a function to do that.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
> Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
> Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
> Cc: Richard Fellner <richard.fellner@student.tugraz.at>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Kees Cook <keescook@google.com>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: x86@kernel.org
> ---
> 
>  b/arch/x86/include/asm/kaiser.h |    5 +++++
>  b/include/linux/kaiser.h        |    5 +++++
>  2 files changed, 10 insertions(+)
> 
> diff -puN arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func arch/x86/include/asm/kaiser.h
> --- a/arch/x86/include/asm/kaiser.h~kaiser-dynamic-check-func	2017-11-22 15:45:55.262619723 -0800
> +++ b/arch/x86/include/asm/kaiser.h	2017-11-22 15:45:55.267619723 -0800
> @@ -56,6 +56,11 @@ extern void kaiser_remove_mapping(unsign
>   */
>  extern void kaiser_init(void);
>  
> +static inline bool kaiser_active(void)
> +{
> +	extern int kaiser_enabled;

Should this really be extern ? 

I am getting a compilation error while linking the bzImage with this series:
arch/x86/boot/compressed/pagetable.o: In function `kernel_ident_mapping_init':
pagetable.c:(.text+0x336): undefined reference to `kaiser_enabled'
arch/x86/boot/compressed/Makefile:109: recipe for target 'arch/x86/boot/compressed/vmlinux' failed
make[2]: *** [arch/x86/boot/compressed/vmlinux] Error 1
arch/x86/boot/Makefile:112: recipe for target 'arch/x86/boot/compressed/vmlinux' failed
make[1]: *** [arch/x86/boot/compressed/vmlinux] Error 2
arch/x86/Makefile:296: recipe for target 'bzImage' failed
make: *** [bzImage] Error 2

What I did was to remove the extern and  EXPORT_SYMBOL(kaiser_enabled) and initialize kaiser_enabled as 0, after that I got a proper bzImage.

> +	return kaiser_enabled;
> +}
>  #endif
>  
>  #endif /* __ASSEMBLY__ */
> diff -puN include/linux/kaiser.h~kaiser-dynamic-check-func include/linux/kaiser.h
> --- a/include/linux/kaiser.h~kaiser-dynamic-check-func	2017-11-22 15:45:55.264619723 -0800
> +++ b/include/linux/kaiser.h	2017-11-22 15:45:55.268619723 -0800
> @@ -28,5 +28,10 @@ static inline int kaiser_add_mapping(uns
>  static inline void kaiser_add_mapping_cpu_entry(int cpu)
>  {
>  }
> +
> +static inline bool kaiser_active(void)
> +{
> +	return 0;
> +}
>  #endif /* !CONFIG_KAISER */
>  #endif /* _INCLUDE_KAISER_H */
> _
> 

-- 
All the best,
Eduardo Valentin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
