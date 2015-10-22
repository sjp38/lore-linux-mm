Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id D80966B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 00:22:00 -0400 (EDT)
Received: by wicfx6 with SMTP id fx6so118086795wic.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 21:22:00 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id db5si5631791wjb.82.2015.10.21.21.21.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Oct 2015 21:21:59 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 1/8] mm: page_counter: let page_counter_try_charge() return bool
Date: Thu, 22 Oct 2015 00:21:29 -0400
Message-Id: <1445487696-21545-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Vladimir Davydov <vdavydov@virtuozzo.com>, Tejun Heo <tj@kernel.org>, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

page_counter_try_charge() currently returns 0 on success and -ENOMEM
on failure, which is surprising behavior given the function name.

Make it follow the expected pattern of try_stuff() functions that
return a boolean true to indicate success, or false for failure.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 include/linux/page_counter.h |  6 +++---
 mm/hugetlb_cgroup.c          |  3 ++-
 mm/memcontrol.c              | 11 +++++------
 mm/page_counter.c            | 14 +++++++-------
 4 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
index 17fa4f8..7e62920 100644
--- a/include/linux/page_counter.h
+++ b/include/linux/page_counter.h
@@ -36,9 +36,9 @@ static inline unsigned long page_counter_read(struct page_counter *counter)
 
 void page_counter_cancel(struct page_counter *counter, unsigned long nr_pages);
 void page_counter_charge(struct page_counter *counter, unsigned long nr_pages);
-int page_counter_try_charge(struct page_counter *counter,
-			    unsigned long nr_pages,
-			    struct page_counter **fail);
+bool page_counter_try_charge(struct page_counter *counter,
+			     unsigned long nr_pages,
+			     struct page_counter **fail);
 void page_counter_uncharge(struct page_counter *counter, unsigned long nr_pages);
 int page_counter_limit(struct page_counter *counter, unsigned long limit);
 int page_counter_memparse(const char *buf, const char *max,
diff --git a/mm/hugetlb_cgroup.c b/mm/hugetlb_cgroup.c
index 6a44263..d8fb10d 100644
--- a/mm/hugetlb_cgroup.c
+++ b/mm/hugetlb_cgroup.c
@@ -186,7 +186,8 @@ again:
 	}
 	rcu_read_unlock();
 
-	ret = page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter);
+	if (!page_counter_try_charge(&h_cg->hugepage[idx], nr_pages, &counter))
+		ret = -ENOMEM;
 	css_put(&h_cg->css);
 done:
 	*ptr = h_cg;
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c71fe40..a8ccdbc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2018,8 +2018,8 @@ retry:
 		return 0;
 
 	if (!do_swap_account ||
-	    !page_counter_try_charge(&memcg->memsw, batch, &counter)) {
-		if (!page_counter_try_charge(&memcg->memory, batch, &counter))
+	    page_counter_try_charge(&memcg->memsw, batch, &counter)) {
+		if (page_counter_try_charge(&memcg->memory, batch, &counter))
 			goto done_restock;
 		if (do_swap_account)
 			page_counter_uncharge(&memcg->memsw, batch);
@@ -2383,14 +2383,13 @@ int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 {
 	unsigned int nr_pages = 1 << order;
 	struct page_counter *counter;
-	int ret = 0;
+	int ret;
 
 	if (!memcg_kmem_is_active(memcg))
 		return 0;
 
-	ret = page_counter_try_charge(&memcg->kmem, nr_pages, &counter);
-	if (ret)
-		return ret;
+	if (!page_counter_try_charge(&memcg->kmem, nr_pages, &counter))
+		return -ENOMEM;
 
 	ret = try_charge(memcg, gfp, nr_pages);
 	if (ret) {
diff --git a/mm/page_counter.c b/mm/page_counter.c
index 11b4bed..7c6a63d 100644
--- a/mm/page_counter.c
+++ b/mm/page_counter.c
@@ -56,12 +56,12 @@ void page_counter_charge(struct page_counter *counter, unsigned long nr_pages)
  * @nr_pages: number of pages to charge
  * @fail: points first counter to hit its limit, if any
  *
- * Returns 0 on success, or -ENOMEM and @fail if the counter or one of
- * its ancestors has hit its configured limit.
+ * Returns %true on success, or %false and @fail if the counter or one
+ * of its ancestors has hit its configured limit.
  */
-int page_counter_try_charge(struct page_counter *counter,
-			    unsigned long nr_pages,
-			    struct page_counter **fail)
+bool page_counter_try_charge(struct page_counter *counter,
+			     unsigned long nr_pages,
+			     struct page_counter **fail)
 {
 	struct page_counter *c;
 
@@ -99,13 +99,13 @@ int page_counter_try_charge(struct page_counter *counter,
 		if (new > c->watermark)
 			c->watermark = new;
 	}
-	return 0;
+	return true;
 
 failed:
 	for (c = counter; c != *fail; c = c->parent)
 		page_counter_cancel(c, nr_pages);
 
-	return -ENOMEM;
+	return false;
 }
 
 /**
-- 
2.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
