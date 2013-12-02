Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f47.google.com (mail-qe0-f47.google.com [209.85.128.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6326B0039
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 16:10:53 -0500 (EST)
Received: by mail-qe0-f47.google.com with SMTP id t7so13844794qeb.6
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:53 -0800 (PST)
Received: from mail-qa0-x230.google.com (mail-qa0-x230.google.com [2607:f8b0:400d:c00::230])
        by mx.google.com with ESMTPS id y5si32358633qar.78.2013.12.02.13.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Dec 2013 13:10:52 -0800 (PST)
Received: by mail-qa0-f48.google.com with SMTP id w5so4993209qac.0
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 13:10:51 -0800 (PST)
From: William Roberts <bill.c.roberts@gmail.com>
Subject: [PATCH 2/3] proc: Update get proc_pid_cmdline() to use mm.h helpers
Date: Mon,  2 Dec 2013 13:10:38 -0800
Message-Id: <1386018639-18916-3-git-send-email-wroberts@tresys.com>
In-Reply-To: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
References: <1386018639-18916-1-git-send-email-wroberts@tresys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-audit@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rgb@redhat.com, viro@zeniv.linux.org.uk
Cc: sds@tycho.nsa.gov, William Roberts <wroberts@tresys.com>

Re-factor proc_pid_cmdline() to use get_cmdline_length() and
copy_cmdline() helpers from mm.h

Signed-off-by: William Roberts <wroberts@tresys.com>
---
 fs/proc/base.c |   35 ++++++++++-------------------------
 1 file changed, 10 insertions(+), 25 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
index 03c8d74..fb4eda5 100644
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -203,37 +203,22 @@ static int proc_root_link(struct dentry *dentry, struct path *path)
 static int proc_pid_cmdline(struct task_struct *task, char * buffer)
 {
 	int res = 0;
-	unsigned int len;
+	unsigned int len = 0;
 	struct mm_struct *mm = get_task_mm(task);
 	if (!mm)
-		goto out;
-	if (!mm->arg_end)
-		goto out_mm;	/* Shh! No looking before we're done */
+		return 0;
 
- 	len = mm->arg_end - mm->arg_start;
- 
+	len = get_cmdline_length(mm);
+	if (!len)
+		goto mm_out;
+
+	/*The caller of this allocates a page */
 	if (len > PAGE_SIZE)
 		len = PAGE_SIZE;
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
+
+	res = copy_cmdline(task, mm, buffer, len);
+mm_out:
 	mmput(mm);
-out:
 	return res;
 }
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
