Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id DCD186B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 12:20:58 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id o64so15132291pfb.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 09:20:58 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id l13si6383588pfi.59.2015.12.16.09.20.57
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 09:20:58 -0800 (PST)
Message-Id: <cover.1450283985.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Wed, 16 Dec 2015 08:39:45 -0800
Subject: [PATCHV3 0/3] Machine check recovery when kernel accesses poison
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Elliott@kvack.org, "Robert (Persistent Memory)" <elliott@hpe.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

This series is initially targeted at the folks doing filesystems
on top of NVDIMMs. They really want to be able to return -EIO
when there is a h/w error (just like spinning rust, and SSD does).

I plan to use the same infrastructure in parts 1&2 to write a
machine check aware "copy_from_user()" that will SIGBUS the
calling application when a syscall touches poison in user space
(just like we do when the application touches the poison itself).

Changes V2-V3:

Andy:	Don't hack "regs->ax = BIT(63) | addr;" in the machine check
	handler.  Now have better fixup code that computes the number
	of remaining bytes (just like page-fault fixup).
Andy:	#define for BIT(63). Done, plus couple of extra macros using it.
Boris:	Don't clutter up generic code (like mm/extable.c) with this.
	I moved everything under arch/x86 (the asm-generic change is
	a more generic #define).
Boris:	Dependencies for CONFIG_MCE_KERNEL_RECOVERY are too generic.
	I made it a real menu item with default "n". Dan Williams
	will use "select MCE_KERNEL_RECOVERY" from his persistent
	filesystem code.
Boris:	Simplify conditionals in mce.c by moving tolerant/kill_it
	checks earlier, with a skip to end if they aren't set.
Boris:	Miscellaneous grammar/punctuation. Fixed.
Boris:	Don't leak spurious __start_mcextable symbols into kernels
	that didn't configure MCE_KERNEL_RECOVERY. Done.
Tony:	New code doesn't belong in user_copy_64.S/uaccess*.h. Moved
	to new .S/.h files
Elliott:Cacheing behavior non-optimal. Could use movntdqa, vmovntdqa
	or vmovntdqa on source addresses. I didn't fix this yet. Think
	of the current mcsafe_memcpy() as the first of several functions.
	This one is useful for small copies (meta-data) where the overhead
	of saving SSE/AVX state isn't justified.

Changes V1->V2:

0-day:	Reported build errors and warnings on 32-bit systems. Fixed
0-day:	Reported bloat to tinyconfig. Fixed
Boris:	Suggestions to use extra macros to reduce code duplication in _ASM_*EXTABLE. Done
Boris:	Re-write "tolerant==3" check to reduce indentation level. See below.
Andy:	Check IP is valid before searching kernel exception tables. Done.
Andy:	Explain use of BIT(63) on return value from mcsafe_memcpy(). Done (added decode macros).
Andy:	Untangle mess of code in tail of do_machine_check() to make it
	clear what is going on (e.g. that we only enter the ist_begin_non_atomic()
	if we were called from user code, not from kernel!). Done.

Tony Luck (3):
  x86, ras: Add new infrastructure for machine check fixup tables
  x86, ras: Extend machine check recovery code to annotated ring0 areas
  x86, ras: Add mcsafe_memcpy() function to recover from machine checks

 arch/x86/Kconfig                          |  10 +++
 arch/x86/include/asm/asm.h                |  10 ++-
 arch/x86/include/asm/mce.h                |  14 +++
 arch/x86/include/asm/mcsafe_copy.h        |  11 +++
 arch/x86/kernel/cpu/mcheck/mce-severity.c |  21 ++++-
 arch/x86/kernel/cpu/mcheck/mce.c          |  86 +++++++++++-------
 arch/x86/kernel/vmlinux.lds.S             |   6 +-
 arch/x86/kernel/x8664_ksyms_64.c          |   5 ++
 arch/x86/lib/Makefile                     |   1 +
 arch/x86/lib/mcsafe_copy.S                | 142 ++++++++++++++++++++++++++++++
 arch/x86/mm/extable.c                     |  19 ++++
 include/asm-generic/vmlinux.lds.h         |  12 +--
 12 files changed, 293 insertions(+), 44 deletions(-)
 create mode 100644 arch/x86/include/asm/mcsafe_copy.h
 create mode 100644 arch/x86/lib/mcsafe_copy.S

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
