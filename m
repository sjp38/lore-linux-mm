Subject: [PATCH] get rid of vm_private_data and win posix shm
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 28 Dec 1999 18:32:00 +0100
Message-ID: <qwwd7rrgeen.fsf@sap.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>
List-ID: <linux-mm.kvack.org>

--=-=-=

Hi folks,

Here is my first version of using file semantics in shared
memory. This obsoletes vm_private_data in vm_area_struct and allows
posix shared memory.

I implemented posix shm with its own namespace by extending filp_open
and do_unlink by an additional parameter for the root inode.

Also extending this to a complete filesystem should be easy (but not
my target).

Greetings
		Christoph

P.S. this version is only tested on UP since I cannot access my SMP machine
     from home. I will stress test SMP next week.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=patch-shm_open3

diff -uNr 2.3.34/arch/i386/kernel/entry.S c34/arch/i386/kernel/entry.S
--- 2.3.34/arch/i386/kernel/entry.S	Thu Dec 23 20:41:44 1999
+++ c34/arch/i386/kernel/entry.S	Thu Dec 23 20:44:59 1999
@@ -598,7 +598,9 @@
 	.long SYMBOL_NAME(sys_stat64)		/* 195 */
 	.long SYMBOL_NAME(sys_lstat64)
 	.long SYMBOL_NAME(sys_fstat64)
-
+        .long SYMBOL_NAME(sys_shm_open)
+        .long SYMBOL_NAME(sys_shm_unlink)
+	/* 200 */
 
 	/*
 	 * NOTE!! This doesn't have to be exact - we just have
@@ -606,6 +608,6 @@
 	 * entries. Don't panic if you notice that this hasn't
 	 * been shrunk every time we add a new system call.
 	 */
-	.rept NR_syscalls-197
+	.rept NR_syscalls-199
 		.long SYMBOL_NAME(sys_ni_syscall)
 	.endr
diff -uNr 2.3.34/arch/sparc/kernel/sys_sunos.c c34/arch/sparc/kernel/sys_sunos.c
--- 2.3.34/arch/sparc/kernel/sys_sunos.c	Sat Sep 18 20:49:20 1999
+++ c34/arch/sparc/kernel/sys_sunos.c	Mon Dec 27 11:38:28 1999
@@ -722,7 +722,6 @@
 
 
 extern int do_mount(kdev_t, const char *, const char *, char *, int, void *);
-extern dev_t get_unnamed_dev(void);
 extern void put_unnamed_dev(dev_t);
 extern asmlinkage int sys_mount(char *, char *, char *, unsigned long, void *);
 extern asmlinkage int sys_connect(int fd, struct sockaddr *uservaddr, int addrlen);
diff -uNr 2.3.34/arch/sparc64/kernel/sys_sparc32.c c34/arch/sparc64/kernel/sys_sparc32.c
--- 2.3.34/arch/sparc64/kernel/sys_sparc32.c	Sat Dec 18 10:25:11 1999
+++ c34/arch/sparc64/kernel/sys_sparc32.c	Thu Dec 23 20:42:19 1999
@@ -2775,7 +2775,7 @@
 	for (i=0 ; i<MAX_ARG_PAGES ; i++)	/* clear page-table */
 		bprm.page[i] = 0;
 
-	dentry = open_namei(filename, 0, 0);
+	dentry = open_namei(filename, 0, 0, NULL);
 	retval = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		return retval;
diff -uNr 2.3.34/arch/sparc64/kernel/sys_sunos32.c c34/arch/sparc64/kernel/sys_sunos32.c
--- 2.3.34/arch/sparc64/kernel/sys_sunos32.c	Sat Sep 18 20:49:21 1999
+++ c34/arch/sparc64/kernel/sys_sunos32.c	Mon Dec 27 11:38:20 1999
@@ -686,7 +686,6 @@
 };
 
 extern int do_mount(kdev_t, const char *, const char *, char *, int, void *);
-extern dev_t get_unnamed_dev(void);
 extern void put_unnamed_dev(dev_t);
 extern asmlinkage int sys_mount(char *, char *, char *, unsigned long, void *);
 extern asmlinkage int sys_connect(int fd, struct sockaddr *uservaddr, int addrlen);
diff -uNr 2.3.34/fs/binfmt_elf.c c34/fs/binfmt_elf.c
--- 2.3.34/fs/binfmt_elf.c	Wed Dec  8 21:00:42 1999
+++ c34/fs/binfmt_elf.c	Thu Dec 23 20:42:19 1999
@@ -503,12 +503,12 @@
 					
 				current->personality = PER_SVR4;
 				interpreter_dentry = open_namei(elf_interpreter,
-								0, 0);
+								0, 0, NULL);
 				current->personality = old_pers;
 			} else
 #endif					
 				interpreter_dentry = open_namei(elf_interpreter,
-								0, 0);
+								0, 0, NULL);
 			set_fs(old_fs);
 			retval = PTR_ERR(interpreter_dentry);
 			if (IS_ERR(interpreter_dentry))
diff -uNr 2.3.34/fs/binfmt_em86.c c34/fs/binfmt_em86.c
--- 2.3.34/fs/binfmt_em86.c	Sun Nov  7 11:41:32 1999
+++ c34/fs/binfmt_em86.c	Thu Dec 23 20:42:19 1999
@@ -79,7 +79,7 @@
 	 * Note that we use open_namei() as the name is now in kernel
 	 * space, and we don't need to copy it.
 	 */
-	dentry = open_namei(interp, 0, 0);
+	dentry = open_namei(interp, 0, 0, NULL);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
diff -uNr 2.3.34/fs/binfmt_misc.c c34/fs/binfmt_misc.c
--- 2.3.34/fs/binfmt_misc.c	Wed Dec  8 21:00:50 1999
+++ c34/fs/binfmt_misc.c	Thu Dec 23 20:42:19 1999
@@ -214,7 +214,7 @@
 	bprm->argc++;
 	bprm->filename = iname;	/* for binfmt_script */
 
-	dentry = open_namei(iname, 0, 0);
+	dentry = open_namei(iname, 0, 0, NULL);
 	retval = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto _ret;
diff -uNr 2.3.34/fs/binfmt_script.c c34/fs/binfmt_script.c
--- 2.3.34/fs/binfmt_script.c	Tue Aug  3 19:18:39 1999
+++ c34/fs/binfmt_script.c	Thu Dec 23 20:42:19 1999
@@ -80,7 +80,7 @@
 	/*
 	 * OK, now restart the process with the interpreter's dentry.
 	 */
-	dentry = open_namei(interp, 0, 0);
+	dentry = open_namei(interp, 0, 0, NULL);
 	if (IS_ERR(dentry))
 		return PTR_ERR(dentry);
 
