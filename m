Subject: [PATCH] get rid of vm_private_data and win posix shm version 2
References: <qwwd7rrgeen.fsf@sap.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 31 Dec 1999 17:58:38 +0100
Message-ID: <qwwg0wjf3nl.fsf@sap.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: MM mailing list <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>
Cc: "Eric W. Biederman" <ebiederm+eric@ccr.net>, Linus Torvalds <torvalds@transmeta.com>, Alexander Viro <viro@math.psu.edu>, Alan Cox <alan@lxorguk.ukuu.org.uk>, GOTO Masanori <gotom@debian.or.jp>
List-ID: <linux-mm.kvack.org>

--=-=-=

Hi folks,

This new patch now avoids the new syscalls and the separate namespace
by implementing a minimal filesystem. I have to admit that this
simplified the code a lot. But keep in mind that you now have to mount
the fs to be able to use SYSV SHM.

Also you can mount the fs only once. This will probably break shm in
chrooted environments.

It works fine for me on UP. SMP is still not tested.

Greetings
		Christoph

-- 

--=-=-=
Content-Type: text/x-patch
Content-Disposition: attachment; filename=patch-shmfs3

diff -uNr 2.3.34/fs/exec.c c34/fs/exec.c
--- 2.3.34/fs/exec.c	Thu Dec 23 20:41:45 1999
+++ c34/fs/exec.c	Fri Dec 31 13:42:52 1999
@@ -287,7 +287,6 @@
 		mpnt->vm_ops = NULL;
 		mpnt->vm_pgoff = 0;
 		mpnt->vm_file = NULL;
-		mpnt->vm_private_data = (void *) 0;
 		vmlist_modify_lock(current->mm);
 		insert_vm_struct(current->mm, mpnt);
 		vmlist_modify_unlock(current->mm);
diff -uNr 2.3.34/fs/namei.c c34/fs/namei.c
--- 2.3.34/fs/namei.c	Sat Dec 18 10:25:23 1999
+++ c34/fs/namei.c	Fri Dec 31 13:42:52 1999
@@ -1067,7 +1067,7 @@
 	return error;
 }
 
