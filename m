Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id C33E46B005C
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 12:38:51 -0500 (EST)
Received: by eekc41 with SMTP id c41so1435832eek.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 09:38:49 -0800 (PST)
Subject: [PATCH 1/3] mm: add rss counters consistency check
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Fri, 06 Jan 2012 21:38:27 +0400
Message-ID: <20120106173827.11700.74305.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This patch warn about non-zero rss counters at final mmdrop.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 kernel/fork.c |   21 ++++++++++++++++++---
 1 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index da4a6a1..67a79dd 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -507,6 +507,23 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	return NULL;
 }
 
+static void check_mm(struct mm_struct *mm)
+{
+	int i;
+
+	for (i = 0; i < NR_MM_COUNTERS; i++) {
+		long x = atomic_long_read(&mm->rss_stat.count[i]);
+
+		if (unlikely(x))
+			printk(KERN_ALERT "BUG: Bad rss-counter state "
+					  "mm:%p idx:%d val:%ld\n", mm, i, x);
+	}
+
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+	VM_BUG_ON(mm->pmd_huge_pte);
+#endif
+}
+
 /*
  * Allocate and initialize an mm_struct.
  */
@@ -534,9 +551,7 @@ void __mmdrop(struct mm_struct *mm)
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
-#ifdef CONFIG_TRANSPARENT_HUGEPAGE
-	VM_BUG_ON(mm->pmd_huge_pte);
-#endif
+	check_mm(mm);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
