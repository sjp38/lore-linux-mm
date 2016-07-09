Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 647876B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 03:55:47 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so25695216wmr.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 00:55:47 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id a84si1190160wmd.66.2016.07.09.00.55.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 00:55:45 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id k123so10603953wme.2
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 00:55:45 -0700 (PDT)
Date: Sat, 9 Jul 2016 09:55:40 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 0/9] mm: Hardened usercopy
Message-ID: <20160709075539.GA27852@gmail.com>
References: <1467843928-29351-1-git-send-email-keescook@chromium.org>
 <b113b487-acc6-24b8-d58c-425d3c884f4c@redhat.com>
 <1468032243.13253.59.camel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1468032243.13253.59.camel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Laura Abbott <labbott@redhat.com>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, Casey Schaufler <casey@schaufler-ca.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, "David S. Miller" <davem@davemloft.net>, x86@kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, Mathias Krause <minipli@googlemail.com>, Jan Kara <jack@suse.cz>, Vitaly Wool <vitalywool@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, Laura Abbott <labbott@fedoraproject.org>, linux-arm-kernel@lists.infradead.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com


* Rik van Riel <riel@redhat.com> wrote:

> On Fri, 2016-07-08 at 19:22 -0700, Laura Abbott wrote:
> > 
> > Even with the SLUB fixup I'm still seeing this blow up on my arm64
> > system. This is a
> > Fedora rawhide kernel + the patches
> > 
> > [    0.666700] usercopy: kernel memory exposure attempt detected from
> > fffffc0008b4dd58 (<kernel text>) (8 bytes)
> > [    0.666720] CPU: 2 PID: 79 Comm: modprobe Tainted:
> > G        W       4.7.0-0.rc6.git1.1.hardenedusercopy.fc25.aarch64 #1
> > [    0.666733] Hardware name: AppliedMicro Mustang/Mustang, BIOS
> > 1.1.0 Nov 24 2015
> > [    0.666744] Call trace:
> > [    0.666756] [<fffffc0008088a20>] dump_backtrace+0x0/0x1e8
> > [    0.666765] [<fffffc0008088c2c>] show_stack+0x24/0x30
> > [    0.666775] [<fffffc0008455344>] dump_stack+0xa4/0xe0
> > [    0.666785] [<fffffc000828d874>] __check_object_size+0x6c/0x230
> > [    0.666795] [<fffffc00083a5748>] create_elf_tables+0x74/0x420
> > [    0.666805] [<fffffc00082fb1f0>] load_elf_binary+0x828/0xb70
> > [    0.666814] [<fffffc0008298b4c>] search_binary_handler+0xb4/0x240
> > [    0.666823] [<fffffc0008299864>] do_execveat_common+0x63c/0x950
> > [    0.666832] [<fffffc0008299bb4>] do_execve+0x3c/0x50
> > [    0.666841] [<fffffc00080e3720>]
> > call_usermodehelper_exec_async+0xe8/0x148
> > [    0.666850] [<fffffc0008084a80>] ret_from_fork+0x10/0x50
> > 
> > This happens on every call to execve. This seems to be the first
> > copy_to_user in
> > create_elf_tables. I didn't get a chance to debug and I'm going out
> > of town
> > all of next week so all I have is the report unfortunately. config
> > attached.
> 
> That's odd, this should be copying a piece of kernel data (not text)
> to userspace.
> 
> from fs/binfmt_elf.c
> 
>         const char *k_platform = ELF_PLATFORM;
> 
> ...
>                 size_t len = strlen(k_platform) + 1;
> 		
>                 u_platform = (elf_addr_t __user *)STACK_ALLOC(p, len);
>                 if (__copy_to_user(u_platform, k_platform, len))
>                         return -EFAULT;
> 
> from arch/arm/include/asm/elf.h:
> 
> #define ELF_PLATFORM_SIZE 8
> #define ELF_PLATFORM    (elf_platform)
> 
> extern char elf_platform[];
> 
> from arch/arm/kernel/setup.c:
> 
> char elf_platform[ELF_PLATFORM_SIZE];
> EXPORT_SYMBOL(elf_platform);
> 
> ...
> 
>         snprintf(elf_platform, ELF_PLATFORM_SIZE, "%s%c",
>                  list->elf_name, ENDIANNESS);
> 
> How does that end up in the .text section of the
> image, instead of in one of the various data sections?
> 
> What kind of linker oddity is going on with ARM?

I think the crash happened on ARM64, not ARM.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
