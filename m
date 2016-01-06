Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 74A896B0005
	for <linux-mm@kvack.org>; Wed,  6 Jan 2016 00:02:45 -0500 (EST)
Received: by mail-qg0-f42.google.com with SMTP id o11so295458917qge.2
        for <linux-mm@kvack.org>; Tue, 05 Jan 2016 21:02:45 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b65si344217qkj.116.2016.01.05.21.02.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Jan 2016 21:02:44 -0800 (PST)
From: Mateusz Guzik <mguzik@redhat.com>
Subject: [PATCH 2/2] proc read mm's {arg,env}_{start,end} with mmap semaphore taken.
Date: Wed,  6 Jan 2016 06:02:29 +0100
Message-Id: <1452056549-10048-3-git-send-email-mguzik@redhat.com>
In-Reply-To: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
References: <1452056549-10048-1-git-send-email-mguzik@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Alexey Dobriyan <adobriyan@gmail.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jarod Wilson <jarod@redhat.com>, Jan Stancek <jstancek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>

Only functions doing more than one read are modified. Consumeres
happened to deal with possibly changing data, but it does not seem
like a good thing to rely on.

Signed-off-by: Mateusz Guzik <mguzik@redhat.com>
---
 fs/proc/base.c | 13 ++++++++++---
 mm/util.c      | 16 ++++++++++++----
 2 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index e665097..4f764c2 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -953,6 +953,7 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	unsigned long src = *ppos;
 	int ret = 0;
 	struct mm_struct *mm = file->private_data;
+	unsigned long env_start, env_end;
 
 	if (!mm)
 		return 0;
@@ -964,19 +965,25 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	ret = 0;
 	if (!atomic_inc_not_zero(&mm->mm_users))
 		goto free;
+
+	down_read(&mm->mmap_sem);
+	env_start = mm->env_start;
+	env_end = mm->env_end;
+	up_read(&mm->mmap_sem);
+
 	while (count > 0) {
 		size_t this_len, max_len;
 		int retval;
 
-		if (src >= (mm->env_end - mm->env_start))
+		if (src >= (env_end - env_start))
 			break;
 
-		this_len = mm->env_end - (mm->env_start + src);
+		this_len = env_end - (env_start + src);
 
 		max_len = min_t(size_t, PAGE_SIZE, count);
 		this_len = min(max_len, this_len);
 
-		retval = access_remote_vm(mm, (mm->env_start + src),
+		retval = access_remote_vm(mm, (env_start + src),
 			page, this_len, 0);
 
 		if (retval <= 0) {
diff --git a/mm/util.c b/mm/util.c
index 338e697..bafd4c5 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -506,17 +506,25 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 	int res = 0;
 	unsigned int len;
 	struct mm_struct *mm = get_task_mm(task);
+	unsigned long arg_start, arg_end, env_start, env_end;
 	if (!mm)
 		goto out;
 	if (!mm->arg_end)
 		goto out_mm;	/* Shh! No looking before we're done */
 
-	len = mm->arg_end - mm->arg_start;
+	down_read(&mm->mmap_sem);
+	arg_start = mm->arg_start;
+	arg_end = mm->arg_end;
+	env_start = mm->env_start;
+	env_end = mm->env_end;
+	up_read(&mm->mmap_sem);
+
+	len = arg_end - arg_start;
 
 	if (len > buflen)
 		len = buflen;
 
-	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
+	res = access_process_vm(task, arg_start, buffer, len, 0);
 
 	/*
 	 * If the nul at the end of args has been overwritten, then
@@ -527,10 +535,10 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
 		if (len < res) {
 			res = len;
 		} else {
-			len = mm->env_end - mm->env_start;
+			len = env_end - env_start;
 			if (len > buflen - res)
 				len = buflen - res;
-			res += access_process_vm(task, mm->env_start,
+			res += access_process_vm(task, env_start,
 						 buffer+res, len, 0);
 			res = strnlen(buffer, res);
 		}
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
