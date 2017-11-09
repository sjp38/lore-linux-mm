Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 20563440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 10:38:55 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u97so3410410wrc.3
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 07:38:55 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n8si5661834edi.99.2017.11.09.07.38.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 07:38:53 -0800 (PST)
Date: Thu, 9 Nov 2017 16:38:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] x86/mm: Fix ELF_ET_DYN_BASE for 5-level paging
Message-ID: <20171109153851.xvgmfnbkoxj64jm6@dhcp22.suse.cz>
References: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171107103804.47341-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Nicholas Piggin <npiggin@gmail.com>

On Tue 07-11-17 13:38:04, Kirill A. Shutemov wrote:
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

FWIW
Acked-by: Michal Hocko <mhocko@suse.com>

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

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
