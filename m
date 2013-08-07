Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 7DF1E6B0033
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 19:35:36 -0400 (EDT)
Message-ID: <201308072335.r77NZZwl022494@farm-0012.internal.tilera.com>
In-Reply-To: <5202CEAA.9040204@linux.vnet.ibm.com>
References: <5202CEAA.9040204@linux.vnet.ibm.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Wed, 7 Aug 2013 16:52:22 -0400
Subject: [PATCH v4 2/2] mm: make lru_add_drain_all() selective
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Frederic Weisbecker <fweisbec@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

This change makes lru_add_drain_all() only selectively interrupt
the cpus that have per-cpu free pages that can be drained.

This is important in nohz mode where calling mlockall(), for
example, otherwise will interrupt every core unnecessarily.

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
v4: don't lose possible -ENOMEM in schedule_on_each_cpu()
(Note: no change to the mm/swap.c commit)

v3: split commit into two, one for workqueue and one for mm, though both
should probably be taken through -mm.

 mm/swap.c | 37 ++++++++++++++++++++++++++++++++++++-
 1 file changed, 36 insertions(+), 1 deletion(-)

diff --git a/mm/swap.c b/mm/swap.c
index 4a1d0d2..d4a862b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -405,6 +405,11 @@ static void activate_page_drain(int cpu)
 		pagevec_lru_move_fn(pvec, __activate_page, NULL);
 }
 
+static bool need_activate_page_drain(int cpu)
+{
+	return pagevec_count(&per_cpu(activate_page_pvecs, cpu)) != 0;
+}
+
 void activate_page(struct page *page)
 {
 	if (PageLRU(page) && !PageActive(page) && !PageUnevictable(page)) {
@@ -422,6 +427,11 @@ static inline void activate_page_drain(int cpu)
 {
 }
 
+static bool need_activate_page_drain(int cpu)
+{
+	return false;
+}
+
 void activate_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
@@ -683,7 +693,32 @@ static void lru_add_drain_per_cpu(struct work_struct *dummy)
  */
 int lru_add_drain_all(void)
 {
-	return schedule_on_each_cpu(lru_add_drain_per_cpu);
+	cpumask_var_t mask;
+	int cpu, rc;
+
+	if (!alloc_cpumask_var(&mask, GFP_KERNEL))
+		return -ENOMEM;
+	cpumask_clear(mask);
+
+	/*
+	 * Figure out which cpus need flushing.  It's OK if we race
+	 * with changes to the per-cpu lru pvecs, since it's no worse
+	 * than if we flushed all cpus, since a cpu could still end
+	 * up putting pages back on its pvec before we returned.
+	 * And this avoids interrupting other cpus unnecessarily.
+	 */
+	for_each_online_cpu(cpu) {
+		if (pagevec_count(&per_cpu(lru_add_pvec, cpu)) ||
+		    pagevec_count(&per_cpu(lru_rotate_pvecs, cpu)) ||
+		    pagevec_count(&per_cpu(lru_deactivate_pvecs, cpu)) ||
+		    need_activate_page_drain(cpu))
+			cpumask_set_cpu(cpu, mask);
+	}
+
+	rc = schedule_on_cpu_mask(lru_add_drain_per_cpu, mask);
+
+	free_cpumask_var(mask);
+	return rc;
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
