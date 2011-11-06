Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 26DC36B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 16:15:12 -0500 (EST)
Subject: [RFC PATCH] tmpfs: support user quotas
From: Davidlohr Bueso <dave@gnu.org>
Reply-To: dave@gnu.org
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 06 Nov 2011 18:15:01 -0300
Message-ID: <1320614101.3226.5.camel@offbook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Lennart Poettering <lennart@poettering.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

From: Davidlohr Bueso <dave@gnu.org>

This patch adds a new RLIMIT_TMPFSQUOTA resource limit to restrict an individual user's quota across all mounted tmpfs filesystems.
It's well known that a user can easily fill up commonly used directories (like /tmp, /dev/shm) causing programs to break through DoS.

By default the soft and hard limits are set the RLIM_INFINITY, thus maintaining the current functionality and allowing the user to populate
the fs all he wants.

This is one of the features requested in the Plumbers wishlist (http://0pointer.de/blog/projects/plumbers-wishlist-2.html).

CC: Lennart Poettering <lennart@poettering.net>
Signed-off-by: Davidlohr Bueso <dave@gnu.org>
---
This is my first patch in these waters, so if I'm doing anything terrible wrong here please bare with me.

 fs/proc/base.c                 |    1 +
 include/asm-generic/resource.h |    4 +++-
 include/linux/sched.h          |    3 +++
 mm/shmem.c                     |   14 ++++++++++++--
 4 files changed, 19 insertions(+), 3 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 2db1bd3..f839edb 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -511,6 +511,7 @@ static const struct limit_names lnames[RLIM_NLIMITS] = {
 	[RLIMIT_NICE] = {"Max nice priority", NULL},
 	[RLIMIT_RTPRIO] = {"Max realtime priority", NULL},
 	[RLIMIT_RTTIME] = {"Max realtime timeout", "us"},
+	[RLIMIT_TMPFSQUOTA] = {"Max tmpfs user quota", "bytes"},
 };
 
 /* Display limits for a process */
diff --git a/include/asm-generic/resource.h b/include/asm-generic/resource.h
index 61fa862..8ba77ad 100644
--- a/include/asm-generic/resource.h
+++ b/include/asm-generic/resource.h
@@ -45,7 +45,8 @@
 					   0-39 for nice level 19 .. -20 */
 #define RLIMIT_RTPRIO		14	/* maximum realtime priority */
 #define RLIMIT_RTTIME		15	/* timeout for RT tasks in us */
-#define RLIM_NLIMITS		16
+#define RLIMIT_TMPFSQUOTA	16	/* maximum bytes for tmpfs quota */
+#define RLIM_NLIMITS		17
 
 /*
  * SuS says limits have to be unsigned.
@@ -87,6 +88,7 @@
 	[RLIMIT_NICE]		= { 0, 0 },				\
 	[RLIMIT_RTPRIO]		= { 0, 0 },				\
 	[RLIMIT_RTTIME]		= {  RLIM_INFINITY,  RLIM_INFINITY },	\
+	[RLIMIT_TMPFSQUOTA]    	= {  RLIM_INFINITY,  RLIM_INFINITY },   \
 }
 
 #endif	/* __KERNEL__ */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index e8acce7..849710f 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -703,6 +703,9 @@ struct user_struct {
 	/* protected by mq_lock	*/
 	unsigned long mq_bytes;	/* How many bytes can be allocated to mqueue? */
 #endif
+#ifdef CONFIG_TMPFS
+	atomic_long_t shmem_bytes;
+#endif
 	unsigned long locked_shm; /* How many pages of mlocked shm ? */
 
 #ifdef CONFIG_KEYS
diff --git a/mm/shmem.c b/mm/shmem.c
index 45b9acb..1b8c638 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1159,7 +1159,12 @@ shmem_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	struct inode *inode = mapping->host;
+	struct user_struct *user= current_user();
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+
+	if (atomic_long_read(&user->shmem_bytes) + len > 
+	    rlimit(RLIMIT_TMPFSQUOTA))
+		return -ENOSPC;
 	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
 }
 
@@ -1169,10 +1174,12 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 			struct page *page, void *fsdata)
 {
 	struct inode *inode = mapping->host;
+	struct user_struct *user= current_user();
 
-	if (pos + copied > inode->i_size)
+	if (pos + copied > inode->i_size) {
 		i_size_write(inode, pos + copied);
-
+		atomic_long_add(copied, &user->shmem_bytes);
+	}
 	set_page_dirty(page);
 	unlock_page(page);
 	page_cache_release(page);
@@ -1535,12 +1542,15 @@ out:
 static int shmem_unlink(struct inode *dir, struct dentry *dentry)
 {
 	struct inode *inode = dentry->d_inode;
+	struct user_struct *user = current_user();
 
 	if (inode->i_nlink > 1 && !S_ISDIR(inode->i_mode))
 		shmem_free_inode(inode->i_sb);
 
 	dir->i_size -= BOGO_DIRENT_SIZE;
 	inode->i_ctime = dir->i_ctime = dir->i_mtime = CURRENT_TIME;
+	atomic_long_sub(inode->i_size, &user->shmem_bytes);
+	
 	drop_nlink(inode);
 	dput(dentry);	/* Undo the count from "create" - this does all the work */
 	return 0;
-- 
1.7.4.1



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
