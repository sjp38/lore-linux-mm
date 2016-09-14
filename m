Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54CA96B0069
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 03:19:28 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id e1so28498216itb.3
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 00:19:28 -0700 (PDT)
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com. [15.241.140.78])
        by mx.google.com with ESMTPS id p37si17357627otd.69.2016.09.14.00.19.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Sep 2016 00:19:14 -0700 (PDT)
From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [RFC PATCH v2 0/3] Add support for eXclusive Page Frame Ownership (XPFO)
Date: Wed, 14 Sep 2016 09:18:58 +0200
Message-Id: <20160914071901.8127-1-juerg.haefliger@hpe.com>
In-Reply-To: <20160902113909.32631-1-juerg.haefliger@hpe.com>
References: <20160902113909.32631-1-juerg.haefliger@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-x86_64@vger.kernel.org
Cc: juerg.haefliger@hpe.com, vpk@cs.columbia.edu

Changes from:
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
unmapped from physmap (the kernel's page table). When such a page is
reclaimed from userspace, it is mapped back to physmap.

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

Juerg Haefliger (3):
  Add support for eXclusive Page Frame Ownership (XPFO)
  xpfo: Only put previous userspace pages into the hot cache
  block: Always use a bounce buffer when XPFO is enabled

 arch/x86/Kconfig         |   3 +-
 arch/x86/mm/init.c       |   2 +-
 block/blk-map.c          |   2 +-
 include/linux/highmem.h  |  15 +++-
 include/linux/page_ext.h |   7 ++
 include/linux/xpfo.h     |  41 +++++++++
 lib/swiotlb.c            |   3 +-
 mm/Makefile              |   1 +
 mm/page_alloc.c          |  10 ++-
 mm/page_ext.c            |   4 +
 mm/xpfo.c                | 213 +++++++++++++++++++++++++++++++++++++++++++++++
 security/Kconfig         |  20 +++++
 12 files changed, 314 insertions(+), 7 deletions(-)
 create mode 100644 include/linux/xpfo.h
 create mode 100644 mm/xpfo.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
