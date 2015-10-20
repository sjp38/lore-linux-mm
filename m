Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 24D9B82F66
	for <linux-mm@kvack.org>; Tue, 20 Oct 2015 16:36:37 -0400 (EDT)
Received: by wikq8 with SMTP id q8so64140359wik.1
        for <linux-mm@kvack.org>; Tue, 20 Oct 2015 13:36:36 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0069.outbound.protection.outlook.com. [157.56.112.69])
        by mx.google.com with ESMTPS id lh9si6487017wjc.47.2015.10.20.13.36.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Oct 2015 13:36:36 -0700 (PDT)
From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH v8 03/14] lru_add_drain_all: factor out lru_add_drain_needed
Date: Tue, 20 Oct 2015 16:36:01 -0400
Message-ID: <1445373372-6567-4-git-send-email-cmetcalf@ezchip.com>
In-Reply-To: <1445373372-6567-1-git-send-email-cmetcalf@ezchip.com>
References: <1445373372-6567-1-git-send-email-cmetcalf@ezchip.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@ezchip.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van
 Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Chris Metcalf <cmetcalf@ezchip.com>

This per-cpu check was being done in the loop in lru_add_drain_all(),
but having it be callable for a particular cpu is helpful for the
task-isolation patches.

Signed-off-by: Chris Metcalf <cmetcalf@ezchip.com>
---
 include/linux/swap.h |  1 +
 mm/swap.c            | 13 +++++++++----
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7ba7dccaf0e7..66719610c9f5 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -305,6 +305,7 @@ extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
+extern bool lru_add_drain_needed(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index 983f692a47fd..e21f3357cedd 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -854,6 +854,14 @@ void deactivate_file_page(struct page *page)
 	}
 }
 
+bool lru_add_drain_needed(int cpu)
+{
+	return (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
+		pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
+		pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
+		need_activate_page_drain(cpu));
+}
+
 void lru_add_drain(void)
 {
 	lru_add_drain_cpu(get_cpu());
@@ -880,10 +888,7 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    need_activate_page_drain(cpu)) {
+		if (lru_add_drain_needed(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
 			cpumask_set_cpu(cpu, &has_work);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
