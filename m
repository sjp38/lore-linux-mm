Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 276246B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:37:06 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p4V0axxb032747
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:36:59 -0700
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz21.hot.corp.google.com with ESMTP id p4V0avuY021101
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:36:58 -0700
Received: by pwj9 with SMTP id 9so2468682pwj.34
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:36:57 -0700 (PDT)
Date: Mon, 30 May 2011 17:36:57 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 2/14] mm: move vmtruncate_range to truncate.c
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301735520.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

You would expect to find vmtruncate_range() next to vmtruncate()
in mm/truncate.c: move it there.

Signed-off-by: Hugh Dickins <hughd@google.co>
---
 mm/memory.c   |   24 ------------------------
 mm/truncate.c |   24 ++++++++++++++++++++++++
 2 files changed, 24 insertions(+), 24 deletions(-)

--- linux.orig/mm/memory.c	2011-05-30 13:56:10.416798124 -0700
+++ linux/mm/memory.c	2011-05-30 14:09:52.908876549 -0700
@@ -2796,30 +2796,6 @@ void unmap_mapping_range(struct address_
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
-int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
-{
-	struct address_space *mapping = inode->i_mapping;
-
-	/*
-	 * If the underlying filesystem is not going to provide
-	 * a way to truncate a range of blocks (punch a hole) -
-	 * we should return failure right now.
-	 */
-	if (!inode->i_op->truncate_range)
-		return -ENOSYS;
-
-	mutex_lock(&inode->i_mutex);
-	down_write(&inode->i_alloc_sem);
-	unmap_mapping_range(mapping, offset, (end - offset), 1);
-	truncate_inode_pages_range(mapping, offset, end);
-	unmap_mapping_range(mapping, offset, (end - offset), 1);
-	inode->i_op->truncate_range(inode, offset, end);
-	up_write(&inode->i_alloc_sem);
-	mutex_unlock(&inode->i_mutex);
-
-	return 0;
-}
-
 /*
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
--- linux.orig/mm/truncate.c	2011-05-30 14:08:46.612547848 -0700
+++ linux/mm/truncate.c	2011-05-30 14:09:52.912876640 -0700
@@ -605,3 +605,27 @@ int vmtruncate(struct inode *inode, loff
 	return 0;
 }
 EXPORT_SYMBOL(vmtruncate);
+
+int vmtruncate_range(struct inode *inode, loff_t offset, loff_t end)
+{
+	struct address_space *mapping = inode->i_mapping;
+
+	/*
+	 * If the underlying filesystem is not going to provide
+	 * a way to truncate a range of blocks (punch a hole) -
+	 * we should return failure right now.
+	 */
+	if (!inode->i_op->truncate_range)
+		return -ENOSYS;
+
+	mutex_lock(&inode->i_mutex);
+	down_write(&inode->i_alloc_sem);
+	unmap_mapping_range(mapping, offset, (end - offset), 1);
+	truncate_inode_pages_range(mapping, offset, end);
+	unmap_mapping_range(mapping, offset, (end - offset), 1);
+	inode->i_op->truncate_range(inode, offset, end);
+	up_write(&inode->i_alloc_sem);
+	mutex_unlock(&inode->i_mutex);
+
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
