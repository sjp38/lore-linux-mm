Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F33E6C28D18
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA1DB2075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA1DB2075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6ABF96B0274; Wed,  5 Jun 2019 18:12:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 682626B0276; Wed,  5 Jun 2019 18:12:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5721F6B0277; Wed,  5 Jun 2019 18:12:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 220B66B0274
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:51 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id j26so128886pgj.6
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=8n19+FzQaIDY2xDJy05T7UR8tvZJ9j4S/+ajqMgZvdY=;
        b=DoL4zDQKTzrEGQwRr4NY0kpaaVXoXr5EdWteM8qD9M420BOFUEUnOVmQCo85HwiQHh
         OyzBA+sqRBn6+rSnrCzFgXRambmrVyrFZZDyvwf2HmNH6joYwr4buhkxzYCt1OmI0WHp
         Ma1L6MHkkT5J5KgA26S5tU29OMMVJUTZ9fYfmxBxnmoe1WtZpBOiy+qb2giXSLEEDjav
         HEmTr+i4MmzT4l/hPr+Na+IqMxtSWVm8mvBA9hqfN9YGCqsXWh1dHnaelbwAW1QtiMt8
         yAb36luchaKC6q5/0fQJWgnGt8gyIMcvFkhztZxqzOHQjvBNAKB3f+lb8L1JaElZxlNW
         uLQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXegUctTrPqEoYL+KOTrIJta8Bjm+SeCYROV5CkVL8KUtQZOWHv
	oFPDz763PeC6BpxQoW+X/yvxtKgrDZ3DD2e4duvT5VYTMv8jarPwfyVrkT3xN5HgOjNRjKqqciv
	JasYbpa2nbifvLaUuVsvKPkuTJxjUIubCwh75HyXMRSmtw/N8NkACzeHkpQCUGXOrsQ==
X-Received: by 2002:a17:902:20ec:: with SMTP id v41mr44443966plg.142.1559772770637;
        Wed, 05 Jun 2019 15:12:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz3jUzQswNROJ2QOo5vq+EfUNpkTjrbJ2JEmnSvImOPDxSiFsqt5kbS7sZBnAc8OZ6Ibg8e
X-Received: by 2002:a17:902:20ec:: with SMTP id v41mr44443882plg.142.1559772769776;
        Wed, 05 Jun 2019 15:12:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772769; cv=none;
        d=google.com; s=arc-20160816;
        b=Byq492nmu0gbmzhf1twIxUqFSNd1j9/uqw3COXWS7pfFT91kHS7dVAIKSc3XhqCpzy
         DqHmW+4dnWtQlaEpdlGXjXWTwoZYKMoCOsqMFS2OhJIWIpzWwcHDTmxzflYzsxIDtm00
         Lof7a4DhWAmZcl3P+68dx9Uo6gVZoeZArWVP1TFMi2WU8wPiTlf4WpVkPVRq+ngsv0f+
         jfHuk2no7hQXaXduOkI4VeGq5VU/9FOR6M0TwKPMbSO2pMxXG9lxxNGhuWoFNev0cF3X
         Qx65j29AUt6Vt6/ZxvXkJbVF+DP6O29ROPqL3YCAWetUYQfoh4lFiRFyoZyyVjqTi0Ij
         H7fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=8n19+FzQaIDY2xDJy05T7UR8tvZJ9j4S/+ajqMgZvdY=;
        b=fVoaeL40tVF9dCweye1G6RqRf1RIOQFM1pMW+y2gG/dANUyEhRvezQHAzoibD7ROmi
         oyaCLaXXX5Uo5mymAl5HVcM/kmaKVbh/PvQ+8q0cNX+Hg9IacJ2AOKLogKx8vKtsIjZf
         i4SdINFEmwVCCxeej0/k//+qReIvM8MaIDnJKE85+iQ/Ag5VosSb73hWD/QBkQybzPNr
         l/iFW1HqqoE8MqLFQnKh5qrdMJhmAt5srIIz56QWtMoAdqIB9VjBcu60cZaGH+2tg0mD
         l5N+T9Av1wVz7p7hsNmQOjndc6a1Zw9q3WH2WMnccvmvItIdaOewDVJVzQWQQjjZuKpt
         r8qg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id f9si193471pgv.5.2019.06.05.15.12.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:49 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 05 Jun 2019 15:12:49 -0700
Subject: [PATCH v9 06/12] mm: Kill is_dev_zone() helper
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:32 -0700
Message-ID: <155977191260.2443951.15908146523735681570.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155977186863.2443951.9036044808311959913.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index bd773efe5b82..5dff3f49a372 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5865,7 +5865,7 @@ void __ref memmap_init_zone_device(struct zone *zone,
 	unsigned long start = jiffies;
 	int nid = pgdat->node_id;
 
-	if (WARN_ON_ONCE(!pgmap || !is_dev_zone(zone)))
+	if (WARN_ON_ONCE(!pgmap || zone_idx(zone) != ZONE_DEVICE))
 		return;
 
 	/*

