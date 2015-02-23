Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 60F536B006C
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 21:20:18 -0500 (EST)
Received: by pdjz10 with SMTP id z10so21807140pdj.12
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 18:20:18 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id c12si4169835pdm.248.2015.02.22.18.20.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Feb 2015 18:20:17 -0800 (PST)
Message-ID: <1424658009.6539.15.camel@stgolabs.net>
Subject: [PATCH v2 2/3] kernel/audit: reduce mmap_sem hold for mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 22 Feb 2015 18:20:09 -0800
In-Reply-To: <1424304641-28965-3-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-3-git-send-email-dbueso@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, paul@paul-moore.com, eparis@redhat.com, linux-audit@redhat.com, dave@stgolabs.net

The mm->exe_file is currently serialized with mmap_sem (shared)
in order to both safely (1) read the file and (2) audit it via
audit_log_d_path(). Good users will, on the other hand, make use
of the more standard get_mm_exe_file(), requiring only holding
the mmap_sem to read the value, and relying on reference counting
to make sure that the exe file won't dissapear underneath us.

Additionally, upon NULL return of get_mm_exe_file, we also call
audit_log_format(ab, " exe=(null)").

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

changes from v1: rebased on top of 1/1.

 kernel/audit.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index a71cbfe..b446d54 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -43,6 +43,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/file.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/atomic.h>
@@ -1841,15 +1842,20 @@ EXPORT_SYMBOL(audit_log_task_context);
 void audit_log_d_path_exe(struct audit_buffer *ab,
 			  struct mm_struct *mm)
 {
-	if (!mm) {
-		audit_log_format(ab, " exe=(null)");
-		return;
-	}
+	struct file *exe_file;
+
+	if (!mm)
+		goto out_null;
 
-	down_read(&mm->mmap_sem);
-	if (mm->exe_file)
-		audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
-	up_read(&mm->mmap_sem);
+	exe_file = get_mm_exe_file(mm);
+	if (!exe_file)
+		goto out_null;
+
+	audit_log_d_path(ab, " exe=", &exe_file->f_path);
+	fput(exe_file);
+	return;
+out_null:
+	audit_log_format(ab, " exe=(null)");
 }
 
 void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
-- 
2.1.4




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
