Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 083D4C04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCE7120856
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCE7120856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70BF76B000E; Mon,  6 May 2019 19:53:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BCBE6B0010; Mon,  6 May 2019 19:53:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5869E6B0266; Mon,  6 May 2019 19:53:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 22AF96B000E
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:52 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 94so6339294plc.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=evrTBx4MEJBYRhHlPVYfXUeUNl0Zqok9NmwymN9MOHo=;
        b=HmbAy0SBDrEnU8jkXae9wVFpurf571IyvXNB+IsIZXmfRTBdaIhKvf2wBd/WBsaZUv
         mgifaNbzJIGxKD4kjzZu1PkZ31T7dJSOxFEQdsRDwBCCxnDtm1ZeccKnXsQz7D1fNNGo
         E5KNmybbABoyspVNFx6KvnzmuL1rzGi4WTFHo/ha50rMinC9Yj+tnac+larkweCqg9ZU
         1/6h8W/pvVnCtj/noWYjBACbWU/7EBrlttjcWXNGUeqP/NOrSEg0MnQCtJJfiBDXyWI4
         CubfbWtRwPXHzfXrrTfG3unATPkyyOqXT9myZKiB3OQdVKEKPPXjldVzY53sQriYN0XX
         o7Dw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWY5kVlLOY1HSOIVSrUBOv/uCp2zKDUr3F+hHIibwFtfTFYl6gW
	5j+sr99FAIi04LyuXxkcs4lk2ymPuZTkgVlU3BUFlPrCo6Aw1meuOIwQalMMAKUPNvLSNvawDKi
	LMR4q6qCI6N1uvG7JhI/0DLcX1FxQUKMsOOyibNMGJnEIn4UdORiewSvRW5DRgTaUAA==
X-Received: by 2002:a62:2687:: with SMTP id m129mr38417848pfm.204.1557186831808;
        Mon, 06 May 2019 16:53:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfpRJLTjXGgBLWYpi32iEDsvgkHAmAmlJDx4OYZbP9O6rl0ateUZe4PIJqbSW87J7UJPLa
X-Received: by 2002:a62:2687:: with SMTP id m129mr38417802pfm.204.1557186831038;
        Mon, 06 May 2019 16:53:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186831; cv=none;
        d=google.com; s=arc-20160816;
        b=BgHTpESnTosrF4TczXX5SsMQJe5UsfApcsWzTndgKZ26I/MaBQY+2ZGuXRYimEuJwY
         GAUUWg2xEwqH1lYgbUCCP9hRHkHhhIdsVKWguS8nG8LXOydOwxI5a5n6Gl/HUGp/KCwW
         qGs5gUGpxkMmkzyrBmy+r2m5vy7V61z3u/+KUyhDHwBEMmBcajcjHDnFN9FGEP+PK/tt
         uIiQh340JSKOEjmG0VVFbFcALP6yyESl3T6tDMUe7X1Lh/MJp8y2Qg2JkmM2qdB4ouem
         7PWITJrIvf5QxOWod53rmQtp3RV3o/NyeOXzBFxvU2+2K1+Y9Y4JT33AbcHNKA8JhP+z
         6BkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=evrTBx4MEJBYRhHlPVYfXUeUNl0Zqok9NmwymN9MOHo=;
        b=Kef7aMz/M3ZTjlksawaZQFl5ckMJkbdq5WP5SOZxIpC4JJLBkCfHP8rksk0TkXNkZ0
         ORuvwPRpbdfAYrCgII1tFPlNvrf60EXWA44tpqPaiBC9poeBtIymj83N05QI8y5Kpz2R
         S6HBKlwGn2MbzsFuUwdYRUBCcrLXqDhp3kZJGCiDI2frCH/EOmBpllqU/8Y3Aqw8vGgk
         sTU2jgAdZNkKclusMwLQvPvnw630mqVL4fbRz17xvNRmedc6RztXup/sqEF//+k/zGEe
         PdsflzE/6VibjAG6WSStmaOgxNvziF/9GL9H1LUpf0tBMo6sZkoSs8FACMi4QQKHwDE/
         FYYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id cg5si3112094plb.47.2019.05.06.16.53.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="149002609"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga003.jf.intel.com with ESMTP; 06 May 2019 16:53:50 -0700
Subject: [PATCH v8 07/12] mm: Kill is_dev_zone() helper
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Mon, 06 May 2019 16:40:03 -0700
Message-ID: <155718600386.130019.2834681306356516509.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Given there are no more usages of is_dev_zone() outside of 'ifdef
CONFIG_ZONE_DEVICE' protection, kill off the compilation helper.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Acked-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   12 ------------
 mm/page_alloc.c        |    2 +-
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6dd52d544857..49e7fb452dfd 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -855,18 +855,6 @@ static inline int local_memory_node(int node_id) { return node_id; };
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
-#ifdef CONFIG_ZONE_DEVICE
-static inline bool is_dev_zone(const struct zone *zone)
-{
-	return zone_idx(zone) == ZONE_DEVICE;
-}
-#else
-static inline bool is_dev_zone(const struct zone *zone)
-{
-	return false;
-}
-#endif
-
 /*
  * Returns true if a zone has pages managed by the buddy allocator.
  * All the reclaim decisions have to use this function rather than
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 13816c5a51eb..2a5c5cbfb5fc 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5864,7 +5864,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
 		return;
 
 	/*