-static inline int do_unlink(const char * name)
+int do_unlink(const char * name)
 {
 	int error;
 	struct dentry *dir;
diff -uNr 2.3.34/include/linux/fs.h c34/include/linux/fs.h
--- 2.3.34/include/linux/fs.h	Fri Dec 31 10:56:19 1999
+++ c34/include/linux/fs.h	Fri Dec 31 13:44:27 1999
@@ -843,6 +843,7 @@
 extern struct dentry * open_namei(const char *, int, int);
 extern struct dentry * do_mknod(const char *, int, dev_t);
 extern int do_pipe(int *);
+extern int do_unlink(const char * name);
 
 /* fs/dcache.c -- generic fs support functions */
 extern int is_subdir(struct dentry *, struct dentry *);
diff -uNr 2.3.34/include/linux/mm.h c34/include/linux/mm.h
--- 2.3.34/include/linux/mm.h	Sat Dec 18 11:00:50 1999
+++ c34/include/linux/mm.h	Fri Dec 31 13:44:27 1999
@@ -60,7 +60,6 @@
 	struct vm_operations_struct * vm_ops;
 	unsigned long vm_pgoff;		/* offset in PAGE_SIZE units, *not* PAGE_CACHE_SIZE */
 	struct file * vm_file;
-	void * vm_private_data;		/* was vm_pte (shared mem) */
 };
 
 /*
diff -uNr 2.3.34/ipc/shm.c c34/ipc/shm.c
--- 2.3.34/ipc/shm.c	Thu Dec 23 20:41:46 1999
+++ c34/ipc/shm.c	Fri Dec 31 16:33:27 1999
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
@@ -19,6 +19,9 @@
 #include <linux/swap.h>
 #include <linux/smp_lock.h>
 #include <linux/init.h>
+#include <linux/locks.h>
+#include <linux/file.h>
+#include <linux/mman.h>
 #include <linux/vmalloc.h>
 #include <linux/pagemap.h>
 #include <linux/proc_fs.h>
@@ -29,14 +32,39 @@
 
 #include "util.h"
 
+#define SHM_DEBUG 1
+
+#ifdef SHM_DEBUG
+#define dprint(format, args...)	 printk ( "%s " format "\n", __FUNCTION__ , ## args)
+#else
+#define dprint(x...) 
+#endif
+
+static struct super_block *shm_read_super(struct super_block *,void *, int);
+static void	      shm_put_super  (struct super_block *);
+static void	      shm_read_inode (struct inode *);
+static void	      shm_write_inode(struct inode *);
+static int	      shm_statfs (struct super_block *, struct statfs *, int);
+static int	      shm_create   (struct inode *,struct dentry *,int);
+static struct dentry *shm_lookup   (struct inode *,struct dentry *);
+static int	      shm_unlink   (struct inode *,struct dentry *);
+static int	      shm_notify   (struct dentry *dent, struct iattr *attr);
+static void	      shm_delete   (struct inode *);
+static int	      shm_mmap	   (struct file *, struct vm_area_struct *);
+static int	      shm_readdir  (struct file *, void *, filldir_t);
+
+static char *ipc_path;
+#define SHM_NAME_LEN NAME_MAX
+#define SHM_FMT ".IPC_%08x"
+#define SHM_FMT_LEN 14
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
@@ -52,9 +80,7 @@
 #define shm_buildid(id, seq) \
 	ipc_buildid(&shm_ids, id, seq)
 
-static int newseg (key_t key, int shmflg, size_t size);
-static int shm_map (struct vm_area_struct *shmd);
-static void killseg (int shmid);
+static int newseg (key_t key, const char *name, int namelen, int shmflg, size_t size);
 static void shm_open (struct vm_area_struct *shmd);
 static void shm_close (struct vm_area_struct *shmd);
 static struct page * shm_nopage(struct vm_area_struct *, unsigned long, int);
@@ -63,6 +89,67 @@
 static int sysvipc_shm_read_proc(char *buffer, char **start, off_t offset, int length, int *eof, void *data);
 #endif
 
+static struct super_block * shm_sb;
+
+static struct file_system_type shm_fs_type = {
+	"shm",
+	0,
+	shm_read_super,
+	NULL
+};
+
+static struct super_operations shm_sops = {
+	shm_read_inode,		/* read_inode */
+	shm_write_inode,	/* write_inode */
+	NULL,			/* put_inode */
+	shm_delete,		/* delete_inode */
+	shm_notify,		/* notify_change */
+	shm_put_super,		/* put_super */
+	NULL,		 	/* write_super */
+	shm_statfs,		/* statfs */
+};
+
+static struct file_operations shm_root_operations = {
+	NULL,                   /* llseek */
+	NULL,                   /* read */
+	NULL,                   /* write */
+	shm_readdir,		/* readdir */
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
@@ -75,7 +162,7 @@
 	pagecache_lock
 	shm_lock()/shm_lockall()
 	kernel lock
-	shp->sem
+	inode->i_sem
 	sem_ids.sem
 	mmap_sem
 
@@ -94,12 +181,219 @@
 void __init shm_init (void)
 {
 	ipc_init_ids(&shm_ids, shm_ctlmni);
+
+	register_filesystem (&shm_fs_type);
 #ifdef CONFIG_PROC_FS
 	create_proc_read_entry("sysvipc/shm", 0, 0, sysvipc_shm_read_proc, NULL);
 #endif
 	return;
 }
 
+static struct super_block *shm_read_super(struct super_block *s,void *data, 
+					  int silent)
+{
+	struct inode * root_inode;
+
+	if (shm_sb) {
+		printk ("shm fs already mounted\n");
+		return NULL;
+	}
+
+	lock_super(s);
+	s->s_blocksize = PAGE_SIZE;
+	s->s_blocksize_bits = PAGE_SHIFT;
+	s->s_magic = 0;
+	s->s_op = &shm_sops;
+	root_inode = iget (s, SEQ_MULTIPLIER);
+	if (!root_inode)
+		goto out_no_root;
+	root_inode->i_op = &shm_root_inode_operations;
+	root_inode->i_sb = s;
+	root_inode->i_mode = S_IFDIR | S_IRWXUGO | S_ISVTX;
+	s->s_root = d_alloc_root(root_inode);
+	if (!s->s_root)
+		goto out_no_root;
+	s->u.generic_sbp = (void*) shm_sb;
+	shm_sb = s;
+	unlock_super(s);
+	return s;
+
+out_no_root:
+	printk("proc_read_super: get root inode failed\n");
+	iput(root_inode);
+	s->s_dev = 0;
+	unlock_super(s);
+	return NULL;
+}
+
+static void shm_put_super(struct super_block *sb)
+{
+	struct super_block **p = &shm_sb;
+	while (*p != sb) {
+		if (!*p)	/* should never happen */
+			return;
+		p = (struct super_block **)&(*p)->u.generic_sbp;
+	}
+	*p = (struct super_block *)(*p)->u.generic_sbp;
+	if (shm_sb == NULL) {
+		down(&shm_ids.sem);
+		kfree (ipc_path);
+		ipc_path = NULL;
+		up(&shm_ids.sem);
+	}
+}
+
+static int shm_statfs(struct super_block *sb, struct statfs *buf, int bufsiz)
+{
+	struct statfs tmp;
+
+	tmp.f_type = 0;
+	tmp.f_bsize = PAGE_SIZE;
+	tmp.f_blocks = shm_ctlall;
+	tmp.f_bavail = tmp.f_bfree = shm_ctlall - shm_tot;
+	tmp.f_files = shm_ctlmni;
+	tmp.f_ffree = shm_ctlmni - used_segs;
+	tmp.f_namelen = SHM_NAME_LEN;
+	return copy_to_user(buf, &tmp, bufsiz) ? -EFAULT : 0;
+}
+
+static void shm_write_inode(struct inode * inode)
+{
+}
+
+static void shm_read_inode(struct inode * inode)
+{
+	inode->i_mtime = inode->i_atime = inode->i_ctime = CURRENT_TIME;
+}
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
+	inode->i_mode = shp->u.shm_perm.mode | S_IFREG;
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
+	id = newseg (IPC_PRIVATE, dent->d_name.name, dent->d_name.len, mode, 0);
+	if (id >= 0)
+		id = shm_dget (id, dent);
+	up(&shm_ids.sem);
+	return id;
+}
+
+static int shm_readdir (struct file *filp, void *dirent, filldir_t filldir)
+{
+	struct inode * inode = filp->f_dentry->d_inode;
+	struct shmid_kernel *shp;
+	off_t nr;
+
+	nr = filp->f_pos;
+
+	switch(nr)
+	{
+	case 0:
+		if (filldir(dirent, ".", 1, nr, inode->i_ino) < 0)
+			return 0;
+		filp->f_pos = ++nr;
+		/* fall through */
+	case 1:
+		if (filldir(dirent, "..", 2, nr, inode->i_ino) < 0)
+			return 0;
+		filp->f_pos = ++nr;
+		/* fall through */
+	default:
+		down(&shm_ids.sem);
+		for (; nr-2 <= shm_ids.max_id; nr++ ) {
+			if (!(shp = shm_get (nr-2))) 
+				continue;
+			if (filldir(dirent, shp->name, shp->namelen, nr, nr) < 0 )
+				break;;
+		}
+		filp->f_pos = nr;
+		up(&shm_ids.sem);
+		break;
+	}
+
+	UPDATE_ATIME(inode);
+	return 0;
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
+		if (!(shp->u.shm_perm.mode & SHM_DEST) &&
+		    dent->d_name.len == shp->namelen &&
+		    strncmp(dent->d_name.name, shp->name, shp->namelen) == 0)
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
 #define SHM_ENTRY(shp, index) (shp)->shm_dir[(index)/PTRS_PER_PTE][(index)%PTRS_PER_PTE]
 
 static pte_t **shm_alloc(unsigned long pages)
@@ -108,9 +402,12 @@
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
@@ -127,7 +424,6 @@
 			goto free;
 		memset (*ptr, 0, last*sizeof(pte_t));
 	}
