Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f179.google.com (mail-we0-f179.google.com [74.125.82.179])
	by kanga.kvack.org (Postfix) with ESMTP id 96E916B0039
	for <linux-mm@kvack.org>; Wed, 24 Sep 2014 11:43:23 -0400 (EDT)
Received: by mail-we0-f179.google.com with SMTP id u56so6412513wes.38
        for <linux-mm@kvack.org>; Wed, 24 Sep 2014 08:43:22 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id dt6si20992wib.78.2014.09.24.08.43.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Sep 2014 08:43:22 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: hugetlb_controller: convert to lockless page counters
Date: Wed, 24 Sep 2014 11:43:09 -0400
Message-Id: <1411573390-9601-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
References: <1411573390-9601-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@sr71.net>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Abandon the spinlock-protected byte counters in favor of the unlocked
page counters in the hugetlb controller as well.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/cgroups/hugetlb.txt |   2 +-
 include/linux/hugetlb_cgroup.h    |   1 -
 init/Kconfig                      |   3 +-
 mm/hugetlb_cgroup.c               | 104 +++++++++++++++++++++-----------------
 4 files changed, 62 insertions(+), 48 deletions(-)

diff --git a/Documentation/cgroups/hugetlb.txt b/Documentation/cgroups/hugetlb.txt
index a9faaca1f029..106245c3aecc 100644
--- a/Documentation/cgroups/hugetlb.txt
+++ b/Documentation/cgroups/hugetlb.txt
@@ -29,7 +29,7 @@ Brief summary of control files
 
  hugetlb.<hugepagesize>.limit_in_bytes     # set/show limit of "hugepagesize" hugetlb usage
  hugetlb.<hugepagesize>.max_usage_in_bytes # show max "hugepagesize" hugetlb  usage recorded
- hugetlb.<hugepagesize>.usage_in_bytes     # show current res_counter usage for "hugepagesize" hugetlb
+ hugetlb.<hugepagesize>.usage_in_bytes     # show current usage for "hugepagesize" hugetlb
  hugetlb.<hugepagesize>.failcnt		   # show the number of allocation failure due to HugeTLB limit
 
 For a system supporting two hugepage size (16M and 16G) the control
diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
index 0129f89cf98d..bcc853eccc85 100644
--- a/include/linux/hugetlb_cgroup.h
+++ b/include/linux/hugetlb_cgroup.h
@@ -16,7 +16,6 @@
 #define _LINUX_HUGETLB_CGROUP_H
 
 #include <linux/mmdebug.h>
-#include <linux/res_counter.h>
 
 struct hugetlb_cgroup;
 /*
diff --git a/init/Kconfig b/init/Kconfig
index 88b56940cb9e..eddec767b7ee 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1056,7 +1056,8 @@ config MEMCG_KMEM
 
 config CGROUP_HUGETLB
 	bool "HugeTLB Resource Controller for Control Groups"
-	depends on RESOURCE_COUNTERS && HUGETLB_PAGE
+	depends on HUGETLB_PAGE
+	select PAGE_COUNTER
 	default n
 	help
 	  Provides a cgroup Resource Controller for HugeTLB pages.
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index a67c26e0f360..45b6aba96d89 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -14,6 +14,7 @@
  */
 
 #include <linux/cgroup.h>
+#include <linux/page_counter.h>
 #include <linux/slab.h>
 #include <linux/hugetlb.h>
 #include <linux/hugetlb_cgroup.h>
@@ -23,7 +24,7 @@ struct hugetlb_cgroup {
 	/*
 	 * the counter to account for hugepages from hugetlb.
 	 */
-	struct res_counter hugepage[HUGE_MAX_HSTATE];
+	struct page_counter hugepage[HUGE_MAX_HSTATE];
 };
 
 #define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
