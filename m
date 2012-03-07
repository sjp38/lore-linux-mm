Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id 5BB116B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 06:09:43 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH v2] ksm: cleanup: introduce find_mergeable_vma()
Date: Wed, 7 Mar 2012 19:09:48 +0800
Message-ID: <1331118588-1391-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, aarcange@redhat.com, Bob Liu <lliubbo@gmail.com>

There are multi place do the same check, using find_mergeable_vma() to
replace.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/ksm.c |   34 +++++++++++++++++++---------------
 1 files changed, 19 insertions(+), 15 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 1925ffb..3a00767 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -375,6 +375,20 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
 }
 
+static struct vm_area_struct *find_mergeable_vma(struct mm_struct *mm,
+		unsigned long addr)
+{
+	struct vm_area_struct *vma;
+	if (ksm_test_exit(mm))
+		return NULL;
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr)
+		return NULL;
+	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+		return NULL;
+	return vma;
+}
+
 static void break_cow(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
@@ -388,15 +402,9 @@ static void break_cow(struct rmap_item *rmap_item)
 	put_anon_vma(rmap_item->anon_vma);
 
 	down_read(&mm->mmap_sem);
-	if (ksm_test_exit(mm))
-		goto out;
-	vma = find_vma(mm, addr);
-	if (!vma || vma->vm_start > addr)
-		goto out;
-	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
-		goto out;
-	break_ksm(vma, addr);
-out:
+	vma = find_mergeable_vma(mm, addr);
+	if (vma)
+		break_ksm(vma, addr);
 	up_read(&mm->mmap_sem);
 }
 
@@ -422,12 +430,8 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 	struct page *page;
 
 	down_read(&mm->mmap_sem);
-	if (ksm_test_exit(mm))
-		goto out;
-	vma = find_vma(mm, addr);
-	if (!vma || vma->vm_start > addr)
-		goto out;
-	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+	vma = find_mergeable_vma(mm, addr);
+	if (!vma)
 		goto out;
 
 	page = follow_page(vma, addr, FOLL_GET);
-- 
1.7.0.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
