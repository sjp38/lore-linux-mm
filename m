Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id ABB066B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 11:10:57 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w24so7086694pgm.7
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:10:57 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id l21si3218220pfk.427.2017.10.19.08.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 08:10:56 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm -V2] mm, pagemap: Fix soft dirty marking for PMD migration entry
Date: Thu, 19 Oct 2017 23:10:46 +0800
Message-Id: <20171019151046.3443-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Arnd Bergmann <arnd@arndb.de>, Hugh Dickins <hughd@google.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Daniel Colascione <dancol@google.com>, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

From: Huang Ying <ying.huang@intel.com>

Now, when the page table is walked in the implementation of
/proc/<pid>/pagemap, pmd_soft_dirty() is used for both the PMD huge
page map and the PMD migration entries.  That is wrong,
pmd_swp_soft_dirty() should be used for the PMD migration entries
instead because the different page table entry flag is used.
Otherwise, the soft dirty information in /proc/<pid>/pagemap may be
wrong.

Cc: Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Daniel Colascione <dancol@google.com>
Cc: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Fixes: 84c3fc4e9c56 ("mm: thp: check pmd migration entry in common path")
---
 fs/proc/task_mmu.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 2593a0c609d7..01aad772f8db 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1311,13 +1311,15 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 		pmd_t pmd = *pmdp;
 		struct page *page = NULL;
 
-		if ((vma->vm_flags & VM_SOFTDIRTY) || pmd_soft_dirty(pmd))
+		if (vma->vm_flags & VM_SOFTDIRTY)
 			flags |= PM_SOFT_DIRTY;
 
 		if (pmd_present(pmd)) {
 			page = pmd_page(pmd);
 
 			flags |= PM_PRESENT;
+			if (pmd_soft_dirty(pmd))
+				flags |= PM_SOFT_DIRTY;
 			if (pm->show_pfn)
 				frame = pmd_pfn(pmd) +
 					((addr & ~PMD_MASK) >> PAGE_SHIFT);
@@ -1329,6 +1331,8 @@ static int pagemap_pmd_range(pmd_t *pmdp, unsigned long addr, unsigned long end,
 			frame = swp_type(entry) |
 				(swp_offset(entry) << MAX_SWAPFILES_SHIFT);
 			flags |= PM_SWAP;
+			if (pmd_swp_soft_dirty(pmd))
+				flags |= PM_SOFT_DIRTY;
 			VM_BUG_ON(!is_pmd_migration_entry(pmd));
 			page = migration_entry_to_page(entry);
 		}
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
