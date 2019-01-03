Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E5BC43612
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 00:31:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A83BC2073F
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 00:31:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HuGgvOMl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A83BC2073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FAC78E0050; Wed,  2 Jan 2019 19:31:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A8268E0002; Wed,  2 Jan 2019 19:31:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0709D8E0050; Wed,  2 Jan 2019 19:31:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF2B38E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 19:31:36 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id x3so34427580itb.6
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 16:31:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=HDV6bRTeM31dJ5NVRvjDVymoFmv0ZgrAy5+J+74imwM=;
        b=moFbhiNhH5wA7KCEFgzHOY1HATFMdeRqZkpbQkwG7q1q+YAy0rzrHhKTrk18m8pLYL
         W5svkONE2qG3MiUU+JKxdyZTvvfQ/REwai/F3PB9eq+LPMb+AKSpJNOT3/fdeK5eLvbp
         sB6f4+cDVEldi//mK0D//nxV5SZwENW7RRXR+Oh6Q5te/C/RvFjQGiST3FZ+0kJawozH
         2PfJcEk/4lG+XQoDmZwIipg1CPHhLm6WtOlcfXS7XFt67OjkXKeD+H8MMog6eFPQQEIH
         O4Hy4Y587wCl76IBOxgRCaWzKQeUco7COiuJsbzaKAhH2sHldZEdAFKaozbC4M+eYRdo
         uabw==
X-Gm-Message-State: AJcUukc/PXJb383FkLQObclf49nhehjWA01dupZOblPc0mxmxF3ufwVa
	pc1Cz4A81dbYekSHBkyzAHL3AS3hhrDXARUetfONfRu2AtFEZqPk1aF8m48bYHQwEwN3TF9V4ER
	Ae6FXeLnKx7hPxYdwN8U7aMZ2+jkIfd0hgRFC5miN/ABE/OxOwUqf7U6ZS5CAj12jZKXXNgTzKI
	C4/hbu9IaPIYLP2T5MObQnGPxx5FCoEpLKhgQ1UpX7c6bFAS4FAjJb4j5FtWAUmljXXB41ht/Uo
	uprfJghpjATSJV0P+Am8OcdloGkj6lnmq8g7+rde+NymVjVnJPp0gAu8IJNptwdttkpBbn8L+bg
	qiAba+B46ljBg+wAFkwro/xUkUf11fg2QL2bgLu18EsxgtnPvNJxNebNyAm4cFMQfhGUWN6btop
	1
X-Received: by 2002:a6b:c544:: with SMTP id v65mr32459562iof.118.1546475496594;
        Wed, 02 Jan 2019 16:31:36 -0800 (PST)
