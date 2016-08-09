Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1428A6B025F
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 16:30:15 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id l4so34598058wml.0
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 13:30:15 -0700 (PDT)
Received: from mellanox.co.il (mail-il-dmz.mellanox.com. [193.47.165.129])
        by mx.google.com with ESMTP id s140si4746293wmd.57.2016.08.09.13.30.12
        for <linux-mm@kvack.org>;
        Tue, 09 Aug 2016 13:30:13 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v14 03/14] lru_add_drain_all: factor out lru_add_drain_needed
Date: Tue,  9 Aug 2016 16:29:45 -0400
Message-Id: <1470774596-17341-4-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
References: <1470774596-17341-1-git-send-email-cmetcalf@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@mellanox.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@mellanox.com>

This per-cpu check was being done in the loop in lru_add_drain_all(),
but having it be callable for a particular cpu is helpful for the
task-isolation patches.

Signed-off-by: Chris Metcalf <cmetcalf@mellanox.com>
---
 include/linux/swap.h |  1 +
 mm/swap.c            | 15 ++++++++++-----
 2 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index b17cc4830fa6..58966a235298 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -295,6 +295,7 @@ extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
+extern bool lru_add_drain_needed(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index 75c63bb2a1da..a2be6f0931b5 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -655,6 +655,15 @@ void deactivate_page(struct page *page)
 	}
 }
 
+bool lru_add_drain_needed(int cpu)
+{
+	return (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
+		pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
+		pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		need_activate_page_drain(cpu));
+}
+
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
@@ -699,11 +708,7 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
-		    need_activate_page_drain(cpu)) {
+		if (lru_add_drain_needed(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			queue_work_on(cpu, lru_add_drain_wq, work);
 			cpumask_set_cpu(cpu, &has_work);
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
