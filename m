Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C253C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57FB9217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 03:57:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57FB9217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E7746B0007; Wed, 10 Apr 2019 23:57:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB2D36B0006; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D63B16B0007; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8436B0008
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 23:57:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so3554106pgk.9
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 20:57:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MLWynHGliv6scIgC4xX8HtX9K46TiIdNd3gqOe6+OLg=;
        b=lJi0l01tcXwRUr8yjybldmDSUJKdAs8A8EAnxhghF696LYjn+2qNJeLRIrIAiQy7wq
         J5F+eoAzK1jjjjvcQ9IDxVoxSc9sPmT95g1tSd4jt9FJUiUWRkFt0gdsHTRSdphBgVxb
         OSS5C6EaKij8m2H+2h+IS+dt1EnulOXxRH9+dZVqXtSL/oN6Y+0Z2TYSarF5L71HBBEu
         TUtHKwKOWlaQSrjQFzBgy7z8LfPFkan9c+8qA3Devc+IOxBODRjWgosc893z3GLt5hai
         XefPD+Dt03XGzuiUzUY6Y/SEjIT5MyJXv64oasFlhEw46ItBzgKsJcQEE2vLsmgQ3oDR
         c/sA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX/yzEybwxtFTal4iQcnKDxbPeuM9w70Ckmyyo5OUn6g5QcOWYk
	iZEjZSy3guCnACwELPLlv7gFE+ePUpV8tHpE1SG9l/XdC5w6lH2CA47v0BJgyWNAPnTPFzwm8li
	0NV3FHx311sukwRIa/5eh4gJ8YiDb2/FCDBGFlvJ4qIbZ+HKIVHlTmiMaywCfE+8FCA==
X-Received: by 2002:aa7:8d9a:: with SMTP id i26mr35425466pfr.220.1554955045902;
        Wed, 10 Apr 2019 20:57:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOL8Bn3zu5CgMgkxtCiFx79A9cIRfmzY17PF04qQjp4l3LbFZS9EeoQhVxC8+s1RK8xZv5
X-Received: by 2002:aa7:8d9a:: with SMTP id i26mr35425391pfr.220.1554955044527;
        Wed, 10 Apr 2019 20:57:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554955044; cv=none;
        d=google.com; s=arc-20160816;
        b=kohTdrYyiaoDR5xoliVZdUd4TxUlYz3bmDIRjhq3pOSpONiWdo12hJH0l4inKSNm03
         xutdkydhDsXAwnHlBrCHn8A6jhH4ALGqWWag61t+x2qnSEwXldHtHxR+AIOInJKuVCIL
         POMj3FMqflyzMiEAPfU7ujYwZ/Y1JI2y63KP6WVmhD4JcceeAfEuiP9TCqanxhUvh9pg
         dEfDvITsI0jyfUDnybnrd67yCheJDhNAR/en+qnMG7LN2sASrzcl9W6vzW0s2l564ikM
         +Xhx5UJ1d47GIeNTgJXP2xQB29uV0r5vFg/tMOpvtfI6Y1gZuCrG6TQ5YAmNhc/yoK0M
         fKTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MLWynHGliv6scIgC4xX8HtX9K46TiIdNd3gqOe6+OLg=;
        b=08wtXKQgNbmFw9rgdKEBeVhAD4qwMyeyyVSKOSHW9MqNT6phW6yFEpaZDyc+04RNYp
         A8a7Xr6+phcfn//WzYN5r91BVJRim+L3x7wDIQ4a93Iphf8cyHmU++AreYeoNTafw4XK
         /KTlXcPD+pRcxjg43t0iqBEWH4555UukAd2OUh8LEzwd/UvY1Cbt2xTqu8aL9kV+ag/G
         HwHPAoGVWfvrPAyPdLthhq5NATsBV+uWMVHDt5WwMlFoKZttZTQPyFqObG+8H89v4V/C
         ozKtkyUVIS29EXIDM2Dm7Dcu3guIQyEWsasi7JOEA9043cpmssr4wICWfZ6A6wARI5dw
         B6pg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-57.freemail.mail.aliyun.com (out30-57.freemail.mail.aliyun.com. [115.124.30.57])
        by mx.google.com with ESMTPS id r124si30310016pgr.201.2019.04.10.20.57.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 20:57:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) client-ip=115.124.30.57;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.57 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TP0I5rB_1554955031;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TP0I5rB_1554955031)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 11 Apr 2019 11:57:22 +0800
From: Yang Shi <yang.shi@linux.alibaba.com>
To: mhocko@suse.com,
	mgorman@techsingularity.net,
	riel@surriel.com,
	hannes@cmpxchg.org,
	akpm@linux-foundation.org,
	dave.hansen@intel.com,
	keith.busch@intel.com,
	dan.j.williams@intel.com,
	fengguang.wu@intel.com,
	fan.du@intel.com,
	ying.huang@intel.com,
	ziy@nvidia.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [v2 PATCH 2/9] mm: page_alloc: make find_next_best_node find return cpuless node
Date: Thu, 11 Apr 2019 11:56:52 +0800
Message-Id: <1554955019-29472-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Need find the cloest cpuless node to demote DRAM pages.  Add
"cpuless" parameter to find_next_best_node() to skip DRAM node on
demand.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/internal.h   | 11 +++++++++++
 mm/page_alloc.c | 14 ++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b..a514808 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -292,6 +292,17 @@ static inline bool is_data_mapping(vm_flags_t flags)
 	return (flags & (VM_WRITE | VM_SHARED | VM_STACK)) == VM_WRITE;
 }
 
+#ifdef CONFIG_NUMA
+extern int find_next_best_node(int node, nodemask_t *used_node_mask,
+			       bool cpuless);
+#else
+static inline int find_next_best_node(int node, nodemask_t *used_node_mask,
+				      bool cpuless)
+{
+	return 0;
+}
+#endif
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7cd88a4..bda17c2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5362,6 +5362,7 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
  * @used_node_mask: nodemask_t of already used nodes
+ * @cpuless: find next best cpuless node
  *
  * We use a number of factors to determine which is the next node that should
  * appear on a given node's fallback list.  The node should not have appeared
@@ -5373,7 +5374,8 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  *
  * Return: node id of the found node or %NUMA_NO_NODE if no node is found.
  */
-static int find_next_best_node(int node, nodemask_t *used_node_mask)
+int find_next_best_node(int node, nodemask_t *used_node_mask,
+			bool cpuless)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -5381,13 +5383,18 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	const struct cpumask *tmp = cpumask_of_node(0);
 
 	/* Use the local node if we haven't already */
-	if (!node_isset(node, *used_node_mask)) {
+	if (!node_isset(node, *used_node_mask) &&
+	    !cpuless) {
 		node_set(node, *used_node_mask);
 		return node;
 	}
 
 	for_each_node_state(n, N_MEMORY) {
 
+		/* Find next best cpuless node */
+		if (cpuless && (node_state(n, N_CPU)))
+			continue;
+
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -5419,7 +5426,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	return best_node;
 }
 
-
 /*
  * Build zonelists ordered by node and zones within node.
  * This results in maximum locality--normal zone overflows into local
@@ -5481,7 +5487,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+	while ((node = find_next_best_node(local_node, &used_mask, false)) >= 0) {
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
-- 
1.8.3.1

