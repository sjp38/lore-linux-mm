Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1056A900017
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 18:06:54 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id et14so1883302pad.17
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 15:06:53 -0700 (PDT)
Received: from homiemail-a38.g.dreamhost.com (homie.mail.dreamhost.com. [208.97.132.208])
        by mx.google.com with ESMTP id fz2si5161333pdb.100.2014.10.24.15.06.52
        for <linux-mm@kvack.org>;
        Fri, 24 Oct 2014 15:06:53 -0700 (PDT)
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: [PATCH 09/10] mm/nommu: share the i_mmap_rwsem
Date: Fri, 24 Oct 2014 15:06:19 -0700
Message-Id: <1414188380-17376-10-git-send-email-dave@stgolabs.net>
In-Reply-To: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
References: <1414188380-17376-1-git-send-email-dave@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: hughd@google.com, riel@redhat.com, mgorman@suse.de, peterz@infradead.org, mingo@kernel.org, linux-kernel@vger.kernel.org, dbueso@suse.de, linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>

Shrinking/truncate logic can call nommu_shrink_inode_mappings()
to verify that any shared mappings of the inode in question aren't
broken (dead zone). afaict the only user being ramfs to handle
the size change attribute.

Pretty much a no-brainer to share the lock.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 mm/nommu.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/nommu.c b/mm/nommu.c
index 52a5765..cd519e1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -2094,14 +2094,14 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	high = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	down_write(&nommu_region_sem);
-	i_mmap_lock_write(inode->i_mapping);
+	i_mmap_lock_read(inode->i_mapping);
 
 	/* search for VMAs that fall within the dead zone */
 	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap, low, high) {
 		/* found one - only interested if it's shared out of the page
 		 * cache */
 		if (vma->vm_flags & VM_SHARED) {
-			i_mmap_unlock_write(inode->i_mapping);
+			i_mmap_unlock_read(inode->i_mapping);
 			up_write(&nommu_region_sem);
 			return -ETXTBSY; /* not quite true, but near enough */
 		}
@@ -2113,8 +2113,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	 * we don't check for any regions that start beyond the EOF as there
 	 * shouldn't be any
 	 */
-	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap,
-				  0, ULONG_MAX) {
+	vma_interval_tree_foreach(vma, &inode->i_mapping->i_mmap, 0, ULONG_MAX) {
 		if (!(vma->vm_flags & VM_SHARED))
 			continue;
 
@@ -2129,7 +2128,7 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 		}
 	}
 
-	i_mmap_unlock_write(inode->i_mapping);
+	i_mmap_unlock_read(inode->i_mapping);
 	up_write(&nommu_region_sem);
 	return 0;
 }
-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
