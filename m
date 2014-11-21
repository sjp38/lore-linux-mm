Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 583B46B0072
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 13:25:04 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id z107so2599822qgd.1
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 10:25:04 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id b4si5106226qag.91.2014.11.21.10.25.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 10:25:03 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v6 0/7] Support Write-Through mapping on x86
Date: Fri, 21 Nov 2014 11:10:33 -0700
Message-Id: <1416593440-23083-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com

This patchset adds support of Write-Through (WT) mapping on x86.
The study below shows that using WT mapping may be useful for
non-volatile memory.

  http://www.hpl.hp.com/techreports/2012/HPL-2012-236.pdf

This patchset applies on top of the tip branch, which contains
Juergen's patchset for the PAT management.

All new/modified interfaces have been tested.

v6:
 - Dropped the patch moving [set|get]_page_memtype() to pat.c
   since the tip branch already has this change.
 - Fixed an issue when CONFIG_X86_PAT is not defined.

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
Toshi Kani (7):
  1/7 x86, mm, pat: Set WT to PA7 slot of PAT MSR
  2/7 x86, mm, pat: Change reserve_memtype() to handle WT
  3/7 x86, mm, asm-gen: Add ioremap_wt() for WT
  4/7 x86, mm, pat: Add pgprot_writethrough() for WT
  5/7 x86, mm, pat: Refactor !pat_enable handling
  6/7 x86, mm, asm: Add WT support to set_page_memtype()
  7/7 x86, mm: Add set_memory_wt() for WT

---
 Documentation/x86/pat.txt            |  13 ++-
 arch/x86/include/asm/cacheflush.h    |   6 +-
 arch/x86/include/asm/io.h            |   2 +
 arch/x86/include/asm/pgtable_types.h |   3 +
 arch/x86/mm/init.c                   |   6 +-
 arch/x86/mm/iomap_32.c               |  12 +--
 arch/x86/mm/ioremap.c                |  26 ++++-
 arch/x86/mm/pageattr.c               |  61 ++++++++++--
 arch/x86/mm/pat.c                    | 184 ++++++++++++++++++++++++-----------
 include/asm-generic/io.h             |   4 +
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +
 12 files changed, 239 insertions(+), 86 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
