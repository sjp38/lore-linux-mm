Return-Path: <SRS0=0AWy=R2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D421AC43381
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99442218E2
	for <linux-mm@archiver.kernel.org>; Sat, 23 Mar 2019 04:45:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99442218E2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1C1216B0008; Sat, 23 Mar 2019 00:45:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 05A8F6B000A; Sat, 23 Mar 2019 00:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E62CD6B000C; Sat, 23 Mar 2019 00:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AE87F6B0008
	for <linux-mm@kvack.org>; Sat, 23 Mar 2019 00:45:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id g83so4272065pfd.3
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 21:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=kdFWjbNMrgHE4IiWbQnApU5LlKLCfxjq39LREWERgU0=;
        b=UPaVQtVF9tk21o26Jb7PMaPpXyUTGIxpfVDXu0mX8ckDEHLv4X6zBJFrPlsa+9dS4F
         FsriMGuXeQEsSbRpwtiTK06KVwcnqeYCl/R7B74MBn04D9mUmo99MYHd7nH0SzBayK09
         XUJvmREKbszJzi0GCksB+Xaa40fgW6RqEZFSHPwHD4Pr/bllUAR6uI/db8kM1F/VekJV
         yOncF0Z3bogRpH90AoQHNFwhrSAW6hIF8BMQZwVzAwgQEn9fREstQMz5BJyLbhkO3fbp
         nhHYIbVGrzLKFa0rtFau/wE7YxK43wpPNTVyVN24nfqP4u/ewPG1tbZ+BqBlEaPlxErk
         nihA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXGi7auXfCLsN8Xb9IUA2KQD82615zPcpyjYW3nitTBikkB/ZzR
	JcDoHyv5jpu7knVHeIJ8pBxU5hZ8FSmDATuPMp01bzLHL2/2NAQGDdjJjCiIE7LLDhKle0JAf3R
	kQdXowgvtFbzV+aA0dyuLmNTzRx5eNObx9HbACVZNiYLohiDRCr52SLS+V8n4D6+DZg==
X-Received: by 2002:a17:902:203:: with SMTP id 3mr13429256plc.336.1553316306406;
        Fri, 22 Mar 2019 21:45:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzVMhQEF+c7eLgO2II+Jax/YEyuN0+LhEmOXu+loSq1yT5eDsnEmLIYulTuErQmNjq2hpHh
X-Received: by 2002:a17:902:203:: with SMTP id 3mr13429196plc.336.1553316305387;
        Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553316305; cv=none;
        d=google.com; s=arc-20160816;
        b=qTSxjc7aSibVyZ6k0lsUDtV9OYz9ZeXOPYB5glhIAfzMjEqz1G0jw3Hyi2vmgGhY/+
         fSBTX9dri+eBGYaH8JkJHpMJQkheElK8q8ODiFRxw74KZwmNEXbUvpPhQ/lm+962vPZx
         ohH2iJQtL4ShadXx4PZfWqlJ+1m6giDZEOCgtrPIjHRif83KBlh5deyu8MfoaAU9nrXu
         kU7nEQA8+faAuA81lMOIDEsElbK3XFYOgdns5eDLTJfg0hR1PAkfM7Av1M73noUBN39/
         Wvb/uBvS1MOKrHgvzRxtotOUMsL7199MCy6v6tK3/VxAl6ckNgSTQyRAygB4Hjfy+O1C
         OrlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=kdFWjbNMrgHE4IiWbQnApU5LlKLCfxjq39LREWERgU0=;
        b=uLmi+P5rHOzQmHvglU0bhLkGE3VaRLE/M+O6iGb/EVojZS9Qxh9iqf9PvCTrc2C6Xc
         57DSmmgUi112kvVqAyDNJXstXJBpBhVvxq7TZwMGcYwZyzlA+vP6NYoF1wqyCja3Ujq4
         bB2nKvhv2KJRWu7r4vMsWwJmk4UChGRxjOka5ZHoztSSVkcxsHBgx/9TDmFsagy208kC
         l5aBvif6TzXs03disyMbtujZdNgnbDttE/gL+/VDRFsg47HKCnClZcK8zYk2glzEGzlP
         /+jS/3HMa1SdP5WLzqO23yAx3TTi1LeOUZdABprK9aUGQspmat3GK0pp2Ku2J8Ya+2j/
         PPOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-43.freemail.mail.aliyun.com (out30-43.freemail.mail.aliyun.com. [115.124.30.43])
        by mx.google.com with ESMTPS id 186si8479616pfe.262.2019.03.22.21.45.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 21:45:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) client-ip=115.124.30.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.43 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R661e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01424;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TNPuxAM_1553316293;
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
Subject: [PATCH 03/10] mm: mempolicy: promote page to DRAM for MPOL_HYBRID
Date: Sat, 23 Mar 2019 12:44:28 +0800
Message-Id: <1553316275-21985-4-git-send-email-yang.shi@linux.alibaba.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With MPOL_HYBRID the memory allocation may end up on non-DRAM node, this
may be not optimal for performance.  Promote pages to DRAM with NUMA
balancing for MPOL_HYBRID.

If DRAM nodes are specified, migrate to the specified nodes.  If no DRAM
node is specified, migrate to the local DRAM node.

Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/mempolicy.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 7d0a432..87bc691 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2339,6 +2339,7 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 	struct zoneref *z;
 	int curnid = page_to_nid(page);
 	unsigned long pgoff;
+	nodemask_t nmask;
 	int thiscpu = raw_smp_processor_id();
 	int thisnid = cpu_to_node(thiscpu);
 	int polnid = NUMA_NO_NODE;
@@ -2363,7 +2364,24 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
 		break;
 
 	case MPOL_HYBRID:
-		/* Fall through */
+		if (node_isset(curnid, pol->v.nodes) &&
+		    node_isset(curnid, def_alloc_nodemask))
+			/* The page is already on DRAM node */
+			goto out;
+
+		/*
+		 * Promote to the DRAM node specified by the policy, or
+		 * the local DRAM node if no DRAM node is specified.
+		 */
+		nodes_and(nmask, pol->v.nodes, def_alloc_nodemask);
+
+		z = first_zones_zonelist(
+			node_zonelist(numa_node_id(), GFP_HIGHUSER),
+			gfp_zone(GFP_HIGHUSER),
+			nodes_empty(nmask) ? &def_alloc_nodemask : &nmask);
+		polnid = z->zone->node;
+
+		break;
 
 	case MPOL_BIND:
 
-- 
1.8.3.1

