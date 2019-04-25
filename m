Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E69C1C282CE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A06A2206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A06A2206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72B5E6B000A; Wed, 24 Apr 2019 21:42:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D7C06B000C; Wed, 24 Apr 2019 21:42:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C7FE6B000D; Wed, 24 Apr 2019 21:42:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2737E6B000A
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m9so8815534pge.7
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hqI7L/58NB/51uxAiM/Mz2T2sXjRz7XBu7fn1ORtLXQ=;
        b=Jh1nEv9LofZxXYK7gGZHIx24ND9wBPOJNkvx1JP/JywCiY0/UldPyBwDM/L1KjQfCK
         Z3Nzc6JWpJbT+fUSxfZx24RHLNQmB+UCaGq26b7fSRbbcvYXV/6uyQMYiW59vnhcoOuc
         U3znePHzTwgeXR7Kl6uINUyJ6g1PjBuqA5SzjP0+H8FAdXY/b+lHE6pNI3lKieLsW5He
         bT0cusOlBBUqX9CaP7rg67dBJekhtHkH7Ob5c54LC9y0aBu+sjyoLnhyPsOAVKTji8E7
         GO59SD+4NTuYXLT/Z/2xMKAeEk5kMAR5i9EZ9tjf9S7wglupbmP2jl9fA0eAYVg2T6TC
         //JA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW8Vjvm3oGsFmv4map5Z4DnNm7rkzKHyNtB6l8xyFUrvDex2L5U
	JZeGi20T0WqOo+TXN3LEujh6wvpZDqkVXIKPDphkH37QQUqKckgpJ6VNO9Pumovfg4r0d4LiFW5
	EUoVY8A/rB8TpQ4yVxgpQx2ZZMn72jC6qsH5NTdJokvop0Dv/AvVG+8OtG1LO9Z4ivg==
X-Received: by 2002:a62:69c2:: with SMTP id e185mr36812635pfc.119.1556156569845;
        Wed, 24 Apr 2019 18:42:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnVkowwsN/iBepU+5eH74P4VT5GKWE9KJtYPAtVETdeTlarPQd+HoePrKTk8j+9K03/yEY
X-Received: by 2002:a62:69c2:: with SMTP id e185mr36812577pfc.119.1556156568983;
        Wed, 24 Apr 2019 18:42:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156568; cv=none;
        d=google.com; s=arc-20160816;
        b=kndx0T6QlVq6oaRrvAoxLwuZ/e+pxsxL9+BE05OA2fyB7vpqchNLD/DPM6mx0NCVKj
         rke0Av4XZayhsFLV4ZyHCPlRuDgVLnoPQ8/H/QwlhY0MtSUGeClGBzEoMP7gRbl9/4hd
         IDr9gJdrcp0+fuD4pD2VwY1ubh9guH3KHnWbMDf9FaBZMQn4fnZLMYClZ1aeDdb3UpjO
         4H5kRLkQ4T5tKV7SOxRaULo7JFtQtr3tJhLG+UvF+IAv3XdwFLlVoxOiC+bw1Gs49/FE
         BLTkGPsZhWo3EIQdlhL93MLogU285WyZG4zbYh9Vre13bu72HL053FevQ+CLNtbvFu1Z
         JgpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hqI7L/58NB/51uxAiM/Mz2T2sXjRz7XBu7fn1ORtLXQ=;
        b=0JJ9ULzc3n0IuNY9y8gGf3vUyZoZkBlydWG5YeJEXw/DqHRyM66exoAVAhhLJkC3dX
         daD93koMJQkrwQwWvr2PBQw3GBeHg9/3IM0rr4hDQ2Xs0DBU4KedwrGKgjgrCJZXIwqq
         Gn5cXa70JlmUKuDFVxUO6nzhpG6nes/+HfgJECH6FXvfJNvKv1lWjUm7xfxrwfNFBWVO
         Xc0PHhUi4Qi3iec+Umholmj+l99D2Sa0uGO65uNCahzN2kVm1D94/50rTiIym5mxvsE0
         7DgQ0FQYl+pV2OUSyx5ZWyv7qc/tfAKpzjO0GvML847OTcUFs9o3C8DuHJSGQ4wHvdbB
         5S5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134236"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:47 -0700
