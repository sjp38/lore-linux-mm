Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 83E916B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 12:06:20 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so7614171pbc.14
        for <linux-mm@kvack.org>; Mon, 26 Mar 2012 09:06:19 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/1] mmap.c: find_vma: replace if(mm) check with BUG_ON(!mm)
Date: Mon, 26 Mar 2012 12:06:05 -0400
Message-Id: <1332777965-2534-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

find_vma is called from kernel code where it is absolutely
sure that the mm_struct arg being passed to it is non-NULL.

Convert the if check to a BUG_ON.
This will also serve the purpose of mandating that the execution
context(user-mode/kernel-mode) be known before find_vma is called.

Also fixed 2 checkpatch.pl errors in this function for the rb_node
and vma_tmp local variables.

I have tested this patch on my x86 PC and there are no BUG_ON crashes
due to this in the course of normal desktop execution.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/mmap.c |   52 ++++++++++++++++++++++++++--------------------------
 1 files changed, 26 insertions(+), 26 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index a7bf6a3..7589965 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1589,33 +1589,33 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma = NULL;
 
-	if (mm) {
-		/* Check the cache first. */
-		/* (Cache hit rate is typically around 35%.) */
-		vma = mm->mmap_cache;
-		if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
-			struct rb_node * rb_node;
-
-			rb_node = mm->mm_rb.rb_node;
-			vma = NULL;
-
-			while (rb_node) {
-				struct vm_area_struct * vma_tmp;
-
-				vma_tmp = rb_entry(rb_node,
-						struct vm_area_struct, vm_rb);
-
-				if (vma_tmp->vm_end > addr) {
-					vma = vma_tmp;
-					if (vma_tmp->vm_start <= addr)
-						break;
-					rb_node = rb_node->rb_left;
-				} else
-					rb_node = rb_node->rb_right;
-			}
-			if (vma)
-				mm->mmap_cache = vma;
+	BUG_ON(!mm);
+
+	/* Check the cache first. */
+	/* (Cache hit rate is typically around 35%.) */
+	vma = mm->mmap_cache;
+	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
+		struct rb_node *rb_node;
+
+		rb_node = mm->mm_rb.rb_node;
+		vma = NULL;
+
+		while (rb_node) {
+			struct vm_area_struct *vma_tmp;
+
+			vma_tmp = rb_entry(rb_node,
+					struct vm_area_struct, vm_rb);
+
+			if (vma_tmp->vm_end > addr) {
+				vma = vma_tmp;
+				if (vma_tmp->vm_start <= addr)
+					break;
+				rb_node = rb_node->rb_left;
+			} else
+				rb_node = rb_node->rb_right;
 		}
+		if (vma)
+			mm->mmap_cache = vma;
 	}
 	return vma;
 }
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
