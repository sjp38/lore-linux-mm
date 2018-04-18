Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C8A06B000A
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 14:49:22 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id u11-v6so1466365pls.22
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 11:49:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d72si1602450pfe.291.2018.04.18.11.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Apr 2018 11:49:20 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v3 00/14] Rearrange struct page
Date: Wed, 18 Apr 2018 11:48:58 -0700
Message-Id: <20180418184912.2851-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is actually the combination of two previously posted series.
Since they both deal with rearranging struct page and the second series
depends on the first, I thought it best to combine them.

The overall motivation is to make it easier for people to use the space
in struct page if they've allocated it for their own purposes.  By the
end of the series, we end up with five consecutive words which can be
used almost arbitrarily by the owner.

Highlights:
 - slub's counters no longer share space with _refcount.
 - slub's freelist+counters are now naturally dword aligned.
 - It's now more obvious what fields in struct page are used by which
   owners (some owners still take advantage of the union aliasing).
 - deferred_list now really exists in struct page instead of just a
   comment.
 - slub loses a parameter to a lot of functions.

Matthew Wilcox (14):
  s390: Use _refcount for pgtables
  mm: Split page_type out from _mapcount
  mm: Mark pages in use for page tables
  mm: Switch s_mem and slab_cache in struct page
  mm: Move 'private' union within struct page
  mm: Move _refcount out of struct page union
  slub: Remove page->counters
  mm: Combine first three unions in struct page
  mm: Use page->deferred_list
  mm: Move lru union within struct page
  mm: Combine first two unions in struct page
  mm: Improve struct page documentation
  slab,slub: Remove rcu_head size checks
  slub: Remove kmem_slab_cache->reserved

 arch/s390/mm/pgalloc.c                 |  21 +--
 fs/proc/page.c                         |   2 +
 include/linux/mm.h                     |   2 +
 include/linux/mm_types.h               | 216 +++++++++++--------------
 include/linux/page-flags.h             |  51 +++---
 include/linux/slub_def.h               |   1 -
 include/uapi/linux/kernel-page-flags.h |   2 +-
 kernel/crash_core.c                    |   1 +
 mm/huge_memory.c                       |   7 +-
 mm/page_alloc.c                        |  17 +-
 mm/slab.c                              |   2 -
 mm/slub.c                              | 137 +++++++---------
 scripts/tags.sh                        |   6 +-
 tools/vm/page-types.c                  |   1 +
 14 files changed, 215 insertions(+), 251 deletions(-)

-- 
2.17.0
