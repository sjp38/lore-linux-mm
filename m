Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E7E5C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F2E920663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F2E920663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE19F6B000E; Wed, 17 Apr 2019 14:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CAFB76B0010; Wed, 17 Apr 2019 14:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B801A6B0266; Wed, 17 Apr 2019 14:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 825136B000E
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:19 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x5so16003272pll.2
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=GA3JZMiq0PcBxt4ve/+vCKmPStNhj3ad7dMF+slvpo8=;
        b=ZdStBBX5T9MFARO1huE+SwHpMumfGqQHxyG5oNbSngK1jG8hJGWUyL3K1cA3+ypvDd
         SVoyRq53IOxKHklTbOojr6x5a8sGA5DqaewdFSKy+6bQTrt9EX0398SHVDsCnpGBt13A
         eL8WSoBdluh5SwYU5+XKifO9GbWrjoSaeRuetNeIG+In5Bo0vsuTm8b4J/wijgkcJW5x
         OWDL8My2sulHKYxC2Sql06cqwLnEw1EcOPmzQpbCcuMamRLPO4MMJ3hAZikWCiRO98Sh
         bA2/Ym4F6J1b3lvUQzelqjHx3r+3LBUAOS2ONLf/q2iOx8xU93l34B8Wcpvvp2Aqa0C1
         s1/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVPwvKrqoReMaNCxwdxZ+jUjRDr5GpFKztw2FxP8lThAm62of1h
	43BR47OYBYDRjA5Sa9FCr6OGhnGQ6ne8zEjcs93lMe+ZqV/LjsF8suUALZsUOYI2qb8gchJWLYn
	KGauGk3GP4yFwuSkaPujA6lCdthwSjqRmIBLPm+BHDPtilKPteoMAArVvsU4iBih/Eg==
X-Received: by 2002:a63:8142:: with SMTP id t63mr80205130pgd.63.1555527199201;
        Wed, 17 Apr 2019 11:53:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJbjgsPMDXMfMgVdtyaQAqwEsqFrszUi2x/BdeLUvqFiXc6kt/nuyqt+dqVXUFTRa0hwsa
X-Received: by 2002:a63:8142:: with SMTP id t63mr80205079pgd.63.1555527198549;
        Wed, 17 Apr 2019 11:53:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527198; cv=none;
        d=google.com; s=arc-20160816;
        b=rfnQ8DvUm9j2ALIYF/3FMCtnnmb/yWgGuPuOSAX3WwpKE2eJix1Q7SfUIr9rOdB1Y+
         BsztZgeaoUvI8a+tQDoCt0bgZdBpUr7XA6jj+1LpXogqotRkJ3BmZcnFaP8RNoG4Ra9E
         r8Tb646lQxWnduF56ly9DSAt4v05M9VrngGV88NncmzPRfGM+jrRyNUkqQK3/eMsv43Y
         33vC6gQk3n/iE+iaNWl0vnfMcmVzi4Pc9LHw2ruS90N6E0dbY0l20isx3xnwwHFij0MI
         Q9R5V4EoGH9QPpTL6r8EqLOMEjY6rMaDLHOLKQ6L2R+CGQ/Udc5JEPly4tHiWksWmZV3
         Lijg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=GA3JZMiq0PcBxt4ve/+vCKmPStNhj3ad7dMF+slvpo8=;
        b=mu29tcwc5J/ugYmejevXZ7LP5nfv0RkTDwXXvb+0W9bp2Li1xZkL/5RExJmTW/28fY
         SwCtQRd/oZ9pFNrZfisw6m1B5yYDhk9DFcp41As0inu6jzzlVxRzormLM5E6Cwf1I3sP
         lNQRAtttt5zHKwg0UGUsGGXKyRdBcD6cKK2qkiKyr7Ql3SiNZhQmLDg5iJRlIj/21CmB
         e0UO0bUInFqQPcW0Oxx3Y9BayQquKGxvIXcegNHbbAwVyzcEI+LEkthdbRXmAclHoCpb
         F/optXFOAAjbPAqOmOeC66XuC2iNpki4dxw3p/29xTx00aRBhHVREl5R1hRoYHSZGBvG
         +rBQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f2si26939614pfd.17.2019.04.17.11.53.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:17 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="135207587"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 17 Apr 2019 11:53:16 -0700
Subject: [PATCH v6 07/12] mm: Kill is_dev_zone() helper
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:32 -0700
Message-ID: <155552637207.2015392.16917498971420465931.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
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
Cc: David Hildenbrand <david@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
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
index c9ad28a78018..fd455bd742d5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5844,7 +5844,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
 		return;
 
 	/*

