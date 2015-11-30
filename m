Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8659C6B0038
	for <linux-mm@kvack.org>; Mon, 30 Nov 2015 00:09:02 -0500 (EST)
Received: by padhx2 with SMTP id hx2so172324817pad.1
        for <linux-mm@kvack.org>; Sun, 29 Nov 2015 21:09:02 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id x10si7678473pas.190.2015.11.29.21.09.01
        for <linux-mm@kvack.org>;
        Sun, 29 Nov 2015 21:09:01 -0800 (PST)
Subject: [RFC PATCH 0/5] get_user_pages() for dax mappings
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 29 Nov 2015 21:08:33 -0800
Message-ID: <20151130050833.18366.21963.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave@sr71.net>, toshi.kani@hp.com, linux-nvdimm@lists.01.org, Peter Zijlstra <peterz@infradead.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

Following up on the kernel summit tech topic presentation of
ZONE_DEVICE, here is a re-post of dax-gup support patches.  Originally
posted back in September [1], this reduced set represents the core of
the implementation and the changes most in need of review from -mm
developers.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2015-September/002199.html

---

To date, we have implemented two I/O usage models for persistent memory,
PMEM (a persistent "ram disk") and DAX (mmap persistent memory into
userspace).  This series adds a third, DAX-GUP, that allows DAX mappings
to be the target of direct-i/o.  It allows userspace to coordinate
DMA/RDMA from/to persitent memory.

The implementation leverages the ZONE_DEVICE mm-zone that went into
4.3-rc1 (also discussed at kernel summit) to flag pages that are owned
and dynamically mapped by a device driver.  The pmem driver, after
mapping a persistent memory range into the system memmap via
devm_memremap_pages(), arranges for DAX to distinguish pfn-only versus
page-backed pmem-pfns via flags in the new pfn_t type.

The DAX code, upon seeing a PFN_DEV+PFN_MAP flagged pfn, flags the
resulting pte(s) inserted into the process page tables with a new
_PAGE_DEVMAP flag.  Later, when get_user_pages() is walking ptes it keys
off _PAGE_DEVMAP to pin the device hosting the page range active.
Finally, get_page() and put_page() are modified to take references
against the device driver established page mapping.

The full set in context with other changes is available here:

  git://git.kernel.org/pub/scm/linux/kernel/git/djbw/nvdimm libnvdimm-pending

A test to prove out the pmd path is here:

  https://github.com/pmem/ndctl/blob/master/lib/test-dax-pmd.c

---

Dan Williams (5):
      mm, dax, pmem: introduce {get|put}_dev_pagemap() for dax-gup
      mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd
      mm, x86: get_user_pages() for dax mappings
      dax: provide diagnostics for pmd mapping failures
      dax: re-enable dax pmd mappings


 arch/ia64/include/asm/pgtable.h      |    1 
 arch/sh/include/asm/pgtable-3level.h |    1 
 arch/x86/include/asm/pgtable.h       |    2 -
 arch/x86/mm/gup.c                    |   56 +++++++++++++++++++-
 drivers/nvdimm/pmem.c                |    6 +-
 fs/Kconfig                           |    3 +
 fs/dax.c                             |   55 ++++++++++++++-----
 include/linux/huge_mm.h              |   13 ++++-
 include/linux/mm.h                   |   89 ++++++++++++++++++++++++++-----
 include/linux/mm_types.h             |    5 ++
 kernel/memremap.c                    |   53 +++++++++++++++++--
 mm/gup.c                             |   17 ++++++
 mm/huge_memory.c                     |   97 +++++++++++++++++++++++++---------
 mm/memory.c                          |    8 +--
 mm/swap.c                            |   15 +++++
 15 files changed, 348 insertions(+), 73 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
