Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id A13596B0003
	for <linux-mm@kvack.org>; Wed, 28 Feb 2018 17:32:08 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v8so1669602pgs.9
        for <linux-mm@kvack.org>; Wed, 28 Feb 2018 14:32:08 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v6-v6si2044664plk.577.2018.02.28.14.32.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 28 Feb 2018 14:32:07 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 0/4] Split page_type out from mapcount
Date: Wed, 28 Feb 2018 14:31:53 -0800
Message-Id: <20180228223157.9281-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

I want to use the _mapcount field to record what a page is in use as.
This can help with debugging and we can also expose that information to
userspace through /proc/kpageflags to help diagnose memory usage (not
included as part of this patch set).

First, we need s390 to stop using _mapcount for its own purposes;
Martin, I hope you have time to look at this patch.  I must confess I
don't quite understand what the different bits are used for in the upper
nybble of the _mapcount, but I tried to replicate what you were doing
faithfully.

Matthew Wilcox (4):
  s390: Use _refcount for pgtables
  mm: Split page_type out from _map_count
  mm: Mark pages allocated through vmalloc
  mm: Mark pages in use for page tables

 arch/s390/mm/pgalloc.c     | 21 +++++++++--------
 fs/proc/page.c             |  2 +-
 include/linux/mm.h         |  2 ++
 include/linux/mm_types.h   | 13 +++++++----
 include/linux/page-flags.h | 57 ++++++++++++++++++++++++++++++----------------
 kernel/crash_core.c        |  1 +
 mm/page_alloc.c            | 13 ++++-------
 mm/vmalloc.c               |  2 ++
 scripts/tags.sh            |  6 ++---
 9 files changed, 72 insertions(+), 45 deletions(-)

-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
