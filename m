Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CDE96B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 01:16:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i83so2885116wma.4
        for <linux-mm@kvack.org>; Wed, 06 Dec 2017 22:16:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r19sor2251584wrg.23.2017.12.06.22.16.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 06 Dec 2017 22:16:27 -0800 (PST)
Date: Thu, 7 Dec 2017 07:16:24 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCHv4 1/4] x86/boot/compressed/64: Fix build with GCC < 5
Message-ID: <20171207061624.6sx3f67fmpzkrueh@gmail.com>
References: <20171205135942.24634-1-kirill.shutemov@linux.intel.com>
 <20171205135942.24634-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171205135942.24634-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> 0-day reported this build error:
> 
>    arch/x86/boot/compressed/pgtable_64.o: In function `l5_paging_required':
>    pgtable_64.c:(.text+0x22): undefined reference to `__force_order'
> 
> The issue is only with GCC < 5 and when KASLR is disabled. Newer GCC
> works fine.
> 
> __force_order is used by special_insns.h asm code to force instruction
> serialization.

s/is used by special_insns.h asm code
 /is used by the special_insns.h asm code

> It doesn't actually referenced from the code, but GCC < 5 with -fPIE
> would still generate undefined symbol.

s/It doesn't actually referenced from the code
 /It isn't actually referenced from the code

s/would still generate undefined symbol.
 /would still generate an undefined symbol.

> I didn't noticed this before and failed to move __force_order definition
> from pagetable.c (which compiles only with KASLR enabled) to
> pgtable_64.c.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 10c9a5346f72 ("x86/boot/compressed/64: Detect and handle 5-level paging at boot-time")
> Cc: stable@vger.kernel.org
> ---
>  arch/x86/boot/compressed/pagetable.c  |  3 ---
>  arch/x86/boot/compressed/pgtable_64.c | 11 +++++++++++
>  2 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
> index 6bd51de4475c..250826ac216e 100644
> --- a/arch/x86/boot/compressed/pagetable.c
> +++ b/arch/x86/boot/compressed/pagetable.c
> @@ -38,9 +38,6 @@
>  #define __PAGE_OFFSET __PAGE_OFFSET_BASE
>  #include "../../mm/ident_map.c"
>  
> -/* Used by pgtable.h asm code to force instruction serialization. */
> -unsigned long __force_order;
> -
>  /* Used to track our page table allocation area. */
>  struct alloc_pgt_data {
>  	unsigned char *pgt_buf;
> diff --git a/arch/x86/boot/compressed/pgtable_64.c b/arch/x86/boot/compressed/pgtable_64.c
> index 7bcf03b376da..491fa2d08bca 100644
> --- a/arch/x86/boot/compressed/pgtable_64.c
> +++ b/arch/x86/boot/compressed/pgtable_64.c
> @@ -1,5 +1,16 @@
>  #include <asm/processor.h>
>  
> +/*
> + * __force_order is used by special_insns.h asm code to force instruction
> + * serialization.

s/is used by special_insns.h asm code
 /is used by the special_insns.h asm code

> + *
> + * It doesn't actually referenced from the code, but GCC < 5 with -fPIE
> + * would still generate undefined symbol.

s/It doesn't actually referenced from the code
 /It isn't actually referenced from the code

s/would still generate undefined symbol.
 /would still generate an undefined symbol.

> + *
> + * Let's workaround this by defining the variable.

s/Let's workaround
 /Let's work around

Also, for the title:

s/Fix build with GCC < 5
 /Fix the build with GCC < 5

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
