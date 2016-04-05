Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 4B6546B0268
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 13:39:07 -0400 (EDT)
Received: by mail-qk0-f170.google.com with SMTP id r184so7839589qkc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 10:39:07 -0700 (PDT)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0087.outbound.protection.outlook.com. [157.55.234.87])
        by mx.google.com with ESMTPS id b18si27012300qka.112.2016.04.05.10.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 10:39:06 -0700 (PDT)
From: Chris Metcalf <cmetcalf@mellanox.com>
Subject: [PATCH v12 03/13] lru_add_drain_all: factor out lru_add_drain_needed
Date: Tue, 5 Apr 2016 13:38:32 -0400
Message-ID: <1459877922-15512-4-git-send-email-cmetcalf@mellanox.com>
In-Reply-To: <1459877922-15512-1-git-send-email-cmetcalf@mellanox.com>
References: <1459877922-15512-1-git-send-email-cmetcalf@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben Yossef <giladb@ezchip.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van
 Riel <riel@redhat.com>, Tejun Heo <tj@kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Viresh Kumar <viresh.kumar@linaro.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Andy Lutomirski <luto@amacapital.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
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
index d18b65c53dbb..da21f5240702 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -304,6 +304,7 @@ extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern void lru_add_drain_cpu(int cpu);
+extern bool lru_add_drain_needed(int cpu);
 extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..bdcdfa21094c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -653,6 +653,15 @@ void deactivate_page(struct page *page)
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
@@ -679,11 +688,7 @@ void lru_add_drain_all(void)
 	for_each_online_cpu(cpu) {
 		struct work_struct *work = &per_cpu(lru_add_drain_work, cpu);
 
-		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
-		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_file_pvecs, cpu)) ||
-		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
-		    need_activate_page_drain(cpu)) {
+		if (lru_add_drain_needed(cpu)) {
 			INIT_WORK(work, lru_add_drain_per_cpu);
 			schedule_work_on(cpu, work);
 			cpumask_set_cpu(cpu, &has_work);
-- 
2.7.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
