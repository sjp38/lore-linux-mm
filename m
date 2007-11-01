Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lA14fOZB026766
	for <linux-mm@kvack.org>; Thu, 1 Nov 2007 00:41:24 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id lA14fOdH094362
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lA14fOlc010862
	for <linux-mm@kvack.org>; Wed, 31 Oct 2007 22:41:24 -0600
Message-Id: <20071101044124.835937000@us.ibm.com>
References: <20071101033508.720885000@us.ibm.com>
Date: Wed, 31 Oct 2007 20:35:11 -0700
From: Matt Helsley <matthltc@us.ibm.com>
Subject: [RFC][PATCH 3/3] [RFC][PATCH] Make /proc/pid/exe symlink changeable
Content-Disposition: inline; filename=writeable_proc_pid_exe
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@ftp.linux.org.uk>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch makes the /proc/<pid>|self/exe symlink writeable. This
functionality could be useful to potential checkpoint/restart implementations
restarting Java VMs, for example. Java uses this symlink to locate 
JAVAHOME so any restarted Java program requires that /proc/self/exe points to
the jvm and not the restart exectuable.

Signed-off-by: Matt Helsley <matthltc@us.ibm.com>
---
 fs/proc/base.c |   37 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)

Index: linux-2.6.23/fs/proc/base.c
===================================================================
--- linux-2.6.23.orig/fs/proc/base.c
+++ linux-2.6.23/fs/proc/base.c
@@ -930,10 +930,37 @@ static const struct file_operations proc
 	.release	= single_release,
 };
 
 #endif
 
+static int proc_pid_exe_symlink(struct inode *inode, struct dentry *dentry,
+				const char *path)
+{
+	struct file *new_exe_file;
+	struct task_struct *task;
+	struct mm_struct *mm;
+	int error;
+
+	if (!proc_fd_access_allowed(dentry->d_inode))
+		return -EACCES;
+	task = get_proc_task(inode);
+	if (!task)
+		return -ENOENT;
+	mm = get_task_mm(task);
+	put_task_struct(task);
+	if (!mm)
+		return -ENOENT;
+	new_exe_file = open_exec(path);
+	error = PTR_ERR(new_exe_file);
+	if (!IS_ERR(error)) {
+		set_mm_exe_file(mm, new_exe_file);
+		error = 0;
+	}
+	mmput(mm);
+	return error;
+}
+
 static int proc_exe_link(struct inode *inode, struct dentry **dentry,
 			 struct vfsmount **mnt)
 {
 	struct task_struct *task;
 	struct mm_struct *mm;
@@ -1027,10 +1054,16 @@ static const struct inode_operations pro
 	.readlink	= proc_pid_readlink,
 	.follow_link	= proc_pid_follow_link,
 	.setattr	= proc_setattr,
 };
 
+static const struct inode_operations proc_pid_exe_inode_operations = {
+	.readlink	= proc_pid_readlink,
+	.follow_link	= proc_pid_follow_link,
+	.symlink	= proc_pid_exe_symlink,
+	.setattr	= proc_setattr,
+};
 
 /* building an inode */
 
 static int task_dumpable(struct task_struct *task)
 {
@@ -2087,11 +2120,13 @@ static const struct pid_entry tgid_base_
 	REG("numa_maps",  S_IRUGO, numa_maps),
 #endif
 	REG("mem",        S_IRUSR|S_IWUSR, mem),
 	LNK("cwd",        cwd),
 	LNK("root",       root),
-	LNK("exe",        exe),
+	NOD("exe", (S_IFLNK|S_IRWXUGO),
+		&proc_pid_exe_inode_operations, NULL,
+		{ .proc_get_link = &proc_exe_link }),
 	REG("mounts",     S_IRUGO, mounts),
 	REG("mountstats", S_IRUSR, mountstats),
 #ifdef CONFIG_MMU
 	REG("clear_refs", S_IWUSR, clear_refs),
 	REG("smaps",      S_IRUGO, smaps),

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
