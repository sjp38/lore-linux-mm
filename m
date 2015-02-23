Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8FC6B0032
	for <linux-mm@kvack.org>; Sun, 22 Feb 2015 21:20:08 -0500 (EST)
Received: by pdjz10 with SMTP id z10so21806142pdj.12
        for <linux-mm@kvack.org>; Sun, 22 Feb 2015 18:20:08 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id rv7si2014975pbc.125.2015.02.22.18.20.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 22 Feb 2015 18:20:07 -0800 (PST)
Message-ID: <1424658000.6539.14.camel@stgolabs.net>
Subject: [PATCH v2 1/3] kernel/audit: consolidate handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 22 Feb 2015 18:20:00 -0800
In-Reply-To: <1424304641-28965-2-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-2-git-send-email-dbueso@suse.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, paul@paul-moore.com, eparis@redhat.com, linux-audit@redhat.com, dave@stgolabs.net

This patch adds a audit_log_d_path_exe() helper function
to share how we handle auditing of the exe_file's path.
Used by both audit and auditsc. No functionality is changed.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

changes from v1: created normal function for helper.

 kernel/audit.c   | 23 +++++++++++++++--------
 kernel/audit.h   |  3 +++
 kernel/auditsc.c |  9 +--------
 3 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/kernel/audit.c b/kernel/audit.c
index 72ab759..a71cbfe 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1838,11 +1838,24 @@ error_path:
 }
 EXPORT_SYMBOL(audit_log_task_context);
 
+void audit_log_d_path_exe(struct audit_buffer *ab,
+			  struct mm_struct *mm)
+{
+	if (!mm) {
+		audit_log_format(ab, " exe=(null)");
+		return;
+	}
+
+	down_read(&mm->mmap_sem);
+	if (mm->exe_file)
+		audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
+	up_read(&mm->mmap_sem);
+}
+
 void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 {
 	const struct cred *cred;
 	char comm[sizeof(tsk->comm)];
-	struct mm_struct *mm = tsk->mm;
 	char *tty;
 
 	if (!ab)
@@ -1878,13 +1891,7 @@ void audit_log_task_info(struct audit_buffer *ab, struct task_struct *tsk)
 	audit_log_format(ab, " comm=");
 	audit_log_untrustedstring(ab, get_task_comm(comm, tsk));
 
-	if (mm) {
-		down_read(&mm->mmap_sem);
-		if (mm->exe_file)
-			audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
-		up_read(&mm->mmap_sem);
-	} else
-		audit_log_format(ab, " exe=(null)");
+	audit_log_d_path_exe(ab, tsk->mm);
 	audit_log_task_context(ab);
 }
 EXPORT_SYMBOL(audit_log_task_info);
diff --git a/kernel/audit.h b/kernel/audit.h
index 1caa0d3..d641f9b 100644
--- a/kernel/audit.h
+++ b/kernel/audit.h
@@ -257,6 +257,9 @@ extern struct list_head audit_filter_list[];
 
 extern struct audit_entry *audit_dupe_rule(struct audit_krule *old);
 
+extern void audit_log_d_path_exe(struct audit_buffer *ab,
+				 struct mm_struct *mm);
+
 /* audit watch functions */
 #ifdef CONFIG_AUDIT_WATCH
 extern void audit_put_watch(struct audit_watch *watch);
diff --git a/kernel/auditsc.c b/kernel/auditsc.c
index dc4ae70..84c74d0 100644
--- a/kernel/auditsc.c
+++ b/kernel/auditsc.c
@@ -2361,7 +2361,6 @@ static void audit_log_task(struct audit_buffer *ab)
 	kuid_t auid, uid;
 	kgid_t gid;
 	unsigned int sessionid;
-	struct mm_struct *mm = current->mm;
 	char comm[sizeof(current->comm)];
 
 	auid = audit_get_loginuid(current);
@@ -2376,13 +2375,7 @@ static void audit_log_task(struct audit_buffer *ab)
 	audit_log_task_context(ab);
 	audit_log_format(ab, " pid=%d comm=", task_pid_nr(current));
 	audit_log_untrustedstring(ab, get_task_comm(comm, current));
-	if (mm) {
-		down_read(&mm->mmap_sem);
-		if (mm->exe_file)
-			audit_log_d_path(ab, " exe=", &mm->exe_file->f_path);
-		up_read(&mm->mmap_sem);
-	} else
-		audit_log_format(ab, " exe=(null)");
+	audit_log_d_path_exe(ab, current->mm);
 }
 
 /**
-- 
2.1.4





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
