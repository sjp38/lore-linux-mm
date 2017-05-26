Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D45F86B0292
	for <linux-mm@kvack.org>; Fri, 26 May 2017 18:11:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u96so2262204wrc.7
        for <linux-mm@kvack.org>; Fri, 26 May 2017 15:11:03 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id q81si2332878wrb.280.2017.05.26.15.11.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 May 2017 15:11:02 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id b84so6127011wmh.0
        for <linux-mm@kvack.org>; Fri, 26 May 2017 15:11:02 -0700 (PDT)
Date: Sat, 27 May 2017 01:10:59 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: KASAN vs. boot-time switching between 4- and 5-level paging
Message-ID: <20170526221059.o4kyt3ijdweurz6j@node.shutemov.name>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
 <20170525203334.867-8-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170525203334.867-8-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, May 25, 2017 at 11:33:33PM +0300, Kirill A. Shutemov wrote:
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index 0bf81e837cbf..c795207d8a3c 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -100,7 +100,7 @@ config X86
>  	select HAVE_ARCH_AUDITSYSCALL
>  	select HAVE_ARCH_HUGE_VMAP		if X86_64 || X86_PAE
>  	select HAVE_ARCH_JUMP_LABEL
> -	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP
> +	select HAVE_ARCH_KASAN			if X86_64 && SPARSEMEM_VMEMMAP && !X86_5LEVEL
>  	select HAVE_ARCH_KGDB
>  	select HAVE_ARCH_KMEMCHECK
>  	select HAVE_ARCH_MMAP_RND_BITS		if MMU

Looks like KASAN will be a problem for boot-time paging mode switching.
It wants to know CONFIG_KASAN_SHADOW_OFFSET at compile-time to pass to
gcc -fasan-shadow-offset=. But this value varies between paging modes...

I don't see how to solve it. Folks, any ideas?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
