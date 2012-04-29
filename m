Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 20BB86B00EB
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 02:46:17 -0400 (EDT)
Received: by mail-pz0-f49.google.com with SMTP id q36so2826975dad.8
        for <linux-mm@kvack.org>; Sat, 28 Apr 2012 23:46:16 -0700 (PDT)
From: Sasha Levin <levinsasha928@gmail.com>
Subject: [PATCH 14/14] fs,sysctl: remove proc input checks out of sysctl handlers
Date: Sun, 29 Apr 2012 08:45:37 +0200
Message-Id: <1335681937-3715-14-git-send-email-levinsasha928@gmail.com>
In-Reply-To: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, ebiederm@xmission.com, akpm@linux-foundation.org, tglx@linutronix.de
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, Sasha Levin <levinsasha928@gmail.com>

Simplify sysctl handler by removing user input checks and using the callback
provided by the sysctl table.

Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
---
 fs/pipe.c                 |   11 ++---------
 include/linux/pipe_fs_i.h |    2 +-
 kernel/sysctl.c           |    3 ++-
 3 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index 25feaa3..7bb7395 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -1186,17 +1186,10 @@ static inline unsigned int round_pipe_size(unsigned int size)
  * This should work even if CONFIG_PROC_FS isn't set, as proc_dointvec_minmax
  * will return an error.
  */
-int pipe_proc_fn(struct ctl_table *table, int write, void __user *buf,
-		 size_t *lenp, loff_t *ppos)
+int pipe_proc_fn(void)
 {
-	int ret;
-
-	ret = proc_dointvec_minmax(table, write, buf, lenp, ppos);
-	if (ret < 0 || !write)
-		return ret;
-
 	pipe_max_size = round_pipe_size(pipe_max_size);
-	return ret;
+	return 0;
 }
 
 /*
diff --git a/include/linux/pipe_fs_i.h b/include/linux/pipe_fs_i.h
index 6d626ff..08e02d8 100644
--- a/include/linux/pipe_fs_i.h
+++ b/include/linux/pipe_fs_i.h
@@ -139,7 +139,7 @@ void pipe_unlock(struct pipe_inode_info *);
 void pipe_double_lock(struct pipe_inode_info *, struct pipe_inode_info *);
 
 extern unsigned int pipe_max_size, pipe_min_size;
-int pipe_proc_fn(struct ctl_table *, int, void __user *, size_t *, loff_t *);
+int pipe_proc_fn(void);
 
 
 /* Drop the inode semaphore and wait for a pipe event, atomically */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2104452..35f225b 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1551,7 +1551,8 @@ static struct ctl_table fs_table[] = {
 		.data		= &pipe_max_size,
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= &pipe_proc_fn,
+		.proc_handler	= proc_dointvec_minmax,
+		.callback	= &pipe_proc_fn,
 		.extra1		= &pipe_min_size,
 	},
 	{ }
-- 
1.7.8.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
