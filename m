Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id F14C882F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:19 -0500 (EST)
Received: by ykdv3 with SMTP id v3so68801901ykd.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o10si6527978vkf.149.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:16 -0800 (PST)
Message-Id: <20151105223014.856885835@redhat.com>
Date: Thu, 05 Nov 2015 17:30:17 -0500
From: aris@redhat.com
Subject: [PATCH 3/5] dump_stack: introduce generic show_stack_lvl()
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=introduce_generic_show_stack.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

show_stack_lvl() works like show_stack() but allows also passing the log level.
The default implementation that should be overrided by architecture specific
code simply will call the existing show_stack().

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

---
 include/linux/sched.h |    2 ++
 lib/dump_stack.c      |    8 +++++++-
 2 files changed, 9 insertions(+), 1 deletion(-)

--- linux-2.6.orig/lib/dump_stack.c	2015-11-05 14:31:44.581921915 -0500
+++ linux-2.6/lib/dump_stack.c	2015-11-05 14:32:47.508211219 -0500
@@ -9,10 +9,16 @@
 #include <linux/smp.h>
 #include <linux/atomic.h>
 
+void __weak show_stack_lvl(struct task_struct *task, unsigned long *sp,
+			       char *log_lvl)
+{
+	return show_stack(task, sp);
+}
+
 static void __dump_stack(char *log_lvl)
 {
 	dump_stack_print_info(log_lvl);
-	show_stack(NULL, NULL);
+	show_stack_lvl(NULL, NULL, log_lvl);
 }
 
 /**
--- linux-2.6.orig/include/linux/sched.h	2015-11-05 14:31:44.581921915 -0500
+++ linux-2.6/include/linux/sched.h	2015-11-05 14:31:52.426833314 -0500
@@ -368,6 +368,8 @@ extern void show_regs(struct pt_regs *);
  * trace (or NULL if the entire call-chain of the task should be shown).
  */
 extern void show_stack(struct task_struct *task, unsigned long *sp);
+extern void show_stack_lvl(struct task_struct *task, unsigned long *sp,
+			   char *log_lvl);
 
 extern void cpu_init (void);
 extern void trap_init(void);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
