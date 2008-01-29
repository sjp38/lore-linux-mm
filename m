Message-Id: <20080129154947.110268504@szeredi.hu>
References: <20080129154900.145303789@szeredi.hu>
Date: Tue, 29 Jan 2008 16:49:01 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [patch 1/6] mm: bdi: tweak task dirty penalty
Content-Disposition: inline; filename=bdi-task-dirty.patch
Sender: owner-linux-mm@kvack.org
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: a.p.zijlstra@chello.nl, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Penalizing heavy dirtiers with 1/8-th the total dirty limit might be rather
excessive on large memory machines. Use sqrt to scale it sub-linearly.

Update the comment while we're there.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux/mm/page-writeback.c
===================================================================
--- linux.orig/mm/page-writeback.c	2008-01-17 19:00:56.000000000 +0100
+++ linux/mm/page-writeback.c	2008-01-18 13:07:16.000000000 +0100
@@ -219,17 +219,21 @@ static inline void task_dirties_fraction
 }
 
 /*
- * scale the dirty limit
+ * Task specific dirty limit:
  *
- * task specific dirty limit:
+ *   dirty -= 8 * sqrt(dirty) * p_{t}
  *
- *   dirty -= (dirty/8) * p_{t}
+ * Penalize tasks that dirty a lot of pages by lowering their dirty limit. This
+ * avoids infrequent dirtiers from getting stuck in this other guys dirty
+ * pages.
+ *
+ * Use a sub-linear function to scale the penalty, we only need a little room.
  */
 static void task_dirty_limit(struct task_struct *tsk, long *pdirty)
 {
 	long numerator, denominator;
 	long dirty = *pdirty;
-	u64 inv = dirty >> 3;
+	u64 inv = 8*int_sqrt(dirty);
 
 	task_dirties_fraction(tsk, &numerator, &denominator);
 	inv *= numerator;

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
