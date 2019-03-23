Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3081C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6D74D218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6D74D218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0FB1E6B026B; Sat, 23 Mar 2019 00:45:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0810C6B026C; Sat, 23 Mar 2019 00:45:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E643E6B026D; Sat, 23 Mar 2019 00:45:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A83F36B026B
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:35 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so3964658pgi.10
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=s9/PKRRwNdObDLsxPq9IaWvFf+ZDklBgCSct6YIvkgc=;
        b=ZE+fEhcSc3Iuo2mSoWY+7yuQ/b8Cup8wYfrG88qhY0PzeTWDENkdHgdGM4iOmzbdIG
         UtH2Cja6/ADUmfQvS4WUIjLUf6gskzD0eSOgnhcZtGB28bShvff5OoZULVYLec5fHn3J
         G0P6aZHhJRkGSTX/lQFVHL+jVeJ83yrqXzFH6Bi8jFEUvt38XXonU/8yJOYWNm0fWu+v
         /7BjJi2zlGKmVxJ/SpwrCrlPFjmdfKT+Vs1ZrKPWmPfzDxGXB4JtjbO3tqlKyiWI4AN3
         KOJUcw3TmdoDIzYu8K6/ITIxd/JIayIbwkGkucg9vOi9E8DyPHrmcUowNlDgdqfU8jOm
         SD0g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXz4VtNQhNWukIz9ed/yn3l9n9dXRPgJNV6p32hh/VV0VJ1RKEd
	4MVZ292d7kqcuSSS+CbRDuzYcS8v9HRs452ueQMTmVuXzDd8204rS1/fPd89GhkD8WdFzvK2rJp
	F+pUN1NpQxx15rdchbF4BtKaFApvn9sId7cFwGSGmMwIjTfXNq7mFhJBUaESPtO1IFQ==
X-Received: by 2002:a17:902:b48c:: with SMTP id y12mr13048172plr.280.1553316335283;
        Fri, 22 Mar 2019 21:45:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxmLvfudpEOwjDdElbJRxJSfTNY7WvYK/JVVdYNLBDglVbu7vpeaXUyZLmCjXi2SHMDxdiE
X-Received: by 2002:a17:902:b48c:: with SMTP id y12mr13048106plr.280.1553316333891;
        Fri, 22 Mar 2019 21:45:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316333; cv=none;
        d=google.com; s=arc-20160816;
        b=0O6TnFcbGKOYhh7nsrdctaWwItfBo+ICaxE3+EvWFphT0snxbBl/Dlbmn1gPcUnMPt
         AVXchN0rpwnSjgLldWtwy/ZRPnhRB38bQe92sHYh22xOCMXFO0/OAjiB949aGP0LNhAM
         cJPMEg8rwwGVu2yAhBZ5RWTQTRc7/IhMzanY6Pp9V1bUruAj59y4mwNZtFJo7PPH0dD7
         MrU+X6LBGgpB7A+9mRxRF16uNslP4TT+ogSD7t4MKnjr8GNb/N3V3ISnY3zJhE0jBFpR
         oD/82/Cp2nYkubFk4iVwN8egsGTz2ta1nBpaUCthiPWhIPGUGMtO8eGEbTsfRARInAmR
         5/Lg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=s9/PKRRwNdObDLsxPq9IaWvFf+ZDklBgCSct6YIvkgc=;
        b=HCsIfViK7Rjlp4RxFoUj4NBXHiVe4+Lt8vSCa9grD3v8tihElKS/0ikrAqljHWdC5w
         iWlq0aX/AeXXqvopolLmkAlewUGCyGHC9sxbYMjiXLrrI1I0R3UzaASuroP9tarLqN3X
         s7Ej2+olqUcFjLGBiEsXug94amFSQ92ilK4SJW/k4zhOiqkcmQvVgqIcjoBMD3wDbwtP
         7NzApYvrXj7OlbAk467H4Hq4DYTIpJM27awRjHaFnrpW5RR6b3WTOpeE9APjai7iAmae
         8KyvQfLusDj3XsaXcg1CJmObKsoBmqkT7pB7nUqnVqYmwNNcTQ8rWBD4jnA/lvGc/5JU
         UMEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id m133si8321847pga.314.2019.03.22.21.45.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07487;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:02 +0800
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
	ying.huang@intel.com
Cc: yang.shi@linux.alibaba.com,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 05/10] mm: page_alloc: make find_next_best_node could skip DRAM node
Date: Sat, 23 Mar 2019 12:44:30 +0800
Message-Id: <1553316275-21985-6-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Need find the cloest non-DRAM node to demote DRAM pages.  Add
"skip_ram_node" parameter to find_next_best_node() to skip DRAM node on
demand.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/internal.h   | 11 +++++++++++
 mm/page_alloc.c | 15 +++++++++++----
 2 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/mm/internal.h b/mm/internal.h
index 9eeaf2b..46ad0d8 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -292,6 +292,17 @@ static inline bool is_data_mapping(vm_flags_t flags)
 	return (flags & (VM_WRITE | VM_SHARED | VM_STACK)) == VM_WRITE;
 }
 
+#ifdef CONFIG_NUMA
+extern int find_next_best_node(int node, nodemask_t *used_node_mask,
+			       bool skip_ram_node);
+#else
+static inline int find_next_best_node(int node, nodemask_t *used_node_mask,
+				      bool skip_ram_node)
+{
+	return 0;
+}
+#endif
+
 /* mm/util.c */
 void __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct vm_area_struct *prev, struct rb_node *rb_parent);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 68ad8c6..07d767b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5375,6 +5375,7 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  * find_next_best_node - find the next node that should appear in a given node's fallback list
  * @node: node whose fallback list we're appending
  * @used_node_mask: nodemask_t of already used nodes
+ * @skip_ram_node: find next best non-DRAM node
  *
  * We use a number of factors to determine which is the next node that should
  * appear on a given node's fallback list.  The node should not have appeared
@@ -5386,7 +5387,8 @@ int numa_zonelist_order_handler(struct ctl_table *table, int write,
  *
  * Return: node id of the found node or %NUMA_NO_NODE if no node is found.
  */
-static int find_next_best_node(int node, nodemask_t *used_node_mask)
+int find_next_best_node(int node, nodemask_t *used_node_mask,
+			bool skip_ram_node)
 {
 	int n, val;
 	int min_val = INT_MAX;
@@ -5394,13 +5396,19 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	const struct cpumask *tmp = cpumask_of_node(0);
 
 	/* Use the local node if we haven't already */
-	if (!node_isset(node, *used_node_mask)) {
+	if (!node_isset(node, *used_node_mask) &&
+	    !skip_ram_node) {
 		node_set(node, *used_node_mask);
 		return node;
 	}
 
 	for_each_node_state(n, N_MEMORY) {
 
+		/* Find next best non-DRAM node */
+		if (skip_ram_node &&
+		    (node_isset(n, def_alloc_nodemask)))
+			continue;
+
 		/* Don't want a node to appear more than once */
 		if (node_isset(n, *used_node_mask))
 			continue;
@@ -5432,7 +5440,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	return best_node;
 }
 
-
 /*
  * Build zonelists ordered by node and zones within node.
  * This results in maximum locality--normal zone overflows into local
@@ -5494,7 +5501,7 @@ static void build_zonelists(pg_data_t *pgdat)
 	nodes_clear(used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
-	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+	while ((node = find_next_best_node(local_node, &used_mask, false)) >= 0) {
 		/*
 		 * We don't want to pressure a particular node.
 		 * So adding penalty to the first node in same
-- 
1.8.3.1

