Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id E843D6B00C2
	for <linux-mm@kvack.org>; Wed, 18 Feb 2015 19:11:01 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wp4so8710740obc.10
        for <linux-mm@kvack.org>; Wed, 18 Feb 2015 16:11:01 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id pa11si2454612oeb.27.2015.02.18.16.11.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Feb 2015 16:11:01 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
Date: Wed, 18 Feb 2015 16:10:41 -0800
Message-Id: <1424304641-28965-4-git-send-email-dbueso@suse.de>
In-Reply-To: <1424304641-28965-1-git-send-email-dbueso@suse.de>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, dave@stgolabs.net, takedakn@nttdata.co.jp, penguin-kernel@I-love.SAKURA.ne.jp, linux-security-module@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

The mm->exe_file is currently serialized with mmap_sem (shared)
in order to both safely (1) read the file and (2) compute the
realpath by calling tomoyo_realpath_from_path, making it an absolute
overkill. Good users will, on the other hand, make use of the more
standard get_mm_exe_file(), requiring only holding the mmap_sem to
read the value, and relying on reference counting to make sure that
the exe file won't dissappear underneath us.

When returning from tomoyo_get_exe, we'll hold reference to the exe's
f_path, make sure we put it back when done at the end of the
manager call. This patch also does some cleanups around the function,
such as moving it into common.c and changing the args.

Cc: Kentaro TKentaro Takeda <takedakn@nttdata.co.jp>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-security-module@vger.kernel.org
Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---

Compile tested only.

 security/tomoyo/common.c | 41 ++++++++++++++++++++++++++++++++++++++---
 security/tomoyo/common.h |  1 -
 security/tomoyo/util.c   | 22 ----------------------
 3 files changed, 38 insertions(+), 26 deletions(-)

diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
index e0fb750..f55129f 100644
--- a/security/tomoyo/common.c
+++ b/security/tomoyo/common.c
@@ -908,6 +908,33 @@ static void tomoyo_read_manager(struct tomoyo_io_buffer *head)
 }
 
 /**
+ * tomoyo_get_exe - Get tomoyo_realpath() of current process.
+ *
+ * Returns the tomoyo_realpath() of current process on success, NULL otherwise.
+ *
+ * A successful return will leave the caller with two responsibilities when done
+ * handling the realpath:
+ *    (1) path_put the exe_file's path refcount.
+ *    (2) kfree return buffer.
+ */
+static const char *tomoyo_get_exe(struct mm_struct *mm)
+{
+	struct file *exe_file;
+	const char *cp = NULL;
+
+	if (!mm)
+		return NULL;
+	exe_file = get_mm_exe_file(mm);
+	if (!exe_file)
+		return NULL;
+
+	cp = tomoyo_realpath_from_path(&exe_file->f_path);
+	path_get(&exe_file->f_path);
+	fput(exe_file);
+	return cp;
+}
+
+/**
  * tomoyo_manager - Check whether the current process is a policy manager.
  *
  * Returns true if the current process is permitted to modify policy
@@ -920,20 +947,26 @@ static bool tomoyo_manager(void)
 	struct tomoyo_manager *ptr;
 	const char *exe;
 	const struct task_struct *task = current;
-	const struct tomoyo_path_info *domainname = tomoyo_domain()->domainname;
+	struct mm_struct *mm = current->mm;
+	const struct tomoyo_path_info *domainname;
 	bool found = false;
 
+	domainname = tomoyo_domain()->domainname;
+
 	if (!tomoyo_policy_loaded)
 		return true;
 	if (!tomoyo_manage_by_non_root &&
 	    (!uid_eq(task->cred->uid,  GLOBAL_ROOT_UID) ||
 	     !uid_eq(task->cred->euid, GLOBAL_ROOT_UID)))
 		return false;
-	exe = tomoyo_get_exe();
+
+	exe = tomoyo_get_exe(mm);
 	if (!exe)
 		return false;
+
 	list_for_each_entry_rcu(ptr, &tomoyo_kernel_namespace.
-				policy_list[TOMOYO_ID_MANAGER], head.list) {
+				policy_list[TOMOYO_ID_MANAGER],
+				head.list) {
 		if (!ptr->head.is_deleted &&
 		    (!tomoyo_pathcmp(domainname, ptr->manager) ||
 		     !strcmp(exe, ptr->manager->name))) {
@@ -950,6 +983,8 @@ static bool tomoyo_manager(void)
 			last_pid = pid;
 		}
 	}
+
+	path_put(&mm->exe_file->f_path);
 	kfree(exe);
 	return found;
 }
diff --git a/security/tomoyo/common.h b/security/tomoyo/common.h
index b897d48..fc89eba 100644
--- a/security/tomoyo/common.h
+++ b/security/tomoyo/common.h
@@ -947,7 +947,6 @@ char *tomoyo_init_log(struct tomoyo_request_info *r, int len, const char *fmt,
 char *tomoyo_read_token(struct tomoyo_acl_param *param);
 char *tomoyo_realpath_from_path(struct path *path);
 char *tomoyo_realpath_nofollow(const char *pathname);
-const char *tomoyo_get_exe(void);
 const char *tomoyo_yesno(const unsigned int value);
 const struct tomoyo_path_info *tomoyo_compare_name_union
 (const struct tomoyo_path_info *name, const struct tomoyo_name_union *ptr);
diff --git a/security/tomoyo/util.c b/security/tomoyo/util.c
index 2952ba5..7eff479 100644
--- a/security/tomoyo/util.c
+++ b/security/tomoyo/util.c
@@ -939,28 +939,6 @@ bool tomoyo_path_matches_pattern(const struct tomoyo_path_info *filename,
 }
 
 /**
- * tomoyo_get_exe - Get tomoyo_realpath() of current process.
- *
- * Returns the tomoyo_realpath() of current process on success, NULL otherwise.
- *
- * This function uses kzalloc(), so the caller must call kfree()
- * if this function didn't return NULL.
- */
-const char *tomoyo_get_exe(void)
-{
-	struct mm_struct *mm = current->mm;
-	const char *cp = NULL;
-
-	if (!mm)
-		return NULL;
-	down_read(&mm->mmap_sem);
-	if (mm->exe_file)
-		cp = tomoyo_realpath_from_path(&mm->exe_file->f_path);
-	up_read(&mm->mmap_sem);
-	return cp;
-}
-
-/**
  * tomoyo_get_mode - Get MAC mode.
  *
  * @ns:      Pointer to "struct tomoyo_policy_namespace".
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
