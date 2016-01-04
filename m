Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 97F056B0005
	for <linux-mm@kvack.org>; Mon,  4 Jan 2016 14:35:23 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id do7so1081615pab.2
        for <linux-mm@kvack.org>; Mon, 04 Jan 2016 11:35:23 -0800 (PST)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0083.outbound.protection.outlook.com. [157.56.112.83])
        by mx.google.com with ESMTPS id f90si1871747pfd.25.2016.01.04.11.35.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 04 Jan 2016 11:35:22 -0800 (PST)
From: Chris Metcalf <cmetcalf@ezchip.com>
Subject: [PATCH v9 03/13] lru_add_drain_all: factor out lru_add_drain_needed
Date: Mon, 4 Jan 2016 14:34:41 -0500
Message-ID: <1451936091-29247-4-git-send-email-cmetcalf@ezchip.com>
In-Reply-To: <1451936091-29247-1-git-send-email-cmetcalf@ezchip.com>
References: <1451936091-29247-1-git-send-email-cmetcalf@ezchip.com>
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
index 39395fb549c0..ce1eb052a293 100644
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
