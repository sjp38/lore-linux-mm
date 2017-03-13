Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E4E306B03AF
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 18:15:15 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id n11so15929731wma.5
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 15:15:15 -0700 (PDT)
From: Till Smejkal <till.smejkal@googlemail.com>
Subject: [RFC PATCH 13/13] fs/proc: Add procfs support for first class virtual address spaces
Date: Mon, 13 Mar 2017 15:14:15 -0700
Message-Id: <20170313221415.9375-14-till.smejkal@gmail.com>
In-Reply-To: <20170313221415.9375-1-till.smejkal@gmail.com>
References: <20170313221415.9375-1-till.smejkal@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Vineet Gupta <vgupta@synopsys.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steven Miao <realmz6@gmail.com>, Richard Kuo <rkuo@codeaurora.org>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, James Hogan <james.hogan@imgtec.com>, Ralf Baechle <ralf@linux-mips.org>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Helge Deller <deller@gmx.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S. Miller" <davem@davemloft.net>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andy Lutomirski <luto@amacapital.net>, Chris Zankel <chris@zankel.net>, Max Filippov <jcmvbkbc@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, Pawel Osciak <pawel@osciak.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, David Woodhouse <dwmw2@infradead.org>, Brian Norris <computersforpeace@gmail.com>, Boris Brezillon <boris.brezillon@free-electrons.com>, Marek Vasut <marek.vasut@gmail.com>, Richard Weinberger <richard@nod.at>, Cyrille Pitchen <cyrille.pitchen@atmel.com>, Felipe Balbi <balbi@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Benjamin LaHaise <bcrl@kvack.org>, Nadia Yvette Chambers <nyc@holomorphy.com>, Jeff Layton <jlayton@poochiereds.net>, "J. Bruce Fields" <bfields@fieldses.org>, Peter Zijlstra <peterz@infradead.org>, Hugh Dickins <hughd@google.com>, Arnaldo Carvalho de Melo <acme@kernel.org>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Jaroslav Kysela <perex@perex.cz>, Takashi Iwai <tiwai@suse.com>
Cc: linux-kernel@vger.kernel.org, linux-alpha@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-metag@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-media@vger.kernel.org, linux-mtd@lists.infradead.org, linux-usb@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-aio@kvack.org, linux-mm@kvack.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, alsa-devel@alsa-project.org

Add new files and directories to the procfs file system that contain
various information about the first class virtual address spaces attach to
the processes in the system.

To the procfs directories of each process in the system (/proc/$PID) an
additional directory with the name 'vas' is added that contains information
about all the VAS that are attached to this process. In this directory one
can find for each attached VAS a special folder with a file with some
status information about the attached VAS, a file with the current memory
map of the attached VAS and a link to the sysfs folder of the underlying
VAS.

Signed-off-by: Till Smejkal <till.smejkal@gmail.com>
---
 fs/proc/base.c     | 528 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/proc/inode.c    |   1 +
 fs/proc/internal.h |   1 +
 mm/Kconfig         |   9 +
 4 files changed, 539 insertions(+)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 87c9a9aacda3..e60c13dd087c 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -45,6 +45,9 @@
  *
  *  Paul Mundt <paul.mundt@nokia.com>:
  *  Overall revision about smaps.
+ *
+ *  Till Smejkal <till.smejkal@gmail.com>:
+ *  Add entries for first class virtual address spaces.
  */
 
 #include <linux/uaccess.h>
@@ -87,6 +90,7 @@
 #include <linux/slab.h>
 #include <linux/flex_array.h>
 #include <linux/posix-timers.h>
+#include <linux/vas.h>
 #ifdef CONFIG_HARDWALL
 #include <asm/hardwall.h>
 #endif
@@ -2841,6 +2845,527 @@ static int proc_pid_personality(struct seq_file *m, struct pid_namespace *ns,
 	return err;
 }
 
