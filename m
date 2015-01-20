Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id 36EF86B0074
	for <linux-mm@kvack.org>; Tue, 20 Jan 2015 10:32:08 -0500 (EST)
Received: by mail-we0-f173.google.com with SMTP id q58so38201952wes.4
        for <linux-mm@kvack.org>; Tue, 20 Jan 2015 07:32:07 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id gl9si11815419wjc.3.2015.01.20.07.32.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Jan 2015 07:32:07 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 1/2] mm: page_counter: pull "-1" handling out of page_counter_memparse()
Date: Tue, 20 Jan 2015 10:31:54 -0500
Message-Id: <1421767915-14232-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
References: <1421767915-14232-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The unified hierarchy interface for memory cgroups will no longer use
"-1" to mean maximum possible resource value.  In preparation for
this, make the string an argument and let the caller supply it.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_counter.h | 3 ++-
 mm/hugetlb_cgroup.c          | 2 +-
 mm/memcontrol.c              | 4 ++--
 mm/page_counter.c            | 7 ++++---
 net/ipv4/tcp_memcontrol.c    | 2 +-
 5 files changed, 10 insertions(+), 8 deletions(-)

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
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 037e1c00a5b7..6e0057439a46 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -279,7 +279,7 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 		return -EINVAL;
 
 	buf = strstrip(buf);
-	ret = page_counter_memparse(buf, &nr_pages);
+	ret = page_counter_memparse(buf, "-1", &nr_pages);
 	if (ret)
 		return ret;
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 05ad91cda22c..a3592a756ad9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3442,7 +3442,7 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
 	int ret;
 
 	buf = strstrip(buf);
-	ret = page_counter_memparse(buf, &nr_pages);
+	ret = page_counter_memparse(buf, "-1", &nr_pages);
 	if (ret)
 		return ret;
 
@@ -3814,7 +3814,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	unsigned long usage;
 	int i, size, ret;
 
-	ret = page_counter_memparse(args, &threshold);
+	ret = page_counter_memparse(args, "-1", &threshold);
 	if (ret)
 		return ret;
 
diff --git a/mm/page_counter.c b/mm/page_counter.c
index a009574fbba9..11b4beda14ba 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -166,18 +166,19 @@ int page_counter_limit(struct page_counter *counter, unsigned long limit)
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
-	char unlimited[] = "-1";
 	char *end;
 	u64 bytes;
 
-	if (!strncmp(buf, unlimited, sizeof(unlimited))) {
+	if (!strcmp(buf, max)) {
 		*nr_pages = PAGE_COUNTER_MAX;
 		return 0;
 	}
diff --git a/net/ipv4/tcp_memcontrol.c b/net/ipv4/tcp_memcontrol.c
index 272327134a1b..c2a75c6957a1 100644
--- a/net/ipv4/tcp_memcontrol.c
+++ b/net/ipv4/tcp_memcontrol.c
@@ -120,7 +120,7 @@ static ssize_t tcp_cgroup_write(struct kernfs_open_file *of,
 	switch (of_cft(of)->private) {
 	case RES_LIMIT:
 		/* see memcontrol.c */
-		ret = page_counter_memparse(buf, &nr_pages);
+		ret = page_counter_memparse(buf, "-1", &nr_pages);
 		if (ret)
 			break;
 		mutex_lock(&tcp_limit_mutex);
-- 
2.2.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
