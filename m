Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 49B0F6B0269
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 05:48:26 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id 188so229678055iti.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 02:48:26 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id n23si8125111ioo.207.2016.09.13.02.48.11
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 02:48:12 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v3 09/15] lockdep: Make print_circular_bug() crosslock-aware
Date: Tue, 13 Sep 2016 18:45:08 +0900
Message-Id: <1473759914-17003-10-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
References: <1473759914-17003-1-git-send-email-byungchul.park@lge.com>
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