+#ifdef CONFIG_VAS_PROCFS
+
+/**
+ * Get a string representation of the access type to a VAS.
+ **/
+#define vas_access_type_str(type) ((type) & MAY_WRITE ?			\
+				   ((type) & MAY_READ ? "rw" : "wo") : "ro")
+
+static int att_vas_show_status(struct seq_file *sf, void *unused)
+{
+	struct inode *inode = sf->private;
+	struct proc_inode *pi = PROC_I(inode);
+	struct task_struct *tsk;
+	struct vas_context *vas_ctx;
+	struct att_vas *avas;
+	int vid = pi->vas_id;
+
+	tsk = get_proc_task(inode);
+	if (!tsk)
+		return -ENOENT;
+
+	vas_ctx = tsk->vas_ctx;
+
+	vas_context_lock(vas_ctx);
+
+	list_for_each_entry(avas, &vas_ctx->vases, tsk_link) {
+		if (vid == avas->vas->id)
+			goto good_att_vas;
+	}
+
+	vas_context_unlock(vas_ctx);
+	put_task_struct(tsk);
+
+	return -ENOENT;
+
+good_att_vas:
+	seq_printf(sf,
+		   "pid:  %d\n"
+		   "vid:  %d\n"
+		   "type: %s\n",
+		   avas->tsk->pid, avas->vas->id,
+		   vas_access_type_str(avas->type));
+
+	vas_context_unlock(vas_ctx);
+	put_task_struct(tsk);
+
+	return 0;
+}
+
+static int att_vas_show_status_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, att_vas_show_status, inode);
+}
+
+static const struct file_operations att_vas_show_status_fops = {
+	.open		= att_vas_show_status_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int att_vas_show_mappings(struct seq_file *sf, void *unused)
+{
+	struct inode *inode = sf->private;
+	struct proc_inode *pi = PROC_I(inode);
+	struct task_struct *tsk;
+	struct vas_context *vas_ctx;
+	struct att_vas *avas;
+	struct mm_struct *mm;
+	struct vm_area_struct *vma;
+	int vid = pi->vas_id;
+
+	tsk = get_proc_task(inode);
+	if (!tsk)
+		return -ENOENT;
+
+	vas_ctx = tsk->vas_ctx;
+
+	vas_context_lock(vas_ctx);
+
+	list_for_each_entry(avas, &vas_ctx->vases, tsk_link) {
+		if (avas->vas->id == vid)
+			goto good_att_vas;
+	}
+
+	vas_context_unlock(vas_ctx);
+	put_task_struct(tsk);
+
+	return -ENOENT;
+
+good_att_vas:
+	mm = avas->mm;
+
+	down_read(&mm->mmap_sem);
+
+	if (!mm->mmap) {
+		seq_puts(sf, "EMPTY\n");
+		goto out_unlock;
+	}
+
+	for (vma = mm->mmap; vma; vma = vma->vm_next) {
+		vm_flags_t flags = vma->vm_flags;
+		struct file *file = vma->vm_file;
+		unsigned long long pgoff = 0;
+
+		if (file)
+			pgoff = ((loff_t)vma->vm_pgoff) << PAGE_SHIFT;
+
+		seq_printf(sf, "%08lx-%08lx %c%c%c%c [%c:%c] %08llx",
+			   vma->vm_start, vma->vm_end,
+			   flags & VM_READ ? 'r' : '-',
+			   flags & VM_WRITE ? 'w' : '-',
+			   flags & VM_EXEC ? 'x' : '-',
+			   flags & VM_MAYSHARE ? 's' : 'p',
+			   vma->vas_reference ? 'v' : '-',
+			   vma->vas_attached ? 'a' : '-',
+			   pgoff);
+
+		seq_putc(sf, ' ');
+
+		if (file) {
+			seq_file_path(sf, file, "\n");
+		} else if (vma->vm_ops && vma->vm_ops->name) {
+			seq_puts(sf, vma->vm_ops->name(vma));
+		} else {
+			if (!vma->vm_mm)
+				seq_puts(sf, "[vdso]");
+			else if (vma->vm_start <= mm->brk &&
+				 vma->vm_end >= mm->start_brk)
+				seq_puts(sf, "[heap]");
+			else if (vma->vm_start <= mm->start_stack &&
+				 vma->vm_end >= mm->start_stack)
+				seq_puts(sf, "[stack]");
+		}
+
+		seq_putc(sf, '\n');
+	}
+
+out_unlock:
+	up_read(&mm->mmap_sem);
+
+	vas_context_unlock(vas_ctx);
+	put_task_struct(tsk);
+
+	return 0;
+}
+
+static int att_vas_show_mappings_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, att_vas_show_mappings, inode);
+}
+
+static const struct file_operations att_vas_show_mappings_fops = {
+	.open		= att_vas_show_mappings_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int att_vas_vas_link(char *name, int *buflen, int vid)
+{
+	int len;
+
+	len = scnprintf(name, *buflen, "/sys/kernel/vas/%d", vid);
+	if (len >= *buflen)
+		return -E2BIG;
+
+	*buflen = len;
+	return 0;
+}
+
+static int att_vas_vas_link_readlink(struct dentry *dentry, char __user *buffer,
+				     int buflen)
+{
+	char *name;
+	int len, ret;
+	int vid;
+
+	len = PATH_MAX;
+	name = kmalloc(len, GFP_TEMPORARY);
+	if (!name)
+		return -ENOMEM;
+
+	vid = PROC_I(d_inode(dentry))->vas_id;
+
+	ret = att_vas_vas_link(name, &len, vid);
+	if (ret != 0)
+		goto out_free;
+
+	if (len > buflen)
+		len = buflen;
+	if (copy_to_user(buffer, name, len) != 0) {
+		ret = -EFAULT;
+		goto out_free;
+	}
+
+	ret = len;
+
+out_free:
+	kfree(name);
+
+	return ret;
+}
+
+static const char *att_vas_vas_link_get_link(struct dentry *dentry,
+					     struct inode *inode,
+					     struct delayed_call *done)
+{
+	char *name;
+	int len, ret;
+	int vid;
+
+	if (!dentry)
+		return ERR_PTR(-ECHILD);
+
+	len = PATH_MAX;
+	name = kmalloc(len, GFP_TEMPORARY);
+	if (!name)
+		return NULL;
+
+	vid = PROC_I(inode)->vas_id;
+
+	ret = att_vas_vas_link(name, &len, vid);
+	if (ret != 0) {
+		kfree(name);
+		return ERR_PTR(ret);
+	}
+
+	set_delayed_call(done, kfree_link, name);
+	return name;
+}
+
+static const struct inode_operations att_vas_vas_link_iops = {
+	.readlink	= att_vas_vas_link_readlink,
+	.get_link	= att_vas_vas_link_get_link,
+	.setattr	= proc_setattr
+};
+
+static const struct pid_entry att_vas_stuff[] = {
+	REG("status", 0444, att_vas_show_status_fops),
+	REG("maps", 0440, att_vas_show_mappings_fops),
+	NOD("vas", (S_IFLNK | 0777), &att_vas_vas_link_iops, NULL, {}),
+};
+
+static int att_vas_revalidate(struct dentry *dentry, unsigned int flags)
+{
+	struct inode *inode;
+	struct task_struct *tsk;
+	struct vas_context *vas_ctx;
+	struct att_vas *avas;
+	int vid;
+	int ret;
+
+	if (flags & LOOKUP_RCU)
+		return -ECHILD;
+
+	inode = d_inode(dentry);
+	tsk = get_proc_task(inode);
+	if (!tsk)
+		return 0;
+
+	vid = PROC_I(inode)->vas_id;
+	vas_ctx = tsk->vas_ctx;
+
+	vas_context_lock(vas_ctx);
+
+	ret = 0;
+	list_for_each_entry(avas, &vas_ctx->vases, tsk_link) {
+		if (avas->vas->id == vid) {
+			ret = 1;
+			break;
+		}
+	}
+
+	vas_context_unlock(vas_ctx);
+	put_task_struct(tsk);
+
+	return ret;
+}
+
+static const struct dentry_operations att_vas_dops = {
+	.d_revalidate	= att_vas_revalidate,
+};
+
+static int att_vas_pident_instantiate(struct inode *dir,
+				      struct dentry *dentry,
+				      struct task_struct *task,
+				      const void *ptr)
+{
+	const struct pid_entry *p = ptr;
+	struct inode *inode;
+	struct proc_inode *ei;
+
+	inode = proc_pid_make_inode(dir->i_sb, task, p->mode);
+	if (!inode)
+		goto out;
+
+	ei = PROC_I(inode);
+	if (S_ISDIR(inode->i_mode))
+		set_nlink(inode, 2);
+	if (p->iop)
+		inode->i_op = p->iop;
+	if (p->fop)
+		inode->i_fop = p->fop;
+	ei->op = p->op;
+
+	/* Copy the VAS ID from the parent inode */
+	ei->vas_id = PROC_I(dir)->vas_id;
+
+	d_set_d_op(dentry, &att_vas_dops);
+	d_add(dentry, inode);
+
+	if (att_vas_revalidate(dentry, 0))
+		return 0;
+out:
+	return -ENOENT;
+}
+
+static struct dentry *att_vas_pident_lookup(struct inode *dir,
+					    struct dentry *dentry,
+					    unsigned int flags)
+{
+	int error;
+	struct task_struct *task = get_proc_task(dir);
+	const struct pid_entry *p, *last;
+	const struct pid_entry *entries = att_vas_stuff;
+	int nents = ARRAY_SIZE(att_vas_stuff);
+
+	error = -ENOENT;
+
+	if (!task)
+		goto out_no_task;
+
+	last = &entries[nents];
+	for (p = entries; p < last; p++) {
+		if (p->len != dentry->d_name.len)
+			continue;
+		if (!memcmp(dentry->d_name.name, p->name, p->len))
+			break;
+	}
+	if (p >= last)
+		goto out;
+
+	error = att_vas_pident_instantiate(dir, dentry, task, p);
+out:
+	put_task_struct(task);
+out_no_task:
+	return ERR_PTR(error);
+}
+
+static int att_vas_pident_readdir(struct file *file, struct dir_context *ctx)
+{
+	struct task_struct *task = get_proc_task(file_inode(file));
+	const struct pid_entry *p, *last;
+	const struct pid_entry *entries = att_vas_stuff;
+	int nents = ARRAY_SIZE(att_vas_stuff);
+
+	if (!task)
+		return -ENOENT;
+
+	if (!dir_emit_dots(file, ctx))
+		goto out;
+
+	if (ctx->pos >= nents + 2)
+		goto out;
+
+	last = &entries[nents];
+	for (p = entries + (ctx->pos - 2); p < last; p++) {
+		if (!proc_fill_cache(file, ctx, p->name, p->len,
+				     att_vas_pident_instantiate, task, p))
+			break;
+		ctx->pos++;
+	}
+out:
+	put_task_struct(task);
+	return 0;
+}
+
+static const struct inode_operations proc_att_vas_iops = {
+	.lookup		= att_vas_pident_lookup,
+	.setattr	= proc_setattr,
+	.permission	= generic_permission,
+};
+
+static const struct file_operations proc_att_vas_fops = {
+	.read		= generic_read_dir,
+	.llseek		= generic_file_llseek,
+	.iterate_shared	= att_vas_pident_readdir,
+};
+
+static int proc_att_vas_dir_instantiate(struct inode *dir,
+					struct dentry *dentry,
+					struct task_struct *tsk,
+					const void *data)
+{
+	struct inode *inode;
+	struct proc_inode *pi;
+	const struct att_vas *avas = data;
+
+	inode = proc_pid_make_inode(dir->i_sb, tsk, S_IFDIR | 0555);
+
+	if (!inode)
+		return -ENOENT;
+
+	pi = PROC_I(inode);
+	pi->vas_id = avas->vas->id;
+
+	set_nlink(inode, 2);
+	inode->i_op = &proc_att_vas_iops;
+	inode->i_fop = &proc_att_vas_fops;
+
+	d_add(dentry, inode);
+	d_set_d_op(dentry, &att_vas_dops);
+
+	/*
+	 * No need to revalidate the dentry at this point, because we are still
+	 * holding the lock for the VAS context. Hence this VAS cannot be
+	 * detached from the task and hence the dentry is still valid.
+	 */
+	return 0;
+}
+
+static struct dentry *proc_att_vas_dir_lookup(struct inode *dir,
+					      struct dentry *dentry,
+					      unsigned int flags)
+{
+	struct task_struct *tsk;
+	struct vas_context *vas_ctx;
+	struct att_vas *avas;
+	int vid;
+	int ret;
+
+	tsk = get_proc_task(dir);
+	if (!tsk)
+		return ERR_PTR(-ENOENT);
+
+	if (kstrtoint(dentry->d_name.name, 10, &vid)) {
+		ret = -EINVAL;
+		goto out_put;
+	}
+
+	vas_ctx = tsk->vas_ctx;
+
+	vas_context_lock(vas_ctx);
+
+	ret = -ENOENT;
+	list_for_each_entry(avas, &vas_ctx->vases, tsk_link) {
+		if (vid == avas->vas->id) {
+			ret = proc_att_vas_dir_instantiate(dir, dentry,
+							   tsk, avas);
+			break;
+		}
+	}
+
+	vas_context_unlock(vas_ctx);
+
+out_put:
+	put_task_struct(tsk);
+
+	return ERR_PTR(ret);
+}
+
+static int proc_att_vas_dir_readdir(struct file *file, struct dir_context *ctx)
+{
+	struct inode *inode = file_inode(file);
+	struct task_struct *tsk;
+	struct vas_context *vas_ctx;
+	struct att_vas *avas;
+	int pos = 2;
+
+	tsk = get_proc_task(inode);
+	if (!tsk)
+		return -ENOENT;
+
+	if (!dir_emit_dots(file, ctx))
+		goto out_put;
+
+	vas_ctx = tsk->vas_ctx;
+
+	vas_context_lock(vas_ctx);
+
+	list_for_each_entry(avas, &vas_ctx->vases, tsk_link) {
+		char name[PROC_NUMBUF];
+		int len;
+
+		if (++pos <= ctx->pos)
+			continue;
+
+		snprintf(name, sizeof(name), "%d", avas->vas->id);
+		len = strnlen(name, PROC_NUMBUF);
+
+		if (!proc_fill_cache(file, ctx, name, len,
+				     proc_att_vas_dir_instantiate,
+				     tsk, avas))
+			break;
+
+		ctx->pos++;
+	}
+
+	vas_context_unlock(vas_ctx);
+
+out_put:
+	put_task_struct(tsk);
+
+	return 0;
+}
+
+const struct inode_operations proc_att_vas_dir_iops = {
+	.lookup		= proc_att_vas_dir_lookup,
+	.setattr	= proc_setattr,
+	.permission	= generic_permission,
+};
+
+const struct file_operations proc_att_vas_dir_fops = {
+	.read		= generic_read_dir,
+	.llseek		= generic_file_llseek,
+	.iterate_shared	= proc_att_vas_dir_readdir,
+};
+
+#endif
+
 /*
  * Thread groups
  */
@@ -2856,6 +3381,9 @@ static const struct pid_entry tgid_base_stuff[] = {
 #ifdef CONFIG_NET
 	DIR("net",        S_IRUGO|S_IXUGO, proc_net_inode_operations, proc_net_operations),
 #endif
+#ifdef CONFIG_VAS_PROCFS
+	DIR("vas",        S_IRUGO|S_IXUGO, proc_att_vas_dir_iops, proc_att_vas_dir_fops),
+#endif
 	REG("environ",    S_IRUSR, proc_environ_operations),
 	REG("auxv",       S_IRUSR, proc_auxv_operations),
 	ONE("status",     S_IRUGO, proc_pid_status),
diff --git a/fs/proc/inode.c b/fs/proc/inode.c
index cb2d5702bdce..cc8937d348df 100644
--- a/fs/proc/inode.c
+++ b/fs/proc/inode.c
@@ -63,6 +63,7 @@ static struct inode *proc_alloc_inode(struct super_block *sb)
 	ei->pid = NULL;
 	ei->fd = 0;
 	ei->op.proc_get_link = NULL;
+	ei->vas_id = 0;
 	ei->pde = NULL;
 	ei->sysctl = NULL;
 	ei->sysctl_entry = NULL;
diff --git a/fs/proc/internal.h b/fs/proc/internal.h
index 2de5194ba378..0cb6bb39d61d 100644
--- a/fs/proc/internal.h
+++ b/fs/proc/internal.h
@@ -61,6 +61,7 @@ union proc_op {
 struct proc_inode {
 	struct pid *pid;
 	unsigned int fd;
+	int vas_id;
 	union proc_op op;
 	struct proc_dir_entry *pde;
 	struct ctl_table_header *sysctl;
diff --git a/mm/Kconfig b/mm/Kconfig
index 934c56bcdbf4..9ef3efc16bed 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -745,3 +745,12 @@ config VAS_DEBUG
 	help
 	  Enable extensive debugging output for the First Class Virtual Address
 	  Spaces feature.
+
+config VAS_PROCFS
+	bool "procfs entries for First Class Virtual Address Spaces"
+	depends on VAS && PROC_FS
+	default y
+	help
+	  Provide information in /proc/$PID about all First Class 
+	  Virtual Address Spaces that are currently attached to the
+	  corresponding process.
-- 
2.12.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
