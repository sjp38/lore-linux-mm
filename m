Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f197.google.com (mail-ig0-f197.google.com [209.85.213.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D93A6B0005
	for <linux-mm@kvack.org>; Sun,  8 May 2016 08:03:08 -0400 (EDT)
Received: by mail-ig0-f197.google.com with SMTP id kj7so191411178igb.3
        for <linux-mm@kvack.org>; Sun, 08 May 2016 05:03:08 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id j50si10555588otc.88.2016.05.08.05.03.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 08 May 2016 05:03:07 -0700 (PDT)
From: Zhou Chengming <zhouchengming1@huawei.com>
Subject: [PATCH v4] ksm: fix conflict between mmput and scan_get_next_rmap_item
Date: Sun, 8 May 2016 20:00:15 +0800
Message-ID: <1462708815-31301-1-git-send-email-zhouchengming1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, vbabka@suse.cz, geliangtang@163.com, minchan@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, guohanjun@huawei.com, dingtianhong@huawei.com, huawei.libin@huawei.com, thunder.leizhen@huawei.com, qiuxishi@huawei.com, zhouchengming1@huawei.com

A concurrency issue about KSM in the function scan_get_next_rmap_item.

task A (ksmd):				|task B (the mm's task):
					|
mm = slot->mm;				|
down_read(&mm->mmap_sem);		|
					|
...					|
					|
spin_lock(&ksm_mmlist_lock);		|
					|
ksm_scan.mm_slot go to the next slot;	|
					|
spin_unlock(&ksm_mmlist_lock);		|
					|mmput() ->
					|	ksm_exit():
					|
					|spin_lock(&ksm_mmlist_lock);
					|if (mm_slot && ksm_scan.mm_slot != mm_slot) {
					|	if (!mm_slot->rmap_list) {
					|		easy_to_free = 1;
					|		...
					|
					|if (easy_to_free) {
					|	mmdrop(mm);
					|	...
					|
					|So this mm_struct may be freed in the mmput().
					|
up_read(&mm->mmap_sem);			|

As we can see above, the ksmd thread may access a mm_struct that already
been freed to the kmem_cache.
Suppose a fork will get this mm_struct from the kmem_cache, the ksmd thread
then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
>From the suggestion of Andrea Arcangeli, unmerge_and_remove_all_rmap_items
has the same SMP race condition, so fix it too. My prev fix in function
scan_get_next_rmap_item will introduce a different SMP race condition,
so just invert the up_read/spin_unlock order as Andrea Arcangeli said.

Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index ca6d2a0..1d4c0e8 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -777,6 +777,7 @@ static int unmerge_and_remove_all_rmap_items(void)
 		}
 
 		remove_trailing_rmap_items(mm_slot, &mm_slot->rmap_list);
+		up_read(&mm->mmap_sem);
 
 		spin_lock(&ksm_mmlist_lock);
 		ksm_scan.mm_slot = list_entry(mm_slot->mm_list.next,
@@ -788,12 +789,9 @@ static int unmerge_and_remove_all_rmap_items(void)
 
 			free_mm_slot(mm_slot);
 			clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-			up_read(&mm->mmap_sem);
 			mmdrop(mm);
-		} else {
+		} else
 			spin_unlock(&ksm_mmlist_lock);
-			up_read(&mm->mmap_sem);
-		}
 	}
 
 	/* Clean up stable nodes, but don't worry if some are still busy */
@@ -1657,8 +1655,15 @@ next_mm:
 		up_read(&mm->mmap_sem);
 		mmdrop(mm);
 	} else {
-		spin_unlock(&ksm_mmlist_lock);
 		up_read(&mm->mmap_sem);
+		/*
+		 * up_read(&mm->mmap_sem) first because after
+		 * spin_unlock(&ksm_mmlist_lock) run, the "mm" may
+		 * already have been freed under us by __ksm_exit()
+		 * because the "mm_slot" is still hashed and
+		 * ksm_scan.mm_slot doesn't point to it anymore.
+		 */
+		spin_unlock(&ksm_mmlist_lock);
 	}
 
 	/* Repeat until we've completed scanning the whole list */
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
