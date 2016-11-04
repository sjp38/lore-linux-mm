Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B83C56B0319
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 10:45:45 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 128so124493511oih.1
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 07:45:45 -0700 (PDT)
Received: from g9t5008.houston.hpe.com (g9t5008.houston.hpe.com. [15.241.48.72])
        by mx.google.com with ESMTPS id y187si8879957oig.271.2016.11.04.07.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Nov 2016 07:45:45 -0700 (PDT)
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [RFC PATCH v3 0/2] Add support for eXclusive Page Frame Ownership (XPFO)
Date: Fri,  4 Nov 2016 15:45:32 +0100
Message-Id: <20161104144534.14790-1-juerg.haefliger@hpe.com>
In-Reply-To: <20160914071901.8127-1-juerg.haefliger@hpe.com>
References: <20160914071901.8127-1-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: vpk@cs.columbia.edu, juerg.haefliger@hpe.com

Changes from:
  v2 -> v3:
    - Removed 'depends on DEBUG_KERNEL' and 'select DEBUG_TLBFLUSH'.
      These are left-overs from the original patch and are not required.
    - Make libata XPFO-aware, i.e., properly handle pages that were
      unmapped by XPFO. This takes care of the temporary hack in v2 that
      forced the use of a bounce buffer in block/blk-map.c.
  v1 -> v2:
    - Moved the code from arch/x86/mm/ to mm/ since it's (mostly)
      arch-agnostic.
    - Moved the config to the generic layer and added ARCH_SUPPORTS_XPFO
      for x86.
    - Use page_ext for the additional per-page data.
    - Removed the clearing of pages. This can be accomplished by using
      PAGE_POISONING.
    - Split up the patch into multiple patches.
    - Fixed additional issues identified by reviewers.

This patch series adds support for XPFO which protects against 'ret2dir'
kernel attacks. The basic idea is to enforce exclusive ownership of page
frames by either the kernel or userspace, unless explicitly requested by
the kernel. Whenever a page destined for userspace is allocated, it is
unmapped from physmap (removed from the kernel's page table). When such a
page is reclaimed from userspace, it is mapped back to physmap.

Additional fields in the page_ext struct are used for XPFO housekeeping.
Specifically two flags to distinguish user vs. kernel pages and to tag
unmapped pages and a reference counter to balance kmap/kunmap operations
and a lock to serialize access to the XPFO fields.

Known issues/limitations:
  - Only supports x86-64 (for now)
  - Only supports 4k pages (for now)
  - There are most likely some legitimate uses cases where the kernel needs
    to access userspace which need to be made XPFO-aware
  - Performance penalty

Reference paper by the original patch authors:
  http://www.cs.columbia.edu/~vpk/papers/ret2dir.sec14.pdf

Juerg Haefliger (2):
  Add support for eXclusive Page Frame Ownership (XPFO)
  xpfo: Only put previous userspace pages into the hot cache

 arch/x86/Kconfig         |   3 +-
 arch/x86/mm/init.c       |   2 +-
 drivers/ata/libata-sff.c |   4 +-
 include/linux/highmem.h  |  15 +++-
 include/linux/page_ext.h |   7 ++
 include/linux/xpfo.h     |  41 +++++++++
 lib/swiotlb.c            |   3 +-
 mm/Makefile              |   1 +
 mm/page_alloc.c          |  10 ++-
 mm/page_ext.c            |   4 +
 mm/xpfo.c                | 214 +++++++++++++++++++++++++++++++++++++++++++++++
 security/Kconfig         |  19 +++++
 12 files changed, 315 insertions(+), 8 deletions(-)
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
