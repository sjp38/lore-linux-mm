Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E96835F0001
	for <linux-mm@kvack.org>; Sat, 11 Apr 2009 08:14:41 -0400 (EDT)
References: <m1skkf761y.fsf@fess.ebiederm.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 11 Apr 2009 05:14:50 -0700
In-Reply-To: <m1skkf761y.fsf@fess.ebiederm.org> (Eric W. Biederman's message of "Sat\, 11 Apr 2009 05\:01\:29 -0700")
Message-ID: <m1ljq75qv9.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Subject: [RFC][PATCH 9/9] proc: Use the generic vfs revoke facility that now exists.
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Al Viro <viro@ZenIV.linux.org.uk>, Hugh Dickins <hugh@veritas.com>, Tejun Heo <tj@kernel.org>, Alexey Dobriyan <adobriyan@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Greg Kroah-Hartman <gregkh@suse.de>
List-ID: <linux-mm.kvack.org>


Doing this the code becomes much simpler and more robust.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 fs/proc/generic.c       |  100 +++++----------
 fs/proc/inode.c         |  339 +----------------------------------------------
 fs/proc/internal.h      |    2 +
 fs/proc/root.c          |    2 +-
 include/linux/proc_fs.h |    4 -
 5 files changed, 36 insertions(+), 411 deletions(-)

diff --git a/fs/proc/generic.c b/fs/proc/generic.c
index fa678ab..5453114 100644
--- a/fs/proc/generic.c
+++ b/fs/proc/generic.c
@@ -20,6 +20,8 @@
 #include <linux/bitops.h>
 #include <linux/spinlock.h>
 #include <linux/completion.h>
+#include <linux/file.h>
+#include <linux/mm.h>
 #include <asm/uaccess.h>
 
 #include "internal.h"
@@ -37,7 +39,7 @@ static int proc_match(int len, const char *name, struct proc_dir_entry *de)
 #define PROC_BLOCK_SIZE	(PAGE_SIZE - 1024)
 
 static ssize_t
-__proc_file_read(struct file *file, char __user *buf, size_t nbytes,
+proc_file_read(struct file *file, char __user *buf, size_t nbytes,
 	       loff_t *ppos)
 {
 	struct inode * inode = file->f_path.dentry->d_inode;
@@ -183,27 +185,6 @@ __proc_file_read(struct file *file, char __user *buf, size_t nbytes,
 }
 
 static ssize_t
-proc_file_read(struct file *file, char __user *buf, size_t nbytes,
-	       loff_t *ppos)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	ssize_t rv = -EIO;
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	spin_unlock(&pde->pde_unload_lock);
-
-	rv = __proc_file_read(file, buf, nbytes, ppos);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static ssize_t
 proc_file_write(struct file *file, const char __user *buffer,
 		size_t count, loff_t *ppos)
 {
@@ -211,17 +192,8 @@ proc_file_write(struct file *file, const char __user *buffer,
 	ssize_t rv = -EIO;
 
 	if (pde->write_proc) {
-		spin_lock(&pde->pde_unload_lock);
-		if (!pde->proc_fops) {
-			spin_unlock(&pde->pde_unload_lock);
-			return rv;
-		}
-		pde->pde_users++;
-		spin_unlock(&pde->pde_unload_lock);
-
 		/* FIXME: does this routine need ppos?  probably... */
 		rv = pde->write_proc(file, buffer, count, pde->data);
-		pde_users_dec(pde);
 	}
 	return rv;
 }
@@ -630,10 +602,6 @@ static struct proc_dir_entry *__proc_create(struct proc_dir_entry **parent,
 	ent->mode = mode;
 	ent->nlink = nlink;
 	atomic_set(&ent->count, 1);
-	ent->pde_users = 0;
-	spin_lock_init(&ent->pde_unload_lock);
-	ent->pde_unload_completion = NULL;
-	INIT_LIST_HEAD(&ent->pde_openers);
  out:
 	return ent;
 }
@@ -777,6 +745,33 @@ void free_proc_entry(struct proc_dir_entry *de)
 	kfree(de);
 }
 
+static struct inode *get_pde_inode(struct proc_dir_entry *de)
+{
+	struct inode *inode = NULL;
+	struct super_block *sb;
+
+	spin_lock(&sb_lock);
+	list_for_each_entry(sb, &proc_fs_type.fs_supers, s_instances) {
+		inode = ilookup(sb, de->low_ino);
+		if (inode && inode->i_fop != &revoked_file_ops)
+			break;
+		iput(inode);
+		inode = NULL;
+	}
+	spin_unlock(&sb_lock);
+	return inode;
+}
+
+static void proc_revoke_pde(struct proc_dir_entry *de)
+{
+	struct inode *inode;
+
+	while ((inode = get_pde_inode(de))) {
+		inode_fops_substitute(inode, &revoked_file_ops, &revoked_vm_ops);
+		iput(inode);
+	}
+}
+
 /*
  * Remove a /proc entry and free it if it's not currently in use.
  */
@@ -804,40 +799,7 @@ void remove_proc_entry(const char *name, struct proc_dir_entry *parent)
 	if (!de)
 		return;
 
-	spin_lock(&de->pde_unload_lock);
-	/*
-	 * Stop accepting new callers into module. If you're
-	 * dynamically allocating ->proc_fops, save a pointer somewhere.
-	 */
-	de->proc_fops = NULL;
-	/* Wait until all existing callers into module are done. */
-	if (de->pde_users > 0) {
-		DECLARE_COMPLETION_ONSTACK(c);
-
-		if (!de->pde_unload_completion)
-			de->pde_unload_completion = &c;
-
-		spin_unlock(&de->pde_unload_lock);
-
-		wait_for_completion(de->pde_unload_completion);
-
-		goto continue_removing;
-	}
-	spin_unlock(&de->pde_unload_lock);
-
-continue_removing:
-	spin_lock(&de->pde_unload_lock);
-	while (!list_empty(&de->pde_openers)) {
-		struct pde_opener *pdeo;
-
-		pdeo = list_first_entry(&de->pde_openers, struct pde_opener, lh);
-		list_del(&pdeo->lh);
-		spin_unlock(&de->pde_unload_lock);
-		pdeo->release(pdeo->inode, pdeo->file);
-		kfree(pdeo);
-		spin_lock(&de->pde_unload_lock);
-	}
-	spin_unlock(&de->pde_unload_lock);
+	proc_revoke_pde(de);
 
 	if (S_ISDIR(de->mode))
 		parent->nlink--;
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index d78ade3..aa7e629 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -117,330 +117,6 @@ static const struct super_operations proc_sops = {
 	.statfs		= simple_statfs,
 };
 
-static void __pde_users_dec(struct proc_dir_entry *pde)
-{
-	pde->pde_users--;
-	if (pde->pde_unload_completion && pde->pde_users == 0)
-		complete(pde->pde_unload_completion);
-}
-
-void pde_users_dec(struct proc_dir_entry *pde)
-{
-	spin_lock(&pde->pde_unload_lock);
-	__pde_users_dec(pde);
-	spin_unlock(&pde->pde_unload_lock);
-}
-
-static loff_t proc_reg_llseek(struct file *file, loff_t offset, int whence)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	loff_t rv = -EINVAL;
-	loff_t (*llseek)(struct file *, loff_t, int);
-
-	spin_lock(&pde->pde_unload_lock);
-	/*
-	 * remove_proc_entry() is going to delete PDE (as part of module
-	 * cleanup sequence). No new callers into module allowed.
-	 */
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	/*
-	 * Bump refcount so that remove_proc_entry will wail for ->llseek to
-	 * complete.
-	 */
-	pde->pde_users++;
-	/*
-	 * Save function pointer under lock, to protect against ->proc_fops
-	 * NULL'ifying right after ->pde_unload_lock is dropped.
-	 */
-	llseek = pde->proc_fops->llseek;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (!llseek)
-		llseek = default_llseek;
-	rv = llseek(file, offset, whence);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static ssize_t proc_reg_read(struct file *file, char __user *buf, size_t count, loff_t *ppos)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	ssize_t rv = -EIO;
-	ssize_t (*read)(struct file *, char __user *, size_t, loff_t *);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	read = pde->proc_fops->read;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (read)
-		rv = read(file, buf, count, ppos);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static ssize_t proc_reg_write(struct file *file, const char __user *buf, size_t count, loff_t *ppos)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	ssize_t rv = -EIO;
-	ssize_t (*write)(struct file *, const char __user *, size_t, loff_t *);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	write = pde->proc_fops->write;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (write)
-		rv = write(file, buf, count, ppos);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static unsigned int proc_reg_poll(struct file *file, struct poll_table_struct *pts)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	unsigned int rv = DEFAULT_POLLMASK;
-	unsigned int (*poll)(struct file *, struct poll_table_struct *);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	poll = pde->proc_fops->poll;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (poll)
-		rv = poll(file, pts);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static long proc_reg_unlocked_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	long rv = -ENOTTY;
-	long (*unlocked_ioctl)(struct file *, unsigned int, unsigned long);
-	int (*ioctl)(struct inode *, struct file *, unsigned int, unsigned long);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	unlocked_ioctl = pde->proc_fops->unlocked_ioctl;
-	ioctl = pde->proc_fops->ioctl;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (unlocked_ioctl) {
-		rv = unlocked_ioctl(file, cmd, arg);
-		if (rv == -ENOIOCTLCMD)
-			rv = -EINVAL;
-	} else if (ioctl) {
-		lock_kernel();
-		rv = ioctl(file->f_path.dentry->d_inode, file, cmd, arg);
-		unlock_kernel();
-	}
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-#ifdef CONFIG_COMPAT
-static long proc_reg_compat_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	long rv = -ENOTTY;
-	long (*compat_ioctl)(struct file *, unsigned int, unsigned long);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	compat_ioctl = pde->proc_fops->compat_ioctl;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (compat_ioctl)
-		rv = compat_ioctl(file, cmd, arg);
-
-	pde_users_dec(pde);
-	return rv;
-}
-#endif
-
-static int proc_reg_mmap(struct file *file, struct vm_area_struct *vma)
-{
-	struct proc_dir_entry *pde = PDE(file->f_path.dentry->d_inode);
-	int rv = -EIO;
-	int (*mmap)(struct file *, struct vm_area_struct *);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	mmap = pde->proc_fops->mmap;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (mmap)
-		rv = mmap(file, vma);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static int proc_reg_open(struct inode *inode, struct file *file)
-{
-	struct proc_dir_entry *pde = PDE(inode);
-	int rv = 0;
-	int (*open)(struct inode *, struct file *);
-	int (*release)(struct inode *, struct file *);
-	struct pde_opener *pdeo;
-
-	/*
-	 * What for, you ask? Well, we can have open, rmmod, remove_proc_entry
-	 * sequence. ->release won't be called because ->proc_fops will be
-	 * cleared. Depending on complexity of ->release, consequences vary.
-	 *
-	 * We can't wait for mercy when close will be done for real, it's
-	 * deadlockable: rmmod foo </proc/foo . So, we're going to do ->release
-	 * by hand in remove_proc_entry(). For this, save opener's credentials
-	 * for later.
-	 */
-	pdeo = kmalloc(sizeof(struct pde_opener), GFP_KERNEL);
-	if (!pdeo)
-		return -ENOMEM;
-
-	spin_lock(&pde->pde_unload_lock);
-	if (!pde->proc_fops) {
-		spin_unlock(&pde->pde_unload_lock);
-		kfree(pdeo);
-		return -EINVAL;
-	}
-	pde->pde_users++;
-	open = pde->proc_fops->open;
-	release = pde->proc_fops->release;
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (open)
-		rv = open(inode, file);
-
-	spin_lock(&pde->pde_unload_lock);
-	if (rv == 0 && release) {
-		/* To know what to release. */
-		pdeo->inode = inode;
-		pdeo->file = file;
-		/* Strictly for "too late" ->release in proc_reg_release(). */
-		pdeo->release = release;
-		list_add(&pdeo->lh, &pde->pde_openers);
-	} else
-		kfree(pdeo);
-	__pde_users_dec(pde);
-	spin_unlock(&pde->pde_unload_lock);
-	return rv;
-}
-
-static struct pde_opener *find_pde_opener(struct proc_dir_entry *pde,
-					struct inode *inode, struct file *file)
-{
-	struct pde_opener *pdeo;
-
-	list_for_each_entry(pdeo, &pde->pde_openers, lh) {
-		if (pdeo->inode == inode && pdeo->file == file)
-			return pdeo;
-	}
-	return NULL;
-}
-
-static int proc_reg_release(struct inode *inode, struct file *file)
-{
-	struct proc_dir_entry *pde = PDE(inode);
-	int rv = 0;
-	int (*release)(struct inode *, struct file *);
-	struct pde_opener *pdeo;
-
-	spin_lock(&pde->pde_unload_lock);
-	pdeo = find_pde_opener(pde, inode, file);
-	if (!pde->proc_fops) {
-		/*
-		 * Can't simply exit, __fput() will think that everything is OK,
-		 * and move on to freeing struct file. remove_proc_entry() will
-		 * find slacker in opener's list and will try to do non-trivial
-		 * things with struct file. Therefore, remove opener from list.
-		 *
-		 * But if opener is removed from list, who will ->release it?
-		 */
-		if (pdeo) {
-			list_del(&pdeo->lh);
-			spin_unlock(&pde->pde_unload_lock);
-			rv = pdeo->release(inode, file);
-			kfree(pdeo);
-		} else
-			spin_unlock(&pde->pde_unload_lock);
-		return rv;
-	}
-	pde->pde_users++;
-	release = pde->proc_fops->release;
-	if (pdeo) {
-		list_del(&pdeo->lh);
-		kfree(pdeo);
-	}
-	spin_unlock(&pde->pde_unload_lock);
-
-	if (release)
-		rv = release(inode, file);
-
-	pde_users_dec(pde);
-	return rv;
-}
-
-static const struct file_operations proc_reg_file_ops = {
-	.llseek		= proc_reg_llseek,
-	.read		= proc_reg_read,
-	.write		= proc_reg_write,
-	.poll		= proc_reg_poll,
-	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
-#ifdef CONFIG_COMPAT
-	.compat_ioctl	= proc_reg_compat_ioctl,
-#endif
-	.mmap		= proc_reg_mmap,
-	.open		= proc_reg_open,
-	.release	= proc_reg_release,
-};
-
-#ifdef CONFIG_COMPAT
-static const struct file_operations proc_reg_file_ops_no_compat = {
-	.llseek		= proc_reg_llseek,
-	.read		= proc_reg_read,
-	.write		= proc_reg_write,
-	.poll		= proc_reg_poll,
-	.unlocked_ioctl	= proc_reg_unlocked_ioctl,
-	.mmap		= proc_reg_mmap,
-	.open		= proc_reg_open,
-	.release	= proc_reg_release,
-};
-#endif
-
 struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
 				struct proc_dir_entry *de)
 {
@@ -465,19 +141,8 @@ struct inode *proc_get_inode(struct super_block *sb, unsigned int ino,
 			inode->i_nlink = de->nlink;
 		if (de->proc_iops)
 			inode->i_op = de->proc_iops;
-		if (de->proc_fops) {
-			if (S_ISREG(inode->i_mode)) {
-#ifdef CONFIG_COMPAT
-				if (!de->proc_fops->compat_ioctl)
-					inode->i_fop =
-						&proc_reg_file_ops_no_compat;
-				else
-#endif
-					inode->i_fop = &proc_reg_file_ops;
-			} else {
-				inode->i_fop = de->proc_fops;
-			}
-		}
+		if (de->proc_fops)
+			inode->i_fop = de->proc_fops;
 		unlock_new_inode(inode);
 	} else
 	       de_put(de);
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index f6db961..ea658ac 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -92,3 +92,5 @@ struct pde_opener {
 	struct list_head lh;
 };
 void pde_users_dec(struct proc_dir_entry *pde);
+
+extern struct file_system_type proc_fs_type;
diff --git a/fs/proc/root.c b/fs/proc/root.c
index 1e15a2b..ba7a99d 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -96,7 +96,7 @@ static void proc_kill_sb(struct super_block *sb)
 	put_pid_ns(ns);
 }
 
-static struct file_system_type proc_fs_type = {
+struct file_system_type proc_fs_type = {
 	.name		= "proc",
 	.get_sb		= proc_get_sb,
 	.kill_sb	= proc_kill_sb,
diff --git a/include/linux/proc_fs.h b/include/linux/proc_fs.h
index fbfa3d4..2baeb37 100644
--- a/include/linux/proc_fs.h
+++ b/include/linux/proc_fs.h
@@ -72,10 +72,6 @@ struct proc_dir_entry {
 	read_proc_t *read_proc;
 	write_proc_t *write_proc;
 	atomic_t count;		/* use count */
-	int pde_users;	/* number of callers into module in progress */
-	spinlock_t pde_unload_lock; /* proc_fops checks and pde_users bumps */
-	struct completion *pde_unload_completion;
-	struct list_head pde_openers;	/* who did ->open, but not ->release */
 };
 
 struct kcore_list {
-- 
1.6.1.2.350.g88cc

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
