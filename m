Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8963B8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 09:57:11 -0400 (EDT)
Received: by mail-pv0-f169.google.com with SMTP id 4so777017pvg.14
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 06:57:10 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 3/6] nommu: find vma using the sorted vma list
Date: Mon, 28 Mar 2011 22:56:44 +0900
Message-Id: <1301320607-7259-4-git-send-email-namhyung@gmail.com>
In-Reply-To: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
References: <1301320607-7259-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Now we have the sorted vma list, use it in the find_vma[_exact]()
rather than doing linear search on the rb-tree.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/nommu.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index a6a073f0745a..6c5a13b507b4 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -828,17 +828,15 @@ static void delete_vma(struct mm_struct *mm, struct vm_area_struct *vma)
 struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 {
 	struct vm_area_struct *vma;
-	struct rb_node *n = mm->mm_rb.rb_node;
 
 	/* check the cache first */
 	vma = mm->mmap_cache;
 	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
 		return vma;
 
-	/* trawl the tree (there may be multiple mappings in which addr
+	/* trawl the list (there may be multiple mappings in which addr
 	 * resides) */
-	for (n = rb_first(&mm->mm_rb); n; n = rb_next(n)) {
-		vma = rb_entry(n, struct vm_area_struct, vm_rb);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start > addr)
 			return NULL;
 		if (vma->vm_end > addr) {
@@ -878,7 +876,6 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 					     unsigned long len)
 {
 	struct vm_area_struct *vma;
-	struct rb_node *n = mm->mm_rb.rb_node;
 	unsigned long end = addr + len;
 
 	/* check the cache first */
@@ -886,10 +883,9 @@ static struct vm_area_struct *find_vma_exact(struct mm_struct *mm,
 	if (vma && vma->vm_start == addr && vma->vm_end == end)
 		return vma;
 
-	/* trawl the tree (there may be multiple mappings in which addr
+	/* trawl the list (there may be multiple mappings in which addr
 	 * resides) */
-	for (n = rb_first(&mm->mm_rb); n; n = rb_next(n)) {
-		vma = rb_entry(n, struct vm_area_struct, vm_rb);
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (vma->vm_start < addr)
 			continue;
 		if (vma->vm_start > addr)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
