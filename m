Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CE3BF6B00D0
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 15:51:46 -0500 (EST)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n1GKnMYi000785
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 13:49:22 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n1GKpj6D206284
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 13:51:45 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n1GKpfvW007348
	for <linux-mm@kvack.org>; Mon, 16 Feb 2009 13:51:42 -0700
Subject: Re: What can OpenVZ do?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20090213105302.GC4608@elte.hu>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu>
	 <1234285547.30155.6.camel@nimitz>
	 <20090211141434.dfa1d079.akpm@linux-foundation.org>
	 <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx>
	 <20090212114207.e1c2de82.akpm@linux-foundation.org>
	 <1234475483.30155.194.camel@nimitz>
	 <20090212141014.2cd3d54d.akpm@linux-foundation.org>
	 <20090213105302.GC4608@elte.hu>
Content-Type: text/plain
Date: Mon, 16 Feb 2009 12:51:30 -0800
Message-Id: <1234817490.30155.287.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-api@vger.kernel.org, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, mpm@selenic.com, tglx@linutronix.de, torvalds@linux-foundation.org, xemul@openvz.org, Nathan Lynch <nathanl@austin.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-02-13 at 11:53 +0100, Ingo Molnar wrote:
> In any case, by designing checkpointing to reuse the existing LSM
> callbacks, we'd hit multiple birds with the same stone. (One of
> which is the constant complaints about the runtime costs of the LSM
> callbacks - with checkpointing we get an independent, non-security
> user of the facility which is a nice touch.)

There's a fundamental problem with using LSM that I'm seeing now that I
look at using it for file descriptors.  The LSM hooks are there to say,
"No, you can't do this" and abort whatever kernel operation was going
on.  That's good for detecting when we do something that's "bad" for
checkpointing.

*But* it completely falls on its face when we want to find out when we
are doing things that are *good*.  For instance, let's say that we open
a network socket.  The LSM hook sees it and marks us as
uncheckpointable.  What about when we close it?  We've become
checkpointable again.  But, there's no LSM hook for the close side
because we don't currently have a need for it.

We have a couple of options:

We can let uncheckpointable actions behave like security violations and
just abort the kernel calls.  The problem with this is that it makes it
difficult to do *anything* unless your application is 100% supported.
Pretty inconvenient, especially at first.  Might be useful later on
though.

We could just log the actions and let them proceed.  But the problem
with this is that we don't get the temporal idea when an app transitions
between the "good" and "bad" states.  We would need to work on culling
the output in the logs since we'd be potentially getting a lot of
redundant data.

We could add to the set of security hooks.  Make sure that we cover all
the transitional states like close().

What I'm thinking about doing for now is what I have attached here.  We
allow the apps who we want to be checkpointed to query some interface
that will use the same checks that sys_checkpoint() does internally.
Say:

# cat /proc/1072/checkpointable
mm: 1
files: 0
...

Then, when it realizes that its files can't be checkpointed, it can look
elsewhere:

/proc/1072/fdinfo/2:pos:	0
/proc/1072/fdinfo/2:flags:	02
/proc/1072/fdinfo/2:checkpointable: 0 (special file)
/proc/1072/fdinfo/3:pos:	0
/proc/1072/fdinfo/3:flags:	04000
/proc/1072/fdinfo/3:checkpointable: 0 (pipefs does not support checkpoint)
/proc/1072/fdinfo/4:pos:	0
/proc/1072/fdinfo/4:flags:	04002
/proc/1072/fdinfo/4:checkpointable: 0 (sockfs does not support checkpoint)
/proc/1074/fdinfo/0:pos:	0
/proc/1074/fdinfo/0:flags:	0100002
/proc/1074/fdinfo/0:checkpointable: 0 (devpts does not support checkpoint)

That requires zero overhead during runtime of the app.  It is also less
error-prone because we don't have any of the transitions to catch.

-- Dave

