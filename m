Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0C38bNZ017775
	for <linux-mm@kvack.org>; Tue, 11 Jan 2005 19:08:37 -0800 (PST)
From: pmeda@akamai.com
Date: Tue, 11 Jan 2005 19:11:50 -0800
Message-Id: <200501120311.TAA01315@allur.sanmateo.akamai.com>
Subject: [patch] ptrace: unlocked access to last_siginfo (resending)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, roland@redhat.com
List-ID: <linux-mm.kvack.org>

Since Roland changed now to wakeup tracee with kill, I guess this needs to be fixed.
http://linus.bkbits.net:8080/linux-2.5/gnupatch@41e3fe5fIRH-W3aDnXZgfQ-qIvuXYg

ptrace_setsiginfo/ptrace_getsiginfo need to do locked access
to last_siginfo.  ptrace_notify()/ptrace_stop() sets the
current->last_siginfo and sleeps on schedule(). It can be waked
up by kill signal from signal_wake_up before debugger wakes it up.
On return from schedule(), the current->last_siginfo is reset.

Signed-off-by: Prasanna Meda <pmeda@akamai.com>


--- a/kernel/ptrace.c	Fri Nov 19 18:27:26 2004
+++ b/kernel/ptrace.c	Fri Nov 19 18:52:52 2004
@@ -303,18 +303,33 @@
 
 static int ptrace_getsiginfo(struct task_struct *child, siginfo_t __user * data)
 {
-	if (child->last_siginfo == NULL)
-		return -EINVAL;
-	return copy_siginfo_to_user(data, child->last_siginfo);
+	siginfo_t lastinfo;
+
+	spin_lock_irq(&child->sighand->siglock);
+	if (likely(child->last_siginfo != NULL)) {
+		memcpy(&lastinfo, child->last_siginfo, sizeof (siginfo_t));
+		spin_unlock_irq(&child->sighand->siglock);
+		return copy_siginfo_to_user(data, &lastinfo);
+	}
+	spin_unlock_irq(&child->sighand->siglock);
+	return -EINVAL;
 }
 
 static int ptrace_setsiginfo(struct task_struct *child, siginfo_t __user * data)
 {
-	if (child->last_siginfo == NULL)
-		return -EINVAL;
-	if (copy_from_user(child->last_siginfo, data, sizeof (siginfo_t)) != 0)
+	siginfo_t newinfo;
+
+	if (copy_from_user(&newinfo, data, sizeof (siginfo_t)) != 0)
 		return -EFAULT;
-	return 0;
+
+	spin_lock_irq(&child->sighand->siglock);
+	if (likely(child->last_siginfo != NULL)) {
+		memcpy(child->last_siginfo, &newinfo, sizeof (siginfo_t));
+		spin_unlock_irq(&child->sighand->siglock);
+		return 0;
+	}
+	spin_unlock_irq(&child->sighand->siglock);
+	return -EINVAL;
 }
 
 int ptrace_request(struct task_struct *child, long request,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
