Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 630D86B0007
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 12:37:16 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id w2-v6so6449284qti.8
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 09:37:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j3si4965580qkc.115.2018.04.20.09.37.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 09:37:15 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 2/2] mm: move the high field from struct mem_cgroup to page_counter
Date: Fri, 20 Apr 2018 17:36:32 +0100
Message-ID: <20180420163632.3978-2-guro@fb.com>
In-Reply-To: <20180420163632.3978-1-guro@fb.com>
References: <20180420163632.3978-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

We do store memory.min, memory.low and memory.max actual values
in struct page_counter fields, while memory.high value is located
in the struct mem_cgroup directly, which is not very consistent.

This patch moves the high field from struct mem_cgroup to
struct page_counter to simplify the code and make handling
of all limits/boundaries clearer.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/memcontrol.h   |  3 ---
 include/linux/page_counter.h |  3 +++
 mm/memcontrol.c              | 18 +++++++++---------
 mm/page_counter.c            | 12 ++++++++++++
 4 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 6ee19532f567..b89e060d0283 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -182,9 +182,6 @@ struct mem_cgroup {
 	struct page_counter kmem;
 	struct page_counter tcpmem;
 
-	/* Upper bound of normal memory consumption range */
-	unsigned long high;
-
 	/* Range enforcement for interrupt charges */
 	struct work_struct high_work;
 
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index bab7e57f659b..83999441a43e 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -10,6 +10,7 @@ struct page_counter {
 	atomic_long_t usage;
 	unsigned long min;
 	unsigned long low;
+	unsigned long high;
 	unsigned long max;
 	struct page_counter *parent;
 
@@ -38,6 +39,7 @@ static inline void page_counter_init(struct page_counter *counter,
 				     struct page_counter *parent)
 {
 	atomic_long_set(&counter->usage, 0);
+	counter->high = PAGE_COUNTER_MAX;
 	counter->max = PAGE_COUNTER_MAX;
 	counter->parent = parent;
 }
@@ -55,6 +57,7 @@ bool page_counter_try_charge(struct page_counter *counter,
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_set_min(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_set_low(struct page_counter *counter, unsigned long nr_pages);
+void page_counter_set_high(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_memparse(const char *buf, const char *max,
 			  unsigned long *nr_pages);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9c65de7937d0..f9724dea017c 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1869,7 +1869,7 @@ static void reclaim_high(struct mem_cgroup *memcg,
 			 gfp_t gfp_mask)
 {
 	do {
-		if (page_counter_read(&memcg->memory) <= memcg->high)
+		if (page_counter_read(&memcg->memory) <= memcg->memory.high)
 			continue;
 		memcg_memory_event(memcg, MEMCG_HIGH);
 		try_to_free_mem_cgroup_pages(memcg, nr_pages, gfp_mask, true);
@@ -2040,7 +2040,7 @@ static int try_charge(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * reclaim, the cost of mismatch is negligible.
 	 */
 	do {
-		if (page_counter_read(&memcg->memory) > memcg->high) {
+		if (page_counter_read(&memcg->memory) > memcg->memory.high) {
 			/* Don't bother a random interrupted task */
 			if (in_interrupt()) {
 				schedule_work(&memcg->high_work);
@@ -3857,7 +3857,8 @@ void mem_cgroup_wb_stats(struct bdi_writeback *wb, unsigned long *pfilepages,
 	*pheadroom = PAGE_COUNTER_MAX;
 
 	while ((parent = parent_mem_cgroup(memcg))) {
-		unsigned long ceiling = min(memcg->memory.max, memcg->high);
+		unsigned long ceiling = min(memcg->memory.max,
+					    memcg->memory.high);
 		unsigned long used = page_counter_read(&memcg->memory);
 
 		*pheadroom = min(*pheadroom, ceiling - min(ceiling, used));
@@ -4433,7 +4434,6 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 	if (!memcg)
 		return ERR_PTR(error);
 
-	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	if (parent) {
 		memcg->swappiness = mem_cgroup_swappiness(parent);
@@ -4558,14 +4558,14 @@ static void mem_cgroup_css_reset(struct cgroup_subsys_state *css)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	page_counter_set_min(&memcg->memory, 0);
+	page_counter_set_low(&memcg->memory, 0);
+	page_counter_set_high(&memcg->memory, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->memory, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->swap, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->memsw, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->kmem, PAGE_COUNTER_MAX);
 	page_counter_set_max(&memcg->tcpmem, PAGE_COUNTER_MAX);
-	page_counter_set_min(&memcg->memory, 0);
-	page_counter_set_low(&memcg->memory, 0);
-	memcg->high = PAGE_COUNTER_MAX;
 	memcg->soft_limit = PAGE_COUNTER_MAX;
 	memcg_wb_domain_size_changed(memcg);
 }
@@ -5364,7 +5364,7 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 static int memory_high_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
-	unsigned long high = READ_ONCE(memcg->high);
+	unsigned long high = READ_ONCE(memcg->memory.high);
 
 	if (high == PAGE_COUNTER_MAX)
 		seq_puts(m, "max\n");
@@ -5387,7 +5387,7 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 	if (err)
 		return err;
 
-	memcg->high = high;
+	page_counter_set_high(&memcg->memory, high);
 
 	nr_pages = page_counter_read(&memcg->memory);
 	if (nr_pages > high)
diff --git a/mm/page_counter.c b/mm/page_counter.c
index de31470655f6..7f0013304afd 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -202,6 +202,18 @@ int page_counter_set_max(struct page_counter *counter, unsigned long nr_pages)
 	}
 }
 
+/**
+ * page_counter_set_high - set the upper soft boundary of pages allowed
+ * @counter: counter
+ * @nr_pages: limit to set
+ *
+ * The caller must serialize invocations on the same counter.
+ */
+void page_counter_set_high(struct page_counter *counter, unsigned long nr_pages)
+{
+	counter->high = nr_pages;
+}
+
 /**
  * page_counter_set_min - set the amount of protected memory
  * @counter: counter
-- 
2.14.3