From: Fan Du <fan.du@intel.com>
To: akpm@linux-foundation.org,
	mhocko@suse.com,
	fengguang.wu@intel.com,
	dan.j.williams@intel.com,
	dave.hansen@intel.com,
	xishi.qiuxishi@alibaba-inc.com,
	ying.huang@intel.com
Cc: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Fan Du <fan.du@intel.com>
Subject: [RFC PATCH 4/5] mm, page alloc: build fallback list on per node type basis
Date: Thu, 25 Apr 2019 09:21:34 +0800
Message-Id: <1556155295-77723-5-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On box with both DRAM and PMEM managed by mm system,
Usually node 0, 1 are DRAM nodes, nodes 2, 3 are PMEM nodes.
nofallback list are same as before, fallback list are not
redesigned to be arranged by node type basis, iow,
allocation request of DRAM page start from node 0 will go
through node0->node1->node2->node3 zonelists.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/linux/mmzone.h |  8 ++++++++
 mm/page_alloc.c        | 42 ++++++++++++++++++++++++++----------------
 2 files changed, 34 insertions(+), 16 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d3ee9f9..8c37e1c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -939,6 +939,14 @@ static inline int is_node_dram(int nid)
 	return test_bit(PGDAT_DRAM, &pgdat->flags);
 }
 
+static inline int is_node_same_type(int nida, int nidb)
+{
+	if (node_isset(nida, numa_nodes_pmem))
+		return node_isset(nidb, numa_nodes_pmem);
+	else
+		return node_isset(nidb, numa_nodes_dram);
+}
+
 static inline void set_node_type(int nid)
 {
 	pg_data_t *pgdat = NODE_DATA(nid);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c6ce20a..a408a91 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5372,7 +5372,7 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  *
  * Return: node id of the found node or %NUMA_NO_NODE if no node is found.
  */
-static int find_next_best_node(int node, nodemask_t *used_node_mask)
+static int find_next_best_node(int node, nodemask_t *used_node_mask, int need_same_type)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -5380,7 +5380,7 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	const struct cpumask *tmp = cpumask_of_node(0);
 
 	/* Use the local node if we haven't already */
-	if (!node_isset(node, *used_node_mask)) {
+	if (need_same_type && !node_isset(node, *used_node_mask)) {
 		node_set(node, *used_node_mask);
 		return node;
 	}
@@ -5391,6 +5391,12 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 		if (node_isset(n, *used_node_mask))
 			continue;
 
+		if (need_same_type && !is_node_same_type(node, n))
+			continue;
+
+		if (!need_same_type && is_node_same_type(node, n))
+			continue;
+
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 
@@ -5472,31 +5478,35 @@ static void build_zonelists(pg_data_t *pgdat)
 	int node, load, nr_nodes = 0;
 	nodemask_t used_mask;
 	int local_node, prev_node;
+	int need_same_type;
 
 	/* NUMA-aware ordering of nodes */
 	local_node = pgdat->node_id;
 	load = nr_online_nodes;
 	prev_node = local_node;
-	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
-		/*
-		 * We don't want to pressure a particular node.
-		 * So adding penalty to the first node in same
-		 * distance group to make it round-robin.
-		 */
-		if (node_distance(local_node, node) !=
-		    node_distance(local_node, prev_node))
-			node_load[node] = load;
+	for (need_same_type = 1; need_same_type >= 0; need_same_type--) {
+		nodes_clear(used_mask);
+		while ((node = find_next_best_node(local_node, &used_mask,
+				need_same_type)) >= 0) {
+			/*
+			 * We don't want to pressure a particular node.
+			 * So adding penalty to the first node in same
+			 * distance group to make it round-robin.
+			 */
+			if (node_distance(local_node, node) !=
+			    node_distance(local_node, prev_node))
+				node_load[node] = load;
 
-		node_order[nr_nodes++] = node;
-		prev_node = node;
-		load--;
+			node_order[nr_nodes++] = node;
+			prev_node = node;
+			load--;
+		}
 	}
-
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);
 	build_thisnode_zonelists(pgdat);
+
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
1.8.3.1

