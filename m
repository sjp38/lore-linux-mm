Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id E1A256B002B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2012 10:37:27 -0400 (EDT)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sat, 25 Aug 2012 00:35:52 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7OESbFJ29360258
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:28:37 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7OEbLlP032491
	for <linux-mm@kvack.org>; Sat, 25 Aug 2012 00:37:21 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm/mmu_notifier: init notifier if necessary
Date: Fri, 24 Aug 2012 22:37:04 +0800
Message-Id: <1345819025-12445-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Gavin Shan <shangw@linux.vnet.ibm.com>

While registering MMU notifier, new instance of MMU notifier_mm will
be allocated and later free'd if currrent mm_struct's MMU notifier_mm
has been initialized. That cause some overhead. The patch tries to
eleminate that.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 mm/mmu_notifier.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 862b608..fb4067f 100644
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
+					GFP_ATOMIC);
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
