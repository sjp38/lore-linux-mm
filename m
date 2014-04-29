Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9F6546B003C
	for <linux-mm@kvack.org>; Tue, 29 Apr 2014 15:36:46 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id dc16so659848qab.22
        for <linux-mm@kvack.org>; Tue, 29 Apr 2014 12:36:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m17si10124727qgd.119.2014.04.29.12.36.45
        for <linux-mm@kvack.org>;
        Tue, 29 Apr 2014 12:36:46 -0700 (PDT)
Date: Tue, 29 Apr 2014 15:36:15 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v2] mm,numa: remove BUG_ON in __handle_mm_fault
Message-ID: <20140429153615.2d72098e@annuminas.surriel.com>
In-Reply-To: <1398799576-9pfzypnu@n-horiguchi@ah.jp.nec.com>
References: <20140425144147.679a7608@annuminas.surriel.com>
	<1398799576-9pfzypnu@n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, lwoodman@redhat.com, peterz@infradead.org, mgorman@suse.de, dave.hansen@intel.com, sunil.k.pandey@intel.com

Peter pointed out we can do this slightly simpler, since we already
have a test for pmd_trans_huge(*pmd) below...

---8<---

Changing PTEs and PMDs to pte_numa & pmd_numa is done with the
mmap_sem held for reading, which means a pmd can be instantiated
and turned into a numa one while __handle_mm_fault is examining
the value of old_pmd.

If that happens, __handle_mm_fault should just return and let
the page fault retry, instead of throwing an oops. This is
handled by the test for pmd_trans_huge(*pmd) below.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Reported-by: Sunil Pandey <sunil.k.pandey@intel.com>
Cc: stable@kernel.org
---
 mm/memory.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d0f0bef..9c2dc65 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3900,9 +3900,6 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
-	/* THP should already have been handled */
-	BUG_ON(pmd_numa(*pmd));
-
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't
 	 * run pte_offset_map on the pmd, if an huge pmd could

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
