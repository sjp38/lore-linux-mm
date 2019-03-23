Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 052F3C4360F
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B1F8221900
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B1F8221900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D07F6B0006; Sat, 23 Mar 2019 00:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08B006B0007; Sat, 23 Mar 2019 00:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EB0926B0008; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id B349D6B0007
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:05 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g83so4272035pfd.3
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VeTrpkgTol96HI011wIp/gboY/0gXosEdyexTBsWDs4=;
        b=ugXF9axIJ3BhFSmEWdxfQu549AaEp8I3tIFM5ETgnZfdvkweUZj7fyT5ZaHRZbgc9O
         e/QnYVDb0StNLjWBHj3X92/6OX4rG1L4Rdgwb95ROjeXwcKxhtrxhBOtyVWRPnCnNLlT
         60+g4yf91SEUIn+g6/IBHIaf/IiuU/Q/3+OhQOOjOO3nWxTnU6C5s3Lb5/iamutWbypU
         r0kanqxtReHLjTwyW6mFVlgx9EwAIoEn4whkgU7hJYX106eIz6SIJg/WfktcF2T6/PbT
         joYi4pX5HZDV9zZteJ0TtalDdYHk0+xo2NK25GWVgCrsc+lGHhWLBMtgdLK4oc36Oz0c
         qpCQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAWpftZfzGj6y5zDDoWHa3wJjjznRZ9sfFfX3lSaO0CSRaBoToXy
	jMPe9LJSgmpGa7k+AB4X1kPi3yvyLsD2SlBxCCew5A3Hzbbo2rHO2IG/igIdf/7HmVdWtQnDL2H
	xMF9o3lee5IpPlKQ2PcU3SuqpoDcIobaiSWlmzuPRs6LvalyJm5rqId4yqdtUW6vV3w==
X-Received: by 2002:a62:29c6:: with SMTP id p189mr13211652pfp.194.1553316305330;
        Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqQJVKhwG8CddfG0PSEgiGzyV9kduOGGBmoPagOKFzP+V93WAe2XPhL0DYPrVsC2Z3NeVV
X-Received: by 2002:a62:29c6:: with SMTP id p189mr13211567pfp.194.1553316303876;
        Fri, 22 Mar 2019 21:45:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316303; cv=none;
        d=google.com; s=arc-20160816;
        b=1AiprqyY2Fl8t+taNEbP4vI5me3DB9DFmxZMWNBhXr78ydc26RodfIyBHTZkkwcSLO
         Mbft3d9Xn1pd4AXOVQsjfdjnHaBOFjw0VEQhKdkJETSaBllMb53tsvzLjjSotI8OASNR
         BEWMwKnHS26vjt6CvxQ9LUVi2qHX9OVgfSFiRx6KTBkOqG+pBy5I2m/hh/4pJGpb7Txs
         dB6QVFuFLBfOlgqSwzhSdygmpYqvwU0ysH2Is5XlItHIX3SwBCjrIV/uTpeOejgvxGm9
         S6mv2QfSwoQa+qwF36NM4qW/yLDLencH+JYVJDzU9/MaBlGmRE6l+1/HM4SgVlqdSXa/
         BvLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VeTrpkgTol96HI011wIp/gboY/0gXosEdyexTBsWDs4=;
        b=RS1smvu1A5tbrw5/V71m5z5l6lK0QcH1RNmqk34uDNCyG9jyCrVPk4+qvsxw4UZ4gg
         jZqbwyc0caV52gf3iUtDMTFvkTMw1M8U4mgDsTP1NcuFQTULf1l5H698VBA2fhMzFd4G
         it7SJBWVPvWzxv02NveRVJh1pejKEKbV8RLXYG4QxhRwmuPrGrytuyLM4JObmsNGMvbe
         m/atdRY+CkWRsDM+ckwvfxCNXPUndse/5H1PDEpo0XtcCpdzM1MWL3oDWPV/k+SE3p6w
         dKlHdm8Gcb9CmWwlaEi1EnKK4urq42K4BLSviHndf82437d853EGEXoqFEA2DMFxg4Ju
         xzbw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id w12si8053022pgr.104.2019.03.22.21.45.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R101e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01f04391;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
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
Subject: [PATCH 01/10] mm: control memory placement by nodemask for two tier main memory
Date: Sat, 23 Mar 2019 12:44:26 +0800
Message-Id: <1553316275-21985-2-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When running applications on the machine with NVDIMM as NUMA node, the
memory allocation may end up on NVDIMM node.  This may result in silent
performance degradation and regression due to the difference of hardware
property.

