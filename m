Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f45.google.com (mail-yh0-f45.google.com [209.85.213.45])
	by kanga.kvack.org (Postfix) with ESMTP id 385C06B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 15:44:48 -0400 (EDT)
Received: by mail-yh0-f45.google.com with SMTP id 29so2023633yhl.18
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 12:44:47 -0700 (PDT)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id y69si5327189yhg.110.2014.07.15.12.44.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 12:44:47 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 0/11] Support Write-Through mapping on x86
Date: Tue, 15 Jul 2014 13:34:33 -0600
Message-Id: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, konrad.wilk@oracle.com, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de, Toshi Kani <toshi.kani@hp.com>

This RFC patchset is aimed to seek comments/suggestions for the design
and changes to support of Write-Through (WT) mapping.  The study below
shows that using WT mapping may be useful for non-volatile memory.

  http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

There were idea & patches to support WT in the past, which stimulated
very valuable discussions on this topic.

  https://lkml.org/lkml/2013/4/24/424
  https://lkml.org/lkml/2013/10/27/70
  https://lkml.org/lkml/2013/11/3/72

This RFC patchset tries to address the issues raised by taking the
following design approach:

 - Keep the MTRR interface
 - Keep the WB, WC, and UC- slots in the PAT MSR
 - Keep the PAT bit unused
 - Reassign the UC slot to WT in the PAT MSR

There are 4 usable slots in the PAT MSR, which are currently assigned to:

  PA0/4: WB, PA1/5: WC, PA2/6: UC-, PA3/7: UC

The PAT bit is unused since it shares the same bit as the PSE bit and
there was a bug in older processors.  Among the 4 slots, the uncached
memory type consumes 2 slots, UC- and UC.  They are functionally
equivalent, but UC- allows MTRRs to overwrite it with WC.  All interfaces
that set the uncached memory type use UC- in order to work with MTRRs.
The PA3/7 slot is effectively unused today.  Therefore, this patchset
reassigns the PA3/7 slot to WT.  If MTRRs get deprecated in future,
UC- can be reassigned to UC, and there is still no need to consume
2 slots for the uncached memory type.

This patchset is consist of two parts.  The 1st part, patch [1/11] to
[6/11], enables WT mapping and adds new interfaces for setting WT mapping.
The 2nd part, patch [7/11] to [11/11], cleans up the code that has
internal knowledge of the PAT slot assignment.  This keeps the kernel
code independent from the PAT slot assignment.

This patchset applies on top of the Linus's tree, 3.16.0-rc5.

---
Toshi Kani (11):
  1/11: x86, mm, pat: Redefine _PAGE_CACHE_UC as UC_MINUS
  2/11: x86, mm, pat: Define _PAGE_CACHE_WT for PA3/7 of PAT
  3/11: x86, mm, pat: Change reserve_memtype() to handle WT type
  4/11: x86, mm, asm-gen: Add ioremap_wt() for WT mapping
  5/11: x86, mm: Add set_memory[_array]_wt() for setting WT
  6/11: x86, mm, pat: Add pgprot_writethrough() for WT
  7/11: x86, mm: Keep _set_memory_<type>() slot-independent
  8/11: x86, mm, pat: Keep pgprot_<type>() slot-independent
  9/11: x86, efi: Cleanup PCD bit manipulation in EFI
 10/11: x86, xen: Cleanup PWT/PCD bit manipulation in Xen
 11/11: x86, fbdev: Cleanup PWT/PCD bit manipulation in fbdev

---
 arch/x86/include/asm/cacheflush.h         |  8 +++-
 arch/x86/include/asm/fb.h                 |  3 +-
 arch/x86/include/asm/io.h                 |  2 +
 arch/x86/include/asm/pgtable.h            |  2 +-
 arch/x86/include/asm/pgtable_types.h      | 22 ++++++---
 arch/x86/mm/ioremap.c                     | 37 +++++++++++----
 arch/x86/mm/pageattr.c                    | 75 ++++++++++++++++++++++++++-----
 arch/x86/mm/pat.c                         | 38 +++++++++-------
 arch/x86/mm/pat_internal.h                |  2 +-
 arch/x86/platform/efi/efi_64.c            |  4 +-
 arch/x86/xen/enlighten.c                  |  2 +-
 arch/x86/xen/mmu.c                        |  8 ++--
 drivers/video/fbdev/gbefb.c               |  3 +-
 drivers/video/fbdev/vermilion/vermilion.c |  4 +-
 include/asm-generic/io.h                  |  4 ++
 include/asm-generic/iomap.h               |  4 ++
 include/asm-generic/pgtable.h             |  4 ++
 17 files changed, 169 insertions(+), 53 deletions(-)

=====
This test patch applies on top of the RFC patchset and provides
an easy way to test WT mapping through /dev/mem.  This change is
a hack and test only.

  fd = open("/dev/mem", O_RDWR|O_DSYNC);
  p = mmap(NULL, <map-size>, PROT_READ|PROT_WRITE,
		MAP_SHARED, fd, <addr>);

---
 arch/x86/mm/pat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 0be7ebd..79850b3 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -525,7 +525,7 @@ int phys_mem_access_prot_allowed(struct file *file, unsigned long pfn,
 		return 0;
 
 	if (file->f_flags & O_DSYNC)
-		flags = _PAGE_CACHE_UC_MINUS;
+		flags = _PAGE_CACHE_WT;
 
 #ifdef CONFIG_X86_32
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
