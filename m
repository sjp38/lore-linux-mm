Return-Path: <SRS0=O33Z=PL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFA28C43612
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 16:12:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7229E2184B
	for <linux-mm@archiver.kernel.org>; Thu,  3 Jan 2019 16:12:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="VWoBuwQy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7229E2184B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B92AC8E0083; Thu,  3 Jan 2019 11:12:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B69AD8E0002; Thu,  3 Jan 2019 11:12:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A30858E0083; Thu,  3 Jan 2019 11:12:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7239C8E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 11:12:17 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id y139so20077859vsc.14
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 08:12:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=98ssgJgNVrdcIWbb0R8XUTymywCcz8Wk3LA2x5SCzNQ=;
        b=mM2sNsE49NSvtuLDu2hVMoXcMEI2lbnO3FuWtu1Yb95t+2HbT/JdS5FK48pT2tPa7w
         YiHCkpd3B711lHr4mk+/6iRD0PFIixaTHOQymc/biDptux3Y1AQIGupuwXWBaW9t95dD
         20I/787n/Hp6wDGSxPhmkt7MaECgrHjDq7cPvEMbyj8TsdFNXzF0EiiPiNQz9g8bjjH7
         DsO3VE54HCmtVkBJpSBdcT7bIqDLQcjBRKlKvkZeIdXYdoA3E2SEF2MditSV7SMR6KCr
         JxW/tQ6V5uDnkG00y8dmrOJwB3yoO69Ukb7eESnBC2Ir0sP7z2fhmVSGWY1xTst1LTRd
         ru5w==
X-Gm-Message-State: AJcUukfw3+hFsZwrBTKeG4ABWuNE4ZcbISewc4b/3bpBLfvXycQMTm/2
	7qdTH7PY69LYKqggm0nwWM/2O5/NYFwZvSHnRawyAT2VpH/py1ucy8d27XfMCrkdjpCVlAhj90C
	qTsPZXA7EKfiUPTHivsz36tR1f24rWG0gimge8UkaNsVT0gUCqo9hYkVPKY+zjaV5IPiJ/gswPF
	yY8lYR/BIztKoizm/hbueStfvQACRjxmIWLpA1VkwWYM8qT/Eci8ontuDT244ophBYADzi/iqBE
	gsREeePMIuTtsOjgfEz7zRMCcrm6LY7LRyhYuYV3XpZxIrjcOjPxz0LowcHkub258xaO93nCjiw
	QV/g8U6JV93spT7qV5hR5XQYSHFjD++A7LnjGiTDlM7qCTfVOAo5LQlBz3AwD47BqbEVNB2Gojq
	Y
X-Received: by 2002:a1f:a902:: with SMTP id s2mr17052651vke.2.1546531937024;
        Thu, 03 Jan 2019 08:12:17 -0800 (PST)
