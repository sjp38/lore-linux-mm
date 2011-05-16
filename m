Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A85C790011A
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:19:22 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p4GKwVkK016497
	for <linux-mm@kvack.org>; Mon, 16 May 2011 16:58:31 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p4GLJKZB107694
	for <linux-mm@kvack.org>; Mon, 16 May 2011 17:19:20 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p4GHJ8Cp030189
	for <linux-mm@kvack.org>; Mon, 16 May 2011 14:19:08 -0300
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 2/3] printk: Add %ptc to safely print a task's comm
Date: Mon, 16 May 2011 14:19:16 -0700
Message-Id: <1305580757-13175-3-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
References: <1305580757-13175-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Ted Ts'o <tytso@mit.edu>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Accessing task->comm requires proper locking. However in the past
access to current->comm could be done without locking. This
is no longer the case, so all comm access needs to be done
while holding the comm_lock.

In my attempt to clean up unprotected comm access, I've noticed
most comm access is done for printk output. To simplify correct
locking in these cases, I've introduced a new %ptc format,
which will print the corresponding task's comm.

Example use:
printk("%ptc: unaligned epc - sending SIGBUS.\n", current);

CC: Ted Ts'o <tytso@mit.edu>
CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: David Rientjes <rientjes@google.com>
CC: Dave Hansen <dave@linux.vnet.ibm.com>
CC: Andrew Morton <akpm@linux-foundation.org>
CC: linux-mm@kvack.org
Signed-off-by: John Stultz <john.stultz@linaro.org>
---
 lib/vsprintf.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index bc0ac6b..b7a9953 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -797,6 +797,23 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, uuid, spec);
 }
 
+static noinline_for_stack
+char *task_comm_string(char *buf, char *end, void *addr,
+			 struct printf_spec spec, const char *fmt)
+{
+	struct task_struct *tsk = addr;
+	char *ret;
+	unsigned long flags;
+
+	spin_lock_irqsave(&tsk->comm_lock, flags);
+	ret = string(buf, end, tsk->comm, spec);
+	spin_unlock_irqrestore(&tsk->comm_lock, flags);
+
+	return ret;
+}
+
+
+
 int kptr_restrict = 1;
 
 /*
@@ -864,6 +881,12 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 	}
 
 	switch (*fmt) {
+	case 't':
+		switch (fmt[1]) {
+		case 'c':
+			return task_comm_string(buf, end, ptr, spec, fmt);
+		}
+		break;
 	case 'F':
 	case 'f':
 		ptr = dereference_function_descriptor(ptr);
@@ -1151,6 +1174,7 @@ qualifier:
  *   http://tools.ietf.org/html/draft-ietf-6man-text-addr-representation-00
  * %pU[bBlL] print a UUID/GUID in big or little endian using lower or upper
  *   case.
+ * %ptc outputs the task's comm name
  * %n is ignored
  *
  * The return value is the number of characters which would
-- 
1.7.3.2.146.gca209

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
