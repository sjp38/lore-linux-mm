Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1FD7C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A175220896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 23:30:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A175220896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4BCE08E0009; Thu, 13 Jun 2019 19:30:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46CB88E0002; Thu, 13 Jun 2019 19:30:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 384738E0009; Thu, 13 Jun 2019 19:30:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 023D68E0002
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 19:30:55 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y7so370040pfy.9
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 16:30:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=M/w7NOr7JiE3RTVURowXL/r9lk9zjfF8YDqu6lS/JCo=;
        b=qIE0H/r/IR4uMULovbK4pFIKrLIjddwnnDR5Z/f+Ee0q0OKEFcK1i78FTTxT4Zy5YQ
         Y9qE0xSw6a//V7BxOsRixjRLr7lKqsa/H6HtvbhB4KsWbTDFgDpudUjEG97D4/4FA/tP
         M9O9zn11STXE/pZhjYSxukurWdhBQazurxhp277sDCb0yUUSc1KXDYpoX89eATT+lQ+W
         m9ovUwyTUczn1f3JnkwwQbhs5l7+9BmG9sRm/rj4xCCJG2d+NhLuJLeoP6tBh2438Kei
         8AfYp2bEs6xyXhY/+8bHmnrAnRu2lqXaETMcAMEqmD2LeHap/IAuDdI9fs6TatIleifU
         gn3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUvim40YmNAIj6L5mCA/vYqn0JT4JT/D7x3HaCZLKqNrJ0kc8cm
	GBvxCADwTdxjP/n8GrfyF4thLmqtsAbEoCrpNDdBLtIKSWnGq95v8gU3Qb2WmH1Isfn0hB3Izjb
	rPIRwfiqiFkVKUdkusP1vUlm4WEER5LpFxtBz3XoTWk6nUrS+Ig4KZnu5zW2qlzGfQg==
X-Received: by 2002:a65:5203:: with SMTP id o3mr32666113pgp.379.1560468654596;
        Thu, 13 Jun 2019 16:30:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVMECK+PWUza7yAZefhe+ckhPBbLCFU/pMSLztBzQEGc24a4fSXV9CI7zQVxF6t2+cyVhm
X-Received: by 2002:a65:5203:: with SMTP id o3mr32666071pgp.379.1560468653813;
        Thu, 13 Jun 2019 16:30:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560468653; cv=none;
        d=google.com; s=arc-20160816;
        b=NAswQpRfwcMbMj5oa6RBnHeeuDbW78Mu0dzF/Qy1+K3iEqIfyAgiM5dhx0ZeyJyoGZ
         SjbZ/5O/AfyYbJw8dCrzyVJVG6X+LiqIkSYNfaJO+x5BTuC6sk0gQMHngv4gUyTIu+Ta
         76GIZ1g+UjOTPHC+zV8qUDsEs2lAT0UiRgRBDET0XxpxwYFqDECey6L1p9jUZO+16og3
         2agWFX0VLXOQUsmVcuMvENUL1XE1MAHPiAQkIdqoSvcoOl2ncdEbkyFsJSHco/4J61bZ
         gUxJhMZMrgZbwBVFRRnWRbwwNtak95awkeb3tbvyG/SQhhUImPfaIRDwbCBm4iafePXz
         lStA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=M/w7NOr7JiE3RTVURowXL/r9lk9zjfF8YDqu6lS/JCo=;
        b=M7FVS0+AhfmtwNgd8R78BsaTEqoCo0oQd86khSFwMev99henlZa3DhBp/fBkYu3qz8
         csb2tHZ/J3aSdBvELa+n9Mk9a5+G6/NMKgQSzOZd1zRlkB/QpI5SP6/c/9ouvixN4lnn
         McDkL56ZDZS9/nCYvaM9Np8lVb/yDTs9WUieWUnAPN+v+l/J90iKopl9ODVEbGRpzWVp
         lNMrcKWM+HJjvx0gofALMeuQghtuohpZk5BzE7jPuSZuCyRfr/Xj+PVBk81Shq3RocNC
         3ZKL0IauqulYqcNP6xK7WKf1IqBUM6beASdMzbRoyNzkemU+9S/+P8hXJNm68+3qJrTF
         cTdw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id u132si896082pgc.97.2019.06.13.16.30.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 16:30:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R151e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04400;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=15;SR=0;TI=SMTPD_---0TU6DYEz_1560468591;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TU6DYEz_1560468591)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 14 Jun 2019 07:29:59 +0800
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
Subject: [v3 PATCH 3/9] mm: page_alloc: make find_next_best_node find return migration target node
Date: Fri, 14 Jun 2019 07:29:31 +0800
Message-Id: <1560468577-101178-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1560468577-101178-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Need find the cloest migration target node to demote DRAM pages.  Add
"migration" parameter to find_next_best_node() to skip DRAM node on
demand.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/internal.h   | 11 +++++++++++
 mm/page_alloc.c | 14 ++++++++++----
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b..a3181e2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -292,6 +292,17 @@ static inline bool is_data_mapping(vm_flags_t flags)
 	return (flags & (VM_WRITE | VM_SHARED | VM_STACK)) == VM_WRITE;
 }
 
+#ifdef CONFIG_NUMA
+extern int find_next_best_node(int node, nodemask_t *used_node_mask,
+			       bool migration);
+#else
+static inline int find_next_best_node(int node, nodemask_t *used_node_mask,
+				      bool migtation)
+{
+	return 0;
+}
+#endif
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3b37c71..917f64d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5425,6 +5425,7 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
  * @used_node_mask: nodemask_t of already used nodes
+ * @migration: find next best migration target node
  *
  * We use a number of factors to determine which is the next node that should
  * appear on a given node's fallback list.  The node should not have appeared
@@ -5436,7 +5437,8 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  *
  * Return: node id of the found node or %NUMA_NO_NODE if no node is found.
  */
-static int find_next_best_node(int node, nodemask_t *used_node_mask)
+int find_next_best_node(int node, nodemask_t *used_node_mask,
+			bool migration)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -5444,13 +5446,18 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	const struct cpumask *tmp = cpumask_of_node(0);
 
 	/* Use the local node if we haven't already */
-	if (!node_isset(node, *used_node_mask)) {
+	if (!node_isset(node, *used_node_mask) &&
+	    !migration) {
 		node_set(node, *used_node_mask);
 		return node;
 	}
 
 	for_each_node_state(n, N_MEMORY) {
 
+		/* Find next best migration target node */
+		if (migration && !node_state(n, N_MIGRATE_TARGET))
+			continue;
+
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -5482,7 +5489,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	return best_node;
 }
 
-
 /*
  * Build zonelists ordered by node and zones within node.
  * This results in maximum locality--normal zone overflows into local
@@ -5544,7 +5550,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+	while ((node = find_next_best_node(local_node, &used_mask, false)) >= 0) {
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
-- 
1.8.3.1

