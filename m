Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0F77F6B025E
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 11:03:30 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 63so109666096pfx.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 08:03:30 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p63si258531pfp.244.2016.08.31.08.03.28
        for <linux-mm@kvack.org>;
        Wed, 31 Aug 2016 08:03:28 -0700 (PDT)
From: James Morse <james.morse@arm.com>
Subject: [PATCH] mm, proc: Make the task_mmu walk_page_range() limit in clear_refs_write() obvious
Date: Wed, 31 Aug 2016 16:03:12 +0100
Message-Id: <1472655792-22439-1-git-send-email-james.morse@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, James Morse <james.morse@arm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Trying to walk all of virtual memory requires architecture specific
knowledge. On x86_64, addresses must be sign extended from bit 48,
whereas on arm64 the top VA_BITS of address space have their own set
of page tables.

clear_refs_write() calls walk_page_range() on the range 0 to ~0UL, it
provides a test_walk() callback that only expects to be walking over
VMAs. Currently walk_pmd_range() will skip memory regions that don't
have a VMA, reporting them as a hole.

As this call only expects to walk user address space, make it walk
0 to  'highest_vm_end'.

Signed-off-by: James Morse <james.morse@arm.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

---
This is in preparation for a RFC series that allows walk_page_range() to
walk kernel page tables too.

 fs/proc/task_mmu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..1026b7862896 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1068,7 +1068,7 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
 			}
 			mmu_notifier_invalidate_range_start(mm, 0, -1);
 		}
-		walk_page_range(0, ~0UL, &clear_refs_walk);
+		walk_page_range(0, mm->highest_vm_end, &clear_refs_walk);
 		if (type == CLEAR_REFS_SOFT_DIRTY)
 			mmu_notifier_invalidate_range_end(mm, 0, -1);
 		flush_tlb_mm(mm);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
