Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E40D6B0078
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 22:12:25 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBG3CM3F030045
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Dec 2009 12:12:22 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A8E945DE60
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:12:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7066B45DE4D
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:12:22 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 581861DB803A
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:12:22 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 072A71DB8037
	for <linux-mm@kvack.org>; Wed, 16 Dec 2009 12:12:22 +0900 (JST)
Date: Wed, 16 Dec 2009 12:09:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [mm][RFC][PATCH 9/11] mm accessor for sgi gru
Message-Id: <20091216120918.41b684ba.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091216120011.3eecfe79.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "mingo@elte.hu" <mingo@elte.hu>, andi@firstfloor.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Replacing mmap_sem with mm_accessor functions. for sgi-gru.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 drivers/misc/sgi-gru/grufault.c |   16 ++++++++--------
 drivers/misc/sgi-gru/grufile.c  |    4 ++--
 2 files changed, 10 insertions(+), 10 deletions(-)

Index: mmotm-mm-accessor/drivers/misc/sgi-gru/grufault.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/misc/sgi-gru/grufault.c
+++ mmotm-mm-accessor/drivers/misc/sgi-gru/grufault.c
@@ -81,14 +81,14 @@ static struct gru_thread_state *gru_find
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = NULL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm);
 	vma = gru_find_vma(vaddr);
 	if (vma)
 		gts = gru_find_thread_state(vma, TSID(vaddr, vma));
 	if (gts)
 		mutex_lock(&gts->ts_ctxlock);
 	else
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm);
 	return gts;
 }
 
@@ -98,7 +98,7 @@ static struct gru_thread_state *gru_allo
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = ERR_PTR(-EINVAL);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm);
 	vma = gru_find_vma(vaddr);
 	if (!vma)
 		goto err;
@@ -107,11 +107,11 @@ static struct gru_thread_state *gru_allo
 	if (IS_ERR(gts))
 		goto err;
 	mutex_lock(&gts->ts_ctxlock);
-	downgrade_write(&mm->mmap_sem);
+	mm_write_to_read_lock(mm);
 	return gts;
 
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm);
 	return gts;
 }
 
@@ -121,7 +121,7 @@ err:
 static void gru_unlock_gts(struct gru_thread_state *gts)
 {
 	mutex_unlock(&gts->ts_ctxlock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm);
 }
 
 /*
@@ -583,9 +583,9 @@ static irqreturn_t gru_intr(int chiplet,
 		 */
 		gts->ustats.fmm_tlbmiss++;
 		if (!gts->ts_force_cch_reload &&
-					down_read_trylock(&gts->ts_mm->mmap_sem)) {
+					mm_read_trylock(gts->ts_mm)) {
 			gru_try_dropin(gru, gts, tfh, NULL);
-			up_read(&gts->ts_mm->mmap_sem);
+			mm_read_unlock(gts->ts_mm);
 		} else {
 			tfh_user_polling_mode(tfh);
 			STAT(intr_mm_lock_failed);
Index: mmotm-mm-accessor/drivers/misc/sgi-gru/grufile.c
===================================================================
--- mmotm-mm-accessor.orig/drivers/misc/sgi-gru/grufile.c
+++ mmotm-mm-accessor/drivers/misc/sgi-gru/grufile.c
@@ -144,7 +144,7 @@ static int gru_create_new_context(unsign
 	if (!(req.options & GRU_OPT_MISS_MASK))
 		req.options |= GRU_OPT_MISS_FMM_INTR;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm);
 	vma = gru_find_vma(req.gseg);
 	if (vma) {
 		vdata = vma->vm_private_data;
@@ -155,7 +155,7 @@ static int gru_create_new_context(unsign
 		vdata->vd_tlb_preload_count = req.tlb_preload_count;
 		ret = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm);
 
 	return ret;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