diff -uNr 2.3.34/fs/dquot.c c34/fs/dquot.c
--- 2.3.34/fs/dquot.c	Wed Dec  8 21:00:50 1999
+++ c34/fs/dquot.c	Thu Dec 23 20:42:19 1999
@@ -1486,7 +1486,7 @@
 	if (IS_ERR(tmp))
 		goto out_lock;
 
-	f = filp_open(tmp, O_RDWR, 0600);
+	f = filp_open(tmp, O_RDWR, 0600, NULL);
 	putname(tmp);
 
 	error = PTR_ERR(f);
diff -uNr 2.3.34/fs/exec.c c34/fs/exec.c
--- 2.3.34/fs/exec.c	Thu Dec 23 20:41:45 1999
+++ c34/fs/exec.c	Thu Dec 23 20:42:19 1999
@@ -287,7 +287,6 @@
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
-		mpnt->vm_private_data = (void *) 0;
 		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
 		vmlist_modify_unlock(current->mm);
@@ -710,7 +709,7 @@
 	        for (i = 0 ; i < MAX_ARG_PAGES ; i++)	/* clear page-table */
                     bprm_loader.page[i] = NULL;
 
-		dentry = open_namei(dynloader[0], 0, 0);
+		dentry = open_namei(dynloader[0], 0, 0, NULL);
 		retval = PTR_ERR(dentry);
 		if (IS_ERR(dentry))
 			return retval;
@@ -775,7 +774,7 @@
 	bprm.p = PAGE_SIZE*MAX_ARG_PAGES-sizeof(void *);
 	memset(bprm.page, 0, MAX_ARG_PAGES*sizeof(bprm.page[0])); 
 
-	dentry = open_namei(filename, 0, 0);
+	dentry = open_namei(filename, 0, 0, NULL);
 	retval = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		return retval;
@@ -855,7 +854,7 @@
 #else
 	corename[4] = '\0';
 #endif
-	file = filp_open(corename, O_CREAT | 2 | O_TRUNC | O_NOFOLLOW, 0600);
+	file = filp_open(corename, O_CREAT | 2 | O_TRUNC | O_NOFOLLOW, 0600, NULL);
 	if (IS_ERR(file))
 		goto fail;
 	dentry = file->f_dentry;
diff -uNr 2.3.34/fs/namei.c c34/fs/namei.c
--- 2.3.34/fs/namei.c	Sat Dec 18 10:25:23 1999
+++ c34/fs/namei.c	Fri Dec 24 16:18:29 1999
@@ -680,7 +680,7 @@
  * which is a lot more logical, and also allows the "no perm" needed
  * for symlinks (where the permissions are checked later).
  */
-struct dentry * open_namei(const char * pathname, int flag, int mode)
+struct dentry * open_namei(const char * pathname, int flag, int mode, struct dentry *root)
 {
 	int acc_mode, error;
 	struct inode *inode;
@@ -689,7 +689,7 @@
 	mode &= S_IALLUGO & ~current->fs->umask;
 	mode |= S_IFREG;
 
-	dentry = lookup_dentry(pathname, NULL, lookup_flags(flag));
+	dentry = lookup_dentry(pathname, root, lookup_flags(flag));
 	if (IS_ERR(dentry))
 		return dentry;
 
@@ -1067,13 +1067,13 @@
 	return error;
 }
 