@@ -60,7 +61,7 @@ static inline bool hugetlb_cgroup_have_usage(struct hugetlb_cgroup *h_cg)
 	int idx;
 
 	for (idx = 0; idx < hugetlb_max_hstate; idx++) {
-		if ((res_counter_read_u64(&h_cg->hugepage[idx], RES_USAGE)) > 0)
+		if (page_counter_read(&h_cg->hugepage[idx]))
 			return true;
 	}
 	return false;
@@ -79,12 +80,12 @@ hugetlb_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 
 	if (parent_h_cgroup) {
 		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			res_counter_init(&h_cgroup->hugepage[idx],
-					 &parent_h_cgroup->hugepage[idx]);
+			page_counter_init(&h_cgroup->hugepage[idx],
+					  &parent_h_cgroup->hugepage[idx]);
 	} else {
 		root_h_cgroup = h_cgroup;
 		for (idx = 0; idx < HUGE_MAX_HSTATE; idx++)
-			res_counter_init(&h_cgroup->hugepage[idx], NULL);
+			page_counter_init(&h_cgroup->hugepage[idx], NULL);
 	}
 	return &h_cgroup->css;
 }
@@ -108,9 +109,8 @@ static void hugetlb_cgroup_css_free(struct cgroup_subsys_state *css)
 static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
 				       struct page *page)
 {
-	int csize;
-	struct res_counter *counter;
-	struct res_counter *fail_res;
+	unsigned int nr_pages;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *page_hcg;
 	struct hugetlb_cgroup *parent = parent_hugetlb_cgroup(h_cg);
 
@@ -123,15 +123,15 @@ static void hugetlb_cgroup_move_parent(int idx, struct hugetlb_cgroup *h_cg,
 	if (!page_hcg || page_hcg != h_cg)
 		goto out;
 
-	csize = PAGE_SIZE << compound_order(page);
+	nr_pages = 1 << compound_order(page);
 	if (!parent) {
 		parent = root_h_cgroup;
 		/* root has no limit */
-		res_counter_charge_nofail(&parent->hugepage[idx],
-					  csize, &fail_res);
+		page_counter_charge(&parent->hugepage[idx], nr_pages);
 	}
 	counter = &h_cg->hugepage[idx];
-	res_counter_uncharge_until(counter, counter->parent, csize);
+	/* Take the pages off the local counter */
+	page_counter_cancel(counter, nr_pages);
 
 	set_hugetlb_cgroup(page, parent);
 out:
@@ -166,9 +166,8 @@ int hugetlb_cgroup_charge_cgroup(int idx, unsigned long nr_pages,
 				 struct hugetlb_cgroup **ptr)
 {
 	int ret = 0;
-	struct res_counter *fail_res;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = NULL;
-	unsigned long csize = nr_pages * PAGE_SIZE;
 
 	if (hugetlb_cgroup_disabled())
 		goto done;
@@ -187,7 +186,7 @@ again:
 	}
 	rcu_read_unlock();
 
-	ret = res_counter_charge(&h_cg->hugepage[idx], csize, &fail_res);
+	ret = page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter);
 	css_put(&h_cg->css);
 done:
 	*ptr = h_cg;
@@ -213,7 +212,6 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 				  struct page *page)
 {
 	struct hugetlb_cgroup *h_cg;
-	unsigned long csize = nr_pages * PAGE_SIZE;
 
 	if (hugetlb_cgroup_disabled())
 		return;
@@ -222,61 +220,77 @@ void hugetlb_cgroup_uncharge_page(int idx, unsigned long nr_pages,
 	if (unlikely(!h_cg))
 		return;
 	set_hugetlb_cgroup(page, NULL);
-	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
 	return;
 }
 
 void hugetlb_cgroup_uncharge_cgroup(int idx, unsigned long nr_pages,
 				    struct hugetlb_cgroup *h_cg)
 {
-	unsigned long csize = nr_pages * PAGE_SIZE;
-
 	if (hugetlb_cgroup_disabled() || !h_cg)
 		return;
 
 	if (huge_page_order(&hstates[idx]) < HUGETLB_CGROUP_MIN_ORDER)
 		return;
 
-	res_counter_uncharge(&h_cg->hugepage[idx], csize);
+	page_counter_uncharge(&h_cg->hugepage[idx], nr_pages);
 	return;
 }
 
+enum {
+	RES_USAGE,
+	RES_LIMIT,
+	RES_MAX_USAGE,
+	RES_FAILCNT,
+};
+
 static u64 hugetlb_cgroup_read_u64(struct cgroup_subsys_state *css,
 				   struct cftype *cft)
 {
-	int idx, name;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(css);
 
-	idx = MEMFILE_IDX(cft->private);
-	name = MEMFILE_ATTR(cft->private);
+	counter = &h_cg->hugepage[MEMFILE_IDX(cft->private)];
 
-	return res_counter_read_u64(&h_cg->hugepage[idx], name);
+	switch (MEMFILE_ATTR(cft->private)) {
+	case RES_USAGE:
+		return (u64)page_counter_read(counter) * PAGE_SIZE;
+	case RES_LIMIT:
+		return (u64)counter->limit * PAGE_SIZE;
+	case RES_MAX_USAGE:
+		return (u64)counter->watermark * PAGE_SIZE;
+	case RES_FAILCNT:
+		return counter->failcnt;
+	default:
+		BUG();
+	}
 }
 
+static DEFINE_MUTEX(hugetlb_limit_mutex);
+
 static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 				    char *buf, size_t nbytes, loff_t off)
 {
-	int idx, name, ret;
-	unsigned long long val;
+	int ret, idx;
+	unsigned long nr_pages;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
 
+	if (hugetlb_cgroup_is_root(h_cg)) /* Can't set limit on root */
+		return -EINVAL;
+
 	buf = strstrip(buf);
+	ret = page_counter_memparse(buf, &nr_pages);
+	if (ret)
+		return ret;
+
 	idx = MEMFILE_IDX(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_LIMIT:
-		if (hugetlb_cgroup_is_root(h_cg)) {
-			/* Can't set limit on root */
-			ret = -EINVAL;
-			break;
-		}
-		/* This function does all necessary parse...reuse it */
-		ret = res_counter_memparse_write_strategy(buf, &val);
-		if (ret)
-			break;
-		val = ALIGN(val, 1ULL << huge_page_shift(&hstates[idx]));
-		ret = res_counter_set_limit(&h_cg->hugepage[idx], val);
+		nr_pages = ALIGN(nr_pages, 1UL<<huge_page_order(&hstates[idx]));
+		mutex_lock(&hugetlb_limit_mutex);
+		ret = page_counter_limit(&h_cg->hugepage[idx], nr_pages);
+		mutex_unlock(&hugetlb_limit_mutex);
 		break;
 	default:
 		ret = -EINVAL;
@@ -288,18 +302,18 @@ static ssize_t hugetlb_cgroup_write(struct kernfs_open_file *of,
 static ssize_t hugetlb_cgroup_reset(struct kernfs_open_file *of,
 				    char *buf, size_t nbytes, loff_t off)
 {
-	int idx, name, ret = 0;
+	int ret = 0;
+	struct page_counter *counter;
 	struct hugetlb_cgroup *h_cg = hugetlb_cgroup_from_css(of_css(of));
 
-	idx = MEMFILE_IDX(of_cft(of)->private);
-	name = MEMFILE_ATTR(of_cft(of)->private);
+	counter = &h_cg->hugepage[MEMFILE_IDX(of_cft(of)->private)];
 
-	switch (name) {
+	switch (MEMFILE_ATTR(of_cft(of)->private)) {
 	case RES_MAX_USAGE:
-		res_counter_reset_max(&h_cg->hugepage[idx]);
+		page_counter_reset_watermark(counter);
 		break;
 	case RES_FAILCNT:
-		res_counter_reset_failcnt(&h_cg->hugepage[idx]);
+		counter->failcnt = 0;
 		break;
 	default:
 		ret = -EINVAL;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
