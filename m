Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11171280309
	for <linux-mm@kvack.org>; Thu, 16 Jul 2015 19:24:22 -0400 (EDT)
Received: by oibn4 with SMTP id n4so60809134oib.3
        for <linux-mm@kvack.org>; Thu, 16 Jul 2015 16:24:21 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id td6si7672271oeb.84.2015.07.16.16.24.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jul 2015 16:24:21 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH RESEND 0/3] mm, x86: Fix ioremap RAM check interfaces
Date: Thu, 16 Jul 2015 17:23:13 -0600
Message-Id: <1437088996-28511-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: travis@sgi.com, roland@purestorage.com, dan.j.williams@intel.com, mcgrof@suse.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

ioremap() checks if a target range is in RAM and fails the request
if true.  There are multiple issues in the iormap RAM check interfaces.

 1. region_is_ram() always fails with -1.
 2. The check calls two functions, region_is_ram() and
    walk_system_ram_range(), which are redundant as both walk the
    same iomem_resource table.
 3. walk_system_ram_range() requires RAM ranges be page-aligned in
    the iomem_resource table to work properly.  This restriction
    has allowed multiple ioremaps to RAM which are page-unaligned.

This patchset solves issue 1 and 2.  It does not address issue 3,
but continues to allow the existing ioremaps to work until it is
addressed.

---
resend:
 - Rebased to 4.2-rc2 (no change needed). Modified change logs.

---
Toshi Kani (3):
  1/3 mm, x86: Fix warning in ioremap RAM check
  2/3 mm, x86: Remove region_is_ram() call from ioremap
  3/3 mm: Fix bugs in region_is_ram()

---
 arch/x86/mm/ioremap.c | 23 ++++++-----------------
 kernel/resource.c     |  6 +++---
 2 files changed, 9 insertions(+), 20 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