-static inline int do_unlink(const char * name)
+int do_unlink(const char * name, struct dentry *root)
 {
 	int error;
 	struct dentry *dir;
 	struct dentry *dentry;
 
-	dentry = lookup_dentry(name, NULL, 0);
+	dentry = lookup_dentry(name, root, 0);
 	error = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto exit;
@@ -1098,7 +1098,7 @@
 	tmp = getname(pathname);
 	error = PTR_ERR(tmp);
 	if (!IS_ERR(tmp)) {
-		error = do_unlink(tmp);
+		error = do_unlink(tmp, NULL);
 		putname(tmp);
 	}
 	unlock_kernel();
diff -uNr 2.3.34/fs/open.c c34/fs/open.c
--- 2.3.34/fs/open.c	Wed Dec  8 21:01:51 1999
+++ c34/fs/open.c	Sat Dec 25 20:00:49 1999
@@ -656,7 +656,7 @@
  * for the internal routines (ie open_namei()/follow_link() etc). 00 is
  * used by symlinks.
  */
-struct file *filp_open(const char * filename, int flags, int mode)
+struct file *filp_open(const char * filename, int flags, int mode, struct dentry *dent)
 {
 	struct inode * inode;
 	struct dentry * dentry;
@@ -673,7 +673,7 @@
 		flag++;
 	if (flag & O_TRUNC)
 		flag |= 2;
-	dentry = open_namei(filename,flag,mode);
+	dentry = open_namei(filename,flag,mode,dent);
 	error = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto cleanup_file;
@@ -796,7 +796,7 @@
 		if (fd >= 0) {
 			struct file * f;
 			lock_kernel();
-			f = filp_open(tmp, flags, mode);
+			f = filp_open(tmp, flags, mode, NULL);
 			unlock_kernel();
 			error = PTR_ERR(f);
 			if (IS_ERR(f))
diff -uNr 2.3.34/include/asm-i386/unistd.h c34/include/asm-i386/unistd.h
--- 2.3.34/include/asm-i386/unistd.h	Thu Dec 23 20:41:46 1999
+++ c34/include/asm-i386/unistd.h	Thu Dec 23 20:45:40 1999
@@ -202,6 +202,8 @@
 #define __NR_stat64		195
 #define __NR_lstat64		196
 #define __NR_fstat64		197
+#define __NR_shm_open    	198
+#define __NR_shm_unlink 	199
 
 /* user-visible error numbers are in the range -1 - -124: see <asm-i386/errno.h> */
 
diff -uNr 2.3.34/include/linux/fs.h c34/include/linux/fs.h
--- 2.3.34/include/linux/fs.h	Thu Dec 23 20:41:46 1999
+++ c34/include/linux/fs.h	Tue Dec 28 18:03:25 1999
@@ -736,7 +736,7 @@
 extern int get_unused_fd(void);
 extern void put_unused_fd(unsigned int);
 
-extern struct file *filp_open(const char *, int, int);
+extern struct file *filp_open(const char *, int, int, struct dentry *);
 extern int filp_close(struct file *, fl_owner_t id);
 
 extern char * getname(const char *);
@@ -840,9 +840,10 @@
 extern int permission(struct inode *, int);
 extern int get_write_access(struct inode *);
 extern void put_write_access(struct inode *);
-extern struct dentry * open_namei(const char *, int, int);
+extern struct dentry * open_namei(const char *, int, int, struct dentry *);
 extern struct dentry * do_mknod(const char *, int, dev_t);
 extern int do_pipe(int *);
+extern int do_unlink(const char * name, struct dentry *root);
 
 /* fs/dcache.c -- generic fs support functions */
 extern int is_subdir(struct dentry *, struct dentry *);
@@ -972,6 +973,7 @@
 extern void put_super(kdev_t);
 unsigned long generate_cluster(kdev_t, int b[], int);
 unsigned long generate_cluster_swab32(kdev_t, int b[], int);
+extern kdev_t get_unnamed_dev(void);
 extern kdev_t ROOT_DEV;
 
 extern void show_buffers(void);
diff -uNr 2.3.34/include/linux/mm.h c34/include/linux/mm.h
--- 2.3.34/include/linux/mm.h	Sat Dec 18 11:00:50 1999
+++ c34/include/linux/mm.h	Tue Dec 28 18:03:25 1999
@@ -60,7 +60,6 @@
 	struct vm_operations_struct * vm_ops;
 	unsigned long vm_pgoff;		/* offset in PAGE_SIZE units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;
-	void * vm_private_data;		/* was vm_pte (shared mem) */
 };
 
 /*
diff -uNr 2.3.34/ipc/shm.c c34/ipc/shm.c
--- 2.3.34/ipc/shm.c	Thu Dec 23 20:41:46 1999
+++ c34/ipc/shm.c	Tue Dec 28 17:56:41 1999
@@ -9,8 +9,8 @@
  * BIGMEM support, Andrea Arcangeli <andrea@suse.de>
  * SMP thread shm, Jean-Luc Boyard <jean-luc.boyard@siemens.fr>
  * HIGHMEM support, Ingo Molnar <mingo@redhat.com>
- * avoid vmalloc and make shmmax, shmall, shmmni sysctl'able,
- *                         Christoph Rohland <hans-christoph.rohland@sap.com>
+ * avoid vmalloc, use file semantics, implement posix shm,
+ *			Christoph Rohland <hans-christoph.rohland@sap.com>
  */
 
 #include <linux/config.h>
@@ -19,6 +19,8 @@
 #include <linux/swap.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
+#include <linux/file.h>
+#include <linux/mman.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
@@ -29,14 +31,23 @@
 
 #include "util.h"
 
+static int	      shm_create   (struct inode *,struct dentry *,int);
+static struct dentry *shm_lookup   (struct inode *,struct dentry *);
+static int	      shm_unlink   (struct inode *,struct dentry *);
+static int	      shm_notify   (struct dentry *dent, struct iattr *attr);
+static void	      shm_delete   (struct inode *);
+static int	      shm_mmap	   (struct file *, struct vm_area_struct *);
+static void	      shm_readi	   (struct inode *);
+
+#define SHM_NAME_LEN NAME_MAX
+
 struct shmid_kernel /* extend struct shmis_ds with private fields */
 {	
 	struct shmid_ds		u;
 	unsigned long		shm_npages; /* size of segment (pages) */
-	pte_t			**shm_dir;  /* ptr to array of ptrs to frames -> SHMMAX */ 
-	struct vm_area_struct	*attaches;  /* descriptors for attaches */
-	int                     id; /* backreference to id for shm_close */
-	struct semaphore sem;
+	pte_t			**shm_dir;  /* ptr to array of ptrs to frames */ 
+	int			namelen;
+	char			name[0];
 };
 
 static struct ipc_ids shm_ids;
@@ -52,9 +63,7 @@
 #define shm_buildid(id, seq) \
 	ipc_buildid(&shm_ids, id, seq)
 
-static int newseg (key_t key, int shmflg, size_t size);
-static int shm_map (struct vm_area_struct *shmd);
-static void killseg (int shmid);
+static int newseg (key_t key, const char *name, int namelen, int shmflg, size_t size);
 static void shm_open (struct vm_area_struct *shmd);
 static void shm_close (struct vm_area_struct *shmd);
 static struct page * shm_nopage(struct vm_area_struct *, unsigned long, int);
@@ -63,6 +72,53 @@
 static int sysvipc_shm_read_proc(char *buffer, char **start, off_t offset, int length, int *eof, void *data);
 #endif
 
+static struct super_block * shm_sb;
+
+static struct super_operations shm_sops = {
+	shm_readi,		/* read_inode */
+	NULL,			/* write_inode */
+	NULL,			/* put_inode */
+	shm_delete,		/* delete_inode */
+	shm_notify,		/* notify_change */
+};
+
+static struct file_operations shm_root_operations = {
+};
+
+static struct inode_operations shm_root_inode_operations = {
+	&shm_root_operations,	/* file operations */
+	shm_create,		/* create */
+	shm_lookup,		/* lookup */
+	NULL,			/* link */
+	shm_unlink,		/* unlink */
+};
+
+static struct file_operations shm_operations = {
+	NULL,			/* llseek */
+	NULL,			/* read */
+	NULL,			/* write */
+	NULL,			/* readdir */
+	NULL,			/* poll */
+	NULL,			/* ioctl */
+	shm_mmap,		/* mmap */
+};
+
+static struct inode_operations shm_inode_operations = {
+	&shm_operations,	/* file operations */
+};
+
+static struct vm_operations_struct shm_vm_ops = {
+	shm_open,		/* open - callback for a new vm-area open */
+	shm_close,		/* close - callback for when the vm-area is released */
+	NULL,			/* no need to sync pages at unmap */
+	NULL,			/* protect */
+	NULL,			/* sync */
+	NULL,			/* advise */
+	shm_nopage,		/* nopage */
+	NULL,			/* wppage */
+	shm_swapout		/* swapout */
+};
+
 size_t shm_ctlmax = SHMMAX;
 int shm_ctlall = SHMALL;
 int shm_ctlmni = SHMMNI;
@@ -75,7 +131,7 @@
 	pagecache_lock
 	shm_lock()/shm_lockall()
 	kernel lock
-	shp->sem
+	inode->i_sem
 	sem_ids.sem
 	mmap_sem
 
@@ -93,13 +149,172 @@
 
 void __init shm_init (void)
 {
+	struct inode * inode;
+
 	ipc_init_ids(&shm_ids, shm_ctlmni);
+
+	if (!(shm_sb = get_empty_super()))
+		BUG();
+	shm_sb->s_dev = get_unnamed_dev();
+	shm_sb->s_op = &shm_sops;
+	if (!(inode = iget (shm_sb, SEQ_MULTIPLIER)))
+		BUG();
+	inode->i_op = &shm_root_inode_operations;
+	inode->i_sb = shm_sb;
+	if (!(shm_sb->s_root = d_alloc_root(inode)))
+		BUG();
+
 #ifdef CONFIG_PROC_FS
 	create_proc_read_entry("sysvipc/shm", 0, 0, sysvipc_shm_read_proc, NULL);
 #endif
 	return;
 }
 
+static void shm_readi (struct inode *ino){}
+
+static int shm_dget (int id, struct dentry *dent)
+{
+	struct shmid_kernel *shp;
+	struct inode * inode;
+	
+	inode = iget (shm_sb, id % SEQ_MULTIPLIER);/* we use the plain id so
+						      we can use the upper
+						      space for directory
+						      inodes */
+	if (!inode)
+		return -ENOMEM;
+
+	shp = shm_lock (id);
+	inode->i_mode = shp->u.shm_perm.mode;
+	inode->i_uid  = shp->u.shm_perm.uid;
+	inode->i_gid  = shp->u.shm_perm.gid;
+	inode->i_size = shp->u.shm_segsz;
+	shm_unlock (id);
+	inode->i_op   = &shm_inode_operations;
+
+	d_instantiate(dent, inode);
+	return 0;
+}
+
+static int shm_create (struct inode *dir, struct dentry *dent, int mode)
+{
+	int id;
+
+	down(&shm_ids.sem);
+	id = newseg (IPC_PRIVATE, dent->d_name.name, dent->d_name.len,
+			 mode, 0);
+	if (id >= 0)
+		id = shm_dget (id, dent);
+
+	up(&shm_ids.sem);
+
+	return id;
+}
+
+static struct dentry *shm_lookup (struct inode *dir, struct dentry *dent)
+{
+	int i, err;
+	struct shmid_kernel* shp;
+
+#ifdef SHM_DEBUG
+	if (dir != shm_sb->s_root->d_inode)
+		BUG();
+	if (dent->d_parent != shm_sb->s_root)
+		BUG();
+#endif
+
+	if (dent->d_name.len > SHM_NAME_LEN)
+		return ERR_PTR(-ENAMETOOLONG);
+
+	down(&shm_ids.sem);
+	for(i = 0; i <= shm_ids.max_id; i++) {
+		if (!(shp = shm_lock(i)))
+		    continue;
+		if (!(shp->u.shm_perm.mode & SHM_DEST ||
+		      strncmp(dent->d_name.name, shp->name, shp->namelen)))
+			goto found;
+		shm_unlock(i);
+	}
+	err = 0;
+	goto out;
+
+found:
+	shm_unlock(i);
+	err = shm_dget (i, dent);
+out:
+	if (err == 0)
+		d_rehash (dent);
+	up (&shm_ids.sem);
+	return ERR_PTR(err);
+}
+
+static int shm_unlink (struct inode *dir, struct dentry *dent)
+{
+	struct inode * inode = dent->d_inode;
+	struct shmid_kernel *shp;
+
+	down (&shm_ids.sem);
+	if (!(shp = shm_lock (inode->i_ino)))
+		BUG();
+	shp->u.shm_perm.mode |= SHM_DEST;
+	shp->u.shm_perm.key = IPC_PRIVATE; /* Do not find it any more */
+	shm_unlock (inode->i_ino);
+	up (&shm_ids.sem);
+	inode->i_nlink -= 1;
+	d_delete (dent);
+	return 0;
+}
+
+asmlinkage long sys_shm_open(const char * filename, int flags, int mode)
+{
+	char * tmp, *tmp2;
+	int fd, error;
+
+	tmp2 = tmp = getname(filename);
+
+	fd = PTR_ERR(tmp);
+	if (!IS_ERR(tmp)) {
+		while (*tmp && *tmp == '/')
+			tmp++;
+
+		fd = get_unused_fd();
+		if (fd >= 0) {
+			struct file * f;
+			lock_kernel();
+			f = filp_open(tmp, flags, mode, dget(shm_sb->s_root));
+			unlock_kernel();
+			error = PTR_ERR(f);
+			if (IS_ERR(f))
+				goto out_error;
+			fd_install(fd, f);
+		}
+out:
+		putname(tmp2);
+	}
+	return fd;
+
+out_error:
+	put_unused_fd(fd);
+	fd = error;
+	goto out;
+}
+
+asmlinkage long sys_shm_unlink(const char * pathname)
+{
+	int error;
+	char * tmp;
+
+	lock_kernel();
+	tmp = getname(pathname);
+	error = PTR_ERR(tmp);
+	if (!IS_ERR(tmp)) {
+		error = do_unlink(tmp, dget (shm_sb->s_root));
+		putname(tmp);
+	}
+	unlock_kernel();
+	return error;
+}
+
 #define SHM_ENTRY(shp, index) (shp)->shm_dir[(index)/PTRS_PER_PTE][(index)%PTRS_PER_PTE]
 
 static pte_t **shm_alloc(unsigned long pages)
@@ -108,9 +323,12 @@
 	unsigned short last = pages % PTRS_PER_PTE;
 	pte_t **ret, **ptr;
 
+	if (pages == 0)
+		return NULL;
+
 	ret = kmalloc ((dir+1) * sizeof(pte_t *), GFP_KERNEL);
 	if (!ret)
-		goto out;
+		goto nomem;
 
 	for (ptr = ret; ptr < ret+dir ; ptr++)
 	{
@@ -127,7 +345,6 @@
 			goto free;
 		memset (*ptr, 0, last*sizeof(pte_t));
 	}
-out:	
 	return ret;
 
 free:
@@ -136,66 +353,111 @@
 		free_page ((unsigned long)*ptr);
 
 	kfree (ret);
-	return NULL;
+nomem:
+	return ERR_PTR(-ENOMEM);
 }
 
-
 static void shm_free(pte_t** dir, unsigned long pages)
 {
 	pte_t **ptr = dir+pages/PTRS_PER_PTE;
 
+	if (!dir)
+		return;
+
 	/* first the last page */
 	if (pages%PTRS_PER_PTE)
 		kfree (*ptr);
 	/* now the whole pages */
 	while (--ptr >= dir)
-		free_page ((unsigned long)*ptr);
+		if (*ptr)
+			free_page ((unsigned long)*ptr);
 
 	/* Now the indirect block */
 	kfree (dir);
 }
 
-static int shm_revalidate(struct shmid_kernel* shp, int shmid, int pagecount, int flg)
+static 	int shm_notify (struct dentry *dentry, struct iattr *attr)
 {
-	struct shmid_kernel* new;
-	new = shm_lock(shmid);
-	if(new==NULL) {
-		return -EIDRM;
-	}
-	if(new!=shp || shm_checkid(shp, shmid) || shp->shm_npages != pagecount) {
-		shm_unlock(shmid);
-		return -EIDRM;
-	}
-	if (ipcperms(&shp->u.shm_perm, flg)) {
-		shm_unlock(shmid);
-		return -EACCES;
+	int error;
+	struct inode *inode = dentry->d_inode;
+	struct shmid_kernel *shp;
+	unsigned long new_pages, old_pages;
+	pte_t **new_dir, **old_dir;
+
+	if ((error = inode_change_ok(inode, attr)))
+		return error;
+	if (!(attr->ia_valid & ATTR_SIZE))
+		goto set_attr;
+	if (attr->ia_size > shm_ctlmax)
+		return -EFBIG;
+
+	/* We set old_pages and old_dir for easier cleanup */
+	old_pages = new_pages = (attr->ia_size  + PAGE_SIZE - 1) >> PAGE_SHIFT;
+	if (shm_tot + new_pages >= shm_ctlall)
+		return -ENOSPC;
+	if (IS_ERR(old_dir = new_dir = shm_alloc(new_pages)))
+		return PTR_ERR(new_dir);
+
+	if (!(shp = shm_lock(inode->i_ino)))
+		BUG();
+	if (shp->u.shm_segsz == attr->ia_size)
+		goto out;
+	old_dir = shp->shm_dir;
+	old_pages = shp->shm_npages;
+	if (old_dir){
+		pte_t *swap;
+		int i,j;
+		i = old_pages < new_pages ? old_pages : new_pages;
+		j = i % PTRS_PER_PTE;
+		i /= PTRS_PER_PTE;
+		if (j)
+			memcpy (new_dir[i], old_dir[i], j * sizeof (pte_t));
+		while (i--) {
+			swap = new_dir[i];
+			new_dir[i] = old_dir[i];
+			old_dir[i] = swap;
+		}
 	}
+	shp->shm_dir = new_dir;
+	shp->shm_npages = new_pages;
+	shp->u.shm_segsz = attr->ia_size;
+out:
+	shm_unlock(inode->i_ino);
+	shm_lockall();
+	shm_tot += new_pages - old_pages;
+	shm_unlockall();
+	shm_free (old_dir, old_pages);
+set_attr:
+	inode_setattr(inode, attr);
 	return 0;
 }
 
-static int newseg (key_t key, int shmflg, size_t size)
+static int newseg (key_t key, const char *name, int namelen,
+		   int shmflg, size_t size)
 {
 	struct shmid_kernel *shp;
 	int numpages = (size + PAGE_SIZE -1) >> PAGE_SHIFT;
 	int id;
 
-	if (size < SHMMIN)
-		return -EINVAL;
+	if (namelen > SHM_NAME_LEN)
+		return -ENAMETOOLONG;
 
 	if (size > shm_ctlmax)
 		return -EINVAL;
 	if (shm_tot + numpages >= shm_ctlall)
 		return -ENOSPC;
 
-	shp = (struct shmid_kernel *) kmalloc (sizeof (*shp), GFP_KERNEL);
+	shp = (struct shmid_kernel *) /* sizeof(".IPC_%08x") == 14 */
+		kmalloc (sizeof (*shp) + (namelen ? namelen : 14), GFP_KERNEL);
 	if (!shp)
 		return -ENOMEM;
 
-	shp->shm_dir = shm_alloc (numpages);
-	if (!shp->shm_dir) {
+	if (IS_ERR(shp->shm_dir = shm_alloc (numpages))){
+		int error = PTR_ERR(shp->shm_dir);
 		kfree(shp);
-		return -ENOMEM;
+		return error;
 	}
+
 	id = ipc_addid(&shm_ids, &shp->u.shm_perm, shm_ctlmni);
 	if(id == -1) {
 		shm_free(shp->shm_dir,numpages);
@@ -206,18 +468,24 @@
 	shp->u.shm_perm.mode = (shmflg & S_IRWXUGO);
 	shp->u.shm_segsz = size;
 	shp->u.shm_cpid = current->pid;
-	shp->attaches = NULL;
-	shp->u.shm_lpid = shp->u.shm_nattch = 0;
+	shp->u.shm_lpid = 0;
 	shp->u.shm_atime = shp->u.shm_dtime = 0;
 	shp->u.shm_ctime = CURRENT_TIME;
+	shp->u.shm_nattch = 0;
 	shp->shm_npages = numpages;
-	shp->id = shm_buildid(id,shp->u.shm_perm.seq);
-	init_MUTEX(&shp->sem);
+	id = shm_buildid(id,shp->u.shm_perm.seq);
+	if (namelen != 0) {
+		shp->namelen = namelen;
+		memcpy (shp->name, name, namelen);		  
+	} else {
+		shp->namelen = sprintf (shp->name, ".IPC_%08x", id);
+	}
 
 	shm_tot += numpages;
+	used_segs++;
 	shm_unlock(id);
-
-	return shm_buildid(id,shp->u.shm_perm.seq);
+	
+	return id;
 }
 
 asmlinkage long sys_shmget (key_t key, size_t size, int shmflg)
@@ -225,14 +493,17 @@
 	struct shmid_kernel *shp;
 	int err, id = 0;
 
+	if (size < SHMMIN)
+		return -EINVAL;
+
 	down(&shm_ids.sem);
 	if (key == IPC_PRIVATE) {
-		err = newseg(key, shmflg, size);
+		err = newseg(key, NULL, 0, shmflg, size);
 	} else if ((id = ipc_findkey(&shm_ids,key)) == -1) {
 		if (!(shmflg & IPC_CREAT))
 			err = -ENOENT;
 		else
-			err = newseg(key, shmflg, size);
+			err = newseg(key, NULL, 0, shmflg, size);
 	} else if ((shmflg & IPC_CREAT) && (shmflg & IPC_EXCL)) {
 		err = -EEXIST;
 	} else {
@@ -249,12 +520,9 @@
 	return err;
 }
 
-/*
- * Only called after testing nattch and SHM_DEST.
- * Here pages, pgtable and shmid_kernel are freed.
- */
-static void killseg (int shmid)
+static void shm_delete (struct inode *ino)
 {
+	int shmid = ino->i_ino;
 	struct shmid_kernel *shp;
 	int i, numpages;
 	int rss, swp;
@@ -262,20 +530,9 @@
 	down(&shm_ids.sem);
 	shp = shm_lock(shmid);
 	if(shp==NULL) {
-out_up:
-		up(&shm_ids.sem);
-		return;
-	}
-	if(shm_checkid(shp,shmid) || shp->u.shm_nattch > 0 ||
-	    !(shp->u.shm_perm.mode & SHM_DEST)) {
-		shm_unlock(shmid);
-		goto out_up;
+		BUG();
 	}
 	shp = shm_rmid(shmid);
-	if(shp==NULL)
-		BUG();
-	if (!shp->shm_dir)
-		BUG();
 	shm_unlock(shmid);
 	up(&shm_ids.sem);
 
@@ -299,6 +556,7 @@
 	shm_rss -= rss;
 	shm_swp -= swp;
 	shm_tot -= numpages;
+	used_segs--;
 	shm_unlockall();
 	return;
 }
@@ -444,12 +702,17 @@
 		shp->u.shm_ctime = CURRENT_TIME;
 		break;
 	case IPC_RMID:
-		shp->u.shm_perm.mode |= SHM_DEST;
-		if (shp->u.shm_nattch <= 0) {
-			shm_unlock(shmid);
+		if (shp->u.shm_perm.mode & SHM_DEST) {
+			err = -EIDRM;
+			goto out_unlock_up;
+		}
+		{
+			char   name[SHM_NAME_LEN];
+			
+			strncpy (name, shp->name, SHM_NAME_LEN);
+			shm_unlock (shmid);
 			up(&shm_ids.sem);
-			killseg (shmid);
-			return 0;
+			return do_unlink (name, dget (shm_sb->s_root));
 		}
 	}
 	err = 0;
@@ -463,70 +726,24 @@
 	return err;
 }
 
-/*
- * The per process internal structure for managing segments is
- * `struct vm_area_struct'.
- * A shmat will add to and shmdt will remove from the list.
- * shmd->vm_mm		the attacher
- * shmd->vm_start	virt addr of attach, multiple of SHMLBA
- * shmd->vm_end		multiple of SHMLBA
- * shmd->vm_next	next attach for task
- * shmd->vm_next_share	next attach for segment
- * shmd->vm_pgoff	offset into segment (in pages)
- * shmd->vm_private_data		signature for this attach
- */
-
-static struct vm_operations_struct shm_vm_ops = {
-	shm_open,		/* open - callback for a new vm-area open */
-	shm_close,		/* close - callback for when the vm-area is released */
-	NULL,			/* no need to sync pages at unmap */
-	NULL,			/* protect */
-	NULL,			/* sync */
-	NULL,			/* advise */
-	shm_nopage,		/* nopage */
-	NULL,			/* wppage */
-	shm_swapout		/* swapout */
-};
-
-/* Insert shmd into the list shp->attaches */
-static inline void insert_attach (struct shmid_kernel * shp, struct vm_area_struct * shmd)
-{
-	if((shmd->vm_next_share = shp->attaches) != NULL)
-		shp->attaches->vm_pprev_share = &shmd->vm_next_share;
-	shp->attaches = shmd;
-	shmd->vm_pprev_share = &shp->attaches;
-}
+static inline void shm_inc (int id) {
+	struct shmid_kernel *shp;
 
-/* Remove shmd from list shp->attaches */
-static inline void remove_attach (struct shmid_kernel * shp, struct vm_area_struct * shmd)
-{
-	if(shmd->vm_next_share)
-		shmd->vm_next_share->vm_pprev_share = shmd->vm_pprev_share;
-	*shmd->vm_pprev_share = shmd->vm_next_share;
+	if(!(shp = shm_lock(id)))
+		BUG();
+	shp->u.shm_atime = CURRENT_TIME;
+	shp->u.shm_lpid = current->pid;
+	shp->u.shm_nattch++;
+	shm_unlock(id);
 }
 
-/*
- * ensure page tables exist
- * mark page table entries with shm_sgn.
- */
-static int shm_map (struct vm_area_struct *shmd)
+static int shm_mmap(struct file * file, struct vm_area_struct * vma)
 {
-	unsigned long tmp;
-
-	/* clear old mappings */
-	do_munmap(shmd->vm_start, shmd->vm_end - shmd->vm_start);
-
-	/* add new mapping */
-	tmp = shmd->vm_end - shmd->vm_start;
-	if((current->mm->total_vm << PAGE_SHIFT) + tmp
-	   > (unsigned long) current->rlim[RLIMIT_AS].rlim_cur)
-		return -ENOMEM;
-	current->mm->total_vm += tmp >> PAGE_SHIFT;
-	vmlist_modify_lock(current->mm);
-	insert_vm_struct(current->mm, shmd);
-	merge_segments(current->mm, shmd->vm_start, shmd->vm_end);
-	vmlist_modify_unlock(current->mm);
-
+	if (!(vma->vm_flags & VM_SHARED))
+		return -EINVAL; /* we cannot do private mappings */
+	UPDATE_ATIME(file->f_dentry->d_inode);
+	vma->vm_ops = &shm_vm_ops;
+	shm_inc(file->f_dentry->d_inode->i_ino);
 	return 0;
 }
 
@@ -535,135 +752,73 @@
  */
 asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr)
 {
-	struct shmid_kernel *shp;
-	struct vm_area_struct *shmd;
-	int err;
 	unsigned long addr;
-	unsigned long len;
-	short flg = shmflg & SHM_RDONLY ? S_IRUGO : S_IRUGO|S_IWUGO;
+	size_t len;
+	struct shmid_kernel * shp;
+	struct file * file;
+	int    err;
+	int    flags;
+	char   name[SHM_NAME_LEN];
 
+	if ((addr = (ulong)shmaddr))
+	{
+		if(addr & (SHMLBA-1)) {
+			if (shmflg & SHM_RND)
+				addr &= ~(SHMLBA-1);	   /* round down */
+			else
+				return -EINVAL;
+		}
+		flags = MAP_SHARED | MAP_FIXED;
+	} else
+		flags = MAP_SHARED;
 
-	if (shmid < 0)
-		return -EINVAL;
+	file = get_empty_filp ();
+	if (!file)
+		return -ENOMEM;
 
-	down(&current->mm->mmap_sem);
 	err = -EINVAL;
-	shp = shm_lock(shmid);
-	if (!shp)
-		goto out_up;
-
-	err = -EACCES;
-	if (ipcperms(&shp->u.shm_perm, flg))
-		goto out_unlock_up;
-
-	err = -EIDRM;
-	if (shm_checkid(shp,shmid))
-		goto out_unlock_up;
-
-	if (!(addr = (ulong) shmaddr)) {
-		if (shmflg & SHM_REMAP)
-			goto out_unlock_up;
-		err = -ENOMEM;
-		addr = 0;
-	again:
-		if (!(addr = get_unmapped_area(addr, (unsigned long)shp->u.shm_segsz)))
-			goto out_unlock_up;
-		if(addr & (SHMLBA - 1)) {
-			addr = (addr + (SHMLBA - 1)) & ~(SHMLBA - 1);
-			goto again;
-		}
-	} else if (addr & (SHMLBA-1)) {
-		err=-EINVAL;
-		if (shmflg & SHM_RND)
-			addr &= ~(SHMLBA-1);       /* round down */
+	if (!(shp = shm_lock (shmid)))
+		goto put;
+	if(shm_checkid(shp,shmid)) {
+		err = -EIDRM;
+		shm_unlock (shmid);
+		goto put;
+	}
+
+	strncpy (name, shp->name, SHM_NAME_LEN);
+	len = shp->u.shm_segsz;
+	shm_unlock (shmid);
+	file->f_op = &shm_operations;
+	file->f_mode = shmflg & SHM_RDONLY ? FMODE_READ : FMODE_READ|FMODE_WRITE;
+	file->f_pos  = 0;
+	file->f_dentry = lookup_dentry (name, dget (shm_sb->s_root), 0);
+	if (IS_ERR (file->f_dentry)) {
+		err = PTR_ERR (file->f_dentry);
+		goto put;
+	}
+
+	if (addr && !(shmflg & SHM_REMAP) &&
+	    find_vma_intersection(current->mm, addr, addr + len)) {
+		err = -EINVAL;
+	} else {
+		*raddr = do_mmap (file, addr, len,
+				  (shmflg & SHM_RDONLY ? PROT_READ :
+				   PROT_READ | PROT_WRITE), flags, 0);
+		if (IS_ERR(*raddr))
+			err = PTR_ERR(*raddr);
 		else
-			goto out_unlock_up;
-	}
-	/*
-	 * Check if addr exceeds TASK_SIZE (from do_mmap)
-	 */
-	len = PAGE_SIZE*shp->shm_npages;
-	err = -EINVAL;
-	if (addr >= TASK_SIZE || len > TASK_SIZE  || addr > TASK_SIZE - len)
-		goto out_unlock_up;
-	/*
-	 * If shm segment goes below stack, make sure there is some
-	 * space left for the stack to grow (presently 4 pages).
-	 */
-	if (addr < current->mm->start_stack &&
-	    addr > current->mm->start_stack - PAGE_SIZE*(shp->shm_npages + 4))
-		goto out_unlock_up;
-	if (!(shmflg & SHM_REMAP) && find_vma_intersection(current->mm, addr, addr + (unsigned long)shp->u.shm_segsz))
-		goto out_unlock_up;
-
-	shm_unlock(shmid);
-	err = -ENOMEM;
-	shmd = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
-	err = shm_revalidate(shp, shmid, len/PAGE_SIZE,flg);
-	if(err)	{
-		kmem_cache_free(vm_area_cachep, shmd);
-		goto out_up;
+			err = 0;
 	}
 
-	shmd->vm_private_data = shp;
-	shmd->vm_start = addr;
-	shmd->vm_end = addr + shp->shm_npages * PAGE_SIZE;
-	shmd->vm_mm = current->mm;
-	shmd->vm_page_prot = (shmflg & SHM_RDONLY) ? PAGE_READONLY : PAGE_SHARED;
-	shmd->vm_flags = VM_SHM | VM_MAYSHARE | VM_SHARED
-			 | VM_MAYREAD | VM_MAYEXEC | VM_READ | VM_EXEC
-			 | ((shmflg & SHM_RDONLY) ? 0 : VM_MAYWRITE | VM_WRITE);
-	shmd->vm_file = NULL;
-	shmd->vm_pgoff = 0;
-	shmd->vm_ops = &shm_vm_ops;
-
-	shp->u.shm_nattch++;	    /* prevent destruction */
-	shm_unlock(shp->id);
-	err = shm_map (shmd);
-	shm_lock(shmid); /* cannot fail */
-	if (err)
-		goto failed_shm_map;
-
-	insert_attach(shp,shmd);  /* insert shmd into shp->attaches */
-
-	shp->u.shm_lpid = current->pid;
-	shp->u.shm_atime = CURRENT_TIME;
-
-	*raddr = addr;
-	err = 0;
-out_unlock_up:
-	shm_unlock(shmid);
-out_up:
-	up(&current->mm->mmap_sem);
+put:
+	put_filp (file);
 	return err;
-
-failed_shm_map:
-	{
-		int delete = 0;
-		if (--shp->u.shm_nattch <= 0 && shp->u.shm_perm.mode & SHM_DEST)
-			delete = 1;
-		shm_unlock(shmid);
-		up(&current->mm->mmap_sem);
-		kmem_cache_free(vm_area_cachep, shmd);
-		if(delete)
-			killseg(shmid);
-		return err;
-	}
 }
 
 /* This is called by fork, once for every shm attach. */
 static void shm_open (struct vm_area_struct *shmd)
 {
-	struct shmid_kernel *shp;
-
-	shp = (struct shmid_kernel *) shmd->vm_private_data;
-	if(shp != shm_lock(shp->id))
-		BUG();
-	insert_attach(shp,shmd);  /* insert shmd into shp->attaches */
-	shp->u.shm_nattch++;
-	shp->u.shm_atime = CURRENT_TIME;
-	shp->u.shm_lpid = current->pid;
-	shm_unlock(shp->id);
+	shm_inc (shmd->vm_file->f_dentry->d_inode->i_ino);
 }
 
 /*
@@ -674,22 +829,16 @@
  */
 static void shm_close (struct vm_area_struct *shmd)
 {
+	int id = shmd->vm_file->f_dentry->d_inode->i_ino;
 	struct shmid_kernel *shp;
-	int id;
 
 	/* remove from the list of attaches of the shm segment */
-	shp = (struct shmid_kernel *) shmd->vm_private_data;
-	if(shp != shm_lock(shp->id))
+	if(!(shp = shm_lock(id)))
 		BUG();
-	remove_attach(shp,shmd);  /* remove from shp->attaches */
-  	shp->u.shm_lpid = current->pid;
+	shp->u.shm_lpid = current->pid;
 	shp->u.shm_dtime = CURRENT_TIME;
-	id=-1;
-	if (--shp->u.shm_nattch <= 0 && shp->u.shm_perm.mode & SHM_DEST)
-		id=shp->id;
-	shm_unlock(shp->id);
-	if(id!=-1)
-		killseg(id);
+	shp->u.shm_nattch--;
+	shm_unlock(id);
 }
 
 /*
@@ -733,32 +882,35 @@
 	struct shmid_kernel *shp;
 	unsigned int idx;
 	struct page * page;
+	struct inode * inode = shmd->vm_file->f_dentry->d_inode;
 
-	shp = (struct shmid_kernel *) shmd->vm_private_data;
 	idx = (address - shmd->vm_start) >> PAGE_SHIFT;
 	idx += shmd->vm_pgoff;
 
-	down(&shp->sem);
-	if(shp != shm_lock(shp->id))
+	if(!(shp = shm_lock(inode->i_ino)))
 		BUG();
 
+	if (idx >= shp->shm_npages)
+		goto sigbus;
+
+	down(&inode->i_sem);
 	pte = SHM_ENTRY(shp,idx);
 	if (!pte_present(pte)) {
 		/* page not present so shm_swap can't race with us
 		   and the semaphore protects us by other tasks that
 		   could potentially fault on our pte under us */
 		if (pte_none(pte)) {
-			shm_unlock(shp->id);
+			shm_unlock(inode->i_ino);
 			page = alloc_page(GFP_HIGHUSER);
 			if (!page)
 				goto oom;
 			clear_highpage(page);
-			if(shp != shm_lock(shp->id))
+			if(shp != shm_lock(inode->i_ino))
 				BUG();
 		} else {
 			swp_entry_t entry = pte_to_swp_entry(pte);
 
-			shm_unlock(shp->id);
+			shm_unlock(inode->i_ino);
 			page = lookup_swap_cache(entry);
 			if (!page) {
 				lock_kernel();
@@ -771,7 +923,7 @@
 			delete_from_swap_cache(page);
 			page = replace_with_highmem(page);
 			swap_free(entry);
-			if(shp != shm_lock(shp->id))
+			if(shp != shm_lock(inode->i_ino))
 				BUG();
 			shm_swp--;
 		}
@@ -783,14 +935,17 @@
 
 	/* pte_val(pte) == SHM_ENTRY (shp, idx) */
 	get_page(pte_page(pte));
-	shm_unlock(shp->id);
-	up(&shp->sem);
+	shm_unlock(inode->i_ino);
+	up(&inode->i_sem);
 	current->min_flt++;
 	return pte_page(pte);
 
 oom:
-	up(&shp->sem);
+	up(&inode->i_sem);
 	return NOPAGE_OOM;
+sigbus:
+	shm_unlock(inode->i_ino);
+	return NOPAGE_SIGBUS;
 }
 
 /*
@@ -940,20 +1095,20 @@
 	int i, len = 0;
 
 	down(&shm_ids.sem);
-	len += sprintf(buffer, "       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime\n");
+	len += sprintf(buffer, "       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime name\n");
 
-    	for(i = 0; i <= shm_ids.max_id; i++) {
+	for(i = 0; i <= shm_ids.max_id; i++) {
 		struct shmid_kernel* shp = shm_lock(i);
 		if(shp!=NULL) {
-#define SMALL_STRING "%10d %10d  %4o %10u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
-#define BIG_STRING   "%10d %10d  %4o %21u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu\n"
+#define SMALL_STRING "%10d %10d  %4o %10u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu %.*s\n"
+#define BIG_STRING   "%10d %10d  %4o %21u %5u %5u  %5d %5u %5u %5u %5u %10lu %10lu %10lu %.*s\n"
 			char *format;
 
 			if (sizeof(size_t) <= sizeof(int))
 				format = SMALL_STRING;
 			else
 				format = BIG_STRING;
-	    		len += sprintf(buffer + len, format,
+			len += sprintf(buffer + len, format,
 				shp->u.shm_perm.key,
 				shm_buildid(i, shp->u.shm_perm.seq),
 				shp->u.shm_perm.mode,
@@ -967,7 +1122,9 @@
 				shp->u.shm_perm.cgid,
 				shp->u.shm_atime,
 				shp->u.shm_dtime,
-				shp->u.shm_ctime);
+				shp->u.shm_ctime,
+				shp->namelen,
+				shp->name);
 			shm_unlock(i);
 
 			pos += len;
diff -uNr 2.3.34/kernel/acct.c c34/kernel/acct.c
--- 2.3.34/kernel/acct.c	Wed Dec  8 21:01:51 1999
+++ c34/kernel/acct.c	Thu Dec 23 20:42:19 1999
@@ -162,7 +162,7 @@
 		if (IS_ERR(tmp))
 			goto out;
 		/* Difference from BSD - they don't do O_APPEND */
-		file = filp_open(tmp, O_WRONLY|O_APPEND, 0);
+		file = filp_open(tmp, O_WRONLY|O_APPEND, 0, NULL);
 		putname(tmp);
 		if (IS_ERR(file)) {
 			error = PTR_ERR(file);
diff -uNr 2.3.34/mm/mmap.c c34/mm/mmap.c
--- 2.3.34/mm/mmap.c	Thu Dec 23 20:41:46 1999
+++ c34/mm/mmap.c	Thu Dec 23 20:42:19 1999
@@ -271,7 +271,6 @@
 	vma->vm_ops = NULL;
 	vma->vm_pgoff = pgoff;
 	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
 
 	/* Clear old maps */
 	error = -ENOMEM;
@@ -547,7 +546,6 @@
 		mpnt->vm_ops = area->vm_ops;
 		mpnt->vm_pgoff = area->vm_pgoff + ((end - area->vm_start) >> PAGE_SHIFT);
 		mpnt->vm_file = area->vm_file;
-		mpnt->vm_private_data = area->vm_private_data;
 		if (mpnt->vm_file)
 			get_file(mpnt->vm_file);
 		if (mpnt->vm_ops && mpnt->vm_ops->open)
@@ -780,7 +778,6 @@
 	vma->vm_ops = NULL;
 	vma->vm_pgoff = 0;
 	vma->vm_file = NULL;
-	vma->vm_private_data = NULL;
 
 	/*
 	 * merge_segments may merge our vma, so we can't refer to it
@@ -927,7 +924,6 @@
 
 		/* To share, we must have the same file, operations.. */
 		if ((mpnt->vm_file != prev->vm_file)||
-		    (mpnt->vm_private_data != prev->vm_private_data)	||
 		    (mpnt->vm_ops != prev->vm_ops)	||
 		    (mpnt->vm_flags != prev->vm_flags)	||
 		    (prev->vm_end != mpnt->vm_start))
diff -uNr 2.3.34/net/khttpd/security.c c34/net/khttpd/security.c
--- 2.3.34/net/khttpd/security.c	Sat Sep 18 20:49:06 1999
+++ c34/net/khttpd/security.c	Thu Dec 23 20:42:19 1999
@@ -115,7 +115,7 @@
 
 	
 		
-	filp = filp_open(Filename,00,O_RDONLY);
+	filp = filp_open(Filename,00,O_RDONLY,NULL);
 	
 	
 	if ((IS_ERR(filp))||(filp==NULL)||(filp->f_dentry==NULL))
diff -uNr 2.3.34/net/unix/af_unix.c c34/net/unix/af_unix.c
--- 2.3.34/net/unix/af_unix.c	Sun Nov  7 11:41:39 1999
+++ c34/net/unix/af_unix.c	Thu Dec 23 20:42:19 1999
@@ -572,7 +572,7 @@
 
 		/* Do not believe to VFS, grab kernel lock */
 		lock_kernel();
-		dentry = open_namei(sunname->sun_path, 2|O_NOFOLLOW, S_IFSOCK);
+		dentry = open_namei(sunname->sun_path, 2|O_NOFOLLOW, S_IFSOCK, NULL);
 		if (IS_ERR(dentry)) {
 			*error = PTR_ERR(dentry);
 			unlock_kernel();

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
