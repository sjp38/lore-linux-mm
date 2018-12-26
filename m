Return-Path: <SRS0=eTfr=PD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 874DEC43387
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4381F218FC
	for <linux-mm@archiver.kernel.org>; Wed, 26 Dec 2018 13:37:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4381F218FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50C338E0012; Wed, 26 Dec 2018 08:37:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72BE28E0011; Wed, 26 Dec 2018 08:37:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 13DD58E0014; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 088668E0010
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:08 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id 143so15273932pgc.3
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :user-agent:date:from:to:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:cc:subject
         :references:mime-version:content-disposition;
        bh=xxdhI13zA/ZYq1pM1tVWHu7Nmzr2NFM/Mu6MhY8pnCo=;
        b=a+r5oKmKn5rqvg6iv7DV78ogOGdEZm/fG1PmKB0P1iFUZZW+cJviM5M7FUEzatJh/y
         1T0+CzeiYFBGbkg8MMKh9Yx2lSjX1gNADsIkr/mCxhcfhLpfWwLM/u/x2PnYjK/lrrVU
         KORmAK20f6dApq+MmKCdy0DJccuxQ9HszXxx5jL5x6X7gRx1mhnIE11kcALe3uybKqHe
         bDJjOoAGLK/nCAWPe7lmaL2W9EHHYkwODklUu8KySxHmAG/SIHIqO+sSxty3czEhFkhd
         qMSqIJznqPhw1fm8779fhWyVoLvMVpG05GIE28gPBHNjOdjnGdZ8a/2bX0WmEcqjNK9p
         O7Xw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AA+aEWYlmKYNxMawFS0ldsZ3I5yncdQmJS6LLjDKcdKFu5DEIxkWz0jU
	otA4vr2IEA3HesnNRsU8xO74+gHIPmyVHU9o59G9cgdZmAZZrfUFoWzqO/x2gLT5Wjir8KtXv80
	GzPDAl6sCnqZqvvaFm9uH378jPJ4qRRYrmkL9WTHnzs3oPvV+Jab1XboUcEyXzlT0YA==
X-Received: by 2002:a62:ed0f:: with SMTP id u15mr19787063pfh.188.1545831427700;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
X-Google-Smtp-Source: AFSGD/XupqZauO4RNVNJmfiaBmVPdzL9ZrheeGtt/iA6NhnZDBWuALDdkqQE1HTTBHyINt4yqZCR
X-Received: by 2002:a62:ed0f:: with SMTP id u15mr19787034pfh.188.1545831427176;
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545831427; cv=none;
        d=google.com; s=arc-20160816;
        b=lm8xwco0dh9iTtQ8YPNASc0XeuB1rQRdOAwRhUrXM5fea7Ei1YvyjkATi3fH1CodTR
         gzKAS3tKNAbkuKCAow65x0IAP3975Bzxu9i6+VtkMiRerkqNCFXL/uge/GTmIMMKefBz
         DHkmkek0I2Q/oO1fa8tbHW2Uh38kMAXpWoHvTwtqVTTBcmvAKxbI0RXupVRXMXdKKgXa
         4b+xuumhn0MOFZva5258QWvBgwaWAE8YvCb8/EqF2gC5NlR/E967tCdlbyFAOiRp2cfv
         ey+acb3OIEr6y0sGXtYiaOcBcBbylVt08dhwk22OnkWbXMCk0ED2ESW/fCGHn3sQZJi9
         juzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-disposition:mime-version:references:subject:cc:cc:cc:cc:cc
         :cc:cc:cc:cc:cc:cc:to:from:date:user-agent:message-id;
        bh=xxdhI13zA/ZYq1pM1tVWHu7Nmzr2NFM/Mu6MhY8pnCo=;
        b=w9Vm8e3l58Cwkzeg+Kfz0scnucLIVpfJk/+QnFineqQUtNlJz6FSqQ5zp5pT3z/TTW
         Cq1s00O2NebWhs1zCLZoxAvtyu4bbFtEuQts5StFtRzhf9zxbYH3hpYv66c6KkKLeXbd
         nudu3HlYyJiNi5Ofw5yclIpUOpwa8lZCH3tqhbQpjWIAm+J+Fbp0L+x2jJDd1UY8CG+b
         p62P6wUKg2DY41ktfKMMyBOAkLUU10navu8GDICRHR8RSibrVjUL2Ujs94t9WRgSf4jX
         Nguwq94aqVCisniOnmOByU7cUtUuIGG45Z1I0lj3SDq2TxYsF7YTFg8ETvuJeFW6c+kK
         pwrg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id r12si1487152plo.59.2018.12.26.05.37.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:07 -0800 (PST)
Received-SPF: pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fengguang.wu@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=fengguang.wu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 26 Dec 2018 05:37:05 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.56,400,1539673200"; 
   d="scan'208";a="113358937"
Received: from wangdan1-mobl1.ccr.corp.intel.com (HELO wfg-t570.sh.intel.com) ([10.254.210.154])
  by orsmga003.jf.intel.com with ESMTP; 26 Dec 2018 05:37:02 -0800
Received: from wfg by wfg-t570.sh.intel.com with local (Exim 4.89)
	(envelope-from <fengguang.wu@intel.com>)
	id 1gc9Mr-0005Oe-Dr; Wed, 26 Dec 2018 21:37:01 +0800
