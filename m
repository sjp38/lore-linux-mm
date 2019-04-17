Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CBD99C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7F3B720663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7F3B720663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2806A6B000A; Wed, 17 Apr 2019 14:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 230296B000C; Wed, 17 Apr 2019 14:53:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 146216B000D; Wed, 17 Apr 2019 14:53:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D166F6B000A
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e20so16793447pfn.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=0zgvBeX32KFY/f5kA6MPIacaljL+CBotozBqVDmlEME=;
        b=AowUG6ugTvTvAtlX2nnm6TLL1GXnGlUbvBr5txH60Hc1ThFj5y5VmfLXKBPODCQSgu
         XNGSPXohAfIjhvSPO309w1sCKYO7NO26kGplCDdpzXVSoKDTdZGYSw8YYibQBlkp9tNy
         rto89hVomlihhxYrTCSK2dKY/mbwbO0LDRMHhnUNC9h3jrkgHDicFIlBKbyW5Xx3qG3J
         HN9Sqrt53E/zhY6qs65Q+W5rISWka2Ivjiryhz4hEbAjmWDRWlrHboRCUmZdIZunYteV
         RgiC+fwMJNYLJoYddZPcu9FAaH/axMBnNlpDJmnR1/Hh60h0IcBZGwSKZZvZdz4WkS5A
         3/LQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAW7ECDZboBNfzz+VP29Rpp/xzMBG8dCMsQhWr+l44PKS55N2Hme
	UcJVJQHavC0YpF60p5WROUQ/+kpZiQwEvpW4YY2APWeMoC7GFXAvDdeuks6jvvOytTQYVgZk4IJ
	uxLnIGF8hd8IcZONiFzzxUjszLWBC3I6ex8CyHWnCfOpfDTwVgyg/DsyLpeSMLFf9FA==
X-Received: by 2002:a65:64c8:: with SMTP id t8mr83487360pgv.248.1555527183526;
        Wed, 17 Apr 2019 11:53:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzArcXfbcZqC3ssm8nK24mmlg5A09bxU+9bRcNvMLG1AgiaPPslBBLrUwwBS+o9V29tg0Ac
X-Received: by 2002:a65:64c8:: with SMTP id t8mr83487322pgv.248.1555527182857;
        Wed, 17 Apr 2019 11:53:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527182; cv=none;
        d=google.com; s=arc-20160816;
        b=fMa3pQPMtYXACQgATtrHWDFTIviB5ZhCUUs9jcHSXRUdy7je/frF/t7galzoDRq8EZ
         lvrFUshHWj4z0QGoPwWSKM+z91ZeaEU73sriCermJceS3agOzdxuOo4CVMO8uY64gfL5
         n6XCo/B3JiycLSj9B67dp38aQjnAjeUHDWJTR/hDkqVKo2sFS0tfV7K+1JDm5qyOsTmB
         w7dz12DBshDRhP6lIRWbI5pdwrfYbS+d1Sf/nJTU8hnri6l7EOdKeA+NlASyZgRxBzQz
         GBuqmQLMBixONplJui+LXq/zK3nQPEvZSZcLFkpwk6lYbBrhhx/EmgIZ1D85rt7CK/Ta
         Rb2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=0zgvBeX32KFY/f5kA6MPIacaljL+CBotozBqVDmlEME=;
        b=gInyUhDsJwK7LRPl2AnCIG/aKE5BvA/kQHSx5bIdL2UVfoATcSaDc5/mu7vAB90Vi6
         /isr0zPfh61ILrle/v9KA/QJub4BcPihF5IvQsvY7GyZ91yKlV1CVb+pnB3GIucPvtnI
         Xvpcwg5BkSsy5MaAGvEv3C7F2QjUT7qeq/hbduJb6rin9HxgJCb4OCTzbje0N8Jkpyxk
         z8YkPRcaHi0wjGYjLVfZxBxsOKglEhvifwzdo1su/M3OYh919DvCCPz9UvupPb+fvpP3
         a7BBWcMzptq19u+rHgFJCTyd23iFOzvrbzXjqIIlfg3xgwMJ/6JVVwIv4oCwErj/1jOr
         m00A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id h2si21340726pfk.277.2019.04.17.11.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:02 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="143759198"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 17 Apr 2019 11:53:01 -0700
Subject: [PATCH v6 04/12] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:16 -0700
Message-ID: <155552635609.2015392.6246305135559796835.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Sub-section hotplug support reduces the unit of operation of hotplug
from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
valid_section(), can toggle.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    2 ++
 mm/memory_hotplug.c    |   16 ++++++++--------
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index cffde898e345..b13f0cddf75e 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1164,6 +1164,8 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 
 #define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
 #define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
+#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
+#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
 
 struct mem_section_usage {
 	/*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8b7415736d21..d5874f9d4043 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -327,10 +327,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 {
 	struct mem_section *ms;
 
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(start_pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -355,10 +355,10 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -417,10 +417,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	 * it check the zone has only hole or not.
 	 */
 	pfn = zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -485,10 +485,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	 * has only hole or not.
 	 */
 	pfn = pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)

