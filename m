Received: from smtp3.akamai.com (vwall2.sanmateo.corp.akamai.com [172.23.1.72])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0R3VVNZ021059
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 19:31:32 -0800 (PST)
Message-ID: <41F861A5.1C21FE1@akamai.com>
Date: Wed, 26 Jan 2005 19:36:05 -0800
From: Prasanna Meda <pmeda@akamai.com>
MIME-Version: 1.0
Subject: Re: [patch] ptrace: unlocked access to last_siginfo (resending)
References: <200501140746.j0E7kVf3008191@magilla.sf.frob.com>
Content-Type: multipart/mixed;
 boundary="------------1CF758C8139E2D4C28FCE7C3"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland McGrath <roland@redhat.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------1CF758C8139E2D4C28FCE7C3
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Roland McGrath wrote:

> > Since Roland changed now to wakeup tracee with kill, I guess this needs to be fixed.
> > http://linus.bkbits.net:8080/linux-2.5/gnupatch@41e3fe5fIRH-W3aDnXZgfQ-qIvuXYg
> Indeed, this change should go in.  I'd forgotten about this.  I don't think
> there are any other things we decided to leave one way or another based on
> the ptrace behavior that has now changed back again, but I might be
> forgetting others too.  Thanks for bringing it up.

  Thanks, but looks like we fixed only part of the problem. If the
  child is on the exit path and releases sighand, we need to check for
  its existence too.  The attached patch should work.


Thanks,
Prasanna.


--------------1CF758C8139E2D4C28FCE7C3
Content-Type: text/plain; charset=us-ascii;
 name="ptrace_needs_tasklistlock.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ptrace_needs_tasklistlock.patch"



Looks like we fixed only part of the problem earlier. When the child
moves away from ptrace notify and resets the last_siginfo, sighand lock
helps. But if the child goes further in exit and releases the sighand,
we need to test that case too.See ptrace_check_attach() and exit_sighand().
They also use the task_list_lock.


Signed-Off-by: Prasanna Meda <pmeda@akamai.com>


--- a/kernel/ptrace.c	Sun Jan 16 10:57:30 2005
+++ b/kernel/ptrace.c	Sun Jan 16 11:59:03 2005
@@ -320,32 +320,44 @@
 static int ptrace_getsiginfo(struct task_struct *child, siginfo_t __user * data)
 {
 	siginfo_t lastinfo;
+	int error = -ESRCH;
 
-	spin_lock_irq(&child->sighand->siglock);
-	if (likely(child->last_siginfo != NULL)) {
-		memcpy(&lastinfo, child->last_siginfo, sizeof (siginfo_t));
-		spin_unlock_irq(&child->sighand->siglock);
-		return copy_siginfo_to_user(data, &lastinfo);
+	read_lock_irq(&tasklist_lock);
+	if (likely(child->sighand != NULL)) {
+		error = -EINVAL;
+		spin_lock(&child->sighand->siglock);
+		if (likely(child->last_siginfo != NULL)) {
+			memcpy(&lastinfo, child->last_siginfo, sizeof (siginfo_t));
+			error = 0;
+		}
+		spin_unlock(&child->sighand->siglock);
 	}
-	spin_unlock_irq(&child->sighand->siglock);
-	return -EINVAL;
+	read_unlock_irq(&tasklist_lock);
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
-		spin_unlock_irq(&child->sighand->siglock);
-		return 0;
+	read_lock_irq(&tasklist_lock);
+	if (likely(child->sighand != NULL)) {
+		error = -EINVAL;
+		spin_lock(&child->sighand->siglock);
+		if (likely(child->last_siginfo != NULL)) {
+			memcpy(child->last_siginfo, &newinfo, sizeof (siginfo_t));
+			error = 0;
+		}
+		spin_unlock(&child->sighand->siglock);
 	}
-	spin_unlock_irq(&child->sighand->siglock);
-	return -EINVAL;
+	read_unlock_irq(&tasklist_lock);
+	return error;
 }
 
 int ptrace_request(struct task_struct *child, long request,

--------------1CF758C8139E2D4C28FCE7C3--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
