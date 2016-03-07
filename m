Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 488D0828E4
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 06:57:26 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id bj10so78137916pad.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 03:57:26 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id gr1si2726551pac.52.2016.03.07.03.57.22
        for <linux-mm@kvack.org>;
        Mon, 07 Mar 2016 03:57:23 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 1/4] rmap: introduce rmap_walk_locked()
Date: Mon,  7 Mar 2016 14:57:15 +0300
Message-Id: <1457351838-114702-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1457351838-114702-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

rmap_walk_locked() is the same as rmap_walk(), but caller takes care
about relevant rmap lock.

It's preparation to switch THP splitting from custom rmap walk in
freeze_page()/unfreeze_page() to generic one.

Not support for KSM pages for now: not clear which lock is implied.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  1 +
 mm/rmap.c            | 41 ++++++++++++++++++++++++++++++++---------
 2 files changed, 33 insertions(+), 9 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index a07f42bedda3..a5875e9b4a27 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -266,6 +266,7 @@ struct rmap_walk_control {
 };
 
 int rmap_walk(struct page *page, struct rmap_walk_control *rwc);
+int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc);
 
 #else	/* !CONFIG_MMU */
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 02f0bfc3c80a..30b739ce0ffa 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1715,14 +1715,21 @@ static struct anon_vma *rmap_walk_anon_lock(struct page *page,
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * LOCKED.
  */
-static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
+static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc,
+		bool locked)
 {
 	struct anon_vma *anon_vma;
 	pgoff_t pgoff;
 	struct anon_vma_chain *avc;
 	int ret = SWAP_AGAIN;
 
-	anon_vma = rmap_walk_anon_lock(page, rwc);
+	if (locked) {
+		anon_vma = page_anon_vma(page);
+		/* anon_vma disappear under us? */
+		VM_BUG_ON_PAGE(!anon_vma, page);
+	} else {
+		anon_vma = rmap_walk_anon_lock(page, rwc);
+	}
 	if (!anon_vma)
 		return ret;
 
@@ -1742,7 +1749,9 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
 		if (rwc->done && rwc->done(page))
 			break;
 	}
-	anon_vma_unlock_read(anon_vma);
+
+	if (!locked)
+		anon_vma_unlock_read(anon_vma);
 	return ret;
 }
 
@@ -1759,9 +1768,10 @@ static int rmap_walk_anon(struct page *page, struct rmap_walk_control *rwc)
  * vm_flags for that VMA.  That should be OK, because that vma shouldn't be
  * LOCKED.
  */
-static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
+static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc,
+		bool locked)
 {
-	struct address_space *mapping = page->mapping;
+	struct address_space *mapping = page_mapping(page);
 	pgoff_t pgoff;
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
@@ -1778,7 +1788,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 		return ret;
 
 	pgoff = page_to_pgoff(page);
-	i_mmap_lock_read(mapping);
+	if (!locked)
+		i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1795,7 +1806,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 	}
 
 done:
-	i_mmap_unlock_read(mapping);
+	if (!locked)
+		i_mmap_unlock_read(mapping);
 	return ret;
 }
 
@@ -1804,9 +1816,20 @@ int rmap_walk(struct page *page, struct rmap_walk_control *rwc)
 	if (unlikely(PageKsm(page)))
 		return rmap_walk_ksm(page, rwc);
 	else if (PageAnon(page))
-		return rmap_walk_anon(page, rwc);
+		return rmap_walk_anon(page, rwc, false);
+	else
+		return rmap_walk_file(page, rwc, false);
+}
+
+/* Like rmap_walk, but caller holds relevant rmap lock */
+int rmap_walk_locked(struct page *page, struct rmap_walk_control *rwc)
+{
+	/* no ksm support for now */
+	VM_BUG_ON_PAGE(PageKsm(page), page);
+	if (PageAnon(page))
+		return rmap_walk_anon(page, rwc, true);
 	else
-		return rmap_walk_file(page, rwc);
+		return rmap_walk_file(page, rwc, true);
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
