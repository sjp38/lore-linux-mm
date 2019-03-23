Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83363C43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D8DC218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D8DC218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 36A296B000E; Sat, 23 Mar 2019 00:45:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 340BB6B0010; Sat, 23 Mar 2019 00:45:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 121A96B0266; Sat, 23 Mar 2019 00:45:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id BC12E6B000E
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:10 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id y2so4233340pfl.16
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=mRnqNBUA/+X55QouLJxhPr6tTyfUiX9z7wlgO1jXwO8=;
        b=RxOaH9kw3emRkau5AWoQYox4IuH/lLaxlGXETJhGN2+SjKWcvUaSeCDxK7Sb1J4RDD
         bIKCqJJZhfdGyTyk07ybmTsuC+tRYIpd6PRRSJTjFOR4Go1K1JNFMk/qbSVYRsfKKpuN
         UcMyerEmmqS5Xcz1HO0TxozYsCQK3+YdbHhcO2PoeDptJ/IUK0seEESlMK6hjpAIymim
         ysseO/RMCONXfu3HJPJooStgKWHNFGVZY4olSQxRk09YqTbt6yW+crwdx6qGBXYTENWZ
         o4JhsDtT5TNgcZzEziHI3Cnwa7mQLMGhX2Ut8BiWZqp7stJiqbAsCTsdkaxqJSMmeRMx
         JKyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWTmrtd1MkSFOeCwho8ttAkXkBRaqhKtQjWTXsRk08D6Pbwt8DF
	xcdzD+oYtjblbmm87W9B9TrpS7PlHtyiB2m36Obx/KmfbBzzj12B4g2+dC/M7KaC7Pf7ACNr3+3
	TlSMcqmTfoSfq7b5LUDt3zZBrX5VI0J2sV6pmmFRKg5CDGfz5AGGeR8bqyN+v/MHdtw==
X-Received: by 2002:a17:902:d705:: with SMTP id w5mr13172402ply.243.1553316310405;
        Fri, 22 Mar 2019 21:45:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj1ZavJZzrZw0+DKfGF3fk7Xct7j2R9/YwqQGhWUL49+oVCiePxkL6Dw6hgabMXI5/yi2V
X-Received: by 2002:a17:902:d705:: with SMTP id w5mr13172313ply.243.1553316308960;
        Fri, 22 Mar 2019 21:45:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316308; cv=none;
        d=google.com; s=arc-20160816;
        b=gYOETg0oyafrBsP6C8p1EOSJ0YE8voBSlO47sLl6RXhGWY5MAZHIt02uxZVYjDTbuG
         R2GKlDu4eMRO7nbvU/rpQesURx15f1ww6BElWQuLcVY1IfBxRgUktI0lozc5BMMQfb7v
         bnkxjQi5T/rghTEy5ohb1tkvThcn6NmLuZVmnWNtZzafgZRGuKWESXzOKRcpVp0+aUFL
         Cz938xeCLpF1DZeSoOWN5Ve5shi75cD1l6OAK9/NYeAGfqpwTwnrI4JvL/+FE4dctYoH
         14YtW4sxG+m6nEU8nD/+TNXiugUwKu/qFHAz4yskRmRoKKykhn1UB+uFUH9jOA7o+2B8
         FuHw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=mRnqNBUA/+X55QouLJxhPr6tTyfUiX9z7wlgO1jXwO8=;
        b=YldVzOyNaJQbdFPuzY1T1SGcg5/EnwCgoErL883xrGGjx0RpUjBBNjDaer84VfLjDF
         xlQACxPdMW2eEGMExESb5LNzZbUbFk49D/zZrSi2y/yIbz6lnE+G9MhyYjIPn7liip3/
         siF/ElbRVZqiti/GEtwxXaxanOVQKLv5zEwmd9nHFH+uptRIhXMzgp3yC/FVf+7wqSOb
         2XQjinAO0UTMgGo4+kdKJrC6cvWFGJy7JRP6F68RAR0/QqMjhb0ymKsM1fLjGE4CT8nd
         6s3qGdqWxg9/vmqdxwsOapui2dOCD4IXsuNnPn37PB8d3yizGdy7xoiVzyMgEE94Hbb4
         N8xg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id h12si6714801plt.69.2019.03.22.21.45.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) client-ip=47.88.44.36;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.36 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R641e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04397;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
