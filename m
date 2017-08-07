Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8203F6B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 03:14:14 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t80so91062744pgb.0
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 00:14:14 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id m29si4344338pgn.176.2017.08.07.00.14.12
        for <linux-mm@kvack.org>;
        Mon, 07 Aug 2017 00:14:13 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v8 08/14] lockdep: Make print_circular_bug() aware of crossrelease
Date: Mon,  7 Aug 2017 16:12:55 +0900
Message-Id: <1502089981-21272-9-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
References: <1502089981-21272-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, walken@google.com, boqun.feng@gmail.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, willy@infradead.org, npiggin@gmail.com, kernel-team@lge.com

print_circular_bug() reporting circular bug assumes that target hlock is
owned by the current. However, in crossrelease, target hlock can be
owned by other than the current. So the report format needs to be
changed to reflect the change.

Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 kernel/locking/lockdep.c | 67 +++++++++++++++++++++++++++++++++---------------
 1 file changed, 47 insertions(+), 20 deletions(-)

diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 4eae7dc..a2b6aaa 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -1141,22 +1141,41 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
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
@@ -1181,7 +1200,12 @@ static inline int __bfs_backwards(struct lock_list *src_entry,
 	pr_warn("%s/%d is trying to acquire lock:\n",
 		curr->comm, task_pid_nr(curr));
 	print_lock(check_src);
-	pr_warn("\nbut task is already holding lock:\n");
+
+	if (cross_lock(check_tgt->instance))
+		pr_warn("\nbut now in release context of a crosslock acquired at the following:\n");
+	else
+		pr_warn("\nbut task is already holding lock:\n");
+
 	print_lock(check_tgt);
 	pr_warn("\nwhich lock already depends on the new lock.\n\n");
 	pr_warn("\nthe existing dependency chain (in reverse order) is:\n");
@@ -1199,7 +1223,8 @@ static inline int class_equal(struct lock_list *entry, void *data)
 static noinline int print_circular_bug(struct lock_list *this,
 				struct lock_list *target,
 				struct held_lock *check_src,
-				struct held_lock *check_tgt)
+				struct held_lock *check_tgt,
+				struct stack_trace *trace)
 {
 	struct task_struct *curr = current;
 	struct lock_list *parent;
@@ -1209,7 +1234,9 @@ static noinline int print_circular_bug(struct lock_list *this,
 	if (!debug_locks_off_graph_unlock() || debug_locks_silent)
 		return 0;
 
-	if (!save_trace(&this->trace))
+	if (cross_lock(check_tgt->instance))
+		this->trace = *trace;
+	else if (!save_trace(&this->trace))
 		return 0;
 
 	depth = get_lock_depth(target);
@@ -1853,7 +1880,7 @@ static inline void inc_chains(void)
 	this.parent = NULL;
 	ret = check_noncircular(&this, hlock_class(prev), &target_entry);
 	if (unlikely(!ret))
-		return print_circular_bug(&this, target_entry, next, prev);
+		return print_circular_bug(&this, target_entry, next, prev, trace);
 	else if (unlikely(ret < 0))
 		return print_bfs_bug(ret);
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
