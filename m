Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1606B00BF
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:10:54 -0500 (EST)
Received: by mail-ob0-f170.google.com with SMTP id va2so8831686obc.1
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:10:54 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id rs6si2168055oeb.49.2015.02.18.16.10.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 16:10:52 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 2/3] kernel/audit: robustify handling of mm->exe_file
Date: Wed, 18 Feb 2015 16:10:40 -0800
Message-Id: <1424304641-28965-3-git-send-email-dbueso@suse.de>
In-Reply-To: <1424304641-28965-1-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, paul@paul-moore.com, eparis@redhat.com, linux-audit@redhat.com, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

The mm->exe_file is currently serialized with mmap_sem (shared)
in order to both safely (1) read the file and (2) audit it via
audit_log_d_path(). Good users will, on the other hand, make use
of the more standard get_mm_exe_file(), requiring only holding
the mmap_sem to read the value, and relying on reference counting
to make sure that the exe file won't dissapear underneath us.

This is safe as audit_log_d_path() does not need the mmap_sem --
...and if it did we seriously need to fix that.

Additionally, upon NULL return of get_mm_exe_file, we also call
audit_log_format(ab, " exe=(null)").

Cc: Paul Moore <paul@paul-moore.com>
Cc: Eric Paris <eparis@redhat.com>
Cc: linux-audit@redhat.com
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

Compiled tested only.

 kernel/audit.h | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/kernel/audit.h b/kernel/audit.h
index 510901f..17020f0 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -20,6 +20,7 @@
  */
 
 #include <linux/fs.h>
+#include <linux/file.h>
 #include <linux/audit.h>
 #include <linux/skbuff.h>
 #include <uapi/linux/mqueue.h>
@@ -260,15 +261,20 @@ extern struct audit_entry *audit_dupe_rule(struct audit_krule *old);
 static inline void audit_log_d_path_exe(struct audit_buffer *ab,
 					struct mm_struct *mm)
 {
-	if (!mm) {
-		audit_log_format(ab, " exe=(null)");
-		return;
-	}
-
-	down_read(&mm->mmap_sem);
-	if (mm->exe_file)
-		audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
-	up_read(&mm->mmap_sem);
+	struct file *exe_file;
+
+	if (!mm)
+		goto out_null;
+
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
 
 /* audit watch functions */
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