Received: from e19h19392.et15sqa.tbsite.net(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TNPuxAM_1553316293)
          by smtp.aliyun-inc.com(127.0.0.1);
          Sat, 23 Mar 2019 12:45:01 +0800
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
Subject: [PATCH 02/10] mm: mempolicy: introduce MPOL_HYBRID policy
Date: Sat, 23 Mar 2019 12:44:27 +0800
Message-Id: <1553316275-21985-3-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Introduce a new NUMA policy, MPOL_HYBRID.  It behaves like MPOL_BIND,
but since we need migrate pages from non-DRAM node (i.e. PMEM node) to
DRAM node on demand, MPOL_HYBRID would do page migration on numa fault,
so it would have MPOL_F_MOF set by default.

The NUMA balancing stuff will be enabled in the following patch.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 include/uapi/linux/mempolicy.h |  1 +
 mm/mempolicy.c                 | 56 +++++++++++++++++++++++++++++++++++++-----
 2 files changed, 51 insertions(+), 6 deletions(-)

diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolicy.h
index 3354774..0fdc73d 100644
--- a/include/uapi/linux/mempolicy.h
+++ b/include/uapi/linux/mempolicy.h
@@ -22,6 +22,7 @@ enum {
 	MPOL_BIND,
 	MPOL_INTERLEAVE,
 	MPOL_LOCAL,
+	MPOL_HYBRID,
 	MPOL_MAX,	/* always last member of enum */
 };
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171cc..7d0a432 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -31,6 +31,10 @@
  *                but useful to set in a VMA when you have a non default
  *                process policy.
  *
+ * hybrid         Only allocate memory on specific set of nodes. If the set of
+ *                nodes include non-DRAM nodes, NUMA balancing would promote
+ *                the page to DRAM node.
+ *
  * default        Allocate on the local node first, or when on a VMA
  *                use the process policy. This is what Linux always did
  *		  in a NUMA aware kernel and still does by, ahem, default.
@@ -191,6 +195,17 @@ static int mpol_new_bind(struct mempolicy *pol, const nodemask_t *nodes)
 	return 0;
 }
 