diff --git a/checkpoint/ckpt_file.c b/checkpoint/ckpt_file.c
index e3097ac..ebe776a 100644
--- a/checkpoint/ckpt_file.c
+++ b/checkpoint/ckpt_file.c
@@ -72,6 +72,32 @@ int cr_scan_fds(struct files_struct *files, int **fdtable)
 	return n;
 }
 
+int cr_can_checkpoint_file(struct file *file, char *explain, int left)
+{
+	char p[] = "checkpointable";
+	struct inode *inode = file->f_dentry->d_inode;
+	struct file_system_type *fs_type = inode->i_sb->s_type;
+
+	printk("%s() left: %d\n", __func__, left);
+
+	if (!(fs_type->fs_flags & FS_CHECKPOINTABLE)) {
+		if (explain)
+			snprintf(explain, left,
+				"%s: 0 (%s does not support checkpoint)\n",
+				p, fs_type->name);
+		return 0;
+	}
+
+	if (special_file(inode->i_mode)) {
+		if (explain)
+			snprintf(explain, left,	"%s: 0 (special file)\n", p);
+		return 0;
+	}
+
+	snprintf(explain, left, "%s: 1\n", p);
+	return 1;
+}
+
 /* cr_write_fd_data - dump the state of a given file pointer */
 static int cr_write_fd_data(struct cr_ctx *ctx, struct file *file, int parent)
 {
diff --git a/fs/proc/base.c b/fs/proc/base.c
index d467760..2300353 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1597,7 +1597,19 @@ out:
 	return ~0U;
 }
 
-#define PROC_FDINFO_MAX 64
+#define PROC_FDINFO_MAX PAGE_SIZE
+
+static void proc_fd_write_info(struct file *file, char *info)
+{
+	int max = PROC_FDINFO_MAX;
+	int p = 0;
+	if (!info)
+		return;
+
+	p += snprintf(info+p, max-p, "pos:\t%lli\n", (long long) file->f_pos);
+	p += snprintf(info+p, max-p, "flags:\t0%o\n", file->f_flags);
+	cr_can_checkpoint_file(file, info, max-p);
+}
 
 static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 {
@@ -1622,12 +1634,7 @@ static int proc_fd_info(struct inode *inode, struct path *path, char *info)
 				*path = file->f_path;
 				path_get(&file->f_path);
 			}
-			if (info)
-				snprintf(info, PROC_FDINFO_MAX,
-					 "pos:\t%lli\n"
-					 "flags:\t0%o\n",
-					 (long long) file->f_pos,
-					 file->f_flags);
+			proc_fd_write_info(file, info);
 			spin_unlock(&files->file_lock);
 			put_files_struct(files);
 			return 0;
@@ -1831,10 +1838,11 @@ static int proc_readfd(struct file *filp, void *dirent, filldir_t filldir)
 static ssize_t proc_fdinfo_read(struct file *file, char __user *buf,
 				      size_t len, loff_t *ppos)
 {
-	char tmp[PROC_FDINFO_MAX];
+	char *tmp = kmalloc(PROC_FDINFO_MAX, GFP_KERNEL);
 	int err = proc_fd_info(file->f_path.dentry->d_inode, NULL, tmp);
 	if (!err)
 		err = simple_read_from_buffer(buf, len, ppos, tmp, strlen(tmp));
+	kfree(tmp);
 	return err;
 }
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 217cf6e..84e69b0 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -142,11 +142,17 @@ static inline void __task_deny_checkpointing(struct task_struct *task,
 #define task_deny_checkpointing(p)  \
 	__task_deny_checkpointing(p, __FILE__, __LINE__)
 
+int cr_can_checkpoint_file(struct file *file, char *explain, int left);
+
 #else
 
 static inline void task_deny_checkpointing(struct task_struct *task) {}
 static inline void process_deny_checkpointing(struct task_struct *task) {}
 
-#endif
+static inline int cr_can_checkpoint_file(struct file *file, char *explain, int left)
+{
+	return 0;
+}
 
+#endif
 #endif /* _CHECKPOINT_CKPT_H_ */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
