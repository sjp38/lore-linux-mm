Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 14D9F6B0035
	for <linux-mm@kvack.org>; Wed, 17 Sep 2014 15:59:26 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id r5so2979568qcx.26
        for <linux-mm@kvack.org>; Wed, 17 Sep 2014 12:59:25 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id d28si15875222yhd.127.2014.09.17.12.59.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 17 Sep 2014 12:59:25 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 0/5] Support Write-Through mapping on x86
Date: Wed, 17 Sep 2014 13:48:36 -0600
Message-Id: <1410983321-15162-1-git-send-email-toshi.kani@hp.com>
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

  https://lkml.org/lkml/2014/9/12/205

All new/modified interfaces have been tested.

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
Toshi Kani (5):
  1/5 x86, mm, pat: Set WT to PA7 slot of PAT MSR
  2/5 x86, mm, pat: Change reserve_memtype() to handle WT
  3/5 x86, mm, asm-gen: Add ioremap_wt() for WT
  4/5 x86, mm, pat: Add pgprot_writethrough() for WT
  5/5 x86, mm, pat: Refactor !pat_enable handling

---
 Documentation/x86/pat.txt            |   4 +-
 arch/x86/include/asm/cacheflush.h    |   4 +
 arch/x86/include/asm/io.h            |   2 +
 arch/x86/include/asm/pgtable_types.h |   3 +
 arch/x86/mm/init.c                   |   6 +-
 arch/x86/mm/iomap_32.c               |  18 ++--
 arch/x86/mm/ioremap.c                |  26 +++++-
 arch/x86/mm/pageattr.c               |   3 -
 arch/x86/mm/pat.c                    | 160 ++++++++++++++++++++++-------------
 include/asm-generic/io.h             |   4 +
 include/asm-generic/iomap.h          |   4 +
 include/asm-generic/pgtable.h        |   4 +
 12 files changed, 156 insertions(+), 82 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