-out:	
 	return ret;
 
 free:
@@ -136,66 +432,111 @@
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
+	shp = (struct shmid_kernel *) 
+		kmalloc (sizeof (*shp) + (namelen ? namelen : SHM_FMT_LEN), GFP_KERNEL);
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
@@ -206,18 +547,25 @@
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
+		shp->namelen = sprintf (shp->name, SHM_FMT, id);
+	}
 
 	shm_tot += numpages;
+	used_segs++;
+	shm_sb->s_root->d_inode->i_size++;
 	shm_unlock(id);
-
-	return shm_buildid(id,shp->u.shm_perm.seq);
+	
+	return id;
 }
 
 asmlinkage long sys_shmget (key_t key, size_t size, int shmflg)
@@ -225,14 +573,20 @@
 	struct shmid_kernel *shp;
 	int err, id = 0;
 
+	if (!shm_sb)
+		return -EINVAL;
+
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
@@ -249,12 +603,9 @@
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
@@ -262,20 +613,9 @@
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
 
@@ -299,16 +639,47 @@
 	shm_rss -= rss;
 	shm_swp -= swp;
 	shm_tot -= numpages;
+	shm_sb->s_root->d_inode->i_size--;
+	used_segs--;
 	shm_unlockall();
 	return;
 }
 
