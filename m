From: Jann Horn <jann@thejh.net>
Subject: [PATCH v2 3/3] selinux: require EXECMEM for forced ptrace poke
Date: Thu, 29 Sep 2016 00:54:41 +0200
Message-ID: <1475103281-7989-4-git-send-email-jann@thejh.net>
References: <1475103281-7989-1-git-send-email-jann@thejh.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1475103281-7989-1-git-send-email-jann@thejh.net>
Sender: owner-linux-security-module@vger.kernel.org
To: security@kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, Eric Paris <eparis@parisplace.org>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge@hallyn.com>
Cc: Nick Kralevich <nnk@google.com>, Janis Danisevskis <jdanis@google.com>, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

This is a breaking change for SELinux users that restrict EXECMEM: It might
break gdb if gdb is executed in a domain that does not have EXECMEM
privilege over the debuggee domain.

Unlike most other SELinux hooks, this one takes the subject credentials as
an argument instead of looking up current_cred(). This is done because the
security_forced_write() LSM hook can be invoked from within the write
handler of /proc/$pid/mem, where current_cred() is pretty useless.

Signed-off-by: Jann Horn <jann@thejh.net>
Reviewed-by: Janis Danisevskis <jdanis@android.com>
---
 security/selinux/hooks.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 13185a6..e36682a 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -2149,6 +2149,20 @@ static int selinux_ptrace_traceme(struct task_struct *parent)
 	return task_has_perm(parent, current, PROCESS__PTRACE);
 }
 
+static int selinux_forced_write(struct vm_area_struct *vma,
+				const struct cred *subject_cred,
+				const struct cred *object_cred)
+{
+	/* Permitting a write to readonly memory is fine - making the readonly
+	 * memory executable afterwards would require EXECMOD permission because
+	 * anon_vma would be non-NULL.
+	 */
+	if ((vma->vm_flags & VM_EXEC) == 0)
+		return 0;
+
+	return cred_has_perm(subject_cred, object_cred, PROCESS__EXECMEM);
+}
+
 static int selinux_capget(struct task_struct *target, kernel_cap_t *effective,
 			  kernel_cap_t *inheritable, kernel_cap_t *permitted)
 {
@@ -6033,6 +6047,7 @@ static struct security_hook_list selinux_hooks[] = {
 
 	LSM_HOOK_INIT(ptrace_access_check, selinux_ptrace_access_check),
 	LSM_HOOK_INIT(ptrace_traceme, selinux_ptrace_traceme),
+	LSM_HOOK_INIT(forced_write, selinux_forced_write),
 	LSM_HOOK_INIT(capget, selinux_capget),
 	LSM_HOOK_INIT(capset, selinux_capset),
 	LSM_HOOK_INIT(capable, selinux_capable),
-- 
2.1.4

