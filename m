Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E76EA6B031C
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 09:59:29 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id o128so522579pfg.6
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 06:59:29 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id l4-v6si1183288plt.29.2018.02.07.06.59.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Feb 2018 06:59:28 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC 0/3] x86: Patchable constants
Date: Wed,  7 Feb 2018 17:59:10 +0300
Message-Id: <20180207145913.2703-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Tom Lendacky <thomas.lendacky@amd.com>, Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patchset introduces concept of patchable constants: constant values
that can be adjusted at boot-time in response to system configuration or
user input (kernel command-line).

Patchable constants can replace variables that never changes at runtime
(only at boot-time), but used in very hot path.

Patchable constants implemented by replacing a constant with call to
inline function that returns the constant value using inline assembler.
In inline assembler we also write down into separate section location of
the instruction that loads the constant. This way we can find the
location later and adjust the value.

My idea was to make __PHYSICAL_MASK a patchable constant in hope to offset
overhead of having it dynamic. We need it dynamic for memory encryption
implementation (both AMD SME and Intel MKTME).

But this didn't pay off. :(

This conversion makes GCC generate worse code. Conversion __PHYSICAL_MASK
to a patchable constant adds about 5k in .text on defconfig and makes it
slightly slower at runtime (~0.2% on my box).

That's not result I hoped for.

I this wanted to share it just in case if anybody find a better use of it
or a way to improve it.

Other candidates may be PAGE_OFFSET/VMALLOC_START/VMEMMAP_START.

Kudos to PeterZ for hints on how it can be implemented.

Any feedback?

Kirill A. Shutemov (3):
  x86: Introduce patchable constants
  x86/mm/encrypt: Convert __PHYSICAL_MASK to patchable constant
  x86/mm/encrypt: Convert sme_me_mask to patchable constant

 arch/x86/Kconfig                       |   5 ++
 arch/x86/include/asm/mem_encrypt.h     |   5 +-
 arch/x86/include/asm/page_types.h      |  11 ++-
 arch/x86/include/asm/patchable_const.h |  28 ++++++++
 arch/x86/kernel/Makefile               |   3 +
 arch/x86/kernel/module.c               |  14 ++++
 arch/x86/kernel/patchable_const.c      | 119 +++++++++++++++++++++++++++++++++
 arch/x86/mm/mem_encrypt.c              |  20 +++---
 8 files changed, 192 insertions(+), 13 deletions(-)
 create mode 100644 arch/x86/include/asm/patchable_const.h
 create mode 100644 arch/x86/kernel/patchable_const.c

-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
