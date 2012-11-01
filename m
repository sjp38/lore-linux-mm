Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 80DA06B0068
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 03:58:38 -0400 (EDT)
Subject: [PATCH 2/3] mm: Only enforce stable page writes if the backing device
 requires it
From: "Darrick J. Wong" <darrick.wong@oracle.com>
Date: Thu, 01 Nov 2012 00:58:21 -0700
Message-ID: <20121101075821.16153.38301.stgit@blackbox.djwong.org>
In-Reply-To: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, darrick.wong@oracle.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov
Cc: linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, bharrosh@panasas.com, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

Create a helper function to check if a backing device requires stable page
writes and, if so, performs the necessary wait.  Then, make it so that all
points in the memory manager that handle making pages writable use the helper
function.  This should provide stable page write support to most filesystems,
while eliminating unnecessary waiting for devices that don't require the
feature.

Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
---
 fs/buffer.c             |    2 +-
 fs/ext4/inode.c         |    2 +-
 include/linux/pagemap.h |    1 +
 mm/filemap.c            |    3 ++-
 mm/page-writeback.c     |   11 +++++++++++
 5 files changed, 16 insertions(+), 3 deletions(-)


diff --git a/fs/buffer.c b/fs/buffer.c
index b5f0442..cac3007 100644
--- a/fs/buffer.c
+++ b/fs/buffer.c
@@ -2334,7 +2334,7 @@ int __block_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf,
 	if (unlikely(ret < 0))
 		goto out_unlock;
 	set_page_dirty(page);
-	wait_on_page_writeback(page);
+	wait_on_stable_page_write(page);
 	return 0;
 out_unlock:
 	unlock_page(page);
diff --git a/fs/ext4/inode.c b/fs/ext4/inode.c
index b3c243b..948d68a 100644
--- a/fs/ext4/inode.c
+++ b/fs/ext4/inode.c
@@ -4814,7 +4814,7 @@ int ext4_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 		if (!walk_page_buffers(NULL, page_buffers(page), 0, len, NULL,
 					ext4_bh_unmapped)) {
 			/* Wait so that we don't change page under IO */
-			wait_on_page_writeback(page);
+			wait_on_stable_page_write(page);
 			ret = VM_FAULT_LOCKED;
 			goto out;
 		}
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index e42c762..c28da25 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -398,6 +398,7 @@ static inline void wait_on_page_writeback(struct page *page)
 }
 
 extern void end_page_writeback(struct page *page);
+void wait_on_stable_page_write(struct page *page);
 
 /*
  * Add an arbitrary waiter to a page's wait queue
diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..ee46141 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1728,6 +1728,7 @@ int filemap_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
 	 * see the dirty page and writeprotect it again.
 	 */
 	set_page_dirty(page);
+	wait_on_stable_page_write(page);
 out:
 	sb_end_pagefault(inode->i_sb);
 	return ret;
@@ -2274,7 +2275,7 @@ repeat:
 		return NULL;
 	}
 found:
-	wait_on_page_writeback(page);
+	wait_on_stable_page_write(page);
 	return page;
 }
 EXPORT_SYMBOL(grab_cache_page_write_begin);
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 830893b..916dae1 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2275,3 +2275,14 @@ int mapping_tagged(struct address_space *mapping, int tag)
 	return radix_tree_tagged(&mapping->page_tree, tag);
 }
 EXPORT_SYMBOL(mapping_tagged);
+
+void wait_on_stable_page_write(struct page *page)
+{
+	struct backing_dev_info *bdi = page->mapping->backing_dev_info;
+
+	if (!bdi_cap_stable_pages_required(bdi))
+		return;
+
+	wait_on_page_writeback(page);
+}
+EXPORT_SYMBOL_GPL(wait_on_stable_page_write);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
