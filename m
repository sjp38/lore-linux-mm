Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 30665C04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA926217F4
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA926217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 952246B0010; Thu,  2 May 2019 02:09:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 902D26B0266; Thu,  2 May 2019 02:09:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F25D6B0269; Thu,  2 May 2019 02:09:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A05D6B0010
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:42 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x5so700424pfi.5
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=mV0vBGkFbHqI8MQAzWF9l08qAvVtY/5fx7U+Bbzbpug=;
        b=IqNaWuKN+U3D3LKsKS42qJ3VbcLkHAI6b0Y4l/twsSIvuNYJGtEWhX3u0NQTczWYvQ
         M4aHyDXx/FofqsH5JraePYsLbFkSq9WM43ou4XAkbft7gUBqoSCb0wLX66/GCLvX9iSk
         C8z0ceyrl375Ur4jkL7QLkyXvMXEkIv1Ymg9KEhbbxnAKUtHA0mX9shQHT8E+y5sxmKI
         YHumgBVKrA0PBVU3MacQe1WeM2RospDc/x1QnAlCDjCEe2VbESz0H/h/lzFtm1v3gx/B
         Q/rH3Jf+1WIRoNZVnyhhG4Yyqz0m1y9mX4DJMa47rJiW7fl2QPEG8Swf97LpCxZB6ald
         uCNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVwKqNXN7L9Fp6vWk12etpL/SAVNkW80Aeg/ybh7halVBbI4s4w
	l8a5E060+srZsZ1XZZ0C6a3XkeGLE9/Ls4uYzQNTuMWaUTAkGfIxzTR3S9G7dQSvDsu2/Jxwls3
	GFV1clcajvPnie6iQre8SHzIyRxVX1Sqt3Xa4Fc+4F/x2/B1YP0b2L38B7FyeTz27TA==
X-Received: by 2002:a63:5947:: with SMTP id j7mr2204115pgm.62.1556777381994;
        Wed, 01 May 2019 23:09:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj5vHnCi7d47Z8XFvg6UUihPyY0wX4h8nWEOeXOVrzcHBdM+CfiUtYj/bHygCYWt+09QSR
X-Received: by 2002:a63:5947:: with SMTP id j7mr2204051pgm.62.1556777381236;
        Wed, 01 May 2019 23:09:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777381; cv=none;
        d=google.com; s=arc-20160816;
        b=pu61BqP5O4u5PVmVNtbXFZgfDLc1EuqDL0+4MXGBoaoFU4eWEiVGr5VahsS1XLibrt
         skfrEOp94PXT07oZFga+vEqN2/gPtR8POYYBNgdMcyJsvZ6sJXQ6qrUePe/1O53NkwyW
         Qr6TCzuweK9UgVRIY+QIccVtoiesQyX0wR+3GyUtPX7gb294zgM6koT+8mU+tknAbDeD
         Ul7dHJONazeg2e8v2Yl8TiBueWVDPK3+0n8DVeKALMerQp+qzBX3Q8v5sMUvyHFritj5
         92CBLOpEbLZdu66iWxnTywf0nDuetfMLQuo0T/y+zjt5cTNmE/1PTw35nFvovDKqAegU
         5vOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=mV0vBGkFbHqI8MQAzWF9l08qAvVtY/5fx7U+Bbzbpug=;
        b=RwH3l2UlTpnzDVltvrYv/kpmMFfNKCZ4x9sdipZUHPwW7yn3veL9mX54b1of1DZ7g+
         uxezIMd1vdye7U5NoGhroPBrvPF2hmVfXSBRTOnj1RefxmBddTuucR2fny06r4JVvPmg
         KJlkfRN/4pVk/4FdSLfT0xRQDfBe+kyMCrhnuEEt/4HdnE3J2QLACXb0UIe5QJfHKN0v
         pYtBUdQdNkE95h55QgPo+vYhSI0zrrLrV5W89FppQOJJcJVyjO7qT4ZRRsAinjDm0tLs
         4oaktr2txj3c2JVwzvQcVxXGk/goiIRgc4d0UkCwlOzkpbReWAjezXxv8g94Y7N+0D6p
         UixA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s17si44984215pfm.170.2019.05.01.23.09.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:40 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="169819071"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga001.fm.intel.com with ESMTP; 01 May 2019 23:09:40 -0700
Subject: [PATCH v7 06/12] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 01 May 2019 22:55:53 -0700
Message-ID: <155677655373.2336373.15845721823034005000.stgit@dwillia2-desk3.amr.corp.intel.com>
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

The zone type check was a leftover from the cleanup that plumbed altmap
through the memory hotplug path, i.e. commit da024512a1fa "mm: pass the
vmem_altmap to arch_remove_memory and __remove_pages".

Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: David Hildenbrand <david@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory_hotplug.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 0d379da0f1a8..108380e20d8f 100644
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
 

