Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C5C4C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEA4E206BA
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 01:42:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEA4E206BA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81C446B000C; Wed, 24 Apr 2019 21:42:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7274F6B000D; Wed, 24 Apr 2019 21:42:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 556DE6B000E; Wed, 24 Apr 2019 21:42:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF536B000C
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 21:42:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r5so6856852pgb.11
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 18:42:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=R8qhdg+2AWOPlfSzyMslwEMBF9euYTiSJ41K7L0E3wQ=;
        b=dq+L2wGHCpyOKlO0EvNVoDpswapmk2DgM/W1CZHB3m+yjKrjC9z7+iMBMEVVkXyiAz
         R6zLkKjwjCmSroW92SSNK8g8nsSCdMCEcL4+Le8olL8j5tTg1bJd2qwLuFg1ouObvarB
         Q8TqBFuEDLi8GtAJyrB2QY64VQvjqlMfNyo90SZPvFU8F+bX3pyKn6MUwKwMSeOxeC2e
         2INntPRgOUvFBPV5QIfT7Kh9nIjFMNaN9W31nt240uidPxSwWbkh7OSV/iJPIJEazbzn
         x7QEEezrGEb1x7q3CcOQ0x8G77YhOY56sF/Sz6hTRLQQbHijkMIPFLycgqvNJEvKk8H2
         twGg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWzU7l+/cILIqCVfy2XKTgevMywqgkZlB4mPRUVjXSEt5U2rpXH
	iC4u+SrTBXZeQXyrp+8shvg8PYsjK47qUHQFJM06t/2ntzThc6pJfwGEcG8DysCGeQk+w07j9fJ
	XPNMHGaso85Px1snDGMa17HqjWRrP3gT6h9vaHqjgjCN3LKAdNchYV4wksPwaHh2RcA==
X-Received: by 2002:a63:c54a:: with SMTP id g10mr10468829pgd.71.1556156571761;
        Wed, 24 Apr 2019 18:42:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRw9+kkPK85Rt2LCnz9xxehq4NV8zhocSVdEC/M/b1gMJORbTsXCwGIznDbSKeDu6R+UEj
X-Received: by 2002:a63:c54a:: with SMTP id g10mr10468756pgd.71.1556156570712;
        Wed, 24 Apr 2019 18:42:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556156570; cv=none;
        d=google.com; s=arc-20160816;
        b=y6sB7pnpyJWHVfO4rlu5R/rjAxrMGU6u4E5Magu6JlB/anykIBChIelo/os1af/AcW
         VegDtIBHU2fw+MFldrBYIBERZ86dldmJS5xQ79qC0CFjEnin5DsCp17EnpmGhmeU7WxZ
         S1GT4eKmnnHx1ZqIp596864SCRGu/77ldkrHAqzhPBL0P9NnZ23gAAUAK3lvHb8gLnmR
         fIYb1a8m6yhJuSUMP48eJ7DatNtomv4dGDLt3jbn0jvE/IMM8H01nRV2uHu3h6zE+dT4
         vXUDCO1/wEaY6z6aF+EXH6TcqSf0eXYoS8Em9QPPGJs4RCDPFZN3kuGa9Mr6h1t/me2e
         KVhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=R8qhdg+2AWOPlfSzyMslwEMBF9euYTiSJ41K7L0E3wQ=;
        b=tqXCPINkNh5nILy03ayHKb9U54iHRpqUgM9UQB7N94/nmcirHoPvcHFapNRK6Q8+wr
         j8qXCFvC+Miq7eyojI7BJkfFkAsjQD0fzRMaj2dVrau4IaVV58n0lIyV7G6k7FTMmf67
         6jEI1aHmnant5ARrjNn3f0wHLqhia07soXvvxqE7LZDAfuiwhqyGcHHGP5Lxl3BhO7UZ
         dSm0f62xuq8q8xGk9cPimT4HBhif0dczE9F+HKQ+UWY/6EZ/+cjZEmSarN91TmRRoiUw
         LEfF0I/DhEiGVMlEQKSXMRkzLA2OyZCXj0ypudr542n3fIaIKUuxVF6zen596LCeAG0L
         0GZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id d3si21134661pfc.278.2019.04.24.18.42.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 18:42:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of fan.du@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=fan.du@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 24 Apr 2019 18:42:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,391,1549958400"; 
   d="scan'208";a="152134261"
