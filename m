Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0F1900014
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:06:50 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so229335pdb.35
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:06:50 -0700 (PDT)
Received: from homiemail-a38.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id fk2si5059635pdb.228.2014.10.24.15.06.49
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:06:49 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 04/10] mm/rmap: share the i_mmap_rwsem
Date: Fri, 24 Oct 2014 15:06:14 -0700
Message-Id: <1414188380-17376-5-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
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
---
 include/linux/fs.h | 10 ++++++++++
 mm/rmap.c          |  6 +++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index b183792..1059be0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -465,6 +465,16 @@ static inline void i_mmap_unlock_write(struct address_space *mapping)
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
index f234bc6..a77726f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1674,7 +1674,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
 
 	if (!mapping)
 		return ret;
-	i_mmap_lock_write(mapping);
+
+	i_mmap_lock_read(mapping);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 
@@ -1695,9 +1696,8 @@ static int rmap_walk_file(struct page *page, struct rmap_walk_control *rwc)
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
