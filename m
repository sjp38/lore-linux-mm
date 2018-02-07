Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1218A6B0346
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 12:12:19 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id i12so864291wra.22
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 09:12:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15sor1542903edl.9.2018.02.07.09.12.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 09:12:17 -0800 (PST)
Date: Wed, 7 Feb 2018 20:12:15 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 0/3] x86: Patchable constants
Message-ID: <20180207171215.b52hql2bv5wzff6o@node.shutemov.name>
References: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
 <20180207162507.GB25219@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180207162507.GB25219@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 07, 2018 at 05:25:07PM +0100, Peter Zijlstra wrote:
> On Wed, Feb 07, 2018 at 05:59:10PM +0300, Kirill A. Shutemov wrote:
> > This conversion makes GCC generate worse code. Conversion __PHYSICAL_MASK
> > to a patchable constant adds about 5k in .text on defconfig and makes it
> > slightly slower at runtime (~0.2% on my box).
> 
> Do you have explicit examples for the worse code? That might give clue
> on how to improve things.

Clarification: increase by 5k was for defconfig, where I replaced pure constant
define __PHYSICAL_MASK with patchable constant.

With CONFIG_AMD_MEM_ENCRYPT=y increase is smaller: ~1.8k.

The disassembler below is for CONFIG_AMD_MEM_ENCRYPT=y.

Before:

Dump of assembler code for function migration_entry_wait:
   0xffffffff8118ab40 <+0>:     mov    (%rsi),%rcx
   0xffffffff8118ab43 <+3>:     shr    $0x9,%rdx
   0xffffffff8118ab47 <+7>:     mov    0x10aecba(%rip),%r8        # 0xffffffff82239808 <sme_me_mask>
   0xffffffff8118ab4e <+14>:    mov    %rdx,%rax
   0xffffffff8118ab51 <+17>:    mov    0x10aec90(%rip),%r9        # 0xffffffff822397e8 <vmemmap_base>
   0xffffffff8118ab58 <+24>:    movabs $0x3fffffe00000,%rsi
   0xffffffff8118ab62 <+34>:    and    $0xff8,%eax
   0xffffffff8118ab67 <+39>:    test   $0x80,%cl
   0xffffffff8118ab6a <+42>:    not    %r8
   0xffffffff8118ab6d <+45>:    jne    0xffffffff8118ab79 <migration_entry_wait+57>
   0xffffffff8118ab6f <+47>:    movabs $0x3ffffffff000,%rsi
   0xffffffff8118ab79 <+57>:    and    %r8,%rsi
   0xffffffff8118ab7c <+60>:    add    0x10aec75(%rip),%rax        # 0xffffffff822397f8 <page_offset_base>
   0xffffffff8118ab83 <+67>:    and    %rsi,%rcx
   0xffffffff8118ab86 <+70>:    mov    %rcx,%rdx
   0xffffffff8118ab89 <+73>:    shr    $0x6,%rdx
   0xffffffff8118ab8d <+77>:    mov    %rax,%rsi
   0xffffffff8118ab90 <+80>:    lea    0x30(%r9,%rdx,1),%rdx
   0xffffffff8118ab95 <+85>:    add    %rcx,%rsi
   0xffffffff8118ab98 <+88>:    jmpq   0xffffffff8118aa20 <__migration_entry_wait>

After:

Dump of assembler code for function migration_entry_wait:
   0xffffffff8118b3e0 <+0>:     mov    (%rsi),%rsi
   0xffffffff8118b3e3 <+3>:     mov    %rdx,%rax
   0xffffffff8118b3e6 <+6>:     mov    0x10ae41b(%rip),%r8        # 0xffffffff82239808 <vmemmap_base>
   0xffffffff8118b3ed <+13>:    shr    $0x9,%rax
   0xffffffff8118b3f1 <+17>:    and    $0xff8,%eax
   0xffffffff8118b3f6 <+22>:    test   $0x80,%sil
   0xffffffff8118b3fa <+26>:    jne    0xffffffff8118b432 <migration_entry_wait+82>
   0xffffffff8118b3fc <+28>:    mov    %rsi,%rdx
   0xffffffff8118b3ff <+31>:    movabs $0x3fffffffffff,%rcx
   0xffffffff8118b409 <+41>:    and    %rcx,%rdx
   0xffffffff8118b40c <+44>:    and    $0xfffffffffffff000,%rcx
   0xffffffff8118b413 <+51>:    shr    $0xc,%rdx
   0xffffffff8118b417 <+55>:    shl    $0x6,%rdx
   0xffffffff8118b41b <+59>:    lea    0x30(%r8,%rdx,1),%rdx
   0xffffffff8118b420 <+64>:    add    0x10ae3f1(%rip),%rax        # 0xffffffff82239818 <page_offset_base>
   0xffffffff8118b427 <+71>:    and    %rcx,%rsi
   0xffffffff8118b42a <+74>:    add    %rax,%rsi
   0xffffffff8118b42d <+77>:    jmpq   0xffffffff8118b2c0 <__migration_entry_wait>
   0xffffffff8118b432 <+82>:    mov    %rsi,%rdx
   0xffffffff8118b435 <+85>:    and    $0xffffffffffe00000,%rdx
   0xffffffff8118b43c <+92>:    movabs $0x3fffffffffff,%rcx
   0xffffffff8118b446 <+102>:   and    %rcx,%rdx
   0xffffffff8118b449 <+105>:   and    $0xffffffffffe00000,%rcx
   0xffffffff8118b450 <+112>:   shr    $0x6,%rdx
   0xffffffff8118b454 <+116>:   lea    0x30(%r8,%rdx,1),%rdx
   0xffffffff8118b459 <+121>:   jmp    0xffffffff8118b420 <migration_entry_wait+64>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
