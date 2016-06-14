Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 010466B028B
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:42:45 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id y7so11903289obt.0
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:42:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id w1si37499042pfa.213.2016.06.14.01.42.43
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 01:42:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/2] Revert "mm: disable fault around on emulated access bit architecture"
Date: Tue, 14 Jun 2016 11:42:30 +0300
Message-Id: <1465893750-44080-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This reverts commit d0834a6c2c5b0c76cfb806bd7dba6556d8b4edbb.

After revert of 5c0a85fad949 ("mm: make faultaround produce old ptes")
faultaround doesn't have dependencies on hardware accessed bit, so let's
revert this one too.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 61fe7e7b56bf..cd1f29e4897e 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2898,16 +2898,8 @@ void do_set_pte(struct vm_area_struct *vma, unsigned long address,
 	update_mmu_cache(vma, address, pte);
 }
 
-/*
- * If architecture emulates "accessed" or "young" bit without HW support,
- * there is no much gain with fault_around.
- */
 static unsigned long fault_around_bytes __read_mostly =
-#ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
-	PAGE_SIZE;
-#else
 	rounddown_pow_of_two(65536);
-#endif
 
 #ifdef CONFIG_DEBUG_FS
 static int fault_around_bytes_get(void *data, u64 *val)
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
