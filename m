Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAD646B000D
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 16:23:13 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23so1052226pfm.7
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 13:23:13 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m4-v6si8006053plt.561.2018.04.30.13.23.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 13:23:11 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v4 00/16] Rearrange struct page
Date: Mon, 30 Apr 2018 13:22:31 -0700
Message-Id: <20180430202247.25220-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

As presented at LSFMM last week, this patch-set rearranges struct page
to give more usable space to users who have allocated a struct page for
their own purposes.  For a graphical view of before-and-after, see the first
two tabs of https://docs.google.com/spreadsheets/d/1tvCszs_7FXrjei9_mtFiKV6nW1FLnYyvPvW-qNZhdog/edit?usp=sharing

Highlights:
 - slub's counters no longer share space with _refcount.
 - slub's freelist+counters are now naturally dword aligned.
 - It's now more obvious what fields in struct page are used by which
   owners (some owners still take advantage of the union aliasing).
 - deferred_list now really exists in struct page instead of just a
   comment.
 - slub loses a parameter to a lot of functions.
 - Several hidden uses of struct page are now documented in code.

Changes v3 -> v4:

 - Added acks/reviews from Kirill & Randy
 - Removed call to page_mapcount_reset from slub since it no longer uses
   mapcount union.
 - Add pt_mm and hmm_data to struct page

Matthew Wilcox (16):
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
  mm: Add pt_mm to struct page
  mm: Add hmm_data to struct page
  slab,slub: Remove rcu_head size checks
  slub: Remove kmem_cache->reserved

 arch/s390/mm/pgalloc.c                 |  21 ++-
 arch/x86/mm/pgtable.c                  |   5 +-
 fs/proc/page.c                         |   2 +
 include/linux/hmm.h                    |   8 +-
 include/linux/mm.h                     |   2 +
 include/linux/mm_types.h               | 218 ++++++++++++-------------
 include/linux/page-flags.h             |  51 +++---
 include/linux/slub_def.h               |   1 -
 include/uapi/linux/kernel-page-flags.h |   2 +-
 kernel/crash_core.c                    |   1 +
 mm/huge_memory.c                       |   7 +-
 mm/page_alloc.c                        |  17 +-
 mm/slab.c                              |   2 -
 mm/slub.c                              | 138 ++++++----------
 scripts/tags.sh                        |   6 +-
 tools/vm/page-types.c                  |   1 +
 16 files changed, 222 insertions(+), 260 deletions(-)

-- 
2.17.0
