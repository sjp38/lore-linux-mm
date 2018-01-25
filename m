Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 925BB6B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 10:50:48 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id c14so4056094wrd.2
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 07:50:48 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n15sor1680149edl.54.2018.01.25.07.50.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 25 Jan 2018 07:50:47 -0800 (PST)
Date: Thu, 25 Jan 2018 18:50:44 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 4.14 023/159] mm/sparsemem: Allocate mem_section at
 runtime for CONFIG_SPARSEMEM_EXTREME=y
Message-ID: <20180125155043.nj5b26yxutds7f37@node.shutemov.name>
References: <20171222084623.668990192@linuxfoundation.org>
 <20171222084625.007160464@linuxfoundation.org>
 <1515302062.6507.18.camel@gmx.de>
 <20180108160444.2ol4fvgqbxnjmlpg@gmail.com>
 <20180108174653.7muglyihpngxp5tl@black.fi.intel.com>
 <20180109001303.dy73bpixsaegn4ol@node.shutemov.name>
 <20180117052454.GA2321@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180117052454.GA2321@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>, Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Dave Young <dyoung@redhat.com>, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, Vivek Goyal <vgoyal@redhat.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Wed, Jan 17, 2018 at 01:24:54PM +0800, Baoquan He wrote:
> Hi Kirill,
> 
> I setup qemu 2.9.0 to test 5-level on kexec/kdump support. While both
> kexec and kdump reset to BIOS immediately after triggering. I saw your
> patch adding 5-level paging support for kexec. Wonder if your test
> succeeded to jump into kexec/kdump kernel, and what else I need to
> make it. By the way, I just tested the latest upstream kernel.
> 
> commit 7f6890418 x86/kexec: Add 5-level paging support
> 
> [ ~]$ qemu-system-x86_64 --version
> QEMU emulator version 2.9.0(qemu-2.9.0-1.fc26.1)
> Copyright (c) 2003-2017 Fabrice Bellard and the QEMU Project developers

Sorry for delay.

I didn't tested it in 5-level paging mode :-/

The patch below helps in my case. Could you test it?

diff --git a/arch/x86/kernel/relocate_kernel_64.S b/arch/x86/kernel/relocate_kernel_64.S
index 307d3bac5f04..65a98cf2307d 100644
--- a/arch/x86/kernel/relocate_kernel_64.S
+++ b/arch/x86/kernel/relocate_kernel_64.S
@@ -126,8 +126,12 @@ identity_mapped:
        /*
         * Set cr4 to a known state:
         *  - physical address extension enabled
+        *  - 5-level paging, if enabled
         */
        movl    $X86_CR4_PAE, %eax
+#ifdef CONFIG_X86_5LEVEL
+       orl     $X86_CR4_LA57, %eax
+#endif
        movq    %rax, %cr4

        jmp 1f
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
