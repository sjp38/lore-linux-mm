Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 12F666B0254
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:12 -0500 (EST)
Received: by mail-pf0-f179.google.com with SMTP id e127so30208803pfe.3
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:12 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id q21si12874055pfi.231.2016.02.11.06.22.04
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:04 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 02/28] rmap: introduce rmap_walk_locked()
Date: Thu, 11 Feb 2016 17:21:30 +0300
Message-Id: <1455200516-132137-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

rmap_walk_locked() is the same as rmap_walk(), but caller takes care
about relevant rmap lock.

It's preparation to switch THP splitting from custom rmap walk in
freeze_page()/unfreeze_page() to generic one.

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
