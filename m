Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 7B58A6B005C
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 19:52:48 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 04/80] c/r: split core function out of some set*{u,g}id functions
Date: Wed, 23 Sep 2009 19:50:44 -0400
Message-Id: <1253749920-18673-5-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

From: Serge E. Hallyn <serue@us.ibm.com>

When restarting tasks, we want to be able to change xuid and
xgid in a struct cred, and do so with security checks.  Break
the core functionality of set{fs,res}{u,g}id into cred_setX
which performs the access checks based on current_cred(),
but performs the requested change on a passed-in cred.

This will allow us to securely construct struct creds based
on a checkpoint image, constrained by the caller's permissions,
and apply them to the caller at the end of sys_restart().

Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
---
 include/linux/cred.h |    8 +++
 kernel/cred.c        |  114 ++++++++++++++++++++++++++++++++++++++++++
 kernel/sys.c         |  134 ++++++++------------------------------------------
 3 files changed, 143 insertions(+), 113 deletions(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 4fa9996..2ffffbe 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -21,6 +21,9 @@ struct user_struct;
 struct cred;
 struct inode;
 
+/* defined in sys.c, used in cred_setresuid */
+extern int set_user(struct cred *new);
+
 /*
  * COW Supplementary groups list
  */
@@ -344,4 +347,9 @@ do {						\
 	*(_fsgid) = __cred->fsgid;		\
 } while(0)
 
+int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid);
+int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid, gid_t sgid);
+int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid);
+int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid);
+
 #endif /* _LINUX_CRED_H */
diff --git a/kernel/cred.c b/kernel/cred.c
index 1bb4d7e..5c8db56 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -589,3 +589,117 @@ int set_create_files_as(struct cred *new, struct inode *inode)
 	return security_kernel_create_files_as(new, inode);
 }
 EXPORT_SYMBOL(set_create_files_as);
+
+int cred_setresuid(struct cred *new, uid_t ruid, uid_t euid, uid_t suid)
+{
+	int retval;
+	const struct cred *old;
+
+	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+	old = current_cred();
+
+	if (!capable(CAP_SETUID)) {
+		if (ruid != (uid_t) -1 && ruid != old->uid &&
+		    ruid != old->euid  && ruid != old->suid)
+			return -EPERM;
+		if (euid != (uid_t) -1 && euid != old->uid &&
+		    euid != old->euid  && euid != old->suid)
+			return -EPERM;
+		if (suid != (uid_t) -1 && suid != old->uid &&
+		    suid != old->euid  && suid != old->suid)
+			return -EPERM;
+	}
+
+	if (ruid != (uid_t) -1) {
+		new->uid = ruid;
+		if (ruid != old->uid) {
+			retval = set_user(new);
+			if (retval < 0)
+				return retval;
+		}
+	}
+	if (euid != (uid_t) -1)
+		new->euid = euid;
+	if (suid != (uid_t) -1)
+		new->suid = suid;
+	new->fsuid = new->euid;
+
+	return security_task_fix_setuid(new, old, LSM_SETID_RES);
+}
+
+int cred_setresgid(struct cred *new, gid_t rgid, gid_t egid,
+			gid_t sgid)
+{
+	const struct cred *old = current_cred();
+	int retval;
+
+	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
+	if (retval)
+		return retval;
+
+	if (!capable(CAP_SETGID)) {
+		if (rgid != (gid_t) -1 && rgid != old->gid &&
+		    rgid != old->egid  && rgid != old->sgid)
+			return -EPERM;
+		if (egid != (gid_t) -1 && egid != old->gid &&
+		    egid != old->egid  && egid != old->sgid)
+			return -EPERM;
+		if (sgid != (gid_t) -1 && sgid != old->gid &&
+		    sgid != old->egid  && sgid != old->sgid)
+			return -EPERM;
+	}
+
+	if (rgid != (gid_t) -1)
+		new->gid = rgid;
+	if (egid != (gid_t) -1)
+		new->egid = egid;
+	if (sgid != (gid_t) -1)
+		new->sgid = sgid;
+	new->fsgid = new->egid;
+	return 0;
+}
+
+int cred_setfsuid(struct cred *new, uid_t uid, uid_t *old_fsuid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsuid = old->fsuid;
+
+	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
+		return -EPERM;
+
+	if (uid == old->uid  || uid == old->euid  ||
+	    uid == old->suid || uid == old->fsuid ||
+	    capable(CAP_SETUID)) {
+		if (uid != *old_fsuid) {
+			new->fsuid = uid;
+			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
+				return 0;
+		}
+	}
+	return -EPERM;
+}
+
+int cred_setfsgid(struct cred *new, gid_t gid, gid_t *old_fsgid)
+{
+	const struct cred *old;
+
+	old = current_cred();
+	*old_fsgid = old->fsgid;
+
+	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
+		return -EPERM;
+
+	if (gid == old->gid  || gid == old->egid  ||
+	    gid == old->sgid || gid == old->fsgid ||
+	    capable(CAP_SETGID)) {
+		if (gid != *old_fsgid) {
+			new->fsgid = gid;
+			return 0;
+		}
+	}
+	return -EPERM;
+}
diff --git a/kernel/sys.c b/kernel/sys.c
index b3f1097..da4f9e0 100644
--- a/kernel/sys.c
+++ b/kernel/sys.c
@@ -559,11 +559,12 @@ error:
 /*
  * change the user struct in a credentials set to match the new UID
  */
