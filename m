Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7398028027D
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 00:25:03 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id f62so4437700otf.3
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 21:25:03 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w50si1779474otw.58.2018.01.16.21.25.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jan 2018 21:25:02 -0800 (PST)
Date: Wed, 17 Jan 2018 13:24:54 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180117052454.GA2321@localhost.localdomain>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Kirill,

I setup qemu 2.9.0 to test 5-level on kexec/kdump support. While both
kexec and kdump reset to BIOS immediately after triggering. I saw your
patch adding 5-level paging support for kexec. Wonder if your test
succeeded to jump into kexec/kdump kernel, and what else I need to
make it. By the way, I just tested the latest upstream kernel.

commit 7f6890418 x86/kexec: Add 5-level paging support

[ ~]$ qemu-system-x86_64 --version
QEMU emulator version 2.9.0(qemu-2.9.0-1.fc26.1)
Copyright (c) 2003-2017 Fabrice Bellard and the QEMU Project developers

Thanks
Baoquan

On 01/09/18 at 03:13am, Kirill A. Shutemov wrote:
> On Mon, Jan 08, 2018 at 08:46:53PM +0300, Kirill A. Shutemov wrote:
> > On Mon, Jan 08, 2018 at 04:04:44PM +0000, Ingo Molnar wrote:
> > > 
> > > hi Kirill,
> > > 
> > > As Mike reported it below, your 5-level paging related upstream commit 
> > > 83e3c48729d9 and all its followup fixes:
> > > 
> > >  83e3c48729d9: mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y
> > >  629a359bdb0e: mm/sparsemem: Fix ARM64 boot crash when CONFIG_SPARSEMEM_EXTREME=y
> > >  d09cfbbfa0f7: mm/sparse.c: wrong allocation for mem_section
> > > 
> > > ... still breaks kexec - and that now regresses -stable as well.
> > > 
> > > Given that 5-level paging now syntactically depends on having this commit, if we 
> > > fully revert this then we'll have to disable 5-level paging as well.
> 
> This *should* help.
> 
> Mike, could you test this? (On top of the rest of the fixes.)
> 
> Sorry for the mess.
> 
> From 100fd567754f1457be94732046aefca204c842d2 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 9 Jan 2018 02:55:47 +0300
> Subject: [PATCH] kdump: Write a correct address of mem_section into vmcoreinfo
> 
> Depending on configuration mem_section can now be an array or a pointer
> to an array allocated dynamically. In most cases, we can continue to refer
> to it as 'mem_section' regardless of what it is.
> 
> But there's one exception: '&mem_section' means "address of the array" if
> mem_section is an array, but if mem_section is a pointer, it would mean
> "address of the pointer".
> 
> We've stepped onto this in kdump code. VMCOREINFO_SYMBOL(mem_section)
> writes down address of pointer into vmcoreinfo, not array as we wanted.
> 
> Let's introduce VMCOREINFO_ARRAY() that would handle the situation
> correctly for both cases.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: 83e3c48729d9 ("mm/sparsemem: Allocate mem_section at runtime for CONFIG_SPARSEMEM_EXTREME=y")
> ---
>  include/linux/crash_core.h | 2 ++
>  kernel/crash_core.c        | 2 +-
>  2 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/crash_core.h b/include/linux/crash_core.h
> index 06097ef30449..83ae04950269 100644
> --- a/include/linux/crash_core.h
> +++ b/include/linux/crash_core.h
> @@ -42,6 +42,8 @@ phys_addr_t paddr_vmcoreinfo_note(void);
>  	vmcoreinfo_append_str("PAGESIZE=%ld\n", value)
>  #define VMCOREINFO_SYMBOL(name) \
>  	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)&name)
> +#define VMCOREINFO_ARRAY(name) \
> +	vmcoreinfo_append_str("SYMBOL(%s)=%lx\n", #name, (unsigned long)name)
>  #define VMCOREINFO_SIZE(name) \
>  	vmcoreinfo_append_str("SIZE(%s)=%lu\n", #name, \
>  			      (unsigned long)sizeof(name))
> diff --git a/kernel/crash_core.c b/kernel/crash_core.c
> index b3663896278e..d4122a837477 100644
> --- a/kernel/crash_core.c
> +++ b/kernel/crash_core.c
> @@ -410,7 +410,7 @@ static int __init crash_save_vmcoreinfo_init(void)
>  	VMCOREINFO_SYMBOL(contig_page_data);
>  #endif
>  #ifdef CONFIG_SPARSEMEM
> -	VMCOREINFO_SYMBOL(mem_section);
> +	VMCOREINFO_ARRAY(mem_section);
>  	VMCOREINFO_LENGTH(mem_section, NR_SECTION_ROOTS);
>  	VMCOREINFO_STRUCT_SIZE(mem_section);
>  	VMCOREINFO_OFFSET(mem_section, section_mem_map);
> -- 
>  Kirill A. Shutemov
> 
> _______________________________________________
> kexec mailing list
> kexec@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/kexec

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
