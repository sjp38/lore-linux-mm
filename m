Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id D00066B0032
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 11:28:24 -0500 (EST)
Received: by pabkx10 with SMTP id kx10so9059163pab.13
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 08:28:24 -0800 (PST)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id l5si33548060pdb.126.2015.02.20.08.28.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 20 Feb 2015 08:28:23 -0800 (PST)
Message-ID: <1424449696.2317.0.camel@stgolabs.net>
Subject: Re: [PATCH 3/3] tomoyo: robustify handling of mm->exe_file
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Fri, 20 Feb 2015 08:28:16 -0800
In-Reply-To: <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
References: <1424304641-28965-1-git-send-email-dbueso@suse.de>
	 <1424304641-28965-4-git-send-email-dbueso@suse.de>
	 <1424324307.18191.5.camel@stgolabs.net>
	 <201502192007.AFI30725.tHFFOOMVFOQSLJ@I-love.SAKURA.ne.jp>
	 <1424370153.18191.12.camel@stgolabs.net>
	 <201502200711.EIH87066.HSOJLFFOtFVOQM@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, takedakn@nttdata.co.jp, linux-security-module@vger.kernel.org

On Fri, 2015-02-20 at 07:11 +0900, Tetsuo Handa wrote:
> Davidlohr Bueso wrote:
> > On Thu, 2015-02-19 at 20:07 +0900, Tetsuo Handa wrote:
> > > Why do we need to let the caller call path_put() ?
> > > There is no need to do like proc_exe_link() does, for
> > > tomoyo_get_exe() returns pathname as "char *".
> > 
> > Having the pathname doesn't guarantee anything later, and thus doesn't
> > seem very robust in the manager call if it can be dropped during the
> > call... or can this never occur in this context?
> > 
> tomoyo_get_exe() returns the pathname of executable of current thread.
> The executable of current thread cannot be changed while current thread
> is inside the manager call. Although the pathname of executable of
> current thread could be changed by other threads via namespace manipulation
> like pivot_root(), holding a reference guarantees nothing. Your patch helps
> for avoiding memory allocation with mmap_sem held, but does not robustify
> handling of mm->exe_file for tomoyo.

Fair enough, I won't argue. This is beyond the scope if what I'm trying
to accomplish here anyway. Are you ok with this instead?

8<--------------------------------------------------------------------
Subject: [PATCH v2 3/3] tomoyo: reduce mmap_sem hold for mm->exe_file

The mm->exe_file is currently serialized with mmap_sem (shared) in order 
to both safely (1) read the file and (2) compute the realpath by calling
tomoyo_realpath_from_path, making it an absolute overkill. Good users will,
on the other hand, make use of the more standard get_mm_exe_file(), requiring
only holding the mmap_sem to read the value, and relying on reference
counting to make sure that the exe_file won't disappear underneath us.

While at it, do some very minor cleanups around tomoyo_get_exe(), such as
make it local to common.c

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 security/tomoyo/common.c | 33 +++++++++++++++++++++++++++++++--
 security/tomoyo/common.h |  1 -
 security/tomoyo/util.c   | 22 ----------------------
 3 files changed, 31 insertions(+), 25 deletions(-)

diff --git a/security/tomoyo/common.c b/security/tomoyo/common.c
index e0fb750..73ce629 100644
--- a/security/tomoyo/common.c
+++ b/security/tomoyo/common.c
@@ -908,6 +908,31 @@ static void tomoyo_read_manager(struct tomoyo_io_buffer *head)
 }
 
 /**
+ * tomoyo_get_exe - Get tomoyo_realpath() of current process.
+ *
+ * Returns the tomoyo_realpath() of current process on success, NULL otherwise.
+ *
+ * This function uses kzalloc(), so the caller must call kfree()
+ * if this function didn't return NULL.
+ */
+static const char *tomoyo_get_exe(void)
+{
+	struct file *exe_file;
+	const char *cp = NULL;
+	struct mm_struct *mm = current->mm;
+
+	if (!mm)
+		return NULL;
+	exe_file = get_mm_exe_file(mm);
+	if (!exe_file)
+		return NULL;
+
+	cp = tomoyo_realpath_from_path(&exe_file->f_path);
+	fput(exe_file);
+	return cp;
+}
+
+/**
  * tomoyo_manager - Check whether the current process is a policy manager.
  *
  * Returns true if the current process is permitted to modify policy
@@ -920,9 +945,11 @@ static bool tomoyo_manager(void)
 	struct tomoyo_manager *ptr;
 	const char *exe;
 	const struct task_struct *task = current;
-	const struct tomoyo_path_info *domainname = tomoyo_domain()->domainname;
+	const struct tomoyo_path_info *domainname;
 	bool found = false;
 
+	domainname = tomoyo_domain()->domainname;
+
 	if (!tomoyo_policy_loaded)
 		return true;
 	if (!tomoyo_manage_by_non_root &&
@@ -932,8 +959,10 @@ static bool tomoyo_manager(void)
 	exe = tomoyo_get_exe();
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
