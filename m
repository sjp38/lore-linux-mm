Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 744026B0038
	for <linux-mm@kvack.org>; Thu, 15 Sep 2016 13:41:48 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id t67so115070633ywg.3
        for <linux-mm@kvack.org>; Thu, 15 Sep 2016 10:41:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p126si1993676ybg.298.2016.09.15.10.41.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Sep 2016 10:41:47 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/2] mm: vm_page_prot: update with WRITE_ONCE/READ_ONCE
Date: Thu, 15 Sep 2016 19:41:43 +0200
Message-Id: <1473961304-19370-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
References: <1473961304-19370-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>, Jan Vorlicek <janvorli@microsoft.com>, Aditya Mandaleeka <adityam@microsoft.com>

vma->vm_page_prot is read lockless from the rmap_walk, it may be
updated concurrently and this prevents the risk of reading
intermediate values.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 2 +-
 mm/migrate.c     | 2 +-
 mm/mmap.c        | 9 ++++++---
 3 files changed, 8 insertions(+), 5 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index cb95a83..995f8a1 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1566,7 +1566,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 			if (soft_dirty)
 				entry = pte_swp_mksoft_dirty(entry);
 		} else {
-			entry = mk_pte(page + i, vma->vm_page_prot);
+			entry = mk_pte(page + i, READ_ONCE(vma->vm_page_prot));
 			entry = maybe_mkwrite(entry, vma);
 			if (!write)
 				entry = pte_wrprotect(entry);
diff --git a/mm/migrate.c b/mm/migrate.c
index 00167df..e49ccce 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -234,7 +234,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 		goto unlock;
 
 	get_page(new);
-	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
+	pte = pte_mkold(mk_pte(new, READ_ONCE(vma->vm_page_prot)));
 	if (pte_swp_soft_dirty(*ptep))
 		pte = pte_mksoft_dirty(pte);
 
diff --git a/mm/mmap.c b/mm/mmap.c
index c34f643..1abf106 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -112,13 +112,16 @@ static pgprot_t vm_pgprot_modify(pgprot_t oldprot, unsigned long vm_flags)
 void vma_set_page_prot(struct vm_area_struct *vma)
 {
 	unsigned long vm_flags = vma->vm_flags;
+	pgprot_t vm_page_prot;
 
-	vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
+	vm_page_prot = vm_pgprot_modify(vma->vm_page_prot, vm_flags);
 	if (vma_wants_writenotify(vma)) {
 		vm_flags &= ~VM_SHARED;
-		vma->vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
-						     vm_flags);
+		vm_page_prot = vm_pgprot_modify(vma->vm_page_prot,
+						vm_flags);
 	}
+	/* remove_protection_ptes reads vma->vm_page_prot without mmap_sem */
+	WRITE_ONCE(vma->vm_page_prot, vm_page_prot);
 }
 
 static unsigned long vm_mergeable __read_mostly;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
