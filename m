Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 726FD829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 13:19:01 -0400 (EDT)
Received: by obbnt9 with SMTP id nt9so15375863obb.9
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 10:19:01 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id n145si4195766oig.14.2015.03.12.10.18.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 10:19:00 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 0/4] mtrr, mm, x86: Enhance MTRR checks for huge I/O mapping
Date: Thu, 12 Mar 2015 11:18:06 -0600
Message-Id: <1426180690-24234-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

This patchset enhances MTRR checks for the kernel huge I/O mapping,
which was enabled by the patchset below:
  https://lkml.org/lkml/2015/3/3/589

The following functional changes are made in patch 4/4.
 - Allow pud_set_huge() and pmd_set_huge() to create a huge page
   mapping to a range covered by a single MTRR entry of any memory
   type.
 - Log a pr_warn() message when a specified PMD map range spans more
   than a single MTRR entry.  Drivers should make a mapping request
   aligned to a single MTRR entry when the range is covered by MTRRs.

Patch 1/4 addresses other review comments to the mapping funcs for
better code read-ability.  Patch 2/4 and 3/4 are bug fix and clean up
to mtrr_type_lookup().

The patchset is based on the -mm tree.
---
v2:
 - Update change logs and comments per review comments.
   (Ingo Molnar)
 - Add patch 3/4 to clean up mtrr_type_lookup(). (Ingo Molnar)

---
Toshi Kani (4):
 1/4 mm, x86: Document return values of mapping funcs
 2/4 mtrr, x86: Fix MTRR lookup to handle inclusive entry
 3/4 mtrr, x86: Clean up mtrr_type_lookup()
 4/4 mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping

---
 arch/x86/Kconfig                   |   2 +-
 arch/x86/include/asm/mtrr.h        |   5 +-
 arch/x86/kernel/cpu/mtrr/generic.c | 151 +++++++++++++++++++++----------------
 arch/x86/mm/pat.c                  |   4 +-
 arch/x86/mm/pgtable.c              |  53 +++++++++----
 5 files changed, 133 insertions(+), 82 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
