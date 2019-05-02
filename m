Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10809C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C262D2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C262D2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6929A6B0266; Thu,  2 May 2019 02:09:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6438F6B0269; Thu,  2 May 2019 02:09:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50C096B026A; Thu,  2 May 2019 02:09:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C4D06B0266
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:48 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a97so728954pla.9
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=UmQ381Oi02UParDnCjy/auhbv+38BBncKGGBYSSyDUI=;
        b=UV09f6ITFyzOGffwhdRFWLzyOk8VzsclEAKxQHzn5KE4xqsao8wSUkIaAbrpCstCcw
         7GeSPgk5vm+mnJnu38H3Acye07yVBRfO+h/rh8aE9xbz9zJoziEo2d4gD9o51hr95DSV
         izKwMDak0haKYIvl+qNbkL82J40StyBIpc80udLjgJmbAJ5PnGY1Ce9oYbeGmWP0taiC
         sgY/nySkP0YlJ2LqEaZTgyUOPdOGOmL4aPZh8mzxNKz9DQNsKMN85kZiAdYXI1nQfGsk
         sjxy0AbNqsRSMi3+cPKOLGoZwM/DGiFQ/M23FRHPru2DX9aCEe2w96aZnyV6OL4HibMO
         UzUw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXUp2VEHzSLPPsaIojyhnRqf3VpwR2YuuGf8IhlrVJsgA/Vc/I
	iJ/IW4CxlL+bbfmVlgo941JDbK/bNiI/goma+EjVnD5EWeJWvTuAXGmLiQbVBZP5wTE8/Zmr8hz
	hZqz1JDEETIYAxCJZ6w8DmDYcxk63b3SYUGXaOiAeWCBX9ZEAwfBZugtWPahyV6nGOg==
X-Received: by 2002:a17:902:32b:: with SMTP id 40mr1868252pld.204.1556777387767;
        Wed, 01 May 2019 23:09:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUXJGq82I2Tx8pHBb264LyOyvtOWbyULrhNC1K3IkQwPPe6FFKin352W5IN2hB1FETJmak
X-Received: by 2002:a17:902:32b:: with SMTP id 40mr1868169pld.204.1556777386940;
        Wed, 01 May 2019 23:09:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777386; cv=none;
        d=google.com; s=arc-20160816;
        b=uj18CJDUFn05/y/nLIqJICP4thW96ToUDBY9rumFfI663+QoyRnZz8mMG3falsemNO
         cdf2TLiN5GlGRurIo6o3VCfyk63v0O+p2W3h7dPcso1JQ0X68uMHbfuCP/M1pdtksxv2
         JqZTEMaKNuuzJiX4cJQ+DvAGC+K6De6rxDwf0RRoz81CaLPaqfJKgU9lpBOlc43DVPS5
         AXeahxnWOwa3IGEE9C3rzkY0xZ03Fo160HD0s3RpsQC0X1cTCRBdGen8xK4BAb9g591z
         kwzxkmgAUCBUT3t1S/7Rul3eD94AmIe/v0nW9PAEP0PO8V8/a7EvoF+bm7pqosPtMqEP
         YRsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=UmQ381Oi02UParDnCjy/auhbv+38BBncKGGBYSSyDUI=;
        b=l7x+08PNuQ2ARoCCQ29WUCFRC38cYHMq8yHHgC19pxQ2Ik3f5cNKQ93N5qv8pzETgs
         KFl/9KYB7NExCHEA0aB53FQEuZ26uTqo/fcHAKwToICoI4JlJvGtRb1455zPlSFI7zUS
         AuMfcVBgxz3/Yaax6XR7O15+GvC3tAJ9AJ+9Ic/2R7XyW84HW3YDP2ZUmpRhLTNOvFDU
         5Af+JqAWkELkgIswWrCw4Xmn66QIJn857fzceOqlTU13pveAE7fG+o/ocFjCIIw0eo0I
         OaVhg3CztZ5yxpxo/BlCo7JFTHPWNH/wtIU+OsQFE46YrqvwPYOhpg/U87CcGoLYhOAL
         DsIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h11si20733196pgs.490.2019.05.01.23.09.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:46 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="154054353"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by FMSMGA003.fm.intel.com with ESMTP; 01 May 2019 23:09:45 -0700
Subject: [PATCH v7 07/12] mm: Kill is_dev_zone() helper
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Wed, 01 May 2019 22:55:59 -0700
Message-ID: <155677655941.2336373.17601391574483353034.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |   12 ------------
 mm/page_alloc.c        |    2 +-
 2 files changed, 1 insertion(+), 13 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index b13f0cddf75e..3237c5e456df 100644
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
index a68735c79609..be309d6a79de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5864,7 +5864,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
 		return;
 
 	/*

