Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E32876B0276
	for <linux-mm@kvack.org>; Fri,  4 May 2018 14:33:36 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id t74-v6so6796031pgc.14
        for <linux-mm@kvack.org>; Fri, 04 May 2018 11:33:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f8-v6si5125741pgr.139.2018.05.04.11.33.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 04 May 2018 11:33:22 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 00/17] Rearrange struct page
Date: Fri,  4 May 2018 11:33:01 -0700
Message-Id: <20180504183318.14415-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

As presented at LSFMM, this patch-set rearranges struct page to give
more contiguous usable space to users who have allocated a struct page
for their own purposes.  For a graphical view of before-and-after, see
the first two tabs of https://docs.google.com/spreadsheets/d/1tvCszs_7FXrjei9_mtFiKV6nW1FLnYyvPvW-qNZhdog/edit?usp=sharing

Highlights:
 - slub's counters no longer share space with _refcount.
 - slub's freelist+counters are now naturally dword aligned.
 - It's now more obvious what fields in struct page are used by which
   owners (some owners still take advantage of the union aliasing).
 - deferred_list now really exists in struct page instead of just a
   comment.
 - slub loses a parameter to a lot of functions.
 - Several hidden uses of struct page are now documented in code.

Changes in v5:
 - Added acks from Christoph Lameter
 - Dropped patch to make slub use page->private instead of page->counters.
 - Combined slab/slob/slub into one union in struct page.
 - Added patch to distinguish VMalloc pages.
 - Added patch to remove slub's 'reserved' file in sysfs.
 - Call the unions 'main union' and 'mapcount union' instead of 'first
   union' and 'second union'.
 - Removed a line which described which double-word slub's freelist was in.

Changes in v4:
 - Added acks/reviews from Kirill & Randy
 - Removed call to page_mapcount_reset from slub since it no longer uses
   mapcount union.
 - Add pt_mm and hmm_data to struct page

Matthew Wilcox (17):
  s390: Use _refcount for pgtables
  mm: Split page_type out from _mapcount
  mm: Mark pages in use for page tables
  mm: Switch s_mem and slab_cache in struct page
  mm: Move 'private' union within struct page
  mm: Move _refcount out of struct page union
  mm: Combine first three unions in struct page
  mm: Use page->deferred_list
  mm: Move lru union within struct page
  mm: Combine LRU and main union in struct page
  mm: Improve struct page documentation
  mm: Add pt_mm to struct page
  mm: Add hmm_data to struct page
  slab,slub: Remove rcu_head size checks
  slub: Remove kmem_cache->reserved
  slub: Remove 'reserved' file from sysfs
  mm: Distinguish VMalloc pages

 arch/s390/mm/pgalloc.c                 |  21 ++-
 arch/x86/mm/pgtable.c                  |   5 +-
 fs/proc/page.c                         |   4 +
 include/linux/hmm.h                    |   8 +-
 include/linux/mm.h                     |   2 +
 include/linux/mm_types.h               | 238 ++++++++++++-------------
 include/linux/page-flags.h             |  76 ++++++--
 include/linux/slub_def.h               |   1 -
 include/uapi/linux/kernel-page-flags.h |   3 +-
 kernel/crash_core.c                    |   1 +
 mm/huge_memory.c                       |   7 +-
 mm/page_alloc.c                        |  17 +-
 mm/slab.c                              |   2 -
 mm/slub.c                              | 102 +++--------
 mm/vmalloc.c                           |   5 +-
 scripts/tags.sh                        |   6 +-
 tools/vm/page-types.c                  |   2 +
 17 files changed, 244 insertions(+), 256 deletions(-)

-- 
2.17.0
