Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 252A46B0055
	for <linux-mm@kvack.org>; Wed,  9 Sep 2009 12:18:23 -0400 (EDT)
Received: by yxe10 with SMTP id 10so7495031yxe.12
        for <linux-mm@kvack.org>; Wed, 09 Sep 2009 09:18:23 -0700 (PDT)
From: Boll Liu <bollliu@gmail.com>
Subject: [PATCH] add vma->ops check before do_nonlinear_fault()
Date: Thu, 10 Sep 2009 00:18:14 +0800
Message-Id: <1252513094-8731-1-git-send-email-BollLiu@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, npiggin@suse.de, kamezawa.hiroyu@jp.fujitsu.com, Boll Liu <BollLiu@gmail.com>
List-ID: <linux-mm.kvack.org>

Function do_nonlinear_fault() will also call vma->vm_ops->fault().
So add vma->ops and vma->vm_ops->fault check the same as before
calling do_nonlinear_fault().

Signed-off-by: Boll Liu <BollLiu@gmail.com>
---
 mm/memory.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index aede2ce..86ebdd6 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2921,9 +2921,13 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, flags);
 		}
-		if (pte_file(entry))
-			return do_nonlinear_fault(mm, vma, address,
-					pte, pmd, flags, entry);
+		if (pte_file(entry)) {
+			if (vma->vm_ops) {
+				if (likely(vma->vm_ops->fault))
+					return do_nonlinear_fault(mm, vma, address,
+						pte, pmd, flags, entry);
+			}
+		}
 		return do_swap_page(mm, vma, address,
 					pte, pmd, flags, entry);
 	}
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