X-Received: by 2002:a1f:a902:: with SMTP id s2mr17052604vke.2.1546531935481;
        Thu, 03 Jan 2019 08:12:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546531935; cv=none;
        d=google.com; s=arc-20160816;
        b=ePdhUzdQWnrTDJcx2oIbYd0QWjvPVgS0UcHIVp6kw8vrkMqG+sMJ8NJSZDdHlJfOBg
         AXd8wWHD5TynFQ798ANPmndRVqD3Tb40sal8Fc1+2KJ948YNTLYL7apWJOveXw4sUmw+
         g+45ucNfCVN891nldDrkdMOtoTlU9bnvfddFzHWVLS9s3KFSL2qrwiRfbev2Jw1B4i7r
         cxygTkEt7OinizGrjjjdsQK/ntAjN8o+9EPDQJMSYoHc4ejyHWm4AaWL5QTm4kPSHX2y
         LNo6U7eUTQgJ2ZHx0TQwdvR3X1Uoq5IL2NrwV3paxpWUM5x5NG1ANYIB65BuEjHjjq79
         DeZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=98ssgJgNVrdcIWbb0R8XUTymywCcz8Wk3LA2x5SCzNQ=;
        b=RW4cLT/OkS+5h5XmAj22XMFdPHCy4RCSwvOuC/722hxa1ItLkJJEVjYGMkk8xfOoPE
         A6A9GPIEjBtRUyG3lhNq71S4cq7jIxrHiFc71ZKgSeuSlbZCpm8O/Q2/2IHS1JS6hySe
         f0YMDWSsjPo4G+RBraVafbuRJLL8Yf8yZebhePr+gsORcjS7TfWGpKMip3ebpZQ4qCNl
         a3DC8U4fxrBwJ9qYOCzeHQtlMw1kO0iXvRBhbB0+NVwEGN1HOZrmxUttcsaQX9YN3gYS
         TThnjIBIcl/khlG6YAzgCllnXtisZDipYiHtLI1mFgryJrHbKKepAot8o02qvP13UrnR
         PuBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VWoBuwQy;
       spf=pass (google.com: domain of 3xzquxagkcggyngqkkrhmuumrk.iusrotad-ssqbgiq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XzQuXAgKCGgYNGQKKRHMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id j81sor36373750vsj.14.2019.01.03.08.12.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 Jan 2019 08:12:15 -0800 (PST)
Received-SPF: pass (google.com: domain of 3xzquxagkcggyngqkkrhmuumrk.iusrotad-ssqbgiq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=VWoBuwQy;
       spf=pass (google.com: domain of 3xzquxagkcggyngqkkrhmuumrk.iusrotad-ssqbgiq.uxm@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XzQuXAgKCGgYNGQKKRHMUUMRK.IUSROTad-SSQbGIQ.UXM@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=98ssgJgNVrdcIWbb0R8XUTymywCcz8Wk3LA2x5SCzNQ=;
        b=VWoBuwQyVsQNAjbV/UhX5Q61Ii1KQDsZkenC3siRY4CxuJIq+T3Eys1CuFctGjP00y
         4qETN8//DhdIX7O1O7vYv1M6K1yCNT9RZFVbt+P9AM7rIWNKooI/bu1rwAhrYWfqhMAm
         vCOB4ZOjNrBGkKLz7y40gQM2FgAUpHPpR2VNFcWH5ldbMbqNrXdbIU4yCxZXttKy/t8V
         t/JdfHNRhdObxG+j13qybvwPyJNhglbZPS3klGpPShV/O4fGrujQXcwj4aW+nHBh+oWL
         3lHjonoJ7lWIDZVSjA9AuQN/JRVMaGIsjPThTPsrtRPW4NZkrz4VkEWq1ABHANd6Qfug
         HNrw==
X-Google-Smtp-Source: AFSGD/W6n1AearGbzHf48QnJay0a3HH+E/jICjjtnhfPzmZRWHCyQLMsbXZVx2T1PveMuvSR84GrSdoF9Na/5A==
X-Received: by 2002:a67:460f:: with SMTP id t15mr41082505vsa.0.1546531935105;
 Thu, 03 Jan 2019 08:12:15 -0800 (PST)
Date: Thu,  3 Jan 2019 08:12:03 -0800
Message-Id: <20190103161203.162375-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.20.1.415.g653613c723-goog
Subject: [PATCH v2] memcg: localize memcg_kmem_enabled() check
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, 
	Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190103161203.JxqloirHFtGuKVi7Qk6lFmHAqCm8VqJ_cgx5zvUOf_I@z>

Move the memcg_kmem_enabled() checks into memcg kmem charge/uncharge
functions, so, the users don't have to explicitly check that condition.
This is purely code cleanup patch without any functional change. Only
the order of checks in memcg_charge_slab() can potentially be changed
but the functionally it will be same. This should not matter as
memcg_charge_slab() is not in the hot path.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
Changelog since v1:
- Fixed the build when CONFIG_MEMCG is not set

 fs/pipe.c                  |  3 +--
 include/linux/memcontrol.h | 37 +++++++++++++++++++++++++++++++++----
 mm/memcontrol.c            | 16 ++++++++--------
 mm/page_alloc.c            |  4 ++--
 mm/slab.h                  |  4 ----
 5 files changed, 44 insertions(+), 20 deletions(-)

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
index 83ae11cbd12c..b0eb29ea0d9c 100644
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
@@ -1325,6 +1345,15 @@ static inline void memcg_kmem_uncharge(struct page *page, int order)
 {
 }
 
+static inline int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order)
+{
+	return 0;
+}
+
+static inline void __memcg_kmem_uncharge(struct page *page, int order)
+{
+}
+
 #define for_each_memcg_cache_index(_idx)	\
 	for (; NULL; )
 
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

