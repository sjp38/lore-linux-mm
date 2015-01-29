Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id A01A76B006C
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 18:12:26 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so44291173pab.11
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 15:12:26 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id yc6si9047668pbc.16.2015.01.29.15.12.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jan 2015 15:12:25 -0800 (PST)
Date: Thu, 29 Jan 2015 15:12:24 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v10 02/17] x86_64: add KASan support
Message-Id: <20150129151224.4e7947af78605c199763102c@linux-foundation.org>
In-Reply-To: <1422544321-24232-3-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
	<1422544321-24232-3-git-send-email-a.ryabinin@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Jonathan Corbet <corbet@lwn.net>, Andy Lutomirski <luto@amacapital.net>, "open
 list:DOCUMENTATION" <linux-doc@vger.kernel.org>

On Thu, 29 Jan 2015 18:11:46 +0300 Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> This patch adds arch specific code for kernel address sanitizer.
> 
> 16TB of virtual addressed used for shadow memory.
> It's located in range [ffffec0000000000 - fffffc0000000000]
> between vmemmap and %esp fixup stacks.
> 
> At early stage we map whole shadow region with zero page.
> Latter, after pages mapped to direct mapping address range
> we unmap zero pages from corresponding shadow (see kasan_map_shadow())
> and allocate and map a real shadow memory reusing vmemmap_populate()
> function.
> 
> Also replace __pa with __pa_nodebug before shadow initialized.
> __pa with CONFIG_DEBUG_VIRTUAL=y make external function call (__phys_addr)
> __phys_addr is instrumented, so __asan_load could be called before
> shadow area initialized.
> 
> ...
>
> --- a/lib/Kconfig.kasan
> +++ b/lib/Kconfig.kasan
> @@ -5,6 +5,7 @@ if HAVE_ARCH_KASAN
>  
>  config KASAN
>  	bool "AddressSanitizer: runtime memory debugger"
> +	depends on !MEMORY_HOTPLUG
>  	help
>  	  Enables address sanitizer - runtime memory debugger,
>  	  designed to find out-of-bounds accesses and use-after-free bugs.

That's a significant restriction.  It has obvious runtime implications.
It also means that `make allmodconfig' and `make allyesconfig' don't
enable kasan, so compile coverage will be impacted.

This wasn't changelogged.  What's the reasoning and what has to be done
to fix it?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
