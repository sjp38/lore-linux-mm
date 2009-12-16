Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 86D876B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:10:34 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG3AWc7032256
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:10:32 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D48C145DE6E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:10:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id AD7C745DE7A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:10:31 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8342C1DB8040
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:10:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 264301DB803E
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:10:31 +0900 (JST)
Date: Wed, 16 Dec 2009 12:07:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 7/11] mm accessor for inifiniband
Message-Id: <20091216120724.cb424ed3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Replacing mmap_sem with mm_accessor, for inifiniband.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/infiniband/core/umem.c                 |   14 +++++++-------
 drivers/infiniband/hw/ipath/ipath_user_pages.c |   12 ++++++------
 drivers/infiniband/hw/ipath/ipath_user_sdma.c  |    4 ++--
 3 files changed, 15 insertions(+), 15 deletions(-)

Index: mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_pages.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/hw/ipath/ipath_user_pages.c
+++ mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_pages.c
@@ -162,24 +162,24 @@ int ipath_get_user_pages(unsigned long s
 {
 	int ret;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	ret = __get_user_pages(start_page, num_pages, p, NULL);
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return ret;
 }
 
 void ipath_release_user_pages(struct page **p, size_t num_pages)
 {
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	__ipath_release_user_pages(p, num_pages, 1);
 
 	current->mm->locked_vm -= num_pages;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 }
 
 struct ipath_user_pages_work {
@@ -193,9 +193,9 @@ static void user_pages_account(struct wo
 	struct ipath_user_pages_work *work =
 		container_of(_work, struct ipath_user_pages_work, work);
 
-	down_write(&work->mm->mmap_sem);
+	mm_write_lock(work->mm);
 	work->mm->locked_vm -= work->num_pages;
-	up_write(&work->mm->mmap_sem);
+	mm_write_unlock(work->mm);
 	mmput(work->mm);
 	kfree(work);
 }
Index: mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_sdma.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/hw/ipath/ipath_user_sdma.c
+++ mmotm-mm-accessor/drivers/infiniband/hw/ipath/ipath_user_sdma.c
@@ -811,9 +811,9 @@ int ipath_user_sdma_writev(struct ipath_
 	while (dim) {
 		const int mxp = 8;
 
-		down_write(&current->mm->mmap_sem);
+		mm_write_lock(current->mm);
 		ret = ipath_user_sdma_queue_pkts(dd, pq, &list, iov, dim, mxp);
-		up_write(&current->mm->mmap_sem);
+		mm_write_unlock(current->mm);
 
 		if (ret <= 0)
 			goto done_unlock;
Index: mmotm-mm-accessor/drivers/infiniband/core/umem.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/infiniband/core/umem.c
+++ mmotm-mm-accessor/drivers/infiniband/core/umem.c
@@ -133,7 +133,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 
 	npages = PAGE_ALIGN(size + umem->offset) >> PAGE_SHIFT;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 
 	locked     = npages + current->mm->locked_vm;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
@@ -207,7 +207,7 @@ out:
 	} else
 		current->mm->locked_vm = locked;
 
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 	if (vma_list)
 		free_page((unsigned long) vma_list);
 	free_page((unsigned long) page_list);
@@ -220,9 +220,9 @@ static void ib_umem_account(struct work_
 {
 	struct ib_umem *umem = container_of(work, struct ib_umem, work);
 
-	down_write(&umem->mm->mmap_sem);
+	mm_write_lock(umem->mm);
 	umem->mm->locked_vm -= umem->diff;
-	up_write(&umem->mm->mmap_sem);
+	mm_write_unlock(umem->mm);
 	mmput(umem->mm);
 	kfree(umem);
 }
@@ -256,7 +256,7 @@ void ib_umem_release(struct ib_umem *ume
 	 * we defer the vm_locked accounting to the system workqueue.
 	 */
 	if (context->closing) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm)) {
 			INIT_WORK(&umem->work, ib_umem_account);
 			umem->mm   = mm;
 			umem->diff = diff;
@@ -265,10 +265,10 @@ void ib_umem_release(struct ib_umem *ume
 			return;
 		}
 	} else
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm);
 
 	current->mm->locked_vm -= diff;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	mmput(mm);
 	kfree(umem);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
