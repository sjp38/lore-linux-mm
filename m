Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 14 of 24] oom select should only take rss into account
Message-Id: <dde19626aa495cd8a6fa.1187786941@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:01 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID dde19626aa495cd8a6fa6b14a4f195438c2039ba
# Parent  cd70d64570b9add8072f7abe952b34fe57c60086
oom select should only take rss into account

Running workloads where many tasks grow their virtual memory
simultaneously, so they all have a relatively small virtual memory when
oom triggers (if compared to innocent longstanding tasks), the oom
killer then selects mysql/apache and other things with very large VM but
very small RSS. RSS is the only thing that matters, killing a task with
huge VM but zero RSS is not useful. Many apps tend to have large VM but
small RSS in the first place (regardless of swapping activity) and they
shouldn't be penalized like this.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -67,7 +67,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_rss(mm);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -91,7 +91,7 @@ unsigned long badness(struct task_struct
 	list_for_each_entry(child, &p->children, sibling) {
 		task_lock(child);
 		if (child->mm != mm && child->mm)
-			points += child->mm->total_vm/2 + 1;
+			points += get_mm_rss(child->mm)/2 + 1;
 		task_unlock(child);
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