X-Received: by 2002:a6b:c544:: with SMTP id v65mr32459533iof.118.1546475495735;
        Wed, 02 Jan 2019 16:31:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546475495; cv=none;
        d=google.com; s=arc-20160816;
        b=n8HcoYejtSO7640N7i3v1QsuJWU4r9exnuqx8S4bDe8WqaR1vKNx5opLsshBB9UYgj
         aceA9NLjQBDrqDb503FuygGnfnZkptqKHfpxKBYQ9vE/5OCC8wCXn0pq8QFOw8Y1lYMW
         l3fk5KzHb0mWd3MMAyZFZOCDwFrYseNd90jM5YAhmJIEcFmqNkRc9MDblkLeublisA01
         mUpxgd3lydQN7w+jj85tIx3B9xYULMmJQWncE3/7NPd5iB/WQVnE8v5pYbF0UODN3664
         HJ0Wf0+UPvwYAFOci1me3FjQ5S5vR2661YSIkDOJuhdTGrhVtNTkCI0+rhKF6C5cLMlZ
         aPxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=HDV6bRTeM31dJ5NVRvjDVymoFmv0ZgrAy5+J+74imwM=;
        b=YqvQPYnDE6EgOhPl+ZRcneGmAQ/X4+bcaBWzIqyy47Ha9BLSYJLJcAmjmuBN9KOIqw
         Kd/u0LNJ8d/FR0MCfegHmRM5jYEcQdaeUSaj1qDE8EFE9+6ogthkWtVaG972LofSvBba
         NMqn9N1cHWAcpxeGcF9F8j2Y27gfaouw4pCqhD22ZUfedrDhP5Of7809R5/eD5QQVzd/
         j8eW96tvJ1j8u2JkhGytc8Y5LYP9pyaZcogCo5rA9PnywlwQ7WI0UtmTXYq93Gsz4QGC
         uBqP+duSGLF4m1n+jSc+yE/z0UCxZQjyYGv6MMiKEP/epAZKUR26u0h/w/n/vgizEag6
         N7mA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HuGgvOMl;
       spf=pass (google.com: domain of 35lctxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35lctXAgKCDMhWPZTTaQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id e201sor35891092ite.28.2019.01.02.16.31.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 16:31:35 -0800 (PST)
Received-SPF: pass (google.com: domain of 35lctxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HuGgvOMl;
       spf=pass (google.com: domain of 35lctxagkcdmhwpzttaqvddvat.rdbaxcjm-bbzkprz.dgv@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35lctXAgKCDMhWPZTTaQVddVaT.RdbaXcjm-bbZkPRZ.dgV@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=HDV6bRTeM31dJ5NVRvjDVymoFmv0ZgrAy5+J+74imwM=;
        b=HuGgvOMlODWlVV0hrvHa+zm6Vizkv1wtWe4Ggo8yFywSfFUaJe/zU5eWo0Nb0dtMln
         AIp1FuGObkjtff9BqiEwR1w9lW4vRNOA6Ld4H2iRKQ5M+BfnYJ4c6YM4ZAqgOSSybdDm
         rcmJpDz3MGrLCa6yL1+kWJDGDqsoa8+P+YZ9PGnS1U8JxV4hfjNIJSKK4fnUXcfFJJDt
         Sx5uvFDZSLvqfJgrigsNmh13wWy3ZhNDeTJnyMg7PXPQR1b6A8Ccv5syH9SIf9MEcQqO
         t9U93PBWacBIU2FhwWDgstJRZp/E4qURmnkZG1ee6nUwuEOdz6RgnLYe43jbYAvMFgGw
         scsw==
X-Google-Smtp-Source: ALg8bN7XI9bnxlLzeYGzBZXtvEXxqzIVleQYnv2+DSRbbDoZHqMErTolDUd55Ia2sKYasXTSbUE2csuYcJpw5w==
X-Received: by 2002:a24:a94:: with SMTP id 142mr33111676itw.15.1546475494416;
 Wed, 02 Jan 2019 16:31:34 -0800 (PST)
Date: Wed,  2 Jan 2019 16:31:29 -0800
Message-Id: <20190103003129.186555-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH] memcg: localize memcg_kmem_enabled() check
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@suse.com>, 
	Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103003129.UtsBEloX3eOl2NfQpdOqZPs5WQQeyc68bLnXseBug_o@z>

Move the memcg_kmem_enabled() checks into memcg kmem charge/uncharge
functions, so, the users don't have to explicitly check that condition.
This is purely code cleanup patch without any functional change. Only
the order of checks in memcg_charge_slab() can potentially be changed
but the functionally it will be same. This should not matter as
memcg_charge_slab() is not in the hot path.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 fs/pipe.c                  |  3 +--
 include/linux/memcontrol.h | 28 ++++++++++++++++++++++++----
 mm/memcontrol.c            | 16 ++++++++--------
 mm/page_alloc.c            |  4 ++--
 mm/slab.h                  |  4 ----
 5 files changed, 35 insertions(+), 20 deletions(-)

diff --git a/fs/pipe.c b/fs/pipe.c
index bdc5d3c0977d..51d5fd8840ab 100644
--- a/fs/pipe.c
+++ b/fs/pipe.c
@@ -140,8 +140,7 @@ static int anon_pipe_buf_steal(struct pipe_inode_info *pipe,
 	struct page *page = buf->page;
 
 	if (page_count(page) == 1) {
-		if (memcg_kmem_enabled())
-			memcg_kmem_uncharge(page, 0);
+		memcg_kmem_uncharge(page, 0);
 		__SetPageLocked(page);
 		return 0;
 	}
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 83ae11cbd12c..e264d5c28781 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1273,12 +1273,12 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
-int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
-			    struct mem_cgroup *memcg);
 
 #ifdef CONFIG_MEMCG_KMEM
-int memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
-void memcg_kmem_uncharge(struct page *page, int order);
+int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
+void __memcg_kmem_uncharge(struct page *page, int order);
+int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
+			      struct mem_cgroup *memcg);
 
 extern struct static_key_false memcg_kmem_enabled_key;
 extern struct workqueue_struct *memcg_kmem_cache_wq;
@@ -1300,6 +1300,26 @@ static inline bool memcg_kmem_enabled(void)
 	return static_branch_unlikely(&memcg_kmem_enabled_key);
 }
 
