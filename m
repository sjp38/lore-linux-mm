Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id CF9576B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:55:38 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so139185142wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:38 -0700 (PDT)
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com. [209.85.212.169])
        by mx.google.com with ESMTPS id rz14si19500085wjb.96.2015.09.14.08.55.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 08:55:37 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so139184285wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 08:55:37 -0700 (PDT)
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Subject: [PATCH 0/3] arm64: remove UEFI reserved regions from linear mapping
Date: Mon, 14 Sep 2015 17:55:26 +0200
Message-Id: <1442246129-13930-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, catalin.marinas@arm.com, will.deacon@arm.com, leif.lindholm@linaro.org, mark.rutland@arm.com, msalter@redhat.com, akpm@linux-foundation.org
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>

This is an alternative approach to the series I posted in November 2014:
thread.gmane.org/gmane.linux.kernel.efi/5133

For arm64, we need to keep track of which parts of the physical memory space
are backed by normal memory, since device mappings and memory mappings are
mutually incompatible (device mappings don't allow unaligned accesses which
may occur when parsing ACPI tables, for instance, and mapping devices as
memory is also not allowed)
 
Instead of adding a physmem memblock table that contains all of memory,
including the memory that should not be covered by the linear mapping,
this series introduces a MEMBLOCK_NOMAP attribute that allows us to
carry the same information in the ordinary 'memory' memblock table.

Patch #1 introduces the attribute and the associated plumbing to interpret
the attribute and to ensure MEMBLOCK_NOMAP regions are not considered for
allocations.

Patch #2 makes the arm64 core mapping code aware of MEMBLOCK_NOMAP, by
honoring it when setting up the linear mapping, and by making pfn_valid()
aware of it.

Patch #3 updates the UEFI memory map handling logic to mark reserved regions
as MEMBLOCK_NOMAP.

Notable about this series is that it does not require any changes to the
iomem resource table handling or the definition of page_is_ram(), since
the nomap regions are still registered as 'System RAM'.

Ard Biesheuvel (3):
  mm/memblock: add MEMBLOCK_NOMAP attribute to memblock memory table
  arm64: only consider memblocks with NOMAP cleared for linear mapping
  arm64/efi: mark UEFI reserved regions as MEMBLOCK_NOMAP

 arch/arm64/kernel/efi.c  |  5 ++--
 arch/arm64/mm/init.c     |  2 +-
 arch/arm64/mm/mmu.c      |  2 ++
 include/linux/memblock.h |  8 ++++++
 mm/memblock.c            | 28 ++++++++++++++++++++
 5 files changed, 41 insertions(+), 4 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
