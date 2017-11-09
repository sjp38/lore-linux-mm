Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 907CE440D03
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 12:12:57 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id k100so3559493wrc.9
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 09:12:57 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id c127si5681034wme.156.2017.11.09.09.12.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 09:12:56 -0800 (PST)
Date: Thu, 9 Nov 2017 18:12:47 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] x86/mm: Fix ELF_ET_DYN_BASE for 5-level paging
In-Reply-To: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
Message-ID: <alpine.DEB.2.20.1711091812210.1839@nanos>
References: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Nicholas Piggin <npiggin@gmail.com>

On Tue, 7 Nov 2017, Kirill A. Shutemov wrote:

> On machines with 5-level paging we don't want to allocate mapping above
> 47-bit unless user explicitly asked for it. See b569bab78d8d ("x86/mm:
> Prepare to expose larger address space to userspace") for details.
> 
> c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base
> changes") broke the behaviour. After the commit elf binary and heap got
> mapped above 47-bits.
> 
> Let's fix this.

That's a really useless sentence.....

> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> ---
>  arch/x86/include/asm/elf.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/x86/include/asm/elf.h b/arch/x86/include/asm/elf.h
> index c1a125e47ff3..3a091cea36c5 100644
> --- a/arch/x86/include/asm/elf.h
> +++ b/arch/x86/include/asm/elf.h
> @@ -253,7 +253,7 @@ extern int force_personality32;
>   * space open for things that want to use the area for 32-bit pointers.
>   */
>  #define ELF_ET_DYN_BASE		(mmap_is_ia32() ? 0x000400000UL : \
> -						  (TASK_SIZE / 3 * 2))
> +						  (DEFAULT_MAP_WINDOW / 3 * 2))
>  
>  /* This yields a mask that user programs can use to figure out what
>     instruction set this CPU supports.  This could be done in user space,
> -- 
> 2.14.2
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
