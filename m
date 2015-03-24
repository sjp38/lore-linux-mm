Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id A93F66B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 18:26:55 -0400 (EDT)
Received: by obbgg8 with SMTP id gg8so5807254obb.1
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 15:26:55 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id pj12si339250oeb.75.2015.03.24.15.26.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 15:26:53 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v4 0/7] mtrr, mm, x86: Enhance MTRR checks for huge I/O mapping
Date: Tue, 24 Mar 2015 16:08:34 -0600
Message-Id: <1427234921-19737-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

This patchset enhances MTRR checks for the kernel huge I/O mapping,
which was enabled by the patchset below:
  https://lkml.org/lkml/2015/3/3/589

The following functional changes are made in patch 7/7.
 - Allow pud_set_huge() and pmd_set_huge() to create a huge page
   mapping to a range covered by a single MTRR entry of any memory
   type.
 - Log a pr_warn() message when a specified PMD map range spans more
   than a single MTRR entry.  Drivers should make a mapping request
   aligned to a single MTRR entry when the range is covered by MTRRs.

Patch 1/7 addresses other review comments to the mapping funcs for
better code read-ability.  Patch 2/7 - 6/7 are bug fixes and clean up
to mtrr_type_lookup().

The patchset is based on the -mm tree.
---
v4:
 - Update the change logs of patchset. (Ingo Molnar)
 - Add patch 3/7 to make the wrong address fix as a separate patch.
   (Ingo Molnar)
 - Add patch 5/7 to define MTRR_TYPE_INVALID. (Ingo Molnar)
 - Update patch 6/7 to document MTRR fixed ranges. (Ingo Molnar)

v3:
 - Add patch 3/5 to fix a bug in MTRR state checks.
 - Update patch 4/5 to create separate functions for the fixed and
   variable entries. (Ingo Molnar)

v2:
 - Update change logs and comments per review comments.
   (Ingo Molnar)
 - Add patch 3/4 to clean up mtrr_type_lookup(). (Ingo Molnar)

---
Toshi Kani (7):
 1/7 mm, x86: Document return values of mapping funcs
 2/7 mtrr, x86: Fix MTRR lookup to handle inclusive entry
 3/7 mtrr, x86: Remove a wrong address check in __mtrr_type_lookup()
 4/7 mtrr, x86: Fix MTRR state checks in mtrr_type_lookup()
 5/7 mtrr, x86: Define MTRR_TYPE_INVALID for mtrr_type_lookup()
 6/7 mtrr, x86: Clean up mtrr_type_lookup()
 7/7 mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping

---
 arch/x86/Kconfig                   |   2 +-
 arch/x86/include/asm/mtrr.h        |   7 +-
 arch/x86/include/uapi/asm/mtrr.h   |  12 ++-
 arch/x86/kernel/cpu/mtrr/generic.c | 192 ++++++++++++++++++++++++-------------
 arch/x86/mm/pat.c                  |   4 +-
 arch/x86/mm/pgtable.c              |  53 +++++++---
 6 files changed, 181 insertions(+), 89 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
