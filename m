Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id A881A6B004A
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 04:32:52 -0500 (EST)
From: Bob Liu <lliubbo@gmail.com>
Subject: [PATCH 2/2] ksm: cleanup: introduce ksm_check_mm()
Date: Thu, 1 Mar 2012 17:32:54 +0800
Message-ID: <1330594374-13497-2-git-send-email-lliubbo@gmail.com>
In-Reply-To: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
References: <1330594374-13497-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com, minchan.kim@gmail.com, linux-mm@kvack.org, Bob Liu <lliubbo@gmail.com>

There are multi place do the same check.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/ksm.c |   35 ++++++++++++++++++-----------------
 1 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 8e10786..33175af 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -375,11 +375,24 @@ static int break_ksm(struct vm_area_struct *vma, unsigned long addr)
 	return (ret & VM_FAULT_OOM) ? -ENOMEM : 0;
 }
 
+static int ksm_check_mm(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long addr)
+{
+	if (ksm_test_exit(mm))
+		return 0;
+	vma = find_vma(mm, addr);
+	if (!vma || vma->vm_start > addr)
+		return 0;
+	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+		return 0;
+	return 1;
+}
+
 static void break_cow(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = NULL;
 
 	/*
 	 * It is not an accident that whenever we want to break COW
@@ -388,15 +401,8 @@ static void break_cow(struct rmap_item *rmap_item)
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
+	if (ksm_check_mm(mm, vma, addr))
+		break_ksm(vma, addr);
 	up_read(&mm->mmap_sem);
 }
 
@@ -418,16 +424,11 @@ static struct page *get_mergeable_page(struct rmap_item *rmap_item)
 {
 	struct mm_struct *mm = rmap_item->mm;
 	unsigned long addr = rmap_item->address;
-	struct vm_area_struct *vma;
+	struct vm_area_struct *vma = NULL;
 	struct page *page;
 
 	down_read(&mm->mmap_sem);
-	if (ksm_test_exit(mm))
-		goto out;
-	vma = find_vma(mm, addr);
-	if (!vma || vma->vm_start > addr)
-		goto out;
-	if (!(vma->vm_flags & VM_MERGEABLE) || !vma->anon_vma)
+	if (!ksm_check_mm(mm, vma, addr))
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