Received: from zz23f_aep_wp03.sh.intel.com ([10.239.85.39])
  by FMSMGA003.fm.intel.com with ESMTP; 24 Apr 2019 18:42:48 -0700
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
Subject: [RFC PATCH 5/5] mm, page_alloc: Introduce ZONELIST_FALLBACK_SAME_TYPE fallback list
Date: Thu, 25 Apr 2019 09:21:35 +0800
Message-Id: <1556155295-77723-6-git-send-email-fan.du@intel.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1556155295-77723-1-git-send-email-fan.du@intel.com>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On system with heterogeneous memory, reasonable fall back lists woul be:
a. No fall back, stick to current running node.
b. Fall back to other nodes of the same type or different type
   e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3
c. Fall back to other nodes of the same type only.
   e.g. DRAM node 0 -> DRAM node 1

a. is already in place, previous patch implement b. providing way to
satisfy memory request as best effort by default. And this patch of
writing build c. to fallback to the same node type when user specify
GFP_SAME_NODE_TYPE only.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 include/linux/gfp.h    |  7 +++++++
 include/linux/mmzone.h |  1 +
 mm/page_alloc.c        | 15 +++++++++++++++
 3 files changed, 23 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de..ca5fdfc 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -44,6 +44,8 @@
 #else
 #define ___GFP_NOLOCKDEP	0
 #endif
+#define ___GFP_SAME_NODE_TYPE	0x1000000u
+
 /* If the above are modified, __GFP_BITS_SHIFT may need updating */
 
 /*
@@ -215,6 +217,7 @@
 
 /* Disable lockdep for GFP context tracking */
 #define __GFP_NOLOCKDEP ((__force gfp_t)___GFP_NOLOCKDEP)
+#define __GFP_SAME_NODE_TYPE ((__force gfp_t)___GFP_SAME_NODE_TYPE)
 
 /* Room for N __GFP_FOO bits */
 #define __GFP_BITS_SHIFT (23 + IS_ENABLED(CONFIG_LOCKDEP))
@@ -301,6 +304,8 @@
 			 __GFP_NOMEMALLOC | __GFP_NOWARN) & ~__GFP_RECLAIM)
 #define GFP_TRANSHUGE	(GFP_TRANSHUGE_LIGHT | __GFP_DIRECT_RECLAIM)
 
+#define GFP_SAME_NODE_TYPE (__GFP_SAME_NODE_TYPE)
+
 /* Convert GFP flags to their corresponding migrate type */
 #define GFP_MOVABLE_MASK (__GFP_RECLAIMABLE|__GFP_MOVABLE)
 #define GFP_MOVABLE_SHIFT 3
@@ -438,6 +443,8 @@ static inline int gfp_zonelist(gfp_t flags)
 #ifdef CONFIG_NUMA
 	if (unlikely(flags & __GFP_THISNODE))
 		return ZONELIST_NOFALLBACK;
+	if (unlikely(flags & __GFP_SAME_NODE_TYPE))
+		return ZONELIST_FALLBACK_SAME_TYPE;
 #endif
 	return ZONELIST_FALLBACK;
 }
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 8c37e1c..2f8603e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -583,6 +583,7 @@ static inline bool zone_intersects(struct zone *zone,
 
 enum {
 	ZONELIST_FALLBACK,	/* zonelist with fallback */
+	ZONELIST_FALLBACK_SAME_TYPE,	/* zonelist with fallback to the same type node */
 #ifdef CONFIG_NUMA
 	/*
 	 * The NUMA zonelists are doubled because we need zonelists that
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a408a91..de797921 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5448,6 +5448,21 @@ static void build_zonelists_in_node_order(pg_data_t *pgdat, int *node_order,
 	}
 	zonerefs->zone = NULL;
 	zonerefs->zone_idx = 0;
+
+	zonerefs = pgdat->node_zonelists[ZONELIST_FALLBACK_SAME_TYPE]._zonerefs;
+
+	for (i = 0; i < nr_nodes; i++) {
+		int nr_zones;
+
+		pg_data_t *node = NODE_DATA(node_order[i]);
+
+		if (!is_node_same_type(node->node_id, pgdat->node_id))
+			continue;
+		nr_zones = build_zonerefs_node(node, zonerefs);
+		zonerefs += nr_zones;
+	}
+	zonerefs->zone = NULL;
+	zonerefs->zone_idx = 0;
 }
 
 /*
-- 
1.8.3.1

