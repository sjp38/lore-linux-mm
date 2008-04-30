Date: Wed, 30 Apr 2008 13:46:30 +1000
From: David Chinner <dgc@sgi.com>
Subject: Re: correct use of vmtruncate()?
Message-ID: <20080430034630.GY108924158@sgi.com>
References: <20080429100601.GO108924158@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080429100601.GO108924158@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 08:06:01PM +1000, David Chinner wrote:
> Folks,
> 
> It appears to me that vmtruncate() is not used correctly in
> block_write_begin() and friends. The short summary is that it
> appears that the usage in these functions implies that vmtruncate()
> should cause truncation of blocks on disk but no filesystem
> appears to do this, nor does the documentation imply they should.

[snip]

> All in all, I'd prefer the ->setattr() with a "ATTR_NO_LOCK" flag
> solution as the simplest way to solve this, but maybe there's
> something that I've missed. Comments, suggestions are welcome....

And the patch to demonstrate this is below. It does appear to fix
the problem, so I'd appreciate some feedback from various other fs
maintainers on whether this will cause problems or not....

Cheers,

Dave.

---
 fs/buffer.c                 |   18 ++++++++++++++----
 fs/xfs/linux-2.6/xfs_iops.c |    4 ++++
 include/linux/fs.h          |    1 +
 3 files changed, 19 insertions(+), 4 deletions(-)

Index: 2.6.x-xfs-new/fs/buffer.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/buffer.c	2008-04-30 12:32:59.482687869 +1000
+++ 2.6.x-xfs-new/fs/buffer.c	2008-04-30 12:43:15.595973324 +1000
@@ -2019,8 +2019,13 @@ int block_write_begin(struct file *file,
 			 * outside i_size.  Trim these off again. Don't need
 			 * i_size_read because we hold i_mutex.
 			 */
-			if (pos + len > inode->i_size)
-				vmtruncate(inode, inode->i_size);
+			if (pos + len > inode->i_size) {
+				struct iattr newattrs;
+
+				newattrs.ia_size = inode->i_size;
+				newattrs.ia_valid = ATTR_SIZE | ATTR_NO_LOCK;
+				notify_change(file->f_dentry, &newattrs);
+			}
 		}
 		goto out;
 	}
@@ -2576,8 +2581,13 @@ out_release:
 	page_cache_release(page);
 	*pagep = NULL;
 
-	if (pos + len > inode->i_size)
-		vmtruncate(inode, inode->i_size);
+	if (pos + len > inode->i_size) {
+		struct iattr newattrs;
+
+		newattrs.ia_size = inode->i_size;
+		newattrs.ia_valid = ATTR_SIZE | ATTR_NO_LOCK;
+		notify_change(file->f_dentry, &newattrs);
+	}
 
 	return ret;
 }
Index: 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_iops.c
===================================================================
--- 2.6.x-xfs-new.orig/fs/xfs/linux-2.6/xfs_iops.c	2008-04-30 12:32:59.046743585 +1000
+++ 2.6.x-xfs-new/fs/xfs/linux-2.6/xfs_iops.c	2008-04-30 12:33:28.946922244 +1000
@@ -709,6 +709,10 @@ xfs_vn_setattr(
 
 	if (ia_valid & (ATTR_MTIME_SET | ATTR_ATIME_SET))
 		flags |= ATTR_UTIME;
+
+	if (ia_valid & ATTR_NO_LOCK)
+		flags |= ATTR_NOLOCK;
+
 #ifdef ATTR_NO_BLOCK
 	if ((ia_valid & ATTR_NO_BLOCK))
 		flags |= ATTR_NONBLOCK;
Index: 2.6.x-xfs-new/include/linux/fs.h
===================================================================
--- 2.6.x-xfs-new.orig/include/linux/fs.h	2008-04-30 12:32:59.094737451 +1000
+++ 2.6.x-xfs-new/include/linux/fs.h	2008-04-30 12:33:28.998915599 +1000
@@ -337,6 +337,7 @@ typedef void (dio_iodone_t)(struct kiocb
 #define ATTR_FILE	8192
 #define ATTR_KILL_PRIV	16384
 #define ATTR_OPEN	32768	/* Truncating from open(O_TRUNC) */
+#define ATTR_NO_LOCK	65536	/* calling with fs locks already held */
 
 /*
  * This is the Inode Attributes structure, used for notify_change().  It

-- 
Dave Chinner
Principal Engineer
SGI Australian Software Group

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
