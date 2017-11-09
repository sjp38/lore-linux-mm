Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id B4CC1440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:38:15 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id 5so3764520wmk.1
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:38:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h36sor3771256eda.12.2017.11.09.02.38.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 Nov 2017 02:38:14 -0800 (PST)
Date: Thu, 9 Nov 2017 13:38:12 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] x86/mm: Fix ELF_ET_DYN_BASE for 5-level paging
Message-ID: <20171109103812.tr3o5ujwokg5s6c6@node.shutemov.name>
References: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Nicholas Piggin <npiggin@gmail.com>

On Tue, Nov 07, 2017 at 01:38:04PM +0300, Kirill A. Shutemov wrote:
> On machines with 5-level paging we don't want to allocate mapping above
> 47-bit unless user explicitly asked for it. See b569bab78d8d ("x86/mm:
> Prepare to expose larger address space to userspace") for details.
> 
> c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base
> changes") broke the behaviour. After the commit elf binary and heap got
> mapped above 47-bits.
> 
> Let's fix this.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: c715b72c1ba4 ("mm: revert x86_64 and arm64 ELF_ET_DYN_BASE base changes")
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: "H. Peter Anvin" <hpa@zytor.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Nicholas Piggin <npiggin@gmail.com>

Folks, can we please get this applied?

Without the change on 5-level paging machine we will have elf binary and
heap mapped above 47-bit by default. This may lead to userspace brakage.

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
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
