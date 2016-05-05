Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 153DA6B0005
	for <linux-mm@kvack.org>; Thu,  5 May 2016 08:59:32 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yl2so113523980pac.2
        for <linux-mm@kvack.org>; Thu, 05 May 2016 05:59:32 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id pb2si11356987pac.41.2016.05.05.05.59.12
        for <linux-mm@kvack.org>;
        Thu, 05 May 2016 05:59:31 -0700 (PDT)
From: Zhou Chengming <zhouchengming1@huawei.com>
Subject: [PATCH] ksm: fix conflict between mmput and scan_get_next_rmap_item
Date: Thu, 5 May 2016 20:42:56 +0800
Message-ID: <1462452176-33462-1-git-send-email-zhouchengming1@huawei.com>
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
					|So this mm_struct will be freed successfully.
					|
up_read(&mm->mmap_sem);			|

As we can see above, the ksmd thread may access a mm_struct that already
been freed to the kmem_cache.
Suppose a fork will get this mm_struct from the kmem_cache, the ksmd thread
then call up_read(&mm->mmap_sem), will cause mmap_sem.count to become -1.
I changed the scan_get_next_rmap_item function refered to the khugepaged
scan function.

Signed-off-by: Zhou Chengming <zhouchengming1@huawei.com>
---
 mm/ksm.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 7ee101e..6e4324d 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1650,6 +1650,7 @@ next_mm:
 	 * because there were no VM_MERGEABLE vmas with such addresses.
 	 */
 	remove_trailing_rmap_items(slot, ksm_scan.rmap_list);
+	up_read(&mm->mmap_sem);
 
 	spin_lock(&ksm_mmlist_lock);
 	ksm_scan.mm_slot = list_entry(slot->mm_list.next,
@@ -1666,16 +1667,12 @@ next_mm:
 		 */
 		hash_del(&slot->link);
 		list_del(&slot->mm_list);
-		spin_unlock(&ksm_mmlist_lock);
 
 		free_mm_slot(slot);
 		clear_bit(MMF_VM_MERGEABLE, &mm->flags);
-		up_read(&mm->mmap_sem);
 		mmdrop(mm);
-	} else {
-		spin_unlock(&ksm_mmlist_lock);
-		up_read(&mm->mmap_sem);
 	}
+	spin_unlock(&ksm_mmlist_lock);
 
 	/* Repeat until we've completed scanning the whole list */
 	slot = ksm_scan.mm_slot;
-- 
1.7.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
