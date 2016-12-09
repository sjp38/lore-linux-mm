Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2629D6B0271
	for <linux-mm@kvack.org>; Fri,  9 Dec 2016 00:16:37 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id x23so16916212pgx.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 21:16:37 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id h5si31946849pgf.209.2016.12.08.21.16.35
        for <linux-mm@kvack.org>;
        Thu, 08 Dec 2016 21:16:36 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v4 09/15] lockdep: Make print_circular_bug() crosslock-aware
Date: Fri,  9 Dec 2016 14:12:05 +0900
Message-Id: <1481260331-360-10-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

Friends of print_circular_bug() reporting circular bug assumes that
target hlock is owned by the current. However, in crossrelease feature,
target hlock can be owned by any context.

In this case, the circular bug is caused by target hlock which cannot be
released since its dependent lock cannot be released. So the report
format needs to be changed to be aware of this.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 56 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 39 insertions(+), 17 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index fbd07ee..cb1a600 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1126,22 +1126,41 @@ print_circular_lock_scenario(struct held_lock *src,
 		printk("\n\n");
 	}
 
-	printk(" Possible unsafe locking scenario:\n\n");
-	printk("       CPU0                    CPU1\n");
-	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(target);
-	printk(");\n");
-	printk("                               lock(");
-	__print_lock_name(parent);
-	printk(");\n");
-	printk("                               lock(");
-	__print_lock_name(target);
-	printk(");\n");
-	printk("  lock(");
-	__print_lock_name(source);
-	printk(");\n");
-	printk("\n *** DEADLOCK ***\n\n");
+	if (cross_class(target)) {
+		printk(" Possible unsafe locking scenario by crosslock:\n\n");
+		printk("       CPU0                    CPU1\n");
+		printk("       ----                    ----\n");
+		printk("  lock(");
+		__print_lock_name(parent);
+		printk(");\n");
+		printk("  lock(");
+		__print_lock_name(target);
+		printk(");\n");
+		printk("                               lock(");
+		__print_lock_name(source);
+		printk(");\n");
+		printk("                               unlock(");
+		__print_lock_name(target);
+		printk(");\n");
+		printk("\n *** DEADLOCK ***\n\n");
+	} else {
+		printk(" Possible unsafe locking scenario:\n\n");
+		printk("       CPU0                    CPU1\n");
+		printk("       ----                    ----\n");
+		printk("  lock(");
+		__print_lock_name(target);
+		printk(");\n");
+		printk("                               lock(");
+		__print_lock_name(parent);
+		printk(");\n");
+		printk("                               lock(");
+		__print_lock_name(target);
+		printk(");\n");
+		printk("  lock(");
+		__print_lock_name(source);
+		printk(");\n");
+		printk("\n *** DEADLOCK ***\n\n");
+	}
 }
 
 /*
@@ -1166,7 +1185,10 @@ print_circular_bug_header(struct lock_list *entry, unsigned int depth,
 	printk("%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
 	print_lock(check_src);
-	printk("\nbut task is already holding lock:\n");
+	if (cross_class(hlock_class(check_tgt)))
+		printk("\nbut now in the release context of lock:\n");
+	else
+		printk("\nbut task is already holding lock:\n");
 	print_lock(check_tgt);
 	printk("\nwhich lock already depends on the new lock.\n\n");
 	printk("\nthe existing dependency chain (in reverse order) is:\n");
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