+char * shm_getname(int id)
+{
+	char *result;
+
+	result = __getname ();
+	if (IS_ERR(result))
+		return result;
+
+	down(&shm_ids.sem);
+	if (!ipc_path) {
+		char *tmp = d_path (shm_sb->s_root, result, PAGE_SIZE);
+		ipc_path = kmalloc (strlen(tmp) + sizeof (SHM_FMT) + 1,
+				     GFP_KERNEL);
+		if (!ipc_path) {
+			putname (result);
+			up (&shm_ids.sem);
+			return ERR_PTR(-ENOMEM);
+		}
+
+		sprintf (ipc_path, "%s/%s", tmp, SHM_FMT);
+	}
+	sprintf (result, ipc_path, id); 
+	up(&shm_ids.sem);
+	return result;
+}
+
 asmlinkage long sys_shmctl (int shmid, int cmd, struct shmid_ds *buf)
 {
 	struct shmid_ds tbuf;
 	struct shmid_kernel *shp;
 	int err;
 
+	if (!shm_sb)
+		return -EINVAL;
+
 	if (cmd < 0 || shmid < 0)
 		return -EINVAL;
 
@@ -410,48 +781,46 @@
 		return err;
 	}
 	case IPC_RMID:
-	case IPC_SET:
-		break;
-	default:
-		return -EINVAL;
+	{
+		char *name = shm_getname(shmid);
+		if (IS_ERR(name))
+			return PTR_ERR(name);
+		err = do_unlink (name);
+		putname (name);
+		if (err == -ENOENT)
+			err = -EINVAL;
+		return err;
 	}
-
-	if (cmd == IPC_SET) {
+	case IPC_SET:
+	{
 		if(copy_from_user (&tbuf, buf, sizeof (*buf)))
 			return -EFAULT;
-	}
-	down(&shm_ids.sem);
-	shp = shm_lock(shmid);
-	err=-EINVAL;
-	if(shp==NULL)
-		goto out_up;
-	err=-EIDRM;
-	if(shm_checkid(shp,shmid))
-		goto out_unlock_up;
-	err=-EPERM;
-	if (current->euid != shp->u.shm_perm.uid &&
-	    current->euid != shp->u.shm_perm.cuid && 
-	    !capable(CAP_SYS_ADMIN)) {
-		goto out_unlock_up;
-	}
+		down(&shm_ids.sem);
+		shp = shm_lock(shmid);
+		err=-EINVAL;
+		if(shp==NULL)
+			goto out_up;
+		err=-EIDRM;
+		if(shm_checkid(shp,shmid))
+			goto out_unlock_up;
+		err=-EPERM;
+		if (current->euid != shp->u.shm_perm.uid &&
+		    current->euid != shp->u.shm_perm.cuid && 
+		    !capable(CAP_SYS_ADMIN))
+			goto out_unlock_up;
 
-	switch (cmd) {
-	case IPC_SET:
 		shp->u.shm_perm.uid = tbuf.shm_perm.uid;
 		shp->u.shm_perm.gid = tbuf.shm_perm.gid;
 		shp->u.shm_perm.mode = (shp->u.shm_perm.mode & ~S_IRWXUGO)
 			| (tbuf.shm_perm.mode & S_IRWXUGO);
 		shp->u.shm_ctime = CURRENT_TIME;
 		break;
-	case IPC_RMID:
-		shp->u.shm_perm.mode |= SHM_DEST;
-		if (shp->u.shm_nattch <= 0) {
-			shm_unlock(shmid);
-			up(&shm_ids.sem);
-			killseg (shmid);
-			return 0;
-		}
 	}
+
+	default:
+		return -EINVAL;
+	}
+
 	err = 0;
 out_unlock_up:
 	shm_unlock(shmid);
