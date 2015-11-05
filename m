Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f173.google.com (mail-yk0-f173.google.com [209.85.160.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3657F82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:24 -0500 (EST)
Received: by ykba4 with SMTP id a4so158301306ykb.3
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q130si6518761vkf.193.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:16 -0800 (PST)
Message-Id: <20151105223014.818548847@redhat.com>
Date: Thu, 05 Nov 2015 17:30:16 -0500
From: aris@redhat.com
Subject: [PATCH 2/5] dump_stack: introduce dump_stack_lvl
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=introduce_dump_stack_lvl.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

dump_stack_lvl() allows passing the log level down to the architecture specific
code.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

---
 include/linux/printk.h |    1 +
 lib/dump_stack.c       |   11 +++++++++++
 2 files changed, 12 insertions(+)

--- linux-2.6.orig/lib/dump_stack.c	2015-11-05 10:56:52.529526114 -0500
+++ linux-2.6/lib/dump_stack.c	2015-11-05 13:16:15.057078858 -0500
@@ -55,6 +55,11 @@ was_locked = 0;
 	preempt_enable();
 }
 
+asmlinkage __visible void dump_stack_lvl(char *log_lvl)
+{
+	_dump_stack(log_lvl);
+}
+
 asmlinkage __visible void dump_stack(void)
 {
 	_dump_stack(KERN_DEFAULT);
@@ -65,5 +70,11 @@ asmlinkage __visible void dump_stack(voi
 {
 	__dump_stack(KERN_DEFAULT);
 }
+
+asmlinkage __visible void dump_stack_lvl(char *log_lvl)
+{
+	__dump_stack(log_lvl);
+}
 #endif
 EXPORT_SYMBOL(dump_stack);
+EXPORT_SYMBOL(dump_stack_lvl);
--- linux-2.6.orig/include/linux/printk.h	2015-11-05 10:56:13.163970713 -0500
+++ linux-2.6/include/linux/printk.h	2015-11-05 13:16:15.057078858 -0500
@@ -231,6 +231,7 @@ static inline void show_regs_print_info(
 #endif
 
 extern asmlinkage void dump_stack(void) __cold;
+extern asmlinkage void dump_stack_lvl(char *log_lvl);
 
 #ifndef pr_fmt
 #define pr_fmt(fmt) fmt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
