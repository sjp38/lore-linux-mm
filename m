Subject: Re: PATCH: rewrite of invalidate_inode_pages
References: <Pine.LNX.4.10.10005111445370.819-100000@penguin.transmeta.com>
	<yttya5ghhtr.fsf@vexeta.dc.fi.udc.es> <shsd7msemwu.fsf@charged.uio.no>
	<yttbt2chf46.fsf@vexeta.dc.fi.udc.es>
	<14619.16278.813629.967654@charged.uio.no>
	<ytt1z38acqg.fsf@vexeta.dc.fi.udc.es> <391BEAED.C9313263@sympatico.ca>
	<yttg0ro6lt8.fsf@vexeta.dc.fi.udc.es> <shs7ld0dj8x.fsf@charged.uio.no>
	<m12qFNa-000OVtC@amadeus.home.nl>
	<14620.2180.8684.529000@charged.uio.no>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: Trond Myklebust's message of "Fri, 12 May 2000 15:35:00 +0200 (CEST)"
Date: 12 May 2000 19:57:57 +0200
Message-ID: <yttem77647u.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: trond.myklebust@fys.uio.no
Cc: Arjan van de Ven <arjan@fenrus.demon.nl>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> "trond" == Trond Myklebust <trond.myklebust@fys.uio.no> writes:

>>>>> " " == Arjan van de Ven <arjan@fenrus.demon.nl> writes:
..

>> I'd vote for "invalidate_unlocked_inode_pages", as it also
>> suggests that the locked pages aren't invalidated.

trond> That sounds very good to me. Just so long as the name becomes more
trond> self-documenting than it is now.
trond> Intelligent people are making mistakes about what we want to do with
trond> this function, so it definitely needs to be documented more clearly.

Here it is a patch that changes all the refernences in the kernel from
invalidate_inode_pages to invalidate_unlocked_inode_pages.

I have CC: the mail to linux-fsdevel because the SMB people also use
that function.

Comments?

Later, Juan.

PD. This patch aplies in top of my previous patch to this function,
    that you can get from the MM-list of from:

http://carpanta.dc.fi.udc.es/~quintela/kernel/2.3.99-pre7/page_cache_get.diff


diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/fs/nfs/inode.c testing/fs/nfs/inode.c
--- works/fs/nfs/inode.c	Wed Apr 26 02:28:56 2000
+++ testing/fs/nfs/inode.c	Fri May 12 19:22:00 2000
@@ -586,7 +586,7 @@
 	NFS_ATTRTIMEO(inode) = NFS_MINATTRTIMEO(inode);
 	NFS_ATTRTIMEO_UPDATE(inode) = jiffies;
 
-	invalidate_inode_pages(inode);
+	invalidate_unlocked_inode_pages(inode);
 
 	memset(NFS_COOKIEVERF(inode), 0, sizeof(NFS_COOKIEVERF(inode)));
 	NFS_CACHEINV(inode);
@@ -982,12 +982,12 @@
  * of the server's inode.
  *
  * This is a bit tricky because we have to make sure all dirty pages
- * have been sent off to the server before calling invalidate_inode_pages.
- * To make sure no other process adds more write requests while we try
- * our best to flush them, we make them sleep during the attribute refresh.
+ * have been sent off to the server before calling
+ * invalidate_unlocked_inode_pages.  To make sure no other process
+ * adds more write requests while we try our best to flush them, we
+ * make them sleep during the attribute refresh.
  *
- * A very similar scenario holds for the dir cache.
- */
+ * A very similar scenario holds for the dir cache.  */
 int
 nfs_refresh_inode(struct inode *inode, struct nfs_fattr *fattr)
 {
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/fs/smbfs/cache.c testing/fs/smbfs/cache.c
--- works/fs/smbfs/cache.c	Sat Dec  4 09:30:56 1999
+++ testing/fs/smbfs/cache.c	Fri May 12 19:22:21 2000
@@ -326,7 +326,7 @@
 	 * Get rid of any unlocked pages, and clear the
 	 * 'valid' flag in case a scan is in progress.
 	 */
-	invalidate_inode_pages(dir);
+	invalidate_unlocked_inode_pages(dir);
 	dir->u.smbfs_i.cache_valid &= ~SMB_F_CACHEVALID;
 	dir->u.smbfs_i.oldmtime = 0;
 }
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/fs/smbfs/inode.c testing/fs/smbfs/inode.c
--- works/fs/smbfs/inode.c	Thu Mar 16 01:51:14 2000
+++ testing/fs/smbfs/inode.c	Fri May 12 19:22:12 2000
@@ -205,7 +205,7 @@
 			 * But we do want to invalidate the caches ...
 			 */
 			if (!S_ISDIR(inode->i_mode))
-				invalidate_inode_pages(inode);
+				invalidate_unlocked_inode_pages(inode);
 			else
 				smb_invalid_dir_cache(inode);
 			error = -EIO;
@@ -263,7 +263,7 @@
 (long) last_time, (long) inode->i_mtime);
 #endif
 		if (!S_ISDIR(inode->i_mode))
-			invalidate_inode_pages(inode);
+			invalidate_unlocked_inode_pages(inode);
 		else
 			smb_invalid_dir_cache(inode);
 	}
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/include/linux/fs.h testing/include/linux/fs.h
--- works/include/linux/fs.h	Fri May 12 01:11:42 2000
+++ testing/include/linux/fs.h	Fri May 12 19:22:52 2000
@@ -954,7 +954,7 @@
 extern void balance_dirty(kdev_t);
 extern int check_disk_change(kdev_t);
 extern int invalidate_inodes(struct super_block *);
-extern void invalidate_inode_pages(struct inode *);
+extern void invalidate_unlocked_inode_pages(struct inode *);
 #define invalidate_buffers(dev)	__invalidate_buffers((dev), 0)
 #define destroy_buffers(dev)	__invalidate_buffers((dev), 1)
 extern void __invalidate_buffers(kdev_t dev, int);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/kernel/ksyms.c testing/kernel/ksyms.c
--- works/kernel/ksyms.c	Fri May 12 01:11:43 2000
+++ testing/kernel/ksyms.c	Fri May 12 19:22:35 2000
@@ -175,7 +175,7 @@
 EXPORT_SYMBOL(check_disk_change);
 EXPORT_SYMBOL(__invalidate_buffers);
 EXPORT_SYMBOL(invalidate_inodes);
-EXPORT_SYMBOL(invalidate_inode_pages);
+EXPORT_SYMBOL(invalidate_unlocked_inode_pages);
 EXPORT_SYMBOL(truncate_inode_pages);
 EXPORT_SYMBOL(fsync_dev);
 EXPORT_SYMBOL(permission);
diff -u -urN --exclude=CVS --exclude=*~ --exclude=.#* --exclude=TAGS works/mm/filemap.c testing/mm/filemap.c
--- works/mm/filemap.c	Fri May 12 19:03:11 2000
+++ testing/mm/filemap.c	Fri May 12 19:22:46 2000
@@ -112,14 +112,15 @@
 #define ITERATIONS 100
 
 /**
- * invalidate_inode_pages - Invalidate all the unlocked pages of one inode
+ * invalidate_unlocked_inode_pages - Invalidate all the unlocked
+ * pages that inode
  * @inode: the inode which pages we want to invalidate
  *
  * This function only removes the unlocked pages, if you want to
  * remove all the pages of one inode, you must call truncate_inode_pages.
  */
 
-void invalidate_inode_pages(struct inode * inode)
+void invalidate_unlocked_inode_pages(struct inode * inode)
 {
 	struct list_head *head, *curr;
 	struct page * page;


-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
