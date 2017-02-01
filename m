Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D19C6B0038
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 201so579320919pfw.5
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:10 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id a29si15726328pgd.80.2017.02.01.15.24.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:09 -0800 (PST)
Subject: [RFC][PATCH 0/7] x86, mpx: Support larger address space (MAWA) (v2)
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:08 -0800
Message-Id: <20170201232408.FA486473@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>

Changes from v1:
 * Added selftests support for this feature
 * Removed "mawa" nomenclature from all variables and functions
 * Added patch to cram new "mawa" value into existing MPX space
   in mmu_context_t
 * Optimize the switch_mpx_bd() code with a likely().  We will
   need to do a bit more analysis here to see what the cheapest
   way to do this is.

--

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

Dave Hansen (7):
      x86, mpx: introduce per-mm MPX table size tracking
      x86, mpx: update MPX to grok larger bounds tables
      x86, mpx: extend MPX prctl() to pass in size of bounds directory
      x86, mpx: context-switch new MPX address size MSR
      x86, mpx: shrink per-mm MPX data
      x86, mpx, selftests: Use prctl header instead of magic numbers
      x86, mpx: update MPX selftest to test larger bounds dir

 arch/x86/include/asm/mmu.h                  |   9 +-
 arch/x86/include/asm/mpx.h                  |  77 ++++++++--
 arch/x86/include/asm/msr-index.h            |   1 +
 arch/x86/include/asm/processor.h            |   6 +-
 arch/x86/mm/mpx.c                           | 100 +++++++++++--
 arch/x86/mm/tlb.c                           |  46 ++++++
 kernel/sys.c                                |   6 +-
 tools/testing/selftests/x86/mpx-hw.h        |  23 ++-
 tools/testing/selftests/x86/mpx-mini-test.c | 156 +++++++++++++++-----
 9 files changed, 349 insertions(+), 75 deletions(-)

1. https://software.intel.com/sites/default/files/managed/2b/80/5-level_paging_white_paper.pdf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
