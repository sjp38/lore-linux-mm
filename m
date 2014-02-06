Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f53.google.com (mail-yh0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id AABF56B0035
	for <linux-mm@kvack.org>; Thu,  6 Feb 2014 18:23:32 -0500 (EST)
Received: by mail-yh0-f53.google.com with SMTP id v1so2410140yhn.12
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 15:23:32 -0800 (PST)
Received: from mail-qa0-x232.google.com (mail-qa0-x232.google.com [2607:f8b0:400d:c00::232])
        by mx.google.com with ESMTPS id j4si1261837qao.24.2014.02.06.10.15.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 10:16:15 -0800 (PST)
Received: by mail-qa0-f50.google.com with SMTP id cm18so3332826qab.23
        for <linux-mm@kvack.org>; Thu, 06 Feb 2014 10:15:44 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH v5 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
Date: Thu,  6 Feb 2014 10:15:27 -0800
Message-Id: <1391710528-23481-2-git-send-email-wroberts@tresys.com>
In-Reply-To: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
References: <1391710528-23481-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov
Cc: William Roberts <wroberts@tresys.com>

Re-factor proc_pid_cmdline() to use get_cmdline() helper
from mm.h.

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Stephen Smalley <sds@tycho.nsa.gov>

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 fs/proc/base.c |   36 ++----------------------------------
 1 file changed, 2 insertions(+), 34 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 5150706..f0c5927 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -200,41 +200,9 @@ static int proc_root_link(struct dentry *dentry, struct path *path)
 	return result;
 }
 
-static int proc_pid_cmdline(struct task_struct *task, char * buffer)
+static int proc_pid_cmdline(struct task_struct *task, char *buffer)
 {
-	int res = 0;
-	unsigned int len;
-	struct mm_struct *mm = get_task_mm(task);
-	if (!mm)
-		goto out;
-	if (!mm->arg_end)
-		goto out_mm;	/* Shh! No looking before we're done */
-
- 	len = mm->arg_end - mm->arg_start;
- 
-	if (len > PAGE_SIZE)
-		len = PAGE_SIZE;
- 
-	res = access_process_vm(task, mm->arg_start, buffer, len, 0);
-
-	// If the nul at the end of args has been overwritten, then
-	// assume application is using setproctitle(3).
-	if (res > 0 && buffer[res-1] != '\0' && len < PAGE_SIZE) {
-		len = strnlen(buffer, res);
-		if (len < res) {
-		    res = len;
-		} else {
-			len = mm->env_end - mm->env_start;
-			if (len > PAGE_SIZE - res)
-				len = PAGE_SIZE - res;
-			res += access_process_vm(task, mm->env_start, buffer+res, len, 0);
-			res = strnlen(buffer, res);
-		}
-	}
-out_mm:
-	mmput(mm);
-out:
-	return res;
+	return get_cmdline(task, buffer, PAGE_SIZE);
 }
 
 static int proc_pid_auxv(struct task_struct *task, char *buffer)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
