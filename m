Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E78F8600794
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:14 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 10/15] IMA: clean up the IMA counts updating code
Date: Fri, 04 Dec 2009 15:48:00 -0500
Message-ID: <20091204204800.18286.94025.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

We currently have a lot of duplicated code around ima file counts.  Clean
that all up.

Signed-off-by: Eric Paris <eparis@redhat.com>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---

 security/integrity/ima/ima.h      |    1 
 security/integrity/ima/ima_main.c |  118 ++++++++++++++++++++++---------------
 2 files changed, 70 insertions(+), 49 deletions(-)

diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 349aabc..268ef57 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -97,7 +97,6 @@ static inline unsigned long ima_hash_key(u8 *digest)
 
 /* iint cache flags */
 #define IMA_MEASURED		1
-#define IMA_IINT_DUMP_STACK	512
 
 /* integrity data associated with an inode */
 struct ima_iint_cache {
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index 96fafc0..e041233 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -13,8 +13,8 @@
  * License.
  *
  * File: ima_main.c
- *             implements the IMA hooks: ima_bprm_check, ima_file_mmap,
- *             and ima_path_check.
+ *	implements the IMA hooks: ima_bprm_check, ima_file_mmap,
+ *	and ima_path_check.
  */
 #include <linux/module.h>
 #include <linux/file.h>
@@ -35,6 +35,69 @@ static int __init hash_setup(char *str)
 }
 __setup("ima_hash=", hash_setup);
 
+/*
+ * Update the counts given an fmode_t
+ */
+static void ima_inc_counts(struct ima_iint_cache *iint, fmode_t mode)
+{
+	BUG_ON(!mutex_is_locked(&iint->mutex));
+
+	iint->opencount++;
+	if ((mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
+		iint->readcount++;
+	if (mode & FMODE_WRITE)
+		iint->writecount++;
+}
+
+/*
+ * Update the counts given open flags instead of fmode
+ */
+static void ima_inc_counts_flags(struct ima_iint_cache *iint, int flags)
+{
+	ima_inc_counts(iint, (__force fmode_t)((flags+1) & O_ACCMODE));
+}
+
+/*
+ * Decrement ima counts
+ */
+static void ima_dec_counts(struct ima_iint_cache *iint, struct inode *inode,
+			   fmode_t mode)
+{
+	BUG_ON(!mutex_is_locked(&iint->mutex));
+
+	iint->opencount--;
+	if ((mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
+		iint->readcount--;
+	if (mode & FMODE_WRITE) {
+		iint->writecount--;
+		if (iint->writecount == 0) {
+			if (iint->version != inode->i_version)
+				iint->flags &= ~IMA_MEASURED;
+		}
+	}
+
+	if ((iint->opencount < 0) ||
+	    (iint->readcount < 0) ||
+	    (iint->writecount < 0)) {
+		static int dumped;
+
+		if (dumped)
+			return;
+		dumped = 1;
+
+		printk(KERN_INFO "%s: open/free imbalance (r:%ld w:%ld o:%ld)\n",
+		       __FUNCTION__, iint->readcount, iint->writecount,
+		       iint->opencount);
+		dump_stack();
+	}
+}
+
+static void ima_dec_counts_flags(struct ima_iint_cache *iint,
+				 struct inode *inode, int flags)
+{
+	ima_dec_counts(iint, inode, (__force fmode_t)((flags+1) & O_ACCMODE));
+}
+
 /**
  * ima_file_free - called on __fput()
  * @file: pointer to file structure being freed
@@ -54,29 +117,7 @@ void ima_file_free(struct file *file)
 		return;
 
 	mutex_lock(&iint->mutex);
-	if (iint->opencount <= 0) {
-		printk(KERN_INFO
-		       "%s: %s open/free imbalance (r:%ld w:%ld o:%ld f:%ld)\n",
-		       __FUNCTION__, file->f_dentry->d_name.name,
-		       iint->readcount, iint->writecount,
-		       iint->opencount, atomic_long_read(&file->f_count));
-		if (!(iint->flags & IMA_IINT_DUMP_STACK)) {
-			dump_stack();
-			iint->flags |= IMA_IINT_DUMP_STACK;
-		}
-	}
-	iint->opencount--;
-
-	if ((file->f_mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
-		iint->readcount--;
-
-	if (file->f_mode & FMODE_WRITE) {
-		iint->writecount--;
-		if (iint->writecount == 0) {
-			if (iint->version != inode->i_version)
-				iint->flags &= ~IMA_MEASURED;
-		}
-	}
+	ima_dec_counts(iint, inode, file->f_mode);
 	mutex_unlock(&iint->mutex);
 	kref_put(&iint->refcount, iint_free);
 }
@@ -116,8 +157,7 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
 {
 	int rc = 0;
 
-	iint->opencount++;
-	iint->readcount++;
+	ima_inc_counts(iint, file->f_mode);
 
 	rc = ima_collect_measurement(iint, file);
 	if (!rc)
@@ -125,15 +165,6 @@ static int get_path_measurement(struct ima_iint_cache *iint, struct file *file,
 	return rc;
 }
 
-static void ima_update_counts(struct ima_iint_cache *iint, int mask)
-{
-	iint->opencount++;
-	if ((mask & MAY_WRITE) || (mask == 0))
-		iint->writecount++;
-	else if (mask & (MAY_READ | MAY_EXEC))
-		iint->readcount++;
-}
-
 /**
  * ima_path_check - based on policy, collect/store measurement.
  * @path: contains a pointer to the path to be measured
@@ -167,7 +198,7 @@ int ima_path_check(struct path *path, int mask, int update_counts)
 
 	mutex_lock(&iint->mutex);
 	if (update_counts)
-		ima_update_counts(iint, mask);
+		ima_inc_counts_flags(iint, mask);
 
 	rc = ima_must_measure(iint, inode, MAY_READ, PATH_CHECK);
 	if (rc < 0)
@@ -260,11 +291,7 @@ void ima_counts_put(struct path *path, int mask)
 		return;
 
 	mutex_lock(&iint->mutex);
-	iint->opencount--;
-	if ((mask & MAY_WRITE) || (mask == 0))
-		iint->writecount--;
-	else if (mask & (MAY_READ | MAY_EXEC))
-		iint->readcount--;
+	ima_dec_counts_flags(iint, inode, mask);
 	mutex_unlock(&iint->mutex);
 
 	kref_put(&iint->refcount, iint_free);
@@ -290,12 +317,7 @@ void ima_counts_get(struct file *file)
 	if (!iint)
 		return;
 	mutex_lock(&iint->mutex);
-	iint->opencount++;
-	if ((file->f_mode & (FMODE_READ | FMODE_WRITE)) == FMODE_READ)
-		iint->readcount++;
-
-	if (file->f_mode & FMODE_WRITE)
-		iint->writecount++;
+	ima_inc_counts(iint, file->f_mode);
 	mutex_unlock(&iint->mutex);
 
 	kref_put(&iint->refcount, iint_free);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
