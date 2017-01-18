Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 842656B026B
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 08:17:56 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id z128so16527440pfb.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 05:17:56 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id 64si228660plw.75.2017.01.18.05.17.54
        for <linux-mm@kvack.org>;
        Wed, 18 Jan 2017 05:17:55 -0800 (PST)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v5 07/13] lockdep: Make print_circular_bug() aware of crossrelease
Date: Wed, 18 Jan 2017 22:17:33 +0900
Message-Id: <1484745459-2055-8-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
References: <1484745459-2055-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com

print_circular_bug() reporting circular bug assumes that target hlock is
owned by the current. However, in crossrelease, target hlock can be
owned by other than the current. So the report format needs to be
changed to reflect the change.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 56 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 39 insertions(+), 17 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 0621b3e..49b9386 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1129,22 +1129,41 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 		printk(KERN_CONT "\n\n");
 	}
 
-	printk(" Possible unsafe locking scenario:\n\n");
-	printk("       CPU0                    CPU1\n");
-	printk("       ----                    ----\n");
-	printk("  lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(parent);
-	printk(KERN_CONT ");\n");
-	printk("                               lock(");
-	__print_lock_name(target);
-	printk(KERN_CONT ");\n");
-	printk("  lock(");
-	__print_lock_name(source);
-	printk(KERN_CONT ");\n");
-	printk("\n *** DEADLOCK ***\n\n");
+	if (cross_lock(tgt->instance)) {
+		printk(" Possible unsafe locking scenario by crosslock:\n\n");
+		printk("       CPU0                    CPU1\n");
+		printk("       ----                    ----\n");
+		printk("  lock(");
+		__print_lock_name(parent);
+		printk(KERN_CONT ");\n");
+		printk("  lock(");
+		__print_lock_name(target);
+		printk(KERN_CONT ");\n");
+		printk("                               lock(");
+		__print_lock_name(source);
+		printk(KERN_CONT ");\n");
+		printk("                               unlock(");
+		__print_lock_name(target);
+		printk(KERN_CONT ");\n");
+		printk("\n *** DEADLOCK ***\n\n");
+	} else {
+		printk(" Possible unsafe locking scenario:\n\n");
+		printk("       CPU0                    CPU1\n");
+		printk("       ----                    ----\n");
+		printk("  lock(");
+		__print_lock_name(target);
+		printk(KERN_CONT ");\n");
+		printk("                               lock(");
+		__print_lock_name(parent);
+		printk(KERN_CONT ");\n");
+		printk("                               lock(");
+		__print_lock_name(target);
+		printk(KERN_CONT ");\n");
+		printk("  lock(");
+		__print_lock_name(source);
+		printk(KERN_CONT ");\n");
+		printk("\n *** DEADLOCK ***\n\n");
+	}
 }
 
 /*
@@ -1169,7 +1188,10 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 	printk("%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
 	print_lock(check_src);
-	printk("\nbut task is already holding lock:\n");
+	if (cross_lock(check_tgt->instance))
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
