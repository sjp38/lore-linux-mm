Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 22F0B6B0038
	for <linux-mm@kvack.org>; Thu,  8 Jan 2015 23:15:12 -0500 (EST)
Received: by mail-wg0-f49.google.com with SMTP id n12so6052868wgh.8
        for <linux-mm@kvack.org>; Thu, 08 Jan 2015 20:15:11 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id cu6si44832088wib.36.2015.01.08.20.15.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jan 2015 20:15:11 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: page_counter: pull "-1" handling out of page_counter_memparse()
Date: Thu,  8 Jan 2015 23:15:03 -0500
Message-Id: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

It was convenient to have the generic function handle it, as all
callsites agreed.  Subsequent patches will add new user interfaces
that do not want to support the "-1" special string.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/hugetlb_cgroup.c       | 10 +++++++---
 mm/memcontrol.c           | 20 ++++++++++++++------
 mm/page_counter.c         |  6 ------
 net/ipv4/tcp_memcontrol.c | 10 +++++++---
 4 files changed, 28 insertions(+), 18 deletions(-)

diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 037e1c00a5b7..ee3fc80adba1 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -279,9 +279,13 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		return -EINVAL;
 
 	buf = strstrip(buf);
-	ret = page_counter_memparse(buf, &nr_pages);
-	if (ret)
-		return ret;
+	if (!strcmp(buf, "-1")) {
+		nr_pages = PAGE_COUNTER_MAX;
+	} else {
+		ret = page_counter_memparse(buf, &nr_pages);
+		if (ret)
+			return ret;
+	}
 
 	idx = MEMFILE_IDX(of_cft(of)->private);
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 202e3862d564..20486da85750 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3400,9 +3400,13 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 	int ret;
 
 	buf = strstrip(buf);
-	ret = page_counter_memparse(buf, &nr_pages);
-	if (ret)
-		return ret;
+	if (!strcmp(buf, "-1")) {
+		nr_pages = PAGE_COUNTER_MAX;
+	} else {
+		ret = page_counter_memparse(buf, &nr_pages);
+		if (ret)
+			return ret;
+	}
 
 	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
@@ -3768,9 +3772,13 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	unsigned long usage;
 	int i, size, ret;
 
-	ret = page_counter_memparse(args, &threshold);
-	if (ret)
-		return ret;
+	if (!strcmp(args, "-1")) {
+		threshold = PAGE_COUNTER_MAX;
+	} else {
+		ret = page_counter_memparse(args, &threshold);
+		if (ret)
+			return ret;
+	}
 
 	mutex_lock(&memcg->thresholds_lock);
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
index a009574fbba9..0d4f9daf68bd 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -173,15 +173,9 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
  */
 int page_counter_memparse(const char *buf, unsigned long *nr_pages)
 {
-	char unlimited[] = "-1";
 	char *end;
 	u64 bytes;
 
-	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
-		*nr_pages = PAGE_COUNTER_MAX;
-		return 0;
-	}
-
 	bytes = memparse(buf, &end);
 	if (*end != '\0')
 		return -EINVAL;
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 272327134a1b..a9d9fcb4dc25 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -120,9 +120,13 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	switch (of_cft(of)->private) {
 	case RES_LIMIT:
 		/* see memcontrol.c */
-		ret = page_counter_memparse(buf, &nr_pages);
-		if (ret)
-			break;
+		if (!strcmp(buf, "-1")) {
+			nr_pages = PAGE_COUNTER_MAX;
+		} else {
+			ret = page_counter_memparse(buf, &nr_pages);
+			if (ret)
+				break;
+		}
 		mutex_lock(&tcp_limit_mutex);
 		ret = tcp_update_limit(memcg, nr_pages);
 		mutex_unlock(&tcp_limit_mutex);
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
