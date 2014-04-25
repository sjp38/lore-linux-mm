Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4C6F36B0035
	for <linux-mm@kvack.org>; Fri, 25 Apr 2014 14:42:15 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id r5so4321257qcx.4
        for <linux-mm@kvack.org>; Fri, 25 Apr 2014 11:42:14 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v39si4320965qge.179.2014.04.25.11.42.14
        for <linux-mm@kvack.org>;
        Fri, 25 Apr 2014 11:42:14 -0700 (PDT)
Date: Fri, 25 Apr 2014 14:41:47 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] mm,numa: remove BUG_ON in __handle_mm_fault
Message-ID: <20140425144147.679a7608@annuminas.surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, lwoodman@redhat.com, peterz@infradead.org, mgorman@suse.de, dave.hansen@intel.com, sunil.k.pandey@intel.com

Changing PTEs and PMDs to pte_numa & pmd_numa is done with the
mmap_sem held for reading, which means a pmd can be instantiated
and/or turned into a numa one while __handle_mm_fault is examining
the value of orig_pmd.

If that happens, __handle_mm_fault should just return and let
the page fault retry, instead of throwing an oops.

Signed-off-by: Rik van Riel <riel@redhat.com>
Reported-by: Sunil Pandey <sunil.k.pandey@intel.com>
---
 mm/memory.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index d0f0bef..9edccb2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3900,8 +3900,9 @@ static int __handle_mm_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 	}
 
-	/* THP should already have been handled */
-	BUG_ON(pmd_numa(*pmd));
+	/* The PMD became NUMA while we examined orig_pmd. Return & retry */
+	if (pmd_numa(*pmd))
+		return 0;
 
 	/*
 	 * Use __pte_alloc instead of pte_alloc_map, because we can't

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
