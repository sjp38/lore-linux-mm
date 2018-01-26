Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 086916B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 21:48:49 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id v8so6241056oth.0
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 18:48:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c3si2840373oia.0.2018.01.25.18.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jan 2018 18:48:48 -0800 (PST)
Date: Fri, 26 Jan 2018 10:48:41 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180126024841.GA1759@localhost.localdomain>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180117052454.GA2321@localhost.localdomain>
 <20180125155043.nj5b26yxutds7f37@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180125155043.nj5b26yxutds7f37@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 01/25/18 at 06:50pm, Kirill A. Shutemov wrote:
> On Wed, Jan 17, 2018 at 01:24:54PM +0800, Baoquan He wrote:
> > Hi Kirill,
> > 
> > I setup qemu 2.9.0 to test 5-level on kexec/kdump support. While both
> > kexec and kdump reset to BIOS immediately after triggering. I saw your
> > patch adding 5-level paging support for kexec. Wonder if your test
> > succeeded to jump into kexec/kdump kernel, and what else I need to
> > make it. By the way, I just tested the latest upstream kernel.
> > 
> > commit 7f6890418 x86/kexec: Add 5-level paging support
> > 
> > [ ~]$ qemu-system-x86_64 --version
> > QEMU emulator version 2.9.0(qemu-2.9.0-1.fc26.1)
> > Copyright (c) 2003-2017 Fabrice Bellard and the QEMU Project developers
> 
> Sorry for delay.
> 
> I didn't tested it in 5-level paging mode :-/
> 
> The patch below helps in my case. Could you test it?

Thanks, Kirill. 

Seems it doesn't work. I have some confusion about the process, will
send you a private mail.

Thanks
Baoquan
> 
> diff --git a/arch/x86/kernel/relocate_kernel_64.S b/arch/x86/kernel/relocate_kernel_64.S
> index 307d3bac5f04..65a98cf2307d 100644
> --- a/arch/x86/kernel/relocate_kernel_64.S
> +++ b/arch/x86/kernel/relocate_kernel_64.S
> @@ -126,8 +126,12 @@ identity_mapped:
>         /*
>          * Set cr4 to a known state:
>          *  - physical address extension enabled
> +        *  - 5-level paging, if enabled
>          */
>         movl    $X86_CR4_PAE, %eax
> +#ifdef CONFIG_X86_5LEVEL
> +       orl     $X86_CR4_LA57, %eax
> +#endif
>         movq    %rax, %cr4
> 
>         jmp 1f
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