@@ -463,70 +832,24 @@
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
 
@@ -535,135 +858,55 @@
  */
 asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr)
 {
-	struct shmid_kernel *shp;
-	struct vm_area_struct *shmd;
-	int err;
 	unsigned long addr;
-	unsigned long len;
-	short flg = shmflg & SHM_RDONLY ? S_IRUGO : S_IRUGO|S_IWUGO;
+	struct file * file;
+	int    err;
+	int    flags;
+	char   *name;
 
-
-	if (shmid < 0)
+	if (!shm_sb)
 		return -EINVAL;
 
-	down(&current->mm->mmap_sem);
-	err = -EINVAL;
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
+	if ((addr = (ulong)shmaddr))
+	{
+		if(addr & (SHMLBA-1)) {
+			if (shmflg & SHM_RND)
+				addr &= ~(SHMLBA-1);	   /* round down */
+			else
+				return -EINVAL;
 		}
-	} else if (addr & (SHMLBA-1)) {
-		err=-EINVAL;
-		if (shmflg & SHM_RND)
-			addr &= ~(SHMLBA-1);       /* round down */
-		else
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
-	}
-
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
+		flags = MAP_SHARED | MAP_FIXED;
+	} else
+		flags = MAP_SHARED;
 
-	*raddr = addr;
-	err = 0;
-out_unlock_up:
-	shm_unlock(shmid);
-out_up:
-	up(&current->mm->mmap_sem);
+	name = shm_getname(shmid);
+	if (IS_ERR (name))
+		return PTR_ERR (name);
+
+	file = filp_open (name, O_RDWR, 0);
+	putname (name);
+	if (IS_ERR (file))
+		goto bad_file;
+	*raddr = do_mmap (file, addr, file->f_dentry->d_inode->i_size,
+			  (shmflg & SHM_RDONLY ? PROT_READ :
+			   PROT_READ | PROT_WRITE), flags, 0);
+	if (IS_ERR(*raddr))
+		err = PTR_ERR(*raddr);
+	else
+		err = 0;
+        fput (file);
 	return err;
 
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
+bad_file:
+	if ((err = PTR_ERR(file)) == -ENOENT)
+		return -EINVAL;
+	return err;
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
@@ -674,22 +917,16 @@
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
@@ -733,32 +970,35 @@
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
@@ -771,7 +1011,7 @@
 			delete_from_swap_cache(page);
 			page = replace_with_highmem(page);
 			swap_free(entry);
-			if(shp != shm_lock(shp->id))
+			if(shp != shm_lock(inode->i_ino))
 				BUG();
 			shm_swp--;
 		}
@@ -783,14 +1023,17 @@
 
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
@@ -940,20 +1183,20 @@
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
@@ -967,7 +1210,9 @@
 				shp->u.shm_perm.cgid,
 				shp->u.shm_atime,
 				shp->u.shm_dtime,
-				shp->u.shm_ctime);
+				shp->u.shm_ctime,
+				shp->namelen,
+				shp->name);
 			shm_unlock(i);
 
 			pos += len;
diff -uNr 2.3.34/mm/mmap.c c34/mm/mmap.c
--- 2.3.34/mm/mmap.c	Thu Dec 23 20:41:46 1999
+++ c34/mm/mmap.c	Fri Dec 31 13:42:52 1999
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

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
