Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE068E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 06:34:21 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m4-v6so12222972pgq.19
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 03:34:21 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id h90-v6si20104366plb.64.2018.09.11.03.34.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 03:34:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] mm, thp: Fix mlocking THP page with migration enabled
Date: Tue, 11 Sep 2018 13:34:03 +0300
Message-Id: <20180911103403.38086-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vegard Nossum <vegard.nossum@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, stable@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>

A transparent huge page is represented by a single entry on an LRU list.
Therefore, we can only make unevictable an entire compound page, not
individual subpages.

If a user tries to mlock() part of a huge page, we want the rest of the
page to be reclaimable.

We handle this by keeping PTE-mapped huge pages on normal LRU lists: the
PMD on border of VM_LOCKED VMA will be split into PTE table.

Introduction of THP migration breaks the rules around mlocking THP
pages. If we had a single PMD mapping of the page in mlocked VMA, the
page will get mlocked, regardless of PTE mappings of the page.

For tmpfs/shmem it's easy to fix by checking PageDoubleMap() in
remove_migration_pmd().

Anon THP pages can only be shared between processes via fork(). Mlocked
page can only be shared if parent mlocked it before forking, otherwise
CoW will be triggered on mlock().

For Anon-THP, we can fix the issue by munlocking the page on removing PTE
migration entry for the page. PTEs for the page will always come after
mlocked PMD: rmap walks VMAs from oldest to newest.

Test-case:

	#include <unistd.h>
	#include <sys/mman.h>
	#include <sys/wait.h>
	#include <linux/mempolicy.h>
	#include <numaif.h>

	int main(void)
	{
	        unsigned long nodemask = 4;
	        void *addr;

		addr = mmap((void *)0x20000000UL, 2UL << 20, PROT_READ | PROT_WRITE,
			MAP_PRIVATE | MAP_ANONYMOUS | MAP_LOCKED, -1, 0);

	        if (fork()) {
			wait(NULL);
			return 0;
	        }

	        mlock(addr, 4UL << 10);
	        mbind(addr, 2UL << 20, MPOL_PREFERRED | MPOL_F_RELATIVE_NODES,
	                &nodemask, 4, MPOL_MF_MOVE | MPOL_MF_MOVE_ALL);

	        return 0;
	}

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-by: Vegard Nossum <vegard.nossum@gmail.com>
Fixes: 616b8371539a ("mm: thp: enable thp migration in generic path")
Cc: <stable@vger.kernel.org> [v4.14+]
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 2 +-
 mm/migrate.c     | 3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 533f9b00147d..00704060b7f7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2931,7 +2931,7 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
 	else
 		page_add_file_rmap(new, true);
 	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
-	if (vma->vm_flags & VM_LOCKED)
+	if ((vma->vm_flags & VM_LOCKED) && !PageDoubleMap(new))
 		mlock_vma_page(new);
 	update_mmu_cache_pmd(vma, address, pvmw->pmd);
 }
diff --git a/mm/migrate.c b/mm/migrate.c
index d6a2e89b086a..01dad96b25b5 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -275,6 +275,9 @@ static bool remove_migration_pte(struct page *page, struct vm_area_struct *vma,
 		if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
 			mlock_vma_page(new);
 
+		if (PageTransCompound(new) && PageMlocked(page))
+			clear_page_mlock(page);
+
 		/* No need to invalidate - it was non-present before */
 		update_mmu_cache(vma, pvmw.address, pvmw.pte);
 	}
-- 
2.18.0
