Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 743AEC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F5C120830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F5C120830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAD786B000D; Mon,  6 May 2019 19:53:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E37206B0010; Mon,  6 May 2019 19:53:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D56DF6B000D; Mon,  6 May 2019 19:53:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9E87D6B000D
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:46 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id x13so9013610pgl.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=T4hW7qSH622eyy5fNq13SROo3yEstLTCwZGD235V01w=;
        b=P88lUen0r56MUBKw9BuZ2R5nZ4L45dHebwxmi9wtemGKFhkzyTfjQyhU+LafGj7XwH
         rWKluCK0sQlroat4vObwV1RPkC5FnTevTDLRiLrzw4r3o2d8BRSS6rfmswo31oYT5btV
         HOY337J/OcDQEIBGwygaaZsMzWPHQIMH/5loGxwbp15fTVqks/B62Bm1/k/db7ct+48N
         MunODZyp3+sPMDwTZy2+6CuRW5UrC2RtAk55NAFvlvXRHSMtDAaRyfYX0VEMM/x0+gkF
         nh60lr3F2o3M3dlnSYv2hwJfhRoAIzYKfRxuKLJqkEXV5SZ0lq30oCLmAQhTfqSrdB6q
         xc2A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXv+Fb9GHA1tbrzAVyQiRiWQpJQ6a62g+3geVSLJ87B27jURlrs
	fQ6l5B6HPoyLGXwiSIwidDXwKTlW7DzeXrJ51E27WBPTUnIRO5scgZB3uoMxyAbhoku8qfP5GKM
	k0ozZ2rWeH9DMMsK5oGZ/dtlypD9JUxEMdWoaUzm/20DW+1KyBQZohL5ZvLWrnxpGgw==
X-Received: by 2002:a63:1d05:: with SMTP id d5mr13066668pgd.157.1557186826321;
        Mon, 06 May 2019 16:53:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyDKFU1nCzc04nw251kTrQAojxxRYaTYGqookcPUjsqFC2K8coomVaqS9AlsR+BDAdyfbDW
X-Received: by 2002:a63:1d05:: with SMTP id d5mr13066626pgd.157.1557186825610;
        Mon, 06 May 2019 16:53:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186825; cv=none;
        d=google.com; s=arc-20160816;
        b=xsER56yj+4i5jCNDO4FP4yeMOI4X7YPRfSbWlC49WX9fmkiWvXSzxKhGlQkUQQ9fCA
         405agZaeWlzSCOsJ1iO3inwb1c7PFEmvX4X3T7C8oEtEzqcD9f+e2G4MAAP9ugViECJ8
         Ngh1YQ990Mg3sVdR6pqa4sgwYE0rMbzGyE17pXtskH3doNHhXte/GHQp6ifjnBMxi6R6
         PFkWyvDj4JMDA4hfa/STkwiFec9cVUUeJKzy7V+mWfHaX8+tw8jcTZGdO9Pc+jMteogy
         fBhy9m5vjMKRXCxbTLSR10ZOPcQk7ZoCx7d4ADS+TTCeGQamW10oDGcP8Pp4ohTKDlGr
         PJBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=T4hW7qSH622eyy5fNq13SROo3yEstLTCwZGD235V01w=;
        b=XzcVDw3tnIFrpsrI8s7g01Q4WDGMkMv0+SvFPXp5zToThsOQejZUkm9dnpHJM9IGqf
         I9akMTlQOsMk8xRYlFyn5CA41N46hTOEC2fTVq2iCJjcYlQDeojbMG9bnMHadb2vKDit
         b0ApIq01n8mxMFIpw6kDpFwYtdA8QwJdYvTFFImpSRsQ0m1F/3D4Ac0yLR7cfGWqkEmO
         xjdKfF19Tb248NWd9Z5xhguy7Cxhyc5aWeCU5a6EWvyyUR4ckG8swz1bEhivosObkpvH
         uCbp+OutDFTf0Si/kE8ynWaeLgas4KcD5SkoRiG8dRGWJlGtenYKTZOKes/xO3QBwto+
         4KXA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b3si18437783plc.106.2019.05.06.16.53.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:44 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="230153605"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001.jf.intel.com with ESMTP; 06 May 2019 16:53:45 -0700
Subject: [PATCH v8 06/12] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Mon, 06 May 2019 16:39:58 -0700
Message-ID: <155718599876.130019.1344795832811586975.stgit@dwillia2-desk3.amr.corp.intel.com>
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

The zone type check was a leftover from the cleanup that plumbed altmap
through the memory hotplug path, i.e. commit da024512a1fa "mm: pass the
vmem_altmap to arch_remove_memory and __remove_pages".

Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: David Hildenbrand <david@redhat.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory_hotplug.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 393ab2b9c3f7..cb9e68729ea3 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -544,11 +544,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 	unsigned long map_offset = 0;
 	int sections_to_remove;
 
-	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	}
+	if (altmap)
+		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 

