Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 704906B0005
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 08:44:48 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w22-v6so1157545pll.2
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 05:44:48 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n3si11473208pgc.12.2018.03.07.05.44.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Mar 2018 05:44:47 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 0/4] Mark vmalloc and page-table pages
Date: Wed,  7 Mar 2018 05:44:39 -0800
Message-Id: <20180307134443.32646-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

This patch set changes how we use the _mapcount field in struct page
so that we can store an extra 20+ bits of information about why the
page was allocated.  We expose that information to userspace through
/proc/kpageflags to help diagnose memory usage.  It can also help
debugging if we know what a page was most recently allocated for.

Changes since v4:
 - Added Kirill's acks
 - Fixed spelling (Kirill)
 - Allow a few extra bits to be used in page_type.

Matthew Wilcox (4):
  s390: Use _refcount for pgtables
  mm: Split page_type out from _mapcount
  mm: Mark pages allocated through vmalloc
  mm: Mark pages in use for page tables

 arch/s390/mm/pgalloc.c                 | 21 +++++++------
 arch/tile/mm/pgtable.c                 |  3 ++
 fs/proc/page.c                         |  4 +++
 include/linux/mm.h                     |  2 ++
 include/linux/mm_types.h               | 13 +++++---
 include/linux/page-flags.h             | 57 ++++++++++++++++++++++------------
 include/uapi/linux/kernel-page-flags.h |  3 +-
 kernel/crash_core.c                    |  1 +
 mm/page_alloc.c                        | 13 +++-----
 mm/vmalloc.c                           |  2 ++
 scripts/tags.sh                        |  6 ++--
 tools/vm/page-types.c                  |  2 ++
 12 files changed, 82 insertions(+), 45 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
