Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 80BF06B0033
	for <linux-mm@kvack.org>; Sun,  1 Oct 2017 11:33:44 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id r17so756957lff.15
        for <linux-mm@kvack.org>; Sun, 01 Oct 2017 08:33:44 -0700 (PDT)
Received: from mail.kapsi.fi (mail.kapsi.fi. [2001:67c:1be8::25])
        by mx.google.com with ESMTPS id j72si4085300lje.99.2017.10.01.08.33.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Oct 2017 08:33:42 -0700 (PDT)
Date: Sun, 1 Oct 2017 18:33:39 +0300 (EEST)
From: Otto Ebeling <otto.ebeling@iki.fi>
Subject: [PATCH] Unify migrate_pages and move_pages access checks
Message-ID: <alpine.DEB.2.11.1710011830320.6333@lakka.kapsi.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; format=flowed; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Christoph Lameter <clameter@sgi.com>

Commit 197e7e521384a23b9e585178f3f11c9fa08274b9 ("Sanitize 'move_pages()'
permission checks") fixed a security issue I reported in the move_pages
syscall, and made it so that you can't act on set-uid processes unless
you have the CAP_SYS_PTRACE capability.

Unify the access check logic of migrate_pages to match the new
behavior of move_pages. We discussed this a bit in the security@ list
and thought it'd be good for consistency even though there's no evident
security impact. The NUMA node access checks are left intact and require
CAP_SYS_NICE as before.

Signed-off-by: Otto Ebeling <otto.ebeling@iki.fi>

---
  mm/mempolicy.c | 11 +++--------
  1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 006ba62..abfe469 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -98,6 +98,7 @@
  #include <linux/mmu_notifier.h>
  #include <linux/printk.h>
  #include <linux/swapops.h>
+#include <linux/ptrace.h>

  #include <asm/tlbflush.h>
  #include <linux/uaccess.h>
@@ -1365,7 +1366,6 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned 
long, maxnode,
  		const unsigned long __user *, old_nodes,
  		const unsigned long __user *, new_nodes)
  {
-	const struct cred *cred = current_cred(), *tcred;
  	struct mm_struct *mm = NULL;
  	struct task_struct *task;
  	nodemask_t task_nodes;
@@ -1402,14 +1402,9 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned 
long, maxnode,

  	/*
  	 * Check if this process has the right to modify the specified
-	 * process. The right exists if the process has administrative
-	 * capabilities, superuser privileges or the same
-	 * userid as the target process.
+	 * process. Use the regular "ptrace_may_access()" checks.
  	 */
-	tcred = __task_cred(task);
-	if (!uid_eq(cred->euid, tcred->suid) && !uid_eq(cred->euid, 
tcred->uid) &&
-	    !uid_eq(cred->uid,  tcred->suid) && !uid_eq(cred->uid, 
tcred->uid) &&
-	    !capable(CAP_SYS_NICE)) {
+	if (!ptrace_may_access(task, PTRACE_MODE_READ_REALCREDS)) {
  		rcu_read_unlock();
  		err = -EPERM;
  		goto out_put;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
