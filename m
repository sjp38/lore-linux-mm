Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 09 of 13] oom select should only take rss into account
Message-Id: <6c433e92ef119dd39893.1199778640@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:40 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID 6c433e92ef119dd39893c6b54e41154866c32ef8
# Parent  be951f4c07326327719ad105f14be41296fcf753
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
@@ -68,7 +68,7 @@ unsigned long badness(struct task_struct
 	/*
 	 * The memory size of the process is the basis for the badness.
 	 */
-	points = mm->total_vm;
+	points = get_mm_rss(mm);
 
 	/*
 	 * After this unlock we can no longer dereference local variable `mm'
@@ -92,7 +92,7 @@ unsigned long badness(struct task_struct
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
