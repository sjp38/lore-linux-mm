Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B7FB3280278
	for <linux-mm@kvack.org>; Fri, 10 Nov 2017 04:12:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y42so4544019wrd.23
        for <linux-mm@kvack.org>; Fri, 10 Nov 2017 01:12:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w79sor3511103wrb.38.2017.11.10.01.12.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 Nov 2017 01:12:39 -0800 (PST)
Date: Fri, 10 Nov 2017 10:12:36 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 1/4] x86/boot/compressed/64: Compile pagetable.c
 unconditionally
Message-ID: <20171110091236.7o2vvmrty7eahziu@gmail.com>
References: <20171101115503.18358-1-kirill.shutemov@linux.intel.com>
 <20171101115503.18358-2-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171101115503.18358-2-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


* Kirill A. Shutemov <kirill.shutemov@linux.intel.com> wrote:

> We are going to put few helpers into pagetable.c that are not specific
> to KASLR.
> 
> Let's make compilation of the file independent of KASLR and wrap
> KASLR-depended code into ifdef.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> ---
>  arch/x86/boot/compressed/Makefile    | 2 +-
>  arch/x86/boot/compressed/pagetable.c | 5 +++++
>  2 files changed, 6 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/x86/boot/compressed/Makefile b/arch/x86/boot/compressed/Makefile
> index 65a150a7f15c..f7b64ecd09b3 100644
> --- a/arch/x86/boot/compressed/Makefile
> +++ b/arch/x86/boot/compressed/Makefile
> @@ -77,7 +77,7 @@ vmlinux-objs-y := $(obj)/vmlinux.lds $(obj)/head_$(BITS).o $(obj)/misc.o \
>  vmlinux-objs-$(CONFIG_EARLY_PRINTK) += $(obj)/early_serial_console.o
>  vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/kaslr.o
>  ifdef CONFIG_X86_64
> -	vmlinux-objs-$(CONFIG_RANDOMIZE_BASE) += $(obj)/pagetable.o
> +	vmlinux-objs-y += $(obj)/pagetable.o
>  endif
>  
>  $(obj)/eboot.o: KBUILD_CFLAGS += -fshort-wchar -mno-red-zone
> diff --git a/arch/x86/boot/compressed/pagetable.c b/arch/x86/boot/compressed/pagetable.c
> index f1aa43854bed..a15bbfcb3413 100644
> --- a/arch/x86/boot/compressed/pagetable.c
> +++ b/arch/x86/boot/compressed/pagetable.c
> @@ -27,6 +27,9 @@
>  /* These actually do the work of building the kernel identity maps. */
>  #include <asm/init.h>
>  #include <asm/pgtable.h>
> +
> +#ifdef CONFIG_RANDOMIZE_BASE
> +
>  /* Use the static base for this part of the boot process */
>  #undef __PAGE_OFFSET
>  #define __PAGE_OFFSET __PAGE_OFFSET_BASE
> @@ -149,3 +152,5 @@ void finalize_identity_maps(void)
>  {
>  	write_cr3(top_level_pgt);
>  }
> +
> +#endif /* CONFIG_RANDOMIZE_BASE */

The #ifdeffery becomes really ugly in this file. I think we should split these 
into separate .c files:

  arch/x86/boot/compressed/kaslr.c
  arch/x86/boot/compressed/5-level-paging.c

With core data structures and code and a well defined interface:

  arch/x86/boot/compressed/pagetable.c
  arch/x86/boot/compressed/pagetable.h

or so.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
