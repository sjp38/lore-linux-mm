Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0R6aBNZ025717
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 22:36:12 -0800 (PST)
From: pmeda@akamai.com
Date: Wed, 26 Jan 2005 22:40:49 -0800
Message-Id: <200501270640.WAA10798@allur.sanmateo.akamai.com>
Subject: [patch] ptrace:last_siginfo also needs tasklist_lock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, roland@redhat.com
List-ID: <linux-mm.kvack.org>

Looks like we fixed only part of the problem earlier. When the child
moves away from ptrace notify and resets the last_siginfo, sighand lock
helps. But if the child goes further in exit and releases the sighand,
we need to test that case too. See ptrace_check_attach() and exit_sighand().
They also use the tasklist_lock.

Followed Roland's suggestions on lock primitive and struct assignment.


Signed-Off-by: Prasanna Meda <pmeda@akamai.com>

--- a/kernel/ptrace.c	Wed Jan 27 22:07:41 2005
+++ b/kernel/ptrace.c	Wed Jan 27 22:14:33 2005
@@ -320,32 +320,44 @@
 static int ptrace_getsiginfo(struct task_struct *child, siginfo_t __user * data)
 {
 	siginfo_t lastinfo;
+	int error = -ESRCH;
 
-	spin_lock_irq(&child->sighand->siglock);
-	if (likely(child->last_siginfo != NULL)) {
-		memcpy(&lastinfo, child->last_siginfo, sizeof (siginfo_t));
+	read_lock(&tasklist_lock);
+	if (likely(child->sighand != NULL)) {
+		error = -EINVAL;
+		spin_lock_irq(&child->sighand->siglock);
+		if (likely(child->last_siginfo != NULL)) {
+			lastinfo = *child->last_siginfo;
+			error = 0;
+		}
 		spin_unlock_irq(&child->sighand->siglock);
-		return copy_siginfo_to_user(data, &lastinfo);
 	}
-	spin_unlock_irq(&child->sighand->siglock);
-	return -EINVAL;
+	read_unlock(&tasklist_lock);
+	if (!error)
+		return copy_siginfo_to_user(data, &lastinfo);
+	return error;
 }
 
 static int ptrace_setsiginfo(struct task_struct *child, siginfo_t __user * data)
 {
 	siginfo_t newinfo;
+	int error = -ESRCH;
 
-	if (copy_from_user(&newinfo, data, sizeof (siginfo_t)) != 0)
+	if (copy_from_user(&newinfo, data, sizeof (siginfo_t)))
 		return -EFAULT;
 
-	spin_lock_irq(&child->sighand->siglock);
-	if (likely(child->last_siginfo != NULL)) {
-		memcpy(child->last_siginfo, &newinfo, sizeof (siginfo_t));
+	read_lock(&tasklist_lock);
+	if (likely(child->sighand != NULL)) {
+		error = -EINVAL;
+		spin_lock_irq(&child->sighand->siglock);
+		if (likely(child->last_siginfo != NULL)) {
+			*child->last_siginfo = newinfo;
+			error = 0;
+		}
 		spin_unlock_irq(&child->sighand->siglock);
-		return 0;
 	}
-	spin_unlock_irq(&child->sighand->siglock);
-	return -EINVAL;
+	read_unlock(&tasklist_lock);
+	return error;
 }
 
 int ptrace_request(struct task_struct *child, long request,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
