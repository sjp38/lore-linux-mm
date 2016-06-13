Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3EFBD6B026F
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 15:45:57 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id u74so63677501lff.0
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:45:57 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id n125si251901wmb.87.2016.06.13.12.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 12:45:55 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id k184so17284269wme.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 12:45:55 -0700 (PDT)
From: Topi Miettinen <toiwoton@gmail.com>
Subject: [RFC 03/18] memcontrol: present maximum used memory also for cgroup-v2
Date: Mon, 13 Jun 2016 22:44:10 +0300
Message-Id: <1465847065-3577-4-git-send-email-toiwoton@gmail.com>
In-Reply-To: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
References: <1465847065-3577-1-git-send-email-toiwoton@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Topi Miettinen <toiwoton@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER MEMCG" <cgroups@vger.kernel.org>, "open list:CONTROL GROUP - MEMORY RESOURCE CONTROLLER MEMCG" <linux-mm@kvack.org>

Present maximum used memory in cgroup memory.current_max.

Signed-off-by: Topi Miettinen <toiwoton@gmail.com>
---
 include/linux/page_counter.h |  7 ++++++-
 mm/memcontrol.c              | 13 +++++++++++++
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 7e62920..be4de17 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -9,9 +9,9 @@ struct page_counter {
 	atomic_long_t count;
 	unsigned long limit;
 	struct page_counter *parent;
+	unsigned long watermark;
 
 	/* legacy */
-	unsigned long watermark;
 	unsigned long failcnt;
 };
 
@@ -34,6 +34,11 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
 	return atomic_long_read(&counter->count);
 }
 
+static inline unsigned long page_counter_read_watermark(struct page_counter *counter)
+{
+	return counter->watermark;
+}
+
 void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
 bool page_counter_try_charge(struct page_counter *counter,
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 75e7440..5513771 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4966,6 +4966,14 @@ static u64 memory_current_read(struct cgroup_subsys_state *css,
 	return (u64)page_counter_read(&memcg->memory) * PAGE_SIZE;
 }
 
+static u64 memory_current_max_read(struct cgroup_subsys_state *css,
+				   struct cftype *cft)
+{
+	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
+
+	return (u64)page_counter_read_watermark(&memcg->memory) * PAGE_SIZE;
+}
+
 static int memory_low_show(struct seq_file *m, void *v)
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
@@ -5179,6 +5187,11 @@ static struct cftype memory_files[] = {
 		.read_u64 = memory_current_read,
 	},
 	{
+		.name = "current_max",
+		.flags = CFTYPE_NOT_ON_ROOT,
+		.read_u64 = memory_current_max_read,
+	},
+	{
 		.name = "low",
 		.flags = CFTYPE_NOT_ON_ROOT,
 		.seq_show = memory_low_show,
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
