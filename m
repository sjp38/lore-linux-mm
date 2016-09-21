Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 566116B0263
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 17:15:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id j129so150963418qkd.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 14:15:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o9si14383799ybg.197.2016.09.21.14.15.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 14:15:25 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 4/4] mm: vma_adjust: remove superfluous confusing update in remove_next == 1 case
Date: Wed, 21 Sep 2016 23:15:22 +0200
Message-Id: <1474492522-2261-5-git-send-email-aarcange@redhat.com>
In-Reply-To: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
References: <1474492522-2261-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

mm->highest_vm_end doesn't need any update.

After finally removing the oddness from vma_merge case 8 that was causing:

1) constant risk of trouble whenever anybody would check vma fields
   from rmap_walks, like it happened when page migration was
   introduced and it read the vma->vm_page_prot from a rmap_walk

2) the callers of vma_merge to re-initialize any value different from
   the current vma, instead of vma_merge() more reliably returning a
   vma that already matches all fields passed as parameter

... it is also worth to take the opportunity of cleaning up
superfluous code in vma_adjust(), that if not removed adds up to the
hard readability of the function.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/mmap.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 57b1eaf..bf2dc6b 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -915,8 +915,28 @@ again:
 		}
 		else if (next)
 			vma_gap_update(next);
-		else
-			mm->highest_vm_end = end;
+		else {
+			/*
+			 * If remove_next == 2 we obviously can't
+			 * reach this path.
+			 *
+			 * If remove_next == 3 we can't reach this
+			 * path because pre-swap() next is always not
+			 * NULL. pre-swap() "next" is not being
+			 * removed and its next->vm_end is not altered
+			 * (and furthermore "end" already matches
+			 * next->vm_end in remove_next == 3).
+			 *
+			 * We reach this only in the remove_next == 1
+			 * case if the "next" vma that was removed was
+			 * the highest vma of the mm. However in such
+			 * case next->vm_end == "end" and the extended
+			 * "vma" has vma->vm_end == next->vm_end so
+			 * mm->highest_vm_end doesn't need any update
+			 * in remove_next == 1 case.
+			 */
+			VM_WARN_ON(mm->highest_vm_end != end);
+		}
 	}
 	if (insert && file)
 		uprobe_mmap(insert);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
