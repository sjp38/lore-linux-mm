Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8DD1C6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 17:40:06 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id 80so327343566pfy.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 14:40:06 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w33si2571532plb.273.2017.01.26.14.40.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jan 2017 14:40:05 -0800 (PST)
Subject: [RFC][PATCH 0/4] x86, mpx: Support larger address space (MAWA)
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 26 Jan 2017 14:40:05 -0800
Message-Id: <20170126224005.A6BBEF2C@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Dave Hansen <dave.hansen@linux.intel.com>

Kirill is chugging right along getting his 5-level paging[1] patch set
ready to be merged.  I figured I'd share an early draft of the MPX
support that will to go along with it.

Background: there is a lot more detail about what bounds tables are in
the changelog for fe3d197f843.  But, basically MPX bounds tables help
us to store the ranges to which a pointer is allowed to point.  The
tables are walked by hardware and they are indexed by the virtual
address of the pointer being checked.

A larger virtual address space (from 5-level paging) means that we
need larger tables.  5-level paging hardware includes a feature called
MPX Address-Width Adjust (MAWA) that grows the bounds tables so they
can address the new address space.  MAWA is controlled independently
from the paging mode (via an MSR) so that old MPX binaries can run on
new hardware and kernels supporting 5-level paging.

But, since userspace is responsible for allocating the table that is
growing (the directory), we need to ensure that userspace and the
kernel agree about the size of these tables and the kernel can set the
MSR appropriately.

These are not quite ready to get applied anywhere, but I don't expect
the basics to change unless folks have big problems with this.  The
only big remaining piece of work is to update the MPX selftest code.

Dave Hansen (4):
      x86, mpx: introduce per-mm MPX table size tracking
      x86, mpx: update MPX to grok larger bounds tables
      x86, mpx: extend MPX prctl() to pass in size of bounds directory
      x86, mpx: context-switch new MPX address size MSR

 arch/x86/include/asm/mmu.h       |  1 +
 arch/x86/include/asm/mpx.h       | 41 ++++++++++++++---
 arch/x86/include/asm/msr-index.h |  1 +
 arch/x86/include/asm/processor.h |  6 +--
 arch/x86/mm/mpx.c                | 79 ++++++++++++++++++++++++++++----
 arch/x86/mm/pgtable.c            |  2 +-
 arch/x86/mm/tlb.c                | 42 +++++++++++++++++
 kernel/sys.c                     |  6 +--
 8 files changed, 155 insertions(+), 23 deletions(-)

1. https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
