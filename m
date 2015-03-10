Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 432276B0092
	for <linux-mm@kvack.org>; Tue, 10 Mar 2015 16:24:06 -0400 (EDT)
Received: by oifu20 with SMTP id u20so3882581oif.11
        for <linux-mm@kvack.org>; Tue, 10 Mar 2015 13:24:06 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id y3si917768oer.66.2015.03.10.13.24.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Mar 2015 13:24:05 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 0/3] mtrr, mm, x86: Enhance MTRR checks for huge I/O mapping
Date: Tue, 10 Mar 2015 14:23:14 -0600
Message-Id: <1426018997-12936-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl

This patchset enhances MTRR checks for the kernel huge I/O mapping,
which was enabled by the patchset below:
  https://lkml.org/lkml/2015/3/3/589

The following functional changes are made in patch 3/3.
 - Allow pud_set_huge() and pmd_set_huge() to create a huge page
   mapping to a range covered by a single MTRR entry of any memory
   type.
 - Log a pr_warn() message when a requested PMD map range spans more
   than a single MTRR entry.  Drivers should make a mapping request
   aligned to a single MTRR entry when the range is covered by MTRRs.

Patch 1/3 addresses other review comments to the mapping funcs for
better code read-ability.  Patch 2/3 fixes a bug in mtrr_type_lookup().

The patchset is based on the -mm tree.
---
Toshi Kani (3):
 1/3 mm, x86: Document return values of mapping funcs
 2/3 mtrr, x86: Fix MTRR lookup to handle inclusive entry
 3/3 mtrr, mm, x86: Enhance MTRR checks for KVA huge page mapping

---
 arch/x86/Kconfig                   |  2 +-
 arch/x86/include/asm/mtrr.h        |  5 ++--
 arch/x86/kernel/cpu/mtrr/generic.c | 52 +++++++++++++++++++++++++------------
 arch/x86/mm/pat.c                  |  4 +--
 arch/x86/mm/pgtable.c              | 53 ++++++++++++++++++++++++++++----------
 5 files changed, 81 insertions(+), 35 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
