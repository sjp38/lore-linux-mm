Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EDA616B0009
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 19:26:49 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g66so282159pfj.11
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 16:26:49 -0800 (PST)
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id y128si6227633pgb.126.2018.02.26.16.26.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 16:26:48 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH 3/4 v2] fs: proc: use down_read_killable() in environ_read()
Date: Tue, 27 Feb 2018 08:25:50 +0800
Message-Id: <1519691151-101999-4-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1519691151-101999-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org, adobriyan@gmail.com
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Like reading /proc/*/cmdline, it is possible to be blocked for long time
when reading /proc/*/environ when manipulating large mapping at the mean
time. The environ reading process will be waiting for mmap_sem become
available for a long time then it may cause the reading task hung.

Convert down_read() and access_remote_vm() to killable version.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
Suggested-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 fs/proc/base.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 9bdb84b..d87d9ab 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -933,7 +933,9 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 	if (!mmget_not_zero(mm))
 		goto free;
 
-	down_read(&mm->mmap_sem);
+	ret = down_read_killable(&mm->mmap_sem);
+	if (ret)
+		goto out_mmput;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
 	up_read(&mm->mmap_sem);
@@ -950,7 +952,8 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		max_len = min_t(size_t, PAGE_SIZE, count);
 		this_len = min(max_len, this_len);
 
-		retval = access_remote_vm(mm, (env_start + src), page, this_len, 0);
+		retval = access_remote_vm_killable(mm, (env_start + src),
+						page, this_len, 0);
 
 		if (retval <= 0) {
 			ret = retval;
@@ -968,6 +971,8 @@ static ssize_t environ_read(struct file *file, char __user *buf,
 		count -= retval;
 	}
 	*ppos = src;
+
+out_mmput:
 	mmput(mm);
 
 free:
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
