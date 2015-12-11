Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 51C4F6B0255
	for <linux-mm@kvack.org>; Fri, 11 Dec 2015 14:32:07 -0500 (EST)
Received: by pfbu66 with SMTP id u66so26810457pfb.3
        for <linux-mm@kvack.org>; Fri, 11 Dec 2015 11:32:07 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id q2si2921504pfi.136.2015.12.11.11.32.06
        for <linux-mm@kvack.org>;
        Fri, 11 Dec 2015 11:32:06 -0800 (PST)
Message-Id: <cover.1449861203.git.tony.luck@intel.com>
From: Tony Luck <tony.luck@intel.com>
Date: Fri, 11 Dec 2015 11:13:23 -0800
Subject: [PATCHV2 0/3] Machine check recovery when kernel accesses poison
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

This series is initially targeted at the folks doing filesystems
on top of NVDIMMs. They really want to be able to return -EIO
when there is a h/w error (just like spinning rust, and SSD does).

I plan to use the same infrastructure in parts 1&2 to write a
machine check aware "copy_from_user()" that will SIGBUS the
calling application when a syscall touches poison in user space
(just like we do when the application touches the poison itself).

Changes V1->V2:

0-day:	Reported build errors and warnings on 32-bit systems. Fixed
0-day:	Reported bloat to tinyconfig. Fixed
Boris:	Suggestions to use extra macros to reduce code duplication in _ASM_*EXTABLE. Done
Boris:	Re-write "tolerant==3" check to reduce indentation level. See below.
Andy:	Check IP is valid before searching kernel exception tables. Done.
Andy:	Explain use of BIT(63) on return value from mcsafe_memcpy(). Done (added decode macros).
Andy:	Untangle mess of code in tail of do_machine_check() to make it
	clear what is going on (e.g. that we only enter the ist_begin_non_atomic()
	if we were called from user code, not from kernel!). Done

Tony Luck (3):
  x86, ras: Add new infrastructure for machine check fixup tables
  2/6] x86, ras: Extend machine check recovery code to annotated ring0
    areas
  3/6] x86, ras: Add mcsafe_memcpy() function to recover from machine
    checks

 arch/x86/Kconfig                          |  4 ++
 arch/x86/include/asm/asm.h                | 10 +++-
 arch/x86/include/asm/uaccess.h            |  8 +++
 arch/x86/include/asm/uaccess_64.h         |  5 ++
 arch/x86/kernel/cpu/mcheck/mce-severity.c | 22 +++++++-
 arch/x86/kernel/cpu/mcheck/mce.c          | 69 +++++++++++------------
 arch/x86/kernel/x8664_ksyms_64.c          |  2 +
 arch/x86/lib/copy_user_64.S               | 91 +++++++++++++++++++++++++++++++
 arch/x86/mm/extable.c                     | 19 +++++++
 include/asm-generic/vmlinux.lds.h         |  6 ++
 include/linux/module.h                    |  1 +
 kernel/extable.c                          | 20 +++++++
 12 files changed, 219 insertions(+), 38 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
