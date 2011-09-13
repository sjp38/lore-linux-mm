Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAA1900137
	for <linux-mm@kvack.org>; Tue, 13 Sep 2011 06:23:16 -0400 (EDT)
Received: by ywe9 with SMTP id 9so386820ywe.14
        for <linux-mm@kvack.org>; Tue, 13 Sep 2011 03:23:14 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] Trivial: Eliminate the ret variable from mm_take_all_locks
Date: Tue, 13 Sep 2011 15:55:31 +0530
Message-Id: <1315909531-13419-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Jiri Kosina <trivial@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

The ret variable is really not needed in mm_take_all_locks as per
the current flow of the mm_take_all_locks function.

So, eliminating this return variable.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/mmap.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a65efd4..48bc056 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2558,7 +2558,6 @@ int mm_take_all_locks(struct mm_struct *mm)
 {
 	struct vm_area_struct *vma;
 	struct anon_vma_chain *avc;
-	int ret = -EINTR;
 
 	BUG_ON(down_read_trylock(&mm->mmap_sem));
 
@@ -2579,13 +2578,12 @@ int mm_take_all_locks(struct mm_struct *mm)
 				vm_lock_anon_vma(mm, avc->anon_vma);
 	}
 
-	ret = 0;
+	return 0;
 
 out_unlock:
-	if (ret)
-		mm_drop_all_locks(mm);
+	mm_drop_all_locks(mm);
 
-	return ret;
+	return -EINTR;
 }
 
 static void vm_unlock_anon_vma(struct anon_vma *anon_vma)
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
