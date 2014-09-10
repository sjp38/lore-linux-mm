Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 361726B0037
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 13:02:27 -0400 (EDT)
Received: by mail-ob0-f174.google.com with SMTP id uz6so13445548obc.33
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:02:26 -0700 (PDT)
Received: from g5t1625.atlanta.hp.com (g5t1625.atlanta.hp.com. [15.192.137.8])
        by mx.google.com with ESMTPS id ns6si23158439obc.22.2014.09.10.10.02.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 10 Sep 2014 10:02:26 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 0/6] Support Write-Through mapping on x86
Date: Wed, 10 Sep 2014 10:51:44 -0600
Message-Id: <1410367910-6026-1-git-send-email-toshi.kani@hp.com>
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

  https://lkml.org/lkml/2014/9/8/55

All new/modified interfaces have been tested.

v2:
 - Changed WT to use slot 7 of the PAT MSR. (H. Peter Anvin,
   Andy Lutomirski)
 - Changed to have conservative checks to exclude all Pentium 2, 3,
   M, and 4 families. (Ingo Molnar, Henrique de Moraes Holschuh,
   Andy Lutomirski)
 - Updated documentation to cover WT interfaces and usages.
   (Andy Lutomirski, Yigal Korman)

---
Toshi Kani (6):
  1/6 x86, mm, pat: Set WT to PA4 slot of PAT MSR
  2/6 x86, mm, pat: Change reserve_memtype() to handle WT
  3/6 x86, mm, asm-gen: Add ioremap_wt() for WT
  4/6 x86, mm: Add set_memory_wt() for WT
  5/6 x86, mm, pat: Add pgprot_writethrough() for WT
  6/6 x86, pat: Update documentation for WT changes

---
 Documentation/x86/pat.txt            | 14 +++++--
 arch/x86/include/asm/cacheflush.h    | 10 ++++-
 arch/x86/include/asm/io.h            |  2 +
 arch/x86/include/asm/pgtable_types.h |  3 ++
 arch/x86/mm/ioremap.c                | 24 ++++++++++++
 arch/x86/mm/pageattr.c               | 73 +++++++++++++++++++++++++++++++++---
 arch/x86/mm/pat.c                    | 69 +++++++++++++++++++++++++---------
 include/asm-generic/io.h             |  4 ++
 include/asm-generic/iomap.h          |  4 ++
 include/asm-generic/pgtable.h        |  4 ++
 10 files changed, 179 insertions(+), 28 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