-static int set_user(struct cred *new)
+int set_user(struct cred *new)
 {
 	struct user_struct *new_user;
 
-	new_user = alloc_uid(current_user_ns(), new->uid);
+	/* is this ok? */
+	new_user = alloc_uid(new->user->user_ns, new->uid);
 	if (!new_user)
 		return -EAGAIN;
 
@@ -704,14 +705,12 @@ error:
 	return retval;
 }
 
-
 /*
  * This function implements a generic ability to update ruid, euid,
  * and suid.  This allows you to implement the 4.4 compatible seteuid().
  */
 SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
@@ -719,45 +718,10 @@ SYSCALL_DEFINE3(setresuid, uid_t, ruid, uid_t, euid, uid_t, suid)
 	if (!new)
 		return -ENOMEM;
 
-	retval = security_task_setuid(ruid, euid, suid, LSM_SETID_RES);
-	if (retval)
-		goto error;
-	old = current_cred();
-
-	retval = -EPERM;
-	if (!capable(CAP_SETUID)) {
-		if (ruid != (uid_t) -1 && ruid != old->uid &&
-		    ruid != old->euid  && ruid != old->suid)
-			goto error;
-		if (euid != (uid_t) -1 && euid != old->uid &&
-		    euid != old->euid  && euid != old->suid)
-			goto error;
-		if (suid != (uid_t) -1 && suid != old->uid &&
-		    suid != old->euid  && suid != old->suid)
-			goto error;
-	}
-
-	if (ruid != (uid_t) -1) {
-		new->uid = ruid;
-		if (ruid != old->uid) {
-			retval = set_user(new);
-			if (retval < 0)
-				goto error;
-		}
-	}
-	if (euid != (uid_t) -1)
-		new->euid = euid;
-	if (suid != (uid_t) -1)
-		new->suid = suid;
-	new->fsuid = new->euid;
-
-	retval = security_task_fix_setuid(new, old, LSM_SETID_RES);
-	if (retval < 0)
-		goto error;
-
-	return commit_creds(new);
+	retval = cred_setresuid(new, ruid, euid, suid);
+	if (retval == 0)
+		return commit_creds(new);
 
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -779,43 +743,17 @@ SYSCALL_DEFINE3(getresuid, uid_t __user *, ruid, uid_t __user *, euid, uid_t __u
  */
 SYSCALL_DEFINE3(setresgid, gid_t, rgid, gid_t, egid, gid_t, sgid)
 {
-	const struct cred *old;
 	struct cred *new;
 	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return -ENOMEM;
-	old = current_cred();
 
-	retval = security_task_setgid(rgid, egid, sgid, LSM_SETID_RES);
-	if (retval)
-		goto error;
+	retval = cred_setresgid(new, rgid, egid, sgid);
+	if (retval == 0)
+		return commit_creds(new);
 
-	retval = -EPERM;
-	if (!capable(CAP_SETGID)) {
-		if (rgid != (gid_t) -1 && rgid != old->gid &&
-		    rgid != old->egid  && rgid != old->sgid)
-			goto error;
-		if (egid != (gid_t) -1 && egid != old->gid &&
-		    egid != old->egid  && egid != old->sgid)
-			goto error;
-		if (sgid != (gid_t) -1 && sgid != old->gid &&
-		    sgid != old->egid  && sgid != old->sgid)
-			goto error;
-	}
-
-	if (rgid != (gid_t) -1)
-		new->gid = rgid;
-	if (egid != (gid_t) -1)
-		new->egid = egid;
-	if (sgid != (gid_t) -1)
-		new->sgid = sgid;
-	new->fsgid = new->egid;
-
-	return commit_creds(new);
-
-error:
 	abort_creds(new);
 	return retval;
 }
@@ -832,7 +770,6 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
 	return retval;
 }
 
