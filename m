Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AE2EB6B0071
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:13:32 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG3DT4w001009
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:13:29 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D6E545DE70
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:13:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2DD345DE7B
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:13:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C5DF61DB8048
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:13:28 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5C04F1DB8042
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:13:28 +0900 (JST)
Date: Wed, 16 Dec 2009 12:10:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 10/11] mm accessor for misc drivers
Message-Id: <20091216121023.5340308a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

mm accessor for misc. drivers.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 drivers/dma/iovlock.c          |    4 ++--
 drivers/oprofile/buffer_sync.c |   10 +++++-----
 drivers/scsi/st.c              |    4 ++--
 drivers/video/pvr2fb.c         |    4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

Index: mmotm-mm-accessor/drivers/dma/iovlock.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/dma/iovlock.c
+++ mmotm-mm-accessor/drivers/dma/iovlock.c
@@ -94,7 +94,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 		pages += page_list->nr_pages;
 
 		/* pin pages down */
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm);
 		ret = get_user_pages(
 			current,
 			current->mm,
@@ -104,7 +104,7 @@ struct dma_pinned_list *dma_pin_iovec_pa
 			0,	/* force */
 			page_list->pages,
 			NULL);
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm);
 
 		if (ret != page_list->nr_pages)
 			goto unpin;
Index: mmotm-mm-accessor/drivers/oprofile/buffer_sync.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/oprofile/buffer_sync.c
+++ mmotm-mm-accessor/drivers/oprofile/buffer_sync.c
@@ -87,11 +87,11 @@ munmap_notify(struct notifier_block *sel
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -99,7 +99,7 @@ munmap_notify(struct notifier_block *sel
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	return 0;
 }
 
@@ -410,7 +410,7 @@ static void release_mm(struct mm_struct 
 {
 	if (!mm)
 		return;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm);
 	mmput(mm);
 }
 
@@ -419,7 +419,7 @@ static struct mm_struct *take_tasks_mm(s
 {
 	struct mm_struct *mm = get_task_mm(task);
 	if (mm)
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm);
 	return mm;
 }
 
Index: mmotm-mm-accessor/drivers/scsi/st.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/scsi/st.c
+++ mmotm-mm-accessor/drivers/scsi/st.c
@@ -4553,7 +4553,7 @@ static int sgl_map_user_pages(struct st_
 		return -ENOMEM;
 
         /* Try to fault in all of the necessary pages */
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages(
 		current,
@@ -4564,7 +4564,7 @@ static int sgl_map_user_pages(struct st_
 		0, /* don't force */
 		pages,
 		NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	/* Errors and no page mapped should return here */
 	if (res < nr_pages)
Index: mmotm-mm-accessor/drivers/video/pvr2fb.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/video/pvr2fb.c
+++ mmotm-mm-accessor/drivers/video/pvr2fb.c
@@ -686,10 +686,10 @@ static ssize_t pvr2fb_write(struct fb_in
 	if (!pages)
 		return -ENOMEM;
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm);
 	ret = get_user_pages(current, current->mm, (unsigned long)buf,
 			     nr_pages, WRITE, 0, pages, NULL);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
