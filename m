Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 04AEE600794
	for <linux-mm@kvack.org>; Fri,  4 Dec 2009 15:48:05 -0500 (EST)
From: Eric Paris <eparis@redhat.com>
Subject: [RFC PATCH 09/15] ima: only insert at inode creation time
Date: Fri, 04 Dec 2009 15:47:52 -0500
Message-ID: <20091204204752.18286.30603.stgit@paris.rdu.redhat.com>
In-Reply-To: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
References: <20091204204646.18286.24853.stgit@paris.rdu.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: viro@zeniv.linux.org.uk, jmorris@namei.org, npiggin@suse.de, eparis@redhat.com, zohar@us.ibm.com, jack@suse.cz, jmalicki@metacarta.com, dsmith@redhat.com, serue@us.ibm.com, hch@lst.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, mszeredi@suse.cz, jens.axboe@oracle.com, akpm@linux-foundation.org, matthew@wil.cx, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, arnd@arndb.de, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

iints are supposed to be allocated when an inode is allocated (during
security_inode_alloc())  But we have code which will attempt to allocate
an iint during measurement calls.  If we couldn't allocate the iint and we
cared, we should have died during security_inode_alloc().  Not make the
code more complex and less efficient.

Signed-off-by: Eric Paris <eparis@redhat.com>
---

 security/integrity/ima/ima.h      |    1 -
 security/integrity/ima/ima_iint.c |   71 +++++--------------------------------
 security/integrity/ima/ima_main.c |    8 ++--
 3 files changed, 14 insertions(+), 66 deletions(-)

diff --git a/security/integrity/ima/ima.h b/security/integrity/ima/ima.h
index 165eb53..349aabc 100644
--- a/security/integrity/ima/ima.h
+++ b/security/integrity/ima/ima.h
@@ -128,7 +128,6 @@ void ima_template_show(struct seq_file *m, void *e,
  */
 struct ima_iint_cache *ima_iint_insert(struct inode *inode);
 struct ima_iint_cache *ima_iint_find_get(struct inode *inode);
-struct ima_iint_cache *ima_iint_find_insert_get(struct inode *inode);
 void ima_iint_delete(struct inode *inode);
 void iint_free(struct kref *kref);
 void iint_rcu_free(struct rcu_head *rcu);
diff --git a/security/integrity/ima/ima_iint.c b/security/integrity/ima/ima_iint.c
index 4a53f39..2f6ab52 100644
--- a/security/integrity/ima/ima_iint.c
+++ b/security/integrity/ima/ima_iint.c
@@ -45,22 +45,21 @@ out:
 	return iint;
 }
 
-/* Allocate memory for the iint associated with the inode
- * from the iint_cache slab, initialize the iint, and
- * insert it into the radix tree.
- *
- * On success return a pointer to the iint; on failure return NULL.
+/**
+ * ima_inode_alloc - allocate an iint associated with an inode
+ * @inode: pointer to the inode
  */
-struct ima_iint_cache *ima_iint_insert(struct inode *inode)
+int ima_inode_alloc(struct inode *inode)
 {
 	struct ima_iint_cache *iint = NULL;
 	int rc = 0;
 
 	if (!ima_initialized)
-		return iint;
+		return 0;
+
 	iint = kmem_cache_alloc(iint_cache, GFP_NOFS);
 	if (!iint)
-		return iint;
+		return -ENOMEM;
 
 	rc = radix_tree_preload(GFP_NOFS);
 	if (rc < 0)
@@ -70,63 +69,13 @@ struct ima_iint_cache *ima_iint_insert(struct inode *inode)
 	rc = radix_tree_insert(&ima_iint_store, (unsigned long)inode, iint);
 	spin_unlock(&ima_iint_lock);
 out:
-	if (rc < 0) {
+	if (rc < 0)
 		kmem_cache_free(iint_cache, iint);
-		if (rc == -EEXIST) {
-			spin_lock(&ima_iint_lock);
-			iint = radix_tree_lookup(&ima_iint_store,
-						 (unsigned long)inode);
-			spin_unlock(&ima_iint_lock);
-		} else
-			iint = NULL;
-	}
-	radix_tree_preload_end();
-	return iint;
-}
-
-/**
- * ima_inode_alloc - allocate an iint associated with an inode
- * @inode: pointer to the inode
- */
-int ima_inode_alloc(struct inode *inode)
-{
-	struct ima_iint_cache *iint;
-
-	if (!ima_initialized)
-		return 0;
-
-	iint = ima_iint_insert(inode);
-	if (!iint)
-		return -ENOMEM;
-	return 0;
-}
-
-/* ima_iint_find_insert_get - get the iint associated with an inode
- *
- * Most insertions are done at inode_alloc, except those allocated
- * before late_initcall. When the iint does not exist, allocate it,
- * initialize and insert it, and increment the iint refcount.
- *
- * (Can't initialize at security_initcall before any inodes are
- * allocated, got to wait at least until proc_init.)
- *
- *  Return the iint.
- */
-struct ima_iint_cache *ima_iint_find_insert_get(struct inode *inode)
-{
-	struct ima_iint_cache *iint = NULL;
 
-	iint = ima_iint_find_get(inode);
-	if (iint)
-		return iint;
-
-	iint = ima_iint_insert(inode);
-	if (iint)
-		kref_get(&iint->refcount);
+	radix_tree_preload_end();
 
-	return iint;
+	return rc;
 }
-EXPORT_SYMBOL_GPL(ima_iint_find_insert_get);
 
 /* iint_free - called when the iint refcount goes to zero */
 void iint_free(struct kref *kref)
diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
index b85e61b..96fafc0 100644
--- a/security/integrity/ima/ima_main.c
+++ b/security/integrity/ima/ima_main.c
@@ -161,7 +161,7 @@ int ima_path_check(struct path *path, int mask, int update_counts)
 
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return 0;
-	iint = ima_iint_find_insert_get(inode);
+	iint = ima_iint_find_get(inode);
 	if (!iint)
 		return 0;
 
@@ -219,7 +219,7 @@ static int process_measurement(struct file *file, const unsigned char *filename,
 
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return 0;
-	iint = ima_iint_find_insert_get(inode);
+	iint = ima_iint_find_get(inode);
 	if (!iint)
 		return -ENOMEM;
 
@@ -255,7 +255,7 @@ void ima_counts_put(struct path *path, int mask)
 	 */
 	if (!ima_initialized || !inode || !S_ISREG(inode->i_mode))
 		return;
-	iint = ima_iint_find_insert_get(inode);
+	iint = ima_iint_find_get(inode);
 	if (!iint)
 		return;
 
@@ -286,7 +286,7 @@ void ima_counts_get(struct file *file)
 
 	if (!ima_initialized || !S_ISREG(inode->i_mode))
 		return;
-	iint = ima_iint_find_insert_get(inode);
+	iint = ima_iint_find_get(inode);
 	if (!iint)
 		return;
 	mutex_lock(&iint->mutex);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
