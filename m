Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 525106B0253
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 12:52:44 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vp2so119635137pab.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 09:52:44 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p69si18349922pfd.56.2016.09.06.09.52.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 09:52:43 -0700 (PDT)
Subject: [PATCH 3/5] mm: fix show_smap() for zone_device-pmd ranges
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:36 -0700
Message-ID: <147318057623.30325.10495460878595242707.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: linux-mm@kvack.org, Ross Zwisler <ross.zwisler@linux.intel.com>, akpm@linux-foundation.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org

Attempting to dump /proc/<pid>/smaps for a process with pmd dax mappings
currently results in the following VM_BUG_ONs:

 kernel BUG at mm/huge_memory.c:1105!
 task: ffff88045f16b140 task.stack: ffff88045be14000
 RIP: 0010:[<ffffffff81268f9b>]  [<ffffffff81268f9b>] follow_trans_huge_pmd+0x2cb/0x340
 [..]
 Call Trace:
  [<ffffffff81306030>] smaps_pte_range+0xa0/0x4b0
  [<ffffffff814c2755>] ? vsnprintf+0x255/0x4c0
  [<ffffffff8123c46e>] __walk_page_range+0x1fe/0x4d0
  [<ffffffff8123c8a2>] walk_page_vma+0x62/0x80
  [<ffffffff81307656>] show_smap+0xa6/0x2b0

 kernel BUG at fs/proc/task_mmu.c:585!
 RIP: 0010:[<ffffffff81306469>]  [<ffffffff81306469>] smaps_pte_range+0x499/0x4b0
 Call Trace:
  [<ffffffff814c2795>] ? vsnprintf+0x255/0x4c0
  [<ffffffff8123c46e>] __walk_page_range+0x1fe/0x4d0
  [<ffffffff8123c8a2>] walk_page_vma+0x62/0x80
  [<ffffffff81307696>] show_smap+0xa6/0x2b0

These locations are sanity checking page flags that must be set for an
anonymous transparent huge page, but are not set for the zone_device
pages associated with dax mappings.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 fs/proc/task_mmu.c |    2 ++
 mm/huge_memory.c   |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..f6fa99eca515 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -581,6 +581,8 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 		mss->anonymous_thp += HPAGE_PMD_SIZE;
 	else if (PageSwapBacked(page))
 		mss->shmem_thp += HPAGE_PMD_SIZE;
+	else if (is_zone_device_page(page))
+		/* pass */;
 	else
 		VM_BUG_ON_PAGE(1, page);
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2db2112aa31e..a6abd76baa72 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1078,7 +1078,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 		goto out;
 
 	page = pmd_page(*pmd);
-	VM_BUG_ON_PAGE(!PageHead(page), page);
+	VM_BUG_ON_PAGE(!PageHead(page) && !is_zone_device_page(page), page);
 	if (flags & FOLL_TOUCH)
 		touch_pmd(vma, addr, pmd);
 	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
@@ -1116,7 +1116,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
 	}
 skip_mlock:
 	page += (addr & ~HPAGE_PMD_MASK) >> PAGE_SHIFT;
-	VM_BUG_ON_PAGE(!PageCompound(page), page);
+	VM_BUG_ON_PAGE(!PageCompound(page) && !is_zone_device_page(page), page);
 	if (flags & FOLL_GET)
 		get_page(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
