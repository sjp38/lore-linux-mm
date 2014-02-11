Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f182.google.com (mail-qc0-f182.google.com [209.85.216.182])
	by kanga.kvack.org (Postfix) with ESMTP id A5F6E6B0036
	for <linux-mm@kvack.org>; Tue, 11 Feb 2014 13:12:11 -0500 (EST)
Received: by mail-qc0-f182.google.com with SMTP id c9so13654550qcz.13
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:12:11 -0800 (PST)
Received: from mail-qa0-x22b.google.com (mail-qa0-x22b.google.com [2607:f8b0:400d:c00::22b])
        by mx.google.com with ESMTPS id e9si13048767qas.29.2014.02.11.10.12.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Feb 2014 10:12:10 -0800 (PST)
Received: by mail-qa0-f43.google.com with SMTP id o15so12162544qap.16
        for <linux-mm@kvack.org>; Tue, 11 Feb 2014 10:12:10 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH v7 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
Date: Tue, 11 Feb 2014 10:12:00 -0800
Message-Id: <1392142321-16217-2-git-send-email-wroberts@tresys.com>
In-Reply-To: <1392142321-16217-1-git-send-email-wroberts@tresys.com>
References: <1392142321-16217-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, sds@tycho.nsa.gov
Cc: William Roberts <wroberts@tresys.com>

Re-factor proc_pid_cmdline() to use get_cmdline() helper
from mm.h.

Acked-by: David Rientjes <rientjes@google.com>
Acked-by: Stephen Smalley <sds@tycho.nsa.gov>
Acked-by: Richard Guy Briggs <rgb@redhat.com>

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
