Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id DA5FC6B0038
	for <linux-mm@kvack.org>; Sat, 17 Jan 2015 10:21:51 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id b13so7882714wgh.8
        for <linux-mm@kvack.org>; Sat, 17 Jan 2015 07:21:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bw9si14550889wjc.74.2015.01.17.07.21.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 17 Jan 2015 07:21:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: memcontrol: default hierarchy interface for memory fix - "none"
Date: Sat, 17 Jan 2015 10:21:47 -0500
Message-Id: <1421508107-29377-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The "none" name for the low-boundary 0 and the high-boundary maximum
value can be confusing.

Just leave the low boundary at 0, and give the highest-possible
boundary value the name "max" that means the same for controls.

Reported-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/unified-hierarchy.txt |  5 +--
 include/linux/page_counter.h                |  3 +-
 mm/memcontrol.c                             | 58 ++++++++++-------------------
 mm/page_counter.c                           |  9 ++++-
 4 files changed, 31 insertions(+), 44 deletions(-)

diff --git a/Documentation/cgroups/unified-hierarchy.txt b/Documentation/cgroups/unified-hierarchy.txt
index 643af9bb9a07..171aa23c113e 100644
--- a/Documentation/cgroups/unified-hierarchy.txt
+++ b/Documentation/cgroups/unified-hierarchy.txt
@@ -404,9 +404,8 @@ supported and the interface files "release_agent" and
   be understood as an underflow into the highest possible value, -2 or
   -10M etc. do not work, so it's not consistent.
 
-  memory.low and memory.high will indicate "none" if the boundary is
-  not configured, and a configured boundary can be unset by writing
-  "none" into these files as well.
+  memory.low, memory.high, and memory.max will use the string "max" to
+  indicate and configure the highest possible value.
 
 5. Planned Changes
 
diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 955421575d16..17fa4f8de3a6 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -41,7 +41,8 @@ int page_counter_try_charge(struct page_counter *counter,
 			    struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_limit(struct page_counter *counter, unsigned long limit);
-int page_counter_memparse(const char *buf, unsigned long *nr_pages);
+int page_counter_memparse(const char *buf, const char *max,
+			  unsigned long *nr_pages);
 
 static inline void page_counter_reset_watermark(struct page_counter *counter)
 {
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7adccee9fecb..718bc6bb5837 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3419,13 +3419,9 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 	int ret;
 
 	buf = strstrip(buf);
-	if (!strcmp(buf, "-1")) {
-		nr_pages = PAGE_COUNTER_MAX;
-	} else {
-		ret = page_counter_memparse(buf, &nr_pages);
-		if (ret)
-			return ret;
-	}
+	ret = page_counter_memparse(buf, "-1", &nr_pages);
+	if (ret)
+		return ret;
 
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
@@ -3795,13 +3791,9 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	unsigned long usage;
 	int i, size, ret;
 
-	if (!strcmp(args, "-1")) {
-		threshold = PAGE_COUNTER_MAX;
-	} else {
-		ret = page_counter_memparse(args, &threshold);
-		if (ret)
-			return ret;
-	}
+	ret = page_counter_memparse(args, "-1", &threshold);
+	if (ret)
+		return ret;
 
 	mutex_lock(&memcg->thresholds_lock);
 
@@ -5246,8 +5238,8 @@ static int memory_low_show(struct seq_file *m, void *v)
 	struct mem_cgroup *memcg = mem_cgroup_from_css(seq_css(m));
 	unsigned long low = ACCESS_ONCE(memcg->low);
 
-	if (low == 0)
-		seq_puts(m, "none\n");
+	if (low == PAGE_COUNTER_MAX)
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)low * PAGE_SIZE);
 
@@ -5262,13 +5254,9 @@ static ssize_t memory_low_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	if (!strcmp(buf, "none")) {
-		low = 0;
-	} else {
-		err = page_counter_memparse(buf, &low);
-		if (err)
-			return err;
-	}
+	err = page_counter_memparse(buf, "max", &low);
+	if (err)
+		return err;
 
 	memcg->low = low;
 
@@ -5281,7 +5269,7 @@ static int memory_high_show(struct seq_file *m, void *v)
 	unsigned long high = ACCESS_ONCE(memcg->high);
 
 	if (high == PAGE_COUNTER_MAX)
-		seq_puts(m, "none\n");
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)high * PAGE_SIZE);
 
@@ -5296,13 +5284,9 @@ static ssize_t memory_high_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	if (!strcmp(buf, "none")) {
-		high = PAGE_COUNTER_MAX;
-	} else {
-		err = page_counter_memparse(buf, &high);
-		if (err)
-			return err;
-	}
+	err = page_counter_memparse(buf, "max", &high);
+	if (err)
+		return err;
 
 	memcg->high = high;
 
@@ -5315,7 +5299,7 @@ static int memory_max_show(struct seq_file *m, void *v)
 	unsigned long max = ACCESS_ONCE(memcg->memory.limit);
 
 	if (max == PAGE_COUNTER_MAX)
-		seq_puts(m, "none\n");
+		seq_puts(m, "max\n");
 	else
 		seq_printf(m, "%llu\n", (u64)max * PAGE_SIZE);
 
@@ -5330,13 +5314,9 @@ static ssize_t memory_max_write(struct kernfs_open_file *of,
 	int err;
 
 	buf = strstrip(buf);
-	if (!strcmp(buf, "none")) {
-		max = PAGE_COUNTER_MAX;
-	} else {
-		err = page_counter_memparse(buf, &max);
-		if (err)
-			return err;
-	}
+	err = page_counter_memparse(buf, "max", &max);
+	if (err)
+		return err;
 
 	err = mem_cgroup_resize_limit(memcg, max);
 	if (err)
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 0d4f9daf68bd..11b4beda14ba 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -166,16 +166,23 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
 /**
  * page_counter_memparse - memparse() for page counter limits
  * @buf: string to parse
+ * @max: string meaning maximum possible value
  * @nr_pages: returns the result in number of pages
  *
  * Returns -EINVAL, or 0 and @nr_pages on success.  @nr_pages will be
  * limited to %PAGE_COUNTER_MAX.
  */
-int page_counter_memparse(const char *buf, unsigned long *nr_pages)
+int page_counter_memparse(const char *buf, const char *max,
+			  unsigned long *nr_pages)
 {
 	char *end;
 	u64 bytes;
 
+	if (!strcmp(buf, max)) {
+		*nr_pages = PAGE_COUNTER_MAX;
+		return 0;
+	}
+
 	bytes = memparse(buf, &end);
 	if (*end != '\0')
 		return -EINVAL;
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