+static inline int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+{
+	if (memcg_kmem_enabled())
+		return __memcg_kmem_charge(page, gfp, order);
+	return 0;
+}
+
+static inline void memcg_kmem_uncharge(struct page *page, int order)
+{
+	if (memcg_kmem_enabled())
+		__memcg_kmem_uncharge(page, order);
+}
+
+static inline int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp,
+					  int order, struct mem_cgroup *memcg)
+{
+	if (memcg_kmem_enabled())
+		return __memcg_kmem_charge_memcg(page, gfp, order, memcg);
+	return 0;
+}
 /*
  * helper for accessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4afd5971f2d4..e8ca09920d71 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2557,7 +2557,7 @@ void memcg_kmem_put_cache(struct kmem_cache *cachep)
 }
 
 /**
- * memcg_kmem_charge_memcg: charge a kmem page
+ * __memcg_kmem_charge_memcg: charge a kmem page
  * @page: page to charge
  * @gfp: reclaim mode
  * @order: allocation order
@@ -2565,7 +2565,7 @@ void memcg_kmem_put_cache(struct kmem_cache *cachep)
  *
  * Returns 0 on success, an error code on failure.
  */
-int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
+int __memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 			    struct mem_cgroup *memcg)
 {
 	unsigned int nr_pages = 1 << order;
@@ -2588,24 +2588,24 @@ int memcg_kmem_charge_memcg(struct page *page, gfp_t gfp, int order,
 }
 
 /**
- * memcg_kmem_charge: charge a kmem page to the current memory cgroup
+ * __memcg_kmem_charge: charge a kmem page to the current memory cgroup
  * @page: page to charge
  * @gfp: reclaim mode
  * @order: allocation order
  *
  * Returns 0 on success, an error code on failure.
  */
-int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 {
 	struct mem_cgroup *memcg;
 	int ret = 0;
 
-	if (mem_cgroup_disabled() || memcg_kmem_bypass())
+	if (memcg_kmem_bypass())
 		return 0;
 
 	memcg = get_mem_cgroup_from_current();
 	if (!mem_cgroup_is_root(memcg)) {
-		ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
+		ret = __memcg_kmem_charge_memcg(page, gfp, order, memcg);
 		if (!ret)
 			__SetPageKmemcg(page);
 	}
@@ -2613,11 +2613,11 @@ int memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
 	return ret;
 }
 /**
- * memcg_kmem_uncharge: uncharge a kmem page
+ * __memcg_kmem_uncharge: uncharge a kmem page
  * @page: page to uncharge
  * @order: allocation order
  */
-void memcg_kmem_uncharge(struct page *page, int order)
+void __memcg_kmem_uncharge(struct page *page, int order)
 {
 	struct mem_cgroup *memcg = page->mem_cgroup;
 	unsigned int nr_pages = 1 << order;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0634fbdef078..d65c337d2257 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1053,7 +1053,7 @@ static __always_inline bool free_pages_prepare(struct page *page,
 	if (PageMappingFlags(page))
 		page->mapping = NULL;
 	if (memcg_kmem_enabled() && PageKmemcg(page))
-		memcg_kmem_uncharge(page, order);
+		__memcg_kmem_uncharge(page, order);
 	if (check_free)
 		bad += free_pages_check(page);
 	if (bad)
@@ -4667,7 +4667,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
-	    unlikely(memcg_kmem_charge(page, gfp_mask, order) != 0)) {
+	    unlikely(__memcg_kmem_charge(page, gfp_mask, order) != 0)) {
 		__free_pages(page, order);
 		page = NULL;
 	}
diff --git a/mm/slab.h b/mm/slab.h
index 4190c24ef0e9..cde51d7f631f 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -276,8 +276,6 @@ static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
 {
-	if (!memcg_kmem_enabled())
-		return 0;
 	if (is_root_cache(s))
 		return 0;
 	return memcg_kmem_charge_memcg(page, gfp, order, s->memcg_params.memcg);
@@ -286,8 +284,6 @@ static __always_inline int memcg_charge_slab(struct page *page,
 static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 						struct kmem_cache *s)
 {
-	if (!memcg_kmem_enabled())
-		return;
 	memcg_kmem_uncharge(page, order);
 }
 
-- 
2.20.1.415.g653613c723-goog

