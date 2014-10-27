Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id A9FE5900021
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 19:09:40 -0400 (EDT)
Received: by mail-yk0-f175.google.com with SMTP id q9so799783ykb.6
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 16:09:40 -0700 (PDT)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id 124si13505916ykj.65.2014.10.27.16.09.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 16:09:39 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 0/7] Support Write-Through mapping on x86
Date: Mon, 27 Oct 2014 16:55:38 -0600
Message-Id: <1414450545-14028-1-git-send-email-toshi.kani@hp.com>
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

  https://lkml.org/lkml/2014/10/27/71

All new/modified interfaces have been tested.

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
 arch/x86/include/asm/cacheflush.h    |  34 ++++---
 arch/x86/include/asm/io.h            |   2 +
 arch/x86/include/asm/pgtable_types.h |   3 +
 arch/x86/mm/init.c                   |   6 +-
 arch/x86/mm/iomap_32.c               |  18 ++--
 arch/x86/mm/ioremap.c                |  26 +++++-
 arch/x86/mm/pageattr.c               |  61 ++++++++++--
 arch/x86/mm/pat.c                    | 174 +++++++++++++++++++++--------------
 include/asm-generic/io.h             |   4 +
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +
 12 files changed, 233 insertions(+), 116 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
