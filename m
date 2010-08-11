Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D600A6B02A5
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 16:13:49 -0400 (EDT)
Date: Wed, 11 Aug 2010 22:13:45 +0200
From: Helge Deller <deller@gmx.de>
Subject: [PATCH] ipc/shm.c: add RSS and swap size information to
 /proc/sysvipc/shm
Message-ID: <20100811201345.GA11304@p100.box>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

The kernel currently provides no functionality to analyze the RSS
and swap space usage of each individual sysvipc shared memory segment.

This patch add this info for each existing shm segment by extending
the output of /proc/sysvipc/shm by two columns for RSS and swap.

Since shmctl(SHM_INFO) already provides a similiar calculation (it
currently sums up all RSS/swap info for all segments), I did split
out a static function which is now used by the /proc/sysvipc/shm 
output and shmctl(SHM_INFO).

Tested on x86-64 and parisc (32- and 64bit). 

Signed-off-by: Helge Deller <deller@gmx.de>

---

 shm.c |   63 ++++++++++++++++++++++++++++++++++++++++++---------------------
 1 file changed, 42 insertions(+), 21 deletions(-)


diff --git a/ipc/shm.c b/ipc/shm.c
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -108,7 +108,11 @@ void __init shm_init (void)
 {
 	shm_init_ns(&init_ipc_ns);
 	ipc_init_proc_interface("sysvipc/shm",
-				"       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime\n",
+#if BITS_PER_LONG <= 32
+				"       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime        RSS       swap\n",
+#else
+				"       key      shmid perms                  size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime                   RSS                  swap\n",
+#endif
 				IPC_SHM_IDS, sysvipc_shm_proc_show);
 }
 
@@ -542,6 +546,34 @@ static inline unsigned long copy_shminfo_to_user(void __user *buf, struct shminf
 }
 
 /*
+ * Calculate and add used RSS and swap pages of a shm.
+ * Called with shm_ids.rw_mutex held as a reader
+ */
+static void shm_add_rss_swap(struct shmid_kernel *shp,
+	unsigned long *rss_add, unsigned long *swp_add)
+{
+	struct inode *inode;
+
+	inode = shp->shm_file->f_path.dentry->d_inode;
+
+	if (is_file_hugepages(shp->shm_file)) {
+		struct address_space *mapping = inode->i_mapping;
+		struct hstate *h = hstate_file(shp->shm_file);
+		*rss_add += pages_per_huge_page(h) * mapping->nrpages;
+	} else {
+#ifdef CONFIG_SHMEM
+		struct shmem_inode_info *info = SHMEM_I(inode);
+		spin_lock(&info->lock);
+		*rss_add += inode->i_mapping->nrpages;
+		*swp_add += info->swapped;
+		spin_unlock(&info->lock);
+#else
+		*rss_add += inode->i_mapping->nrpages;
+#endif
+	}
+}
+
+/*
  * Called with shm_ids.rw_mutex held as a reader
  */
 static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
@@ -558,30 +590,13 @@ static void shm_get_stat(struct ipc_namespace *ns, unsigned long *rss,
 	for (total = 0, next_id = 0; total < in_use; next_id++) {
 		struct kern_ipc_perm *ipc;
 		struct shmid_kernel *shp;
-		struct inode *inode;
 
 		ipc = idr_find(&shm_ids(ns).ipcs_idr, next_id);
 		if (ipc == NULL)
 			continue;
 		shp = container_of(ipc, struct shmid_kernel, shm_perm);
 
-		inode = shp->shm_file->f_path.dentry->d_inode;
-
-		if (is_file_hugepages(shp->shm_file)) {
-			struct address_space *mapping = inode->i_mapping;
-			struct hstate *h = hstate_file(shp->shm_file);
-			*rss += pages_per_huge_page(h) * mapping->nrpages;
-		} else {
-#ifdef CONFIG_SHMEM
-			struct shmem_inode_info *info = SHMEM_I(inode);
-			spin_lock(&info->lock);
-			*rss += inode->i_mapping->nrpages;
-			*swp += info->swapped;
-			spin_unlock(&info->lock);
-#else
-			*rss += inode->i_mapping->nrpages;
-#endif
-		}
+		shm_add_rss_swap(shp, rss, swp);
 
 		total++;
 	}
@@ -1070,6 +1085,9 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 {
 	struct shmid_kernel *shp = it;
+	unsigned long rss = 0, swp = 0;
+
+	shm_add_rss_swap(shp, &rss, &swp);
 
 #if BITS_PER_LONG <= 32
 #define SIZE_SPEC "%10lu"
@@ -1079,7 +1097,8 @@ static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 
 	return seq_printf(s,
 			  "%10d %10d  %4o " SIZE_SPEC " %5u %5u  "
-			  "%5lu %5u %5u %5u %5u %10lu %10lu %10lu\n",
+			  "%5lu %5u %5u %5u %5u %10lu %10lu %10lu "
+			  SIZE_SPEC " " SIZE_SPEC "\n",
 			  shp->shm_perm.key,
 			  shp->shm_perm.id,
 			  shp->shm_perm.mode,
@@ -1093,6 +1112,8 @@ static int sysvipc_shm_proc_show(struct seq_file *s, void *it)
 			  shp->shm_perm.cgid,
 			  shp->shm_atim,
 			  shp->shm_dtim,
-			  shp->shm_ctim);
+			  shp->shm_ctim,
+			  rss * PAGE_SIZE,
+			  swp * PAGE_SIZE);
 }
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
