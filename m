From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] shm: Fix the filename of hugetlb sysv shared memory
References: <787b0d920706062027s5a8fd35q752f8da5d446afc@mail.gmail.com>
	<20070606204432.b670a7b1.akpm@linux-foundation.org>
	<787b0d920706062153u7ad64179p1c4f3f663c3882f@mail.gmail.com>
	<20070607162004.GA27802@vino.hallyn.com>
	<m1ir9zrtwe.fsf@ebiederm.dsl.xmission.com>
	<46697EDA.9000209@us.ibm.com>
Date: Fri, 08 Jun 2007 17:43:34 -0600
In-Reply-To: <46697EDA.9000209@us.ibm.com> (Badari Pulavarty's message of
	"Fri, 08 Jun 2007 09:07:54 -0700")
Message-ID: <m1vedyqaft.fsf_-_@ebiederm.dsl.xmission.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Albert Cahalan <acahalan@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Some user space tools need to identify SYSV shared memory when
examining /proc/<pid>/maps.  To do so they look for a block device
with major zero, a dentry named SYSV<sysv key>, and having the minor of
the internal sysv shared memory kernel mount.

To help these tools and to make it easier for people just browsing
/proc/<pid>/maps this patch modifies hugetlb sysv shared memory to
use the SYSV<key> dentry naming convention.

User space tools will still have to be aware that hugetlb sysv
shared memory lives on a different internal kernel mount and so
has a different block device minor number from the rest of sysv
shared memory.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/hugetlbfs/inode.c    |    7 ++-----
 include/linux/hugetlb.h |    4 ++--
 ipc/shm.c               |    6 +++---
 3 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index aa083dd..e6b46b3 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -736,15 +736,13 @@ static int can_do_hugetlb_shm(void)
 			can_do_mlock());
 }
 
-struct file *hugetlb_zero_setup(size_t size)
+struct file *hugetlb_file_setup(const char *name, size_t size)
 {
 	int error = -ENOMEM;
 	struct file *file;
 	struct inode *inode;
 	struct dentry *dentry, *root;
 	struct qstr quick_string;
-	char buf[16];
-	static atomic_t counter;
 
 	if (!hugetlbfs_vfsmount)
 		return ERR_PTR(-ENOENT);
@@ -756,8 +754,7 @@ struct file *hugetlb_zero_setup(size_t size)
 		return ERR_PTR(-ENOMEM);
 
 	root = hugetlbfs_vfsmount->mnt_root;
-	snprintf(buf, 16, "%u", atomic_inc_return(&counter));
-	quick_string.name = buf;
+	quick_string.name = name;
 	quick_string.len = strlen(quick_string.name);
 	quick_string.hash = 0;
 	dentry = d_alloc(root, &quick_string);
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index b4570b6..2c13715 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -163,7 +163,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
 
 extern const struct file_operations hugetlbfs_file_operations;
 extern struct vm_operations_struct hugetlb_vm_ops;
-struct file *hugetlb_zero_setup(size_t);
+struct file *hugetlb_file_setup(const char *name, size_t);
 int hugetlb_get_quota(struct address_space *mapping);
 void hugetlb_put_quota(struct address_space *mapping);
 
@@ -185,7 +185,7 @@ static inline void set_file_hugepages(struct file *file)
 
 #define is_file_hugepages(file)		0
 #define set_file_hugepages(file)	BUG()
-#define hugetlb_zero_setup(size)	ERR_PTR(-ENOSYS)
+#define hugetlb_file_setup(name,size)	ERR_PTR(-ENOSYS)
 
 #endif /* !CONFIG_HUGETLBFS */
 
diff --git a/ipc/shm.c b/ipc/shm.c
index 4fefbad..c31f743 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -364,9 +364,10 @@ static int newseg (struct ipc_namespace *ns, key_t key, int shmflg, size_t size)
 		return error;
 	}
 
+	sprintf (name, "SYSV%08x", key);
 	if (shmflg & SHM_HUGETLB) {
-		/* hugetlb_zero_setup takes care of mlock user accounting */
-		file = hugetlb_zero_setup(size);
+		/* hugetlb_file_setup takes care of mlock user accounting */
+		file = hugetlb_file_setup(name, size);
 		shp->mlock_user = current->user;
 	} else {
 		int acctflag = VM_ACCOUNT;
@@ -377,7 +378,6 @@ static int newseg (struct ipc_namespace *ns, key_t key, int shmflg, size_t size)
 		if  ((shmflg & SHM_NORESERVE) &&
 				sysctl_overcommit_memory != OVERCOMMIT_NEVER)
 			acctflag = 0;
-		sprintf (name, "SYSV%08x", key);
 		file = shmem_file_setup(name, size, acctflag);
 	}
 	error = PTR_ERR(file);
-- 
1.5.1.1.181.g2de0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
