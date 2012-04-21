Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 3C3B16B004D
	for <linux-mm@kvack.org>; Sat, 21 Apr 2012 09:43:20 -0400 (EDT)
Received: by pbcup15 with SMTP id up15so2606099pbc.14
        for <linux-mm@kvack.org>; Sat, 21 Apr 2012 06:43:19 -0700 (PDT)
From: Rajman Mekaco <rajman.mekaco@gmail.com>
Subject: [PATCH 1/1] mmap.c: find_vma: remove unnecessary if(mm) check
Date: Sat, 21 Apr 2012 19:12:35 +0530
Message-Id: <1335015755-2881-1-git-send-email-rajman.mekaco@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rajman Mekaco <rajman.mekaco@gmail.com>, Kautuk Consul <consul.kautuk@gmail.com>

The if(mm) check is not required in find_vma, as the kernel
code calls find_vma only when it is absolutely sure that the
mm_struct arg to it is non-NULL.

Removing the if(mm) check and adding the a WARN_ONCE(!mm)
for now.
This will serve the purpose of mandating that the execution
context(user-mode/kernel-mode) be known before find_vma is called.
Also fixed 2 checkpatch.pl errors in the declaration
of the rb_node and vma_tmp local variables.

I was browsing through the internet and read a discussion
at https://lkml.org/lkml/2012/3/27/342 which discusses removal
of the validation check within find_vma.
Since no-one responded, I decided to send this patch with Andrew's
suggestions.

Signed-off-by: Rajman Mekaco <rajman.mekaco@gmail.com>
Cc: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/mmap.c |   53 +++++++++++++++++++++++++++--------------------------
 1 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index b38b47e..1c3ef5d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1616,33 +1616,34 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
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
+	if (WARN_ON_ONCE(!mm))
+		return NULL;
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
+					   struct vm_area_struct, vm_rb);
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
