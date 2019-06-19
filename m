Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B400C31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDC5320679
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDC5320679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92C896B000D; Wed, 19 Jun 2019 02:06:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DDCC8E0002; Wed, 19 Jun 2019 02:06:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F4208E0001; Wed, 19 Jun 2019 02:06:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC0A6B000D
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 21so11595603pgl.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ooM3OIIwAC3fXTsl2k3zrap55/PII7cOjsSf5DeeT6Y=;
        b=Rel4wBXu/rycbXnvG84P9xS/q1tuKLMv+FcoqkoHO6H6KoijPM5SdPuR0KH/L12VKc
         GY8ALRJsl5CvnPXf8S7fm9Q4Lgo1YdsOdnK9opN1+hxNOrdSVBfxjD/7c8pY3RUYZm0A
         X8G7e7N8lwIVPza2qI+wayfVM/9wfRmQ0tat6BRmiU4CEtTepgYoPK++QLJQ3jH2kI8X
         zNtujaKZYZR+Or2A/Ov4jeQLKmoxuINjylqwT0YhMSQVQDTxpk+/MSEKaOobsLIz/59t
         vfYP9WxOyLrSK4NYAlfg7P/CtLrael6wDs9US4yjh3/Fq/AsF162bNYtsvr7rfL4eo8q
         cQeQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWN95S6TmzXIDSecHRKU77aKisfvP3mCquttziCEo12223cnc2a
	MFOWKVw2T+rQKls8QiAkSrwdEdB5Or1sR1PocsPeqnFSpieur93p3eUxTalNOqVlyCvFsnqrBvw
	wQ8MfY7sr7yVIl+cvj4TV4SR5tu4QPGVehGOAz7Ut40szmrJKBaIphx4FEGLdUte68Q==
X-Received: by 2002:a65:4841:: with SMTP id i1mr6098623pgs.37.1560924390929;
        Tue, 18 Jun 2019 23:06:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4NxtyrCZLa2R076Wg10jEiYggRvWf9xmHxVHfAc1ITDUW9L14L/vw8EVjqmA+mLmLIOWJ
X-Received: by 2002:a65:4841:: with SMTP id i1mr6098573pgs.37.1560924390144;
        Tue, 18 Jun 2019 23:06:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924390; cv=none;
        d=google.com; s=arc-20160816;
        b=N6tIlBKlyBiVv5sH1CerSC5yCn5yMqnLsdglzOnEMQnhoJA+J8XJLwr6LyAVD/oTse
         kiZxM9DsO+gEa7gh9Fo6+o8lO/cZ5pG4PuD6u43voxUKJ824rbhZl7Kr/uTS2SWHEcun
         LmnquINHnbitgzyLR/Cta+vKYTMdJcmCEl3k9uSnthoBm2lAFs3k0T4DyVC/kwSd1MLd
         wfvWp8YK/u133JbD5GJ7n/xG36ulejF+BuK98XxyJux+6rugCJkAtEbKdsvwQzRl+UM+
         kPzvroRX5RUO1Re7PPUpYsD7kNgNTgOTt67YUZ0WnkcJiB1nyx2VLaC/p8RPtSO0X2g6
         Wm7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ooM3OIIwAC3fXTsl2k3zrap55/PII7cOjsSf5DeeT6Y=;
        b=kzT26rrEdx6NMKMSsERHFwC/DGX3x3+cgyNjy0JeEqXeuHZdGzUaRz5zoG3g2gORzP
         5s3QsRjO+a54mCoM6Bhgz/eZRKGHT+U/049tXdQJK2x4682ax2up3f+TTJnJwcZbitYA
         yABXljdrWHUE14jB/dvE4NUIXphmN8jaAZpRls75BpgMIgop1wjuIiN1gl72mI1gwFka
         2p/XPWC5YzZClLcph3GRUyT1eNxR61qzJrCri45D19yxZc7jU+1nwd7NPLXRepZUV5Df
         jgf8wl8AhF59M7rA+NDdt74r2ZtTEmVJliwQTSvVyOw1oCR30UvDmjkY3HyLaPRd5WFk
         QUdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id w23si15066818ply.230.2019.06.18.23.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:29 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="182640932"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga004-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:29 -0700
Subject: [PATCH v10 07/13] mm: Kill is_dev_zone() helper
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:52:12 -0700
Message-ID: <156092353211.979959.1489004866360828964.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <156092349300.979959.17603710711957735135.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Reviewed-by: Wei Yang <richardw.yang@linux.intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   12 ------------
 mm/page_alloc.c        |    2 +-
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c4e8843e283c..e976faf57292 100644
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
index 8e7215fb6976..12b2afd3a529 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5881,7 +5881,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
 		return;
 
 	/*