DRAM first should be obeyed to prevent from surprising regression.  Any
non-DRAM nodes should be excluded from default allocation.  Use nodemask
to control the memory placement.  Introduce def_alloc_nodemask which has
DRAM nodes set only.  Any non-DRAM allocation should be specified by
NUMA policy explicitly.

In the future we may be able to extract the memory charasteristics from
HMAT or other source to build up the default allocation nodemask.
However, just distinguish DRAM and PMEM (non-DRAM) nodes by SRAT flag
for the time being.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 arch/x86/mm/numa.c     |  1 +
 drivers/acpi/numa.c    |  8 ++++++++
 include/linux/mmzone.h |  3 +++
 mm/page_alloc.c        | 18 ++++++++++++++++--
 4 files changed, 28 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index dfb6c4d..d9e0ca4 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -626,6 +626,7 @@ static int __init numa_init(int (*init_func)(void))
 	nodes_clear(numa_nodes_parsed);
 	nodes_clear(node_possible_map);
 	nodes_clear(node_online_map);
+	nodes_clear(def_alloc_nodemask);
 	memset(&numa_meminfo, 0, sizeof(numa_meminfo));
 	WARN_ON(memblock_set_node(0, ULLONG_MAX, &memblock.memory,
 				  MAX_NUMNODES));
diff --git a/drivers/acpi/numa.c b/drivers/acpi/numa.c
index 867f6e3..79dfedf 100644
--- a/drivers/acpi/numa.c
+++ b/drivers/acpi/numa.c
@@ -296,6 +296,14 @@ void __init acpi_numa_slit_init(struct acpi_table_slit *slit)
 		goto out_err_bad_srat;
 	}
 
+	/*
+	 * Non volatile memory is excluded from zonelist by default.
+	 * Only regular DRAM nodes are set in default allocation node
+	 * mask.
+	 */
+	if (!(ma->flags & ACPI_SRAT_MEM_NON_VOLATILE))
+		node_set(node, def_alloc_nodemask);
+
 	node_set(node, numa_nodes_parsed);
 
 	pr_info("SRAT: Node %u PXM %u [mem %#010Lx-%#010Lx]%s%s\n",
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fba7741..063c3b4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -927,6 +927,9 @@ extern int numa_zonelist_order_handler(struct ctl_table *, int,
 extern struct pglist_data *next_online_pgdat(struct pglist_data *pgdat);
 extern struct zone *next_zone(struct zone *zone);
 
+/* Regular DRAM nodes */
+extern nodemask_t def_alloc_nodemask;
+
 /**
  * for_each_online_pgdat - helper macro to iterate over all online nodes
  * @pgdat - pointer to a pg_data_t variable
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03fcf73..68ad8c6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -134,6 +134,8 @@ struct pcpu_drain {
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
+nodemask_t def_alloc_nodemask __read_mostly;
+
 /*
  * A cached value of the page's pageblock's migratetype, used when the page is
  * put on a pcplist. Used to avoid the pageblock migratetype lookup when
@@ -4524,12 +4526,24 @@ static inline bool prepare_alloc_pages(gfp_t gfp_mask, unsigned int order,
 {
 	ac->high_zoneidx = gfp_zone(gfp_mask);
 	ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
-	ac->nodemask = nodemask;
 	ac->migratetype = gfpflags_to_migratetype(gfp_mask);
 
+	if (!nodemask) {
+		/* Non-DRAM node is preferred node */
+		if (!node_isset(preferred_nid, def_alloc_nodemask))
+			/*
+			 * With MPOL_PREFERRED policy, once PMEM is allowed,
+			 * can falback to all memory nodes.
+			 */
+			ac->nodemask = &node_states[N_MEMORY];
+		else
+			ac->nodemask = &def_alloc_nodemask;
+	} else
+		ac->nodemask = nodemask;
+
 	if (cpusets_enabled()) {
 		*alloc_mask |= __GFP_HARDWALL;
-		if (!ac->nodemask)
+		if (nodes_equal(*ac->nodemask, def_alloc_nodemask))
 			ac->nodemask = &cpuset_current_mems_allowed;
 		else
 			*alloc_flags |= ALLOC_CPUSET;
-- 
1.8.3.1

