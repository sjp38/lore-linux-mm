Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id B54B46B006E
	for <linux-mm@kvack.org>; Fri, 15 May 2015 14:43:19 -0400 (EDT)
Received: by obblk2 with SMTP id lk2so84569718obb.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 11:43:19 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id e5si1621182oeu.50.2015.05.15.11.43.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 May 2015 11:43:18 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v5 0/6] mtrr, mm, x86: Enhance MTRR checks for huge I/O mapping
Date: Fri, 15 May 2015 12:23:51 -0600
Message-Id: <1431714237-880-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, mcgrof@suse.com

This patchset enhances MTRR checks for the kernel huge I/O mapping.

The following functional changes are made in patch 6/6.
 - Allow pud_set_huge() and pmd_set_huge() to create a huge page mapping
   when the range is covered by a single MTRR entry of any memory type.
 - Log a pr_warn_once() message when a specified PMD map range spans more
   than a single MTRR entry.  Drivers should make a mapping request aligned
   to a single MTRR entry when the range is covered by MTRRs.

Patch 1/6 simplifies the condition of HAVE_ARCH_HUGE_VMAP in Kconfig.
Patch 2/6 - 5/6 are bug fix and clean up to mtrr_type_lookup().

The patchset is based on the tip tree.
---
v5:
 - Separate Kconfig change and reordered/squashed the patchset. (Borislav
   Petkov)
 - Update logs, comments and functional structures. (Borislav Petkov)
 - Move MTRR_STATE_MTRR_XXX definitions to kernel asm/mtrr.h.  (Borislav
   Petkov)
 - Change mtrr_type_lookup() not to set 'uniform' in case of MTRR_TYPE_INVALID.
   (Borislav Petkov)
 - Remove a patch accepted in the tip free from the series.

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
Toshi Kani (6):
 1/6 mm, x86: Simplify conditions of HAVE_ARCH_HUGE_VMAP
 2/6 mtrr, x86: Fix MTRR lookup to handle inclusive entry
 3/6 mtrr, x86: Fix MTRR state checks in mtrr_type_lookup()
 4/6 mtrr, x86: Define MTRR_TYPE_INVALID for mtrr_type_lookup()
 5/6 mtrr, x86: Clean up mtrr_type_lookup()
 6/6 mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping

---
 arch/x86/Kconfig                   |   2 +-
 arch/x86/include/asm/mtrr.h        |  10 +-
 arch/x86/include/uapi/asm/mtrr.h   |   8 +-
 arch/x86/kernel/cpu/mtrr/cleanup.c |   3 +-
 arch/x86/kernel/cpu/mtrr/generic.c | 200 ++++++++++++++++++++++++-------------
 arch/x86/mm/pat.c                  |   4 +-
 arch/x86/mm/pgtable.c              |  59 ++++++++---
 7 files changed, 194 insertions(+), 92 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