Message-Id: <20181226133351.644607371@intel.com>
User-Agent: quilt/0.65
Date: Wed, 26 Dec 2018 21:14:56 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
To: Andrew Morton <akpm@linux-foundation.org>
cc: Linux Memory Management List <linux-mm@kvack.org>,
 Fan Du <fan.du@intel.com>,
 Fengguang Wu <fengguang.wu@intel.com>
cc: kvm@vger.kernel.org
Cc: LKML <linux-kernel@vger.kernel.org>
cc: Yao Yuan <yuan.yao@intel.com>
cc: Peng Dong <dongx.peng@intel.com>
cc: Huang Ying <ying.huang@intel.com>
CC: Liu Jingqi <jingqi.liu@intel.com>
cc: Dong Eddie <eddie.dong@intel.com>
cc: Dave Hansen <dave.hansen@intel.com>
cc: Zhang Yi <yi.z.zhang@linux.intel.com>
cc: Dan Williams <dan.j.williams@intel.com>
Subject: [RFC][PATCH v2 10/21] mm: build separate zonelist for PMEM and DRAM node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline; filename=0016-page-alloc-Build-separate-zonelist-for-PMEM-and-RAM-.patch
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181226131456.FW-ohywGmM5JqXLTeh9TVy_0EJFlQxFREip5BYJmkTo@z>

From: Fan Du <fan.du@intel.com>

When allocate page, DRAM and PMEM node should better not fall back to
each other. This allows migration code to explicitly control which type
of node to allocate pages from.

With this patch, PMEM NUMA node can only be used in 2 ways:
- migrate in and out
- numactl

That guarantees PMEM NUMA node will only hold anon pages.
We don't detect hotness for other types of pages for now.
So need to prevent some PMEM page goes hot while not able to
detect/move it to DRAM.

Another implication is, new page allocations will by default goto
DRAM nodes. Which is normally a good choice -- since DRAM writes
are cheaper than PMEM, it's often benefitial to watch new pages in
DRAM for some time and only move the likely cold pages to PMEM.

However there can be exceptions. For example, if PMEM:DRAM ratio is
very high, some page allocations may better go to PMEM nodes directly.
In long term, we may create more kind of fallback zonelists and make
them configurable by NUMA policy.

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 mm/mempolicy.c  |   14 ++++++++++++++
 mm/page_alloc.c |   42 +++++++++++++++++++++++++++++-------------
 2 files changed, 43 insertions(+), 13 deletions(-)

--- linux.orig/mm/mempolicy.c	2018-12-26 20:03:49.821417489 +0800
+++ linux/mm/mempolicy.c	2018-12-26 20:29:24.597884301 +0800
@@ -1745,6 +1745,20 @@ static int policy_node(gfp_t gfp, struct
 		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
 	}
 
+	if (policy->mode == MPOL_BIND) {
+		nodemask_t nodes = policy->v.nodes;
+
+		/*
+		 * The rule is if we run on DRAM node and mbind to PMEM node,
+		 * perferred node id is the peer node, vice versa.
+		 * if we run on DRAM node and mbind to DRAM node, #PF node is
+		 * the preferred node, vice versa, so just fall back.
+		 */
+		if ((is_node_dram(nd) && nodes_subset(nodes, numa_nodes_pmem)) ||
+			(is_node_pmem(nd) && nodes_subset(nodes, numa_nodes_dram)))
+			nd = NODE_DATA(nd)->peer_node;
+	}
+
 	return nd;
 }
 
--- linux.orig/mm/page_alloc.c	2018-12-26 20:03:49.821417489 +0800
+++ linux/mm/page_alloc.c	2018-12-26 20:03:49.817417321 +0800
@@ -5153,6 +5153,10 @@ static int find_next_best_node(int node,
 		if (node_isset(n, *used_node_mask))
 			continue;
 
+		/* DRAM node doesn't fallback to pmem node */
+		if (is_node_pmem(n))
+			continue;
+
 		/* Use the distance array to find the distance */
 		val = node_distance(node, n);
 
@@ -5242,19 +5246,31 @@ static void build_zonelists(pg_data_t *p
 	nodes_clear(used_mask);
 
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
-
-		node_order[nr_nodes++] = node;
-		prev_node = node;
-		load--;
+	/* Pmem node doesn't fallback to DRAM node */
+	if (is_node_pmem(local_node)) {
+		int n;
+
+		/* Pmem nodes should fallback to each other */
+		node_order[nr_nodes++] = local_node;
+		for_each_node_state(n, N_MEMORY) {
+			if ((n != local_node) && is_node_pmem(n))
+				node_order[nr_nodes++] = n;
+		}
+	} else {
+		while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
+			/*
+			 * We don't want to pressure a particular node.
+			 * So adding penalty to the first node in same
+			 * distance group to make it round-robin.
+			 */
+			if (node_distance(local_node, node) !=
+			    node_distance(local_node, prev_node))
+				node_load[node] = load;
+
+			node_order[nr_nodes++] = node;
+			prev_node = node;
+			load--;
+		}
 	}
 
 	build_zonelists_in_node_order(pgdat, node_order, nr_nodes);