+static int mpol_new_hybrid(struct mempolicy *pol, const nodemask_t *nodes)
+{
+	if (nodes_empty(*nodes))
+		return -EINVAL;
+
+	/* Hybrid policy would promote pages in page fault */
+	pol->flags |= MPOL_F_MOF;
+	pol->v.nodes = *nodes;
+	return 0;
+}
+
 /*
  * mpol_set_nodemask is called after mpol_new() to set up the nodemask, if
  * any, for the new policy.  mpol_new() has already validated the nodes
@@ -401,6 +416,10 @@ void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new)
 		.create = mpol_new_bind,
 		.rebind = mpol_rebind_nodemask,
 	},
+	[MPOL_HYBRID] = {
+		.create = mpol_new_hybrid,
+		.rebind = mpol_rebind_nodemask,
+	},
 };
 
 static void migrate_page_add(struct page *page, struct list_head *pagelist,
@@ -782,6 +801,8 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
 		return;
 
 	switch (p->mode) {
+	case MPOL_HYBRID:
+		/* Fall through */
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1721,8 +1742,12 @@ static int apply_policy_zone(struct mempolicy *policy, enum zone_type zone)
  */
 static nodemask_t *policy_nodemask(gfp_t gfp, struct mempolicy *policy)
 {
-	/* Lower zones don't get a nodemask applied for MPOL_BIND */
-	if (unlikely(policy->mode == MPOL_BIND) &&
+	/*
+	 * Lower zones don't get a nodemask applied for MPOL_BIND
+	 * or MPOL_HYBRID.
+	 */
+	if (unlikely((policy->mode == MPOL_BIND) ||
+			(policy->mode == MPOL_HYBRID)) &&
 			apply_policy_zone(policy, gfp_zone(gfp)) &&
 			cpuset_nodemask_valid_mems_allowed(&policy->v.nodes))
 		return &policy->v.nodes;
@@ -1742,7 +1767,9 @@ static int policy_node(gfp_t gfp, struct mempolicy *policy,
 		 * because we might easily break the expectation to stay on the
 		 * requested node and not break the policy.
 		 */
-		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
+		WARN_ON_ONCE((policy->mode == MPOL_BIND ||
+			     policy->mode == MPOL_HYBRID) &&
+			     (gfp & __GFP_THISNODE));
 	}
 
 	return nd;
@@ -1786,6 +1813,8 @@ unsigned int mempolicy_slab_node(void)
 	case MPOL_INTERLEAVE:
 		return interleave_nodes(policy);
 
+	case MPOL_HYBRID:
+		/* Fall through */
 	case MPOL_BIND: {
 		struct zoneref *z;
 
@@ -1856,7 +1885,8 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
  * @addr: address in @vma for shared policy lookup and interleave policy
  * @gfp_flags: for requested zone
  * @mpol: pointer to mempolicy pointer for reference counted mempolicy
- * @nodemask: pointer to nodemask pointer for MPOL_BIND nodemask
+ * @nodemask: pointer to nodemask pointer for MPOL_BIND or MPOL_HYBRID
+ * nodemask
  *
  * Returns a nid suitable for a huge page allocation and a pointer
  * to the struct mempolicy for conditional unref after allocation.
@@ -1871,14 +1901,16 @@ int huge_node(struct vm_area_struct *vma, unsigned long addr, gfp_t gfp_flags,
 	int nid;
 
 	*mpol = get_vma_policy(vma, addr);
-	*nodemask = NULL;	/* assume !MPOL_BIND */
+	/* assume !MPOL_BIND || !MPOL_HYBRID */
+	*nodemask = NULL;
 
 	if (unlikely((*mpol)->mode == MPOL_INTERLEAVE)) {
 		nid = interleave_nid(*mpol, vma, addr,
 					huge_page_shift(hstate_vma(vma)));
 	} else {
 		nid = policy_node(gfp_flags, *mpol, numa_node_id());
-		if ((*mpol)->mode == MPOL_BIND)
+		if ((*mpol)->mode == MPOL_BIND ||
+		    (*mpol)->mode == MPOL_HYBRID)
 			*nodemask = &(*mpol)->v.nodes;
 	}
 	return nid;
@@ -1919,6 +1951,8 @@ bool init_nodemask_of_mempolicy(nodemask_t *mask)
 		init_nodemask_of_node(mask, nid);
 		break;
 
+	case MPOL_HYBRID:
+		/* Fall through */
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -1966,6 +2000,7 @@ bool mempolicy_nodemask_intersects(struct task_struct *tsk,
 		 * nodes in mask.
 		 */
 		break;
+	case MPOL_HYBRID:
 	case MPOL_BIND:
 	case MPOL_INTERLEAVE:
 		ret = nodes_intersects(mempolicy->v.nodes, *mask);
@@ -2170,6 +2205,8 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
 			return false;
 
 	switch (a->mode) {
+	case MPOL_HYBRID:
+		/* Fall through */
 	case MPOL_BIND:
 		/* Fall through */
 	case MPOL_INTERLEAVE:
@@ -2325,6 +2362,9 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 			polnid = pol->v.preferred_node;
 		break;
 
+	case MPOL_HYBRID:
+		/* Fall through */
+
 	case MPOL_BIND:
 
 		/*
@@ -2693,6 +2733,7 @@ void numa_default_policy(void)
 	[MPOL_BIND]       = "bind",
 	[MPOL_INTERLEAVE] = "interleave",
 	[MPOL_LOCAL]      = "local",
+	[MPOL_HYBRID]     = "hybrid",
 };
 
 
@@ -2768,6 +2809,8 @@ int mpol_parse_str(char *str, struct mempolicy **mpol)
 		if (!nodelist)
 			err = 0;
 		goto out;
+	case MPOL_HYBRID:
+		/* Fall through */
 	case MPOL_BIND:
 		/*
 		 * Insist on a nodelist
@@ -2856,6 +2899,7 @@ void mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol)
 		else
 			node_set(pol->v.preferred_node, nodes);
 		break;
+	case MPOL_HYBRID:
 	case MPOL_BIND:
 	case MPOL_INTERLEAVE:
 		nodes = pol->v.nodes;
-- 
1.8.3.1

