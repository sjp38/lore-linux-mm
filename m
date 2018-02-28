Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC526B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 08:19:18 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id n12so1569338wmc.5
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 05:19:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c30sor1118066edf.3.2018.02.28.05.19.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Feb 2018 05:19:16 -0800 (PST)
Date: Wed, 28 Feb 2018 16:19:05 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 2/5] x86/boot/compressed/64: Find a place for 32-bit
 trampoline
Message-ID: <20180228131905.ypzjmaqg3zjke2ud@node.shutemov.name>
References: <20180227154217.69347-1-kirill.shutemov@linux.intel.com>
 <20180227154217.69347-3-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180227154217.69347-3-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 27, 2018 at 06:42:14PM +0300, Kirill A. Shutemov wrote:
> If a bootloader enables 64-bit mode with 4-level paging, we might need to
> switch over to 5-level paging. The switching requires the disabling of
> paging, which works fine if kernel itself is loaded below 4G.
> 
> But if the bootloader puts the kernel above 4G (not sure if anybody does
> this), we would lose control as soon as paging is disabled, because the
> code becomes unreachable to the CPU.
> 
> To handle the situation, we need a trampoline in lower memory that would
> take care of switching on 5-level paging.
> 
> This patch finds a spot in low memory for a trampoline.
> 
> The heuristic is based on code in reserve_bios_regions().
> 
> We find the end of low memory based on BIOS and EBDA start addresses.
> The trampoline is put just before end of low memory. It's mimic approach
> taken to allocate memory for realtime trampoline.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Borislav Petkov <bp@suse.de>
> ---
>  arch/x86/boot/compressed/misc.c       |  4 ++++
>  arch/x86/boot/compressed/pgtable.h    | 11 +++++++++++
>  arch/x86/boot/compressed/pgtable_64.c | 34 ++++++++++++++++++++++++++++++++++
>  3 files changed, 49 insertions(+)
>  create mode 100644 arch/x86/boot/compressed/pgtable.h
> 
> diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
> index b50c42455e25..e58409667b13 100644
> --- a/arch/x86/boot/compressed/misc.c
> +++ b/arch/x86/boot/compressed/misc.c
> @@ -14,6 +14,7 @@
>  
>  #include "misc.h"
>  #include "error.h"
> +#include "pgtable.h"
>  #include "../string.h"
>  #include "../voffset.h"
>  
> @@ -372,6 +373,9 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
>  	debug_putaddr(output_len);
>  	debug_putaddr(kernel_total_size);
>  
> +	/* Report address of 32-bit trampoline */
> +	debug_putaddr(trampoline_32bit);
> +
>  	/*
>  	 * The memory hole needed for the kernel is the larger of either
>  	 * the entire decompressed kernel plus relocation table, or the

0-day found problem with the patch on 32-bit config.

Here's fixup:

diff --git a/arch/x86/boot/compressed/misc.c b/arch/x86/boot/compressed/misc.c
index e58409667b13..8e4b55dd5df9 100644
--- a/arch/x86/boot/compressed/misc.c
+++ b/arch/x86/boot/compressed/misc.c
@@ -373,8 +373,10 @@ asmlinkage __visible void *extract_kernel(void *rmode, memptr heap,
 	debug_putaddr(output_len);
 	debug_putaddr(kernel_total_size);
 
+#ifdef CONFIG_X86_64
 	/* Report address of 32-bit trampoline */
 	debug_putaddr(trampoline_32bit);
+#endif
 
 	/*
 	 * The memory hole needed for the kernel is the larger of either
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
