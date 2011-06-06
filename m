Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2F56B011D
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:23:29 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p564NPfd025649
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:23:25 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by kpbe19.cbf.corp.google.com with ESMTP id p564NNMO030158
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:23:23 -0700
Received: by pwi16 with SMTP id 16so2049641pwi.7
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:23:23 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:23:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/14] mm: move vmtruncate_range to truncate.c
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052121570.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

You would expect to find vmtruncate_range() next to vmtruncate()
in mm/truncate.c: move it there.

Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Christoph Hellwig <hch@infradead.org>
---
 mm/memory.c   |   24 ------------------------
 mm/truncate.c |   24 ++++++++++++++++++++++++
 2 files changed, 24 insertions(+), 24 deletions(-)

--- linux.orig/mm/memory.c	2011-05-29 18:42:37.441882660 -0700
+++ linux/mm/memory.c	2011-06-05 14:26:36.383176813 -0700
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
--- linux.orig/mm/truncate.c	2011-05-29 18:42:37.477882839 -0700
+++ linux/mm/truncate.c	2011-06-05 17:16:33.369740944 -0700
@@ -603,3 +603,27 @@ int vmtruncate(struct inode *inode, loff
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
