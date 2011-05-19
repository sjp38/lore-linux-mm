Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C81E86B0023
	for <linux-mm@kvack.org>; Thu, 19 May 2011 18:49:13 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4JMf4bw031135
	for <linux-mm@kvack.org>; Thu, 19 May 2011 16:41:04 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4JMn7A7161504
	for <linux-mm@kvack.org>; Thu, 19 May 2011 16:49:07 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4JGmcMj026879
	for <linux-mm@kvack.org>; Thu, 19 May 2011 10:48:40 -0600
Subject: [PATCH 3/3] mm: Provide stub page_mkwrite functionality to stabilize
	pages during writes
From: "Darrick J. Wong" <djwong@us.ibm.com>
Date: Thu, 19 May 2011 15:49:03 -0700
Message-ID: <20110519224903.28755.2703.stgit@elm3c44.beaverton.ibm.com>
In-Reply-To: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com>
References: <20110519224841.28755.80650.stgit@elm3c44.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <djwong@us.ibm.com>
Cc: Jens Axboe <axboe@kernel.dk>, Theodore Tso <tytso@mit.edu>, "Martin K. Petersen" <martin.petersen@oracle.com>, Jeff Layton <jlayton@redhat.com>, Dave Chinner <david@fromorbit.com>, linux-kernel <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Chris Mason <chris.mason@oracle.com>, Joel Becker <jlbec@evilplan.org>, linux-scsi <linux-scsi@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, linux-ext4@vger.kernel.org, Mingming Cao <mcao@us.ibm.com>

For filesystems that do not provide any page_mkwrite handler, provide a stub
page_mkwrite function that locks the page and waits for pending writeback to
complete.  This is needed to stabilize pages during writes for a large variety
of filesystem drivers (ext2, ext3, vfat, hfs...).

Signed-off-by: Darrick J. Wong <djwong@us.ibm.com>
---
 mm/filemap.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)


diff --git a/mm/filemap.c b/mm/filemap.c
index fd0e7f2..2a922b4 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1713,8 +1713,27 @@ page_not_uptodate:
 }
 EXPORT_SYMBOL(filemap_fault);
 
+static int stub_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
+{
+	struct page *page = vmf->page;
+	struct inode *inode = vma->vm_file->f_path.dentry->d_inode;
+	loff_t size;
+
+	lock_page(page);
+	size = i_size_read(inode);
+	if ((page->mapping != inode->i_mapping) ||
+	    (page_offset(page) > size)) {
+		/* page got truncated out from underneath us */
+		unlock_page(page);
+		return VM_FAULT_NOPAGE;
+	}
+	wait_on_page_writeback(page);
+	return VM_FAULT_LOCKED;
+}
+
 const struct vm_operations_struct generic_file_vm_ops = {
 	.fault		= filemap_fault,
+	.page_mkwrite	= stub_page_mkwrite,
 };
 
 /* This is used for a general mmap of a disk file */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