-
 /*
  * "setfsuid()" sets the fsuid - the uid used for filesystem checks. This
  * is used for "access()" and for the NFS daemon (letting nfsd stay at
@@ -841,35 +778,20 @@ SYSCALL_DEFINE3(getresgid, gid_t __user *, rgid, gid_t __user *, egid, gid_t __u
  */
 SYSCALL_DEFINE1(setfsuid, uid_t, uid)
 {
-	const struct cred *old;
 	struct cred *new;
 	uid_t old_fsuid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsuid();
-	old = current_cred();
-	old_fsuid = old->fsuid;
-
-	if (security_task_setuid(uid, (uid_t)-1, (uid_t)-1, LSM_SETID_FS) < 0)
-		goto error;
-
-	if (uid == old->uid  || uid == old->euid  ||
-	    uid == old->suid || uid == old->fsuid ||
-	    capable(CAP_SETUID)) {
-		if (uid != old_fsuid) {
-			new->fsuid = uid;
-			if (security_task_fix_setuid(new, old, LSM_SETID_FS) == 0)
-				goto change_okay;
-		}
-	}
 
-error:
-	abort_creds(new);
-	return old_fsuid;
+	retval = cred_setfsuid(new, uid, &old_fsuid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsuid;
 }
 
@@ -878,34 +800,20 @@ change_okay:
  */
 SYSCALL_DEFINE1(setfsgid, gid_t, gid)
 {
-	const struct cred *old;
 	struct cred *new;
 	gid_t old_fsgid;
+	int retval;
 
 	new = prepare_creds();
 	if (!new)
 		return current_fsgid();
-	old = current_cred();
-	old_fsgid = old->fsgid;
-
-	if (security_task_setgid(gid, (gid_t)-1, (gid_t)-1, LSM_SETID_FS))
-		goto error;
-
-	if (gid == old->gid  || gid == old->egid  ||
-	    gid == old->sgid || gid == old->fsgid ||
-	    capable(CAP_SETGID)) {
-		if (gid != old_fsgid) {
-			new->fsgid = gid;
-			goto change_okay;
-		}
-	}
 
-error:
-	abort_creds(new);
-	return old_fsgid;
+	retval = cred_setfsgid(new, gid, &old_fsgid);
+	if (retval == 0)
+		commit_creds(new);
+	else
+		abort_creds(new);
 
-change_okay:
-	commit_creds(new);
 	return old_fsgid;
 }
 
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
