Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7ED2A829CA
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:34:33 -0400 (EDT)
Received: by oiba3 with SMTP id a3so10542761oib.0
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:34:33 -0700 (PDT)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id wb9si1661667obc.21.2015.03.13.14.34.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:34:32 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 0/5] mtrr, mm, x86: Enhance MTRR checks for huge I/O mapping
Date: Fri, 13 Mar 2015 15:33:36 -0600
Message-Id: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

This patchset enhances MTRR checks for the kernel huge I/O mapping,
which was enabled by the patchset below:
  https://lkml.org/lkml/2015/3/3/589

The following functional changes are made in patch 5/5.
 - Allow pud_set_huge() and pmd_set_huge() to create a huge page
   mapping to a range covered by a single MTRR entry of any memory
   type.
 - Log a pr_warn() message when a specified PMD map range spans more
   than a single MTRR entry.  Drivers should make a mapping request
   aligned to a single MTRR entry when the range is covered by MTRRs.

Patch 1/5 addresses other review comments to the mapping funcs for
better code read-ability.  Patch 2/5 - 4/5 are bug fixes and clean up
to mtrr_type_lookup().

The patchset is based on the -mm tree.
---
v3:
 - Add patch 3/5 to fix a bug in MTRR state checks.
 - Update patch 4/5 to create separate functions for the fixed and
   variable entries. (Ingo Molnar)

v2:
 - Update change logs and comments per review comments.
   (Ingo Molnar)
 - Add patch 3/4 to clean up mtrr_type_lookup(). (Ingo Molnar)

---
Toshi Kani (5):
 1/5 mm, x86: Document return values of mapping funcs
 2/5 mtrr, x86: Fix MTRR lookup to handle inclusive entry
 3/5 mtrr, x86: Fix MTRR state checks in mtrr_type_lookup()
 4/5 mtrr, x86: Clean up mtrr_type_lookup()
 5/5 mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping

---
 arch/x86/Kconfig                   |   2 +-
 arch/x86/include/asm/mtrr.h        |   5 +-
 arch/x86/include/uapi/asm/mtrr.h   |   4 +
 arch/x86/kernel/cpu/mtrr/generic.c | 181 ++++++++++++++++++++++++-------------
 arch/x86/mm/pat.c                  |   4 +-
 arch/x86/mm/pgtable.c              |  53 ++++++++---
 6 files changed, 165 insertions(+), 84 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
