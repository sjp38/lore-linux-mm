Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id AFFE46B00BC
	for <linux-mm@kvack.org>; Tue,  4 Nov 2014 17:18:43 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id wn1so11594160obc.4
        for <linux-mm@kvack.org>; Tue, 04 Nov 2014 14:18:43 -0800 (PST)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id g6si1856824obh.55.2014.11.04.14.18.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 04 Nov 2014 14:18:42 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 0/8] Support Write-Through mapping on x86
Date: Tue,  4 Nov 2014 15:04:30 -0700
Message-Id: <1415138678-22958-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

This patchset adds support of Write-Through (WT) mapping on x86.
The study below shows that using WT mapping may be useful for
non-volatile memory.

  http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

This patchset applies on top of the Juergen's patchset below,
which provides the basis of the PAT management.

  https://lkml.org/lkml/2014/11/3/330

All new/modified interfaces have been tested.

v5:
 - Clarified comment of why using slot 7. (Andy Lutomirski,
   Thomas Gleixner)
 - Moved [set|get]_page_memtype() to pat.c. (Thomas Gleixner)
 - Removed BUG() from set_page_memtype(). (Thomas Gleixner)

v4:
 - Added set_memory_wt() by adding WT support of regular memory.

v3:
 - Dropped the set_memory_wt() patch. (Andy Lutomirski)
 - Refactored the !pat_enabled handling. (H. Peter Anvin,
   Andy Lutomirski)
 - Added the picture of PTE encoding. (Konrad Rzeszutek Wilk)

v2:
 - Changed WT to use slot 7 of the PAT MSR. (H. Peter Anvin,
   Andy Lutomirski)
 - Changed to have conservative checks to exclude all Pentium 2, 3,
   M, and 4 families. (Ingo Molnar, Henrique de Moraes Holschuh,
   Andy Lutomirski)
 - Updated documentation to cover WT interfaces and usages.
   (Andy Lutomirski, Yigal Korman)

---
Toshi Kani (8):
  1/8 x86, mm, pat: Set WT to PA7 slot of PAT MSR
  2/8 x86, mm, pat, asm: Move [get|set]_page_memtype() to pat.c
  3/8 x86, mm, pat: Change reserve_memtype() to handle WT
  4/8 x86, mm, asm-gen: Add ioremap_wt() for WT
  5/8 x86, mm, pat: Add pgprot_writethrough() for WT
  6/8 x86, mm, pat: Refactor !pat_enable handling
  7/8 x86, mm, asm: Add WT support to set_page_memtype()
  8/8 x86, mm: Add set_memory_wt() for WT

---
 Documentation/x86/pat.txt            |  13 +-
 arch/x86/include/asm/cacheflush.h    |  75 +----------
 arch/x86/include/asm/io.h            |   2 +
 arch/x86/include/asm/pgtable_types.h |   3 +
 arch/x86/mm/init.c                   |   6 +-
 arch/x86/mm/iomap_32.c               |  12 +-
 arch/x86/mm/ioremap.c                |  26 +++-
 arch/x86/mm/pageattr.c               |  61 +++++++--
 arch/x86/mm/pat.c                    | 241 ++++++++++++++++++++++++-----------
 include/asm-generic/io.h             |   4 +
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
