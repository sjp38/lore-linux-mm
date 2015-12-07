Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 413646B025C
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 16:24:27 -0500 (EST)
Received: by wmec201 with SMTP id c201so4616473wme.1
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 13:24:26 -0800 (PST)
Received: from thejh.net (thejh.net. [2a03:4000:2:1b9::1])
        by mx.google.com with ESMTP id t7si38868090wjf.187.2015.12.07.13.24.26
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 13:24:26 -0800 (PST)
From: Jann Horn <jann@thejh.net>
Subject: [PATCH 1/2] security: let security modules use PTRACE_MODE_* with bitmasks
Date: Mon,  7 Dec 2015 22:25:11 +0100
Message-Id: <1449523512-29200-2-git-send-email-jann@thejh.net>
In-Reply-To: <1449523512-29200-1-git-send-email-jann@thejh.net>
References: <20151207203824.GA27364@pc.thejh.net>
 <1449523512-29200-1-git-send-email-jann@thejh.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Kees Cook <keescook@google.com>, Casey Schaufler <casey@schaufler-ca.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@redhat.com>, James Morris <james.l.morris@oracle.com>, "Serge E. Hallyn" <serge.hallyn@ubuntu.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Andy Lutomirski <luto@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, "Eric W. Biederman" <ebiederm@xmission.com>, Joe Perches <joe@perches.com>, Thomas Gleixner <tglx@linutronix.de>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org, linux-api@vger.kernel.org, security@kernel.org, Willy Tarreau <w@1wt.eu>, Jann Horn <jann@thejh.net>

It looks like smack and yama weren't aware that the ptrace mode
can have flags ORed into it - PTRACE_MODE_NOAUDIT until now, but
only for /proc/$pid/stat, and with the PTRACE_MODE_*CREDS patch,
all modes have flags ORed into them.

Signed-off-by: Jann Horn <jann@thejh.net>
---
 security/smack/smack_lsm.c | 8 +++-----
 security/yama/yama_lsm.c   | 4 ++--
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index ff81026..7c57c7f 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -398,12 +398,10 @@ static int smk_copy_relabel(struct list_head *nhead, struct list_head *ohead,
  */
 static inline unsigned int smk_ptrace_mode(unsigned int mode)
 {
-	switch (mode) {
-	case PTRACE_MODE_READ:
-		return MAY_READ;
-	case PTRACE_MODE_ATTACH:
+	if (mode & PTRACE_MODE_ATTACH)
 		return MAY_READWRITE;
-	}
+	if (mode & PTRACE_MODE_READ)
+		return MAY_READ;
 
 	return 0;
 }
diff --git a/security/yama/yama_lsm.c b/security/yama/yama_lsm.c
index d3c19c9..cb6ed10 100644
--- a/security/yama/yama_lsm.c
+++ b/security/yama/yama_lsm.c
@@ -281,7 +281,7 @@ static int yama_ptrace_access_check(struct task_struct *child,
 	int rc = 0;
 
 	/* require ptrace target be a child of ptracer on attach */
-	if (mode == PTRACE_MODE_ATTACH) {
+	if (mode & PTRACE_MODE_ATTACH) {
 		switch (ptrace_scope) {
 		case YAMA_SCOPE_DISABLED:
 			/* No additional restrictions. */
@@ -307,7 +307,7 @@ static int yama_ptrace_access_check(struct task_struct *child,
 		}
 	}
 
-	if (rc) {
+	if (rc && (mode & PTRACE_MODE_NOAUDIT) == 0) {
 		printk_ratelimited(KERN_NOTICE
 			"ptrace of pid %d was attempted by: %s (pid %d)\n",
 			child->pid, current->comm, current->pid);
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
