Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 1B59D82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 17:30:22 -0500 (EST)
Received: by ykdv3 with SMTP id v3so68803580ykd.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 14:30:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g11si6519781vkf.155.2015.11.05.14.30.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 14:30:16 -0800 (PST)
Message-Id: <20151105223014.759064379@redhat.com>
Date: Thu, 05 Nov 2015 17:30:15 -0500
From: aris@redhat.com
Subject: [PATCH 1/5] dump_stack: pass log level to dump_stack_print_info()
References: <20151105223014.701269769@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Disposition: inline; filename=0001-dump_stack-pass-log-level-to-dump_stack_print_info.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kerne@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>

This is in preparation for dump_stack_lvl() which will allow the log level to
be passed.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>
Signed-off-by: Aristeu Rozanski <aris@redhat.com>

---
 lib/dump_stack.c |   16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

--- linux-2.6.orig/lib/dump_stack.c	2015-11-05 13:56:08.387048346 -0500
+++ linux-2.6/lib/dump_stack.c	2015-11-05 13:56:34.900748897 -0500
@@ -9,9 +9,9 @@
 #include <linux/smp.h>
 #include <linux/atomic.h>
 
-static void __dump_stack(void)
+static void __dump_stack(char *log_lvl)
 {
-	dump_stack_print_info(KERN_DEFAULT);
+	dump_stack_print_info(log_lvl);
 	show_stack(NULL, NULL);
 }
 
@@ -23,7 +23,7 @@ static void __dump_stack(void)
 #ifdef CONFIG_SMP
 static atomic_t dump_lock = ATOMIC_INIT(-1);
 
-asmlinkage __visible void dump_stack(void)
+static void _dump_stack(char *log_lvl)
 {
 	int was_locked;
 	int old;
@@ -47,17 +47,23 @@ was_locked = 0;
 		goto retry;
 	}
 
-	__dump_stack();
+	__dump_stack(log_lvl);
 
 	if (!was_locked)
 		atomic_set(&dump_lock, -1);
 
 	preempt_enable();
 }
+
+asmlinkage __visible void dump_stack(void)
+{
+	_dump_stack(KERN_DEFAULT);
+}
+
 #else
 asmlinkage __visible void dump_stack(void)
 {
-	__dump_stack();
+	__dump_stack(KERN_DEFAULT);
 }
 #endif
 EXPORT_SYMBOL(dump_stack);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
