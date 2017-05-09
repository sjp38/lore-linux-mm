Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0AC302806E8
	for <linux-mm@kvack.org>; Tue,  9 May 2017 11:50:46 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id m91so1458680qte.10
        for <linux-mm@kvack.org>; Tue, 09 May 2017 08:50:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v128si389658qki.3.2017.05.09.08.50.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 08:50:45 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH v4 20/27] cifs: cleanup writeback handling errors and comments
Date: Tue,  9 May 2017 11:49:23 -0400
Message-Id: <20170509154930.29524-21-jlayton@redhat.com>
In-Reply-To: <20170509154930.29524-1-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com

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
index 0bee7f8d91ad..9825d892716e 100644
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
