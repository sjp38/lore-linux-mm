Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 26D6E6B03A2
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 09:24:32 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id f5so40427183qtf.22
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 06:24:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 3si18050676qtx.156.2017.04.24.06.24.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 06:24:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v3 17/20] cifs: cleanup writeback handling errors and comments
Date: Mon, 24 Apr 2017 09:22:56 -0400
Message-Id: <20170424132259.8680-18-jlayton@redhat.com>
In-Reply-To: <20170424132259.8680-1-jlayton@redhat.com>
References: <20170424132259.8680-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk

Now that writeback errors are handled on a per-file basis using the new
sequence counter method at the vfs layer, we no longer need to re-set
errors in the mapping after doing writeback in non-fsync codepaths.

Also, fix up some bogus comments.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/cifs/cifsfs.c |  4 +---
 fs/cifs/file.c   |  7 ++-----
 fs/cifs/inode.c  | 22 +++++++---------------
 3 files changed, 10 insertions(+), 23 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index dd3f5fabfdf6..017a2d1d02c7 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -829,10 +829,8 @@ static loff_t cifs_llseek(struct file *file, loff_t offset, int whence)
 		if (!CIFS_CACHE_READ(CIFS_I(inode)) && inode->i_mapping &&
 		    inode->i_mapping->nrpages != 0) {
 			rc = filemap_fdatawait(inode->i_mapping);
-			if (rc) {
-				mapping_set_error(inode->i_mapping, rc);
+			if (rc)
 				return rc;
-			}
 		}
 		/*
 		 * Some applications poll for the file length in this strange
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 4b696a23b0b1..9b4f7f182add 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -722,9 +722,7 @@ cifs_reopen_file(struct cifsFileInfo *cfile, bool can_flush)
 	cinode = CIFS_I(inode);
 
 	if (can_flush) {
-		rc = filemap_write_and_wait(inode->i_mapping);
-		mapping_set_error(inode->i_mapping, rc);
-
+		filemap_write_and_wait(inode->i_mapping);
 		if (tcon->unix_ext)
 			rc = cifs_get_inode_info_unix(&inode, full_path,
 						      inode->i_sb, xid);
@@ -3906,8 +3904,7 @@ void cifs_oplock_break(struct work_struct *work)
 			break_lease(inode, O_WRONLY);
 		rc = filemap_fdatawrite(inode->i_mapping);
 		if (!CIFS_CACHE_READ(cinode)) {
-			rc = filemap_fdatawait(inode->i_mapping);
-			mapping_set_error(inode->i_mapping, rc);
+			filemap_fdatawait(inode->i_mapping);
 			cifs_zap_mapping(inode);
 		}
 		cifs_dbg(FYI, "Oplock flush inode %p rc %d\n", inode, rc);
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index b261db34103c..a58e605240fc 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -2008,10 +2008,8 @@ int cifs_getattr(const struct path *path, struct kstat *stat,
 	if (!CIFS_CACHE_READ(CIFS_I(inode)) && inode->i_mapping &&
 	    inode->i_mapping->nrpages != 0) {
 		rc = filemap_fdatawait(inode->i_mapping);
-		if (rc) {
-			mapping_set_error(inode->i_mapping, rc);
+		if (rc)
 			return rc;
-		}
 	}
 
 	rc = cifs_revalidate_dentry_attr(dentry);
@@ -2171,15 +2169,12 @@ cifs_setattr_unix(struct dentry *direntry, struct iattr *attrs)
 	 * Attempt to flush data before changing attributes. We need to do
 	 * this for ATTR_SIZE and ATTR_MTIME for sure, and if we change the
 	 * ownership or mode then we may also need to do this. Here, we take
-	 * the safe way out and just do the flush on all setattr requests. If
-	 * the flush returns error, store it to report later and continue.
+	 * the safe way out and just do the flush on all setattr requests.
 	 *
 	 * BB: This should be smarter. Why bother flushing pages that
-	 * will be truncated anyway? Also, should we error out here if
-	 * the flush returns error?
+	 * will be truncated anyway?
 	 */
-	rc = filemap_write_and_wait(inode->i_mapping);
-	mapping_set_error(inode->i_mapping, rc);
+	filemap_write_and_wait(inode->i_mapping);
 	rc = 0;
 
 	if (attrs->ia_valid & ATTR_SIZE) {
@@ -2314,15 +2309,12 @@ cifs_setattr_nounix(struct dentry *direntry, struct iattr *attrs)
 	 * Attempt to flush data before changing attributes. We need to do
 	 * this for ATTR_SIZE and ATTR_MTIME for sure, and if we change the
 	 * ownership or mode then we may also need to do this. Here, we take
-	 * the safe way out and just do the flush on all setattr requests. If
-	 * the flush returns error, store it to report later and continue.
+	 * the safe way out and just do the flush on all setattr requests.
 	 *
 	 * BB: This should be smarter. Why bother flushing pages that
-	 * will be truncated anyway? Also, should we error out here if
-	 * the flush returns error?
+	 * will be truncated anyway?
 	 */
-	rc = filemap_write_and_wait(inode->i_mapping);
-	mapping_set_error(inode->i_mapping, rc);
+	filemap_write_and_wait(inode->i_mapping);
 	rc = 0;
 
 	if (attrs->ia_valid & ATTR_SIZE) {
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
