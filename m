Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 6DA9B6B0068
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 07:40:54 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH] mm: Fix compiler warning in copy_page_range
Date: Mon, 10 Sep 2012 14:40:28 +0300
Message-Id: <1347277228-15057-1-git-send-email-haggaie@mellanox.com>
In-Reply-To: <504C3DCF.9090702@mellanox.com>
References: <504C3DCF.9090702@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Haggai Eran <haggaie@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Minchan Kim <minchan@kernel.org>

This patch fixes the warning about mmun_start/end used uninitialized in
copy_page_range, by initializing them regardless of whether the notifiers are
actually called.  It also makes sure the vm_flags in copy_page_range are only
read once.

Cc: Minchan Kim <minchan@kernel.org>
Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 mm/memory.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3c88368..423d214 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -712,7 +712,7 @@ static void print_bad_pte(struct vm_area_struct *vma, unsigned long addr,
 	add_taint(TAINT_BAD_PAGE);
 }
 
-static inline int is_cow_mapping(vm_flags_t flags)
+static inline bool is_cow_mapping(vm_flags_t flags)
 {
 	return (flags & (VM_SHARED | VM_MAYWRITE)) == VM_MAYWRITE;
 }
@@ -1041,6 +1041,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	unsigned long end = vma->vm_end;
 	unsigned long mmun_start;	/* For mmu_notifiers */
 	unsigned long mmun_end;		/* For mmu_notifiers */
+	bool is_cow;
 	int ret;
 
 	/*
@@ -1073,12 +1074,12 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * parent mm. And a permission downgrade will only happen if
 	 * is_cow_mapping() returns true.
 	 */
-	if (is_cow_mapping(vma->vm_flags)) {
-		mmun_start = addr;
-		mmun_end   = end;
+	is_cow = is_cow_mapping(vma->vm_flags);
+	mmun_start = addr;
+	mmun_end   = end;
+	if (is_cow)
 		mmu_notifier_invalidate_range_start(src_mm, mmun_start,
 						    mmun_end);
-	}
 
 	ret = 0;
 	dst_pgd = pgd_offset(dst_mm, addr);
@@ -1094,7 +1095,7 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		}
 	} while (dst_pgd++, src_pgd++, addr = next, addr != end);
 
-	if (is_cow_mapping(vma->vm_flags))
+	if (is_cow)
 		mmu_notifier_invalidate_range_end(src_mm, mmun_start,
 						  mmun_end);
 	return ret;
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
