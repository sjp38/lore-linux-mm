Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id A1F0B6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jan 2016 20:26:17 -0500 (EST)
Received: by mail-pf0-f180.google.com with SMTP id e65so140591130pfe.1
        for <linux-mm@kvack.org>; Sun, 03 Jan 2016 17:26:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id ff7si27876272pab.184.2016.01.03.17.26.16
        for <linux-mm@kvack.org>;
        Sun, 03 Jan 2016 17:26:16 -0800 (PST)
Message-Id: <cover.1451869360.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Sun, 3 Jan 2016 17:02:40 -0800
Subject: [PATCH v6 0/4] Machine check recovery when kernel accesses poison
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

This series is initially targeted at the folks doing filesystems
on top of NVDIMMs. They really want to be able to return -EIO
when there is a h/w error (just like spinning rust, and SSD does).

I plan to use the same infrastructure to write a machine check aware
"copy_from_user()" that will SIGBUS the calling application when a
syscall touches poison in user space (just like we do when the application
touches the poison itself).

Changes V5-V6
Andy:	Provoked massive re-write by providing what is now part1 of this
	patch series. This frees up two bits in the exception table
	fixup field that can be used to tag exception table entries
	as different "classes". This means we don't need my separate
	exception table fro machine checks. Also avoids duplicating
	fixup actions for #PF and #MC cases that were in version 5.
Andy:	Use C99 array initializers to tie the various class fixup
	functions back to the defintions of each class. Also give the
	functions meanningful names (not fixup_class0() etc.).
Boris:	Cleaned up my lousy assembly code removing many spurious 'l'
	modifiers on instructions.
Boris:	Provided some helper functions for the machine check severity
	calculation that make the code more readable.
Boris:	Have __mcsafe_copy() return a structure with the 'remaining bytes'
	in a separate field from the fault indicator. Boris had suggested
	Linux -EFAULT/-EINVAL ... but I thought it made more sense to return
	the exception number (X86_TRAP_MC, etc.)  This finally kills off
	BIT(63) which has been controversial throughout all the early versions
	of this patch series.

Changes V4-V5
Tony:	Extended __mcsafe_copy() to have fixup entries for both machine
	check and page fault.

Changes V3-V4:
Andy:   Simplify fixup_mcexception() by dropping used-once local variable
Andy:   "Reviewed-by" tag added to part1
Boris:  Moved new functions to memcpy_64.S and declaration to asm/string_64.h
Boris:  Changed name s/mcsafe_memcpy/__mcsafe_copy/ to make it clear that this
        is an internal function and that return value doesn't follow memcpy() semantics.
Boris:  "Reviewed-by" tag added to parts 1&2

Changes V2-V3:

Andy:   Don't hack "regs->ax = BIT(63) | addr;" in the machine check
        handler.  Now have better fixup code that computes the number
        of remaining bytes (just like page-fault fixup).
Andy:   #define for BIT(63). Done, plus couple of extra macros using it.
Boris:  Don't clutter up generic code (like mm/extable.c) with this.
        I moved everything under arch/x86 (the asm-generic change is
        a more generic #define).
Boris:  Dependencies for CONFIG_MCE_KERNEL_RECOVERY are too generic.
        I made it a real menu item with default "n". Dan Williams
        will use "select MCE_KERNEL_RECOVERY" from his persistent
        filesystem code.
Boris:  Simplify conditionals in mce.c by moving tolerant/kill_it
        checks earlier, with a skip to end if they aren't set.
Boris:  Miscellaneous grammar/punctuation. Fixed.
Boris:  Don't leak spurious __start_mcextable symbols into kernels
        that didn't configure MCE_KERNEL_RECOVERY. Done.
Tony:   New code doesn't belong in user_copy_64.S/uaccess*.h. Moved
        to new .S/.h files
Elliott:Cacheing behavior non-optimal. Could use movntdqa, vmovntdqa
        or vmovntdqa on source addresses. I didn't fix this yet. Think
        of the current mcsafe_memcpy() as the first of several functions.
        This one is useful for small copies (meta-data) where the overhead
        of saving SSE/AVX state isn't justified.

Changes V1->V2:

0-day:  Reported build errors and warnings on 32-bit systems. Fixed
0-day:  Reported bloat to tinyconfig. Fixed
Boris:  Suggestions to use extra macros to reduce code duplication in _ASM_*EXTABLE. Done
Boris:  Re-write "tolerant==3" check to reduce indentation level. See below.
Andy:   Check IP is valid before searching kernel exception tables. Done.
Andy:   Explain use of BIT(63) on return value from mcsafe_memcpy(). Done (added decode macros).
Andy:   Untangle mess of code in tail of do_machine_check() to make it
        clear what is going on (e.g. that we only enter the ist_begin_non_atomic()
        if we were called from user code, not from kernel!). Done.

Andy Lutomirski (1):
  x86: Clean up extable entry format (and free up a bit)

Tony Luck (3):
  x86: Cleanup and add a new exception class
  x86, mce: Check for faults tagged in EXTABLE_CLASS_FAULT exception
    table entries
  x86, mce: Add __mcsafe_copy()

 arch/x86/Kconfig                          |  10 +++
 arch/x86/include/asm/asm.h                |  80 ++++++++++++------
 arch/x86/include/asm/string_64.h          |  10 +++
 arch/x86/include/asm/uaccess.h            |  17 +++-
 arch/x86/kernel/cpu/mcheck/mce-severity.c |  32 ++++++-
 arch/x86/kernel/cpu/mcheck/mce.c          |  71 ++++++++--------
 arch/x86/kernel/kprobes/core.c            |   2 +-
 arch/x86/kernel/traps.c                   |   6 +-
 arch/x86/kernel/x8664_ksyms_64.c          |   4 +
 arch/x86/lib/memcpy_64.S                  | 136 ++++++++++++++++++++++++++++++
 arch/x86/mm/extable.c                     |  66 ++++++++++-----
 arch/x86/mm/fault.c                       |   2 +-
 12 files changed, 347 insertions(+), 89 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
