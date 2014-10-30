Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id BCD68280011
	for <linux-mm@kvack.org>; Thu, 30 Oct 2014 15:34:41 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id y10so5804396pdj.0
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 12:34:41 -0700 (PDT)
Received: from theshire.emacs.cl (theshire.emacs.cl. [192.155.80.235])
        by mx.google.com with ESMTP id ey5si7395230pdb.122.2014.10.30.12.34.38
        for <linux-mm@kvack.org>;
        Thu, 30 Oct 2014 12:34:38 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 04/10] mm/rmap: share the i_mmap_rwsem
Date: Thu, 30 Oct 2014 12:34:11 -0700
Message-Id: <1414697657-1678-5-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
References: <1414697657-1678-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

Similarly to the anon memory counterpart, we can share
the mapping's lock ownership as the interval tree is
not modified when doing doing the walk, only the file
page.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@intel.linux.com>
---
 include/linux/fs.h | 10 ++++++++++
 mm/rmap.c          |  6 +++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 648a77e..552a9fc 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -478,6 +478,16 @@ static inline void i_mmap_unlock_write(struct address_space *mapping)
 	up_write(&mapping->i_mmap_rwsem);
 }
 
+static inline void i_mmap_lock_read(struct address_space *mapping)
+{
+	down_read(&mapping->i_mmap_rwsem);
+}
+
+static inline void i_mmap_unlock_read(struct address_space *mapping)
+{
+	up_read(&mapping->i_mmap_rwsem);
+}
+
 /*
  * Might pages of this file be mapped into userspace?
  */
diff --git a/mm/rmap.c b/mm/rmap.c
index e0c0e90..7ab830b 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1688,7 +1688,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 
 	if (!mapping)
 		return ret;
-	i_mmap_lock_write(mapping);
+
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1709,9 +1710,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 		goto done;
 
 	ret = rwc->file_nonlinear(page, mapping, rwc->arg);
-
 done:
-	i_mmap_unlock_write(mapping);
+	i_mmap_unlock_read(mapping);
 	return ret;
 }
 
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
