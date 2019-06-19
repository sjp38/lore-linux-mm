Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6A54C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 755B321530
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 755B321530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1B3406B000C; Wed, 19 Jun 2019 02:06:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 13E508E0002; Wed, 19 Jun 2019 02:06:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02C408E0001; Wed, 19 Jun 2019 02:06:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id C281D6B000C
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:25 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 71so9213064pld.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=LEsj0JvF5oyzUNmNgQWz6pMzr+Cf/rYYP2iyFKbjxv8=;
        b=arLrX7+Pxb6Adh42bTloOYL/i1S0H3S4fgk4ltxt/BRu8xSavr/eTZ/Y7UvatmyYBC
         QBfuxaEKfhMzHW/axsig822TFll3Zn5e7vNbPox0bc8A+WaqrARV1MKD5dUR+FGat29a
         Gnft9a/6cO8eMHEOswgzuymtSr8n6dUi/rcuZ+yKghqff771cy3KOAsLkAcNfrKTtP/1
         kkDxbU8IPL0Syt2ZUc97wm35FVYRBEKhSkZKryNS723EO6WgbzHG6cZY6p4FzRPW1MqK
         kdvPh7I5ddME8XqiZg4vKhA60qYyx8+iPSSoPJChKy+iv5a/GimSV6y9x/6tZ9fwc3ma
         QGeA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX+bn/9WKFMIdjGvQB3a2QIECUDyWhY9sOCN0UBKwGd0vmLZNl0
	rQYY2ojJB3sUISA3fIckY4BwrDlG1o55yMytP8zrApulgLx+SYN/pE0I0ZZQl6LddV3aPU+XeaJ
	O6lo30k/S3CSWATmx0iMjTm0vZGgEtwU0s2BDS0N1y0NI4PIYqcqlkXWns+UKdwznJQ==
X-Received: by 2002:a65:638e:: with SMTP id h14mr5973390pgv.86.1560924385139;
        Tue, 18 Jun 2019 23:06:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwerjnOGfbF6799jvCTrJ7n/6vjBHi8IwQ+H43Me9EFRmS0vb8AtYwRHn59NELNqiVDJOSs
X-Received: by 2002:a65:638e:: with SMTP id h14mr5973321pgv.86.1560924384151;
        Tue, 18 Jun 2019 23:06:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924384; cv=none;
        d=google.com; s=arc-20160816;
        b=ngNarhQgujuxyoLd0uJW7mh544Y8+ikAhAyHoQCPv1vmzZmUpOS2ZpyvzY2zK5ellp
         xwwSAGRcqX8Xigj53xxs72gxhOEbFXQWF3mkhgn2PppYAD4v2kc5HyFsyohZo7hkRjJq
         K019Bo6mjRuCr4pgsvGnUKji/FwDxsg76uBpTn256IEAFeJjMzu639N8QwX3tSrn60n6
         LspAxEpWZFURBpQsv41dL6OQxNYR0a0ElLeAFuYWjxCLshCmRdYCOiYp7mPjzH9Fhro5
         cUda8YWida1cdKd7fcTZ7CDcWD64MhtddmCM3pdOcoD86Qo53zyhKV34byILBqA37c35
         ZeNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=LEsj0JvF5oyzUNmNgQWz6pMzr+Cf/rYYP2iyFKbjxv8=;
        b=pMiB6p3xhXsQg5LLcP1AGu846LMdXgsN3Ut83wXdHbaHLw41AuGAIp80xaO9/0j1pp
         WkuDCb0DTusEBzGKv8NKOsPE8pCKjqEuIdWeK8UYxKdJexKA7EtJc0ApHzb6i/JLT9Ap
         2iotIvl7yBdeaa8t9r8gtd6hTv7lumuGVXa5r2/nJgy9GdeWqhC62k9dzaL2ONnecqhJ
         zxBUYbxG4frzMaskpf5Xnvrkvkh7Fs2CTv84QlDBo37/mwGgJZ6HNEhL7SVQINi+MdCi
         Dfova8mc16nBJsPUYyykqWZR7IM7HhI/7YV6aQFXjmfIJhFGc4NAb1iFhV6kX6efJXEu
         7HhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id c24si2233203pgi.462.2019.06.18.23.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:23 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="358087805"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:23 -0700
Subject: [PATCH v10 06/13] mm/hotplug: Kill is_dev_zone() usage in
 __remove_pages()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:52:06 -0700
Message-ID: <156092352642.979959.6664333788149363039.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index 647859a1d119..4b882c57781a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -535,11 +535,8 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
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
 

