Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id CD89B6B0069
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 02:56:30 -0400 (EDT)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 31 Aug 2012 00:56:30 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 43D0A3E4003F
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 00:55:46 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7V6tkbx177734
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 00:55:46 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7V6tjiD031659
	for <linux-mm@kvack.org>; Fri, 31 Aug 2012 00:55:45 -0600
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2] mm/mmu_notifier: init notifier if necessary
Date: Fri, 31 Aug 2012 14:55:40 +0800
Message-Id: <1346396140-32344-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

While registering MMU notifier, new instance of MMU notifier_mm will
be allocated and later free'd if currrent mm_struct's MMU notifier_mm
has been initialized. That cause some overhead. The patch tries to
eleminate that by allocating the MMU notifier_mm only when the current
mm_struct doesn't have initialized MMU notifier_mm yet.

v2: Using GFP_KERNEL instead of GFP_ATOMIC when allocating the MMU
    notifier_mm as Andrew suggested.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/mmu_notifier.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 862b608..8676453 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -192,22 +192,23 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 
-	ret = -ENOMEM;
-	mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm), GFP_KERNEL);
-	if (unlikely(!mmu_notifier_mm))
-		goto out;
-
 	if (take_mmap_sem)
 		down_write(&mm->mmap_sem);
 	ret = mm_take_all_locks(mm);
 	if (unlikely(ret))
-		goto out_cleanup;
+		goto out;
 
 	if (!mm_has_notifiers(mm)) {
+		mmu_notifier_mm = kmalloc(sizeof(struct mmu_notifier_mm),
+					GFP_KERNEL);
+		if (unlikely(!mmu_notifier_mm)) {
+			ret = -ENOMEM;
+			goto out_of_mem;
+		}
 		INIT_HLIST_HEAD(&mmu_notifier_mm->list);
 		spin_lock_init(&mmu_notifier_mm->lock);
+
 		mm->mmu_notifier_mm = mmu_notifier_mm;
-		mmu_notifier_mm = NULL;
 	}
 	atomic_inc(&mm->mm_count);
 
@@ -223,13 +224,12 @@ static int do_mmu_notifier_register(struct mmu_notifier *mn,
 	hlist_add_head(&mn->hlist, &mm->mmu_notifier_mm->list);
 	spin_unlock(&mm->mmu_notifier_mm->lock);
 
+out_of_mem:
 	mm_drop_all_locks(mm);
-out_cleanup:
+out:
 	if (take_mmap_sem)
 		up_write(&mm->mmap_sem);
-	/* kfree() does nothing if mmu_notifier_mm is NULL */
-	kfree(mmu_notifier_mm);
-out:
+
 	BUG_ON(atomic_read(&mm->mm_users) <= 0);
 	return ret;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
