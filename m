Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 568CBC04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 127E620830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 23:53:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 127E620830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7BF26B000A; Mon,  6 May 2019 19:53:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2B2F6B000C; Mon,  6 May 2019 19:53:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A41BF6B000D; Mon,  6 May 2019 19:53:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F1706B000A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 19:53:36 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 93so6220138plf.14
        for <linux-mm@kvack.org>; Mon, 06 May 2019 16:53:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=a7EZldfln8O+xN6/aEzC/yGj8XySO3ehbPGaCHwyPHM=;
        b=gs6XY/nZczyxoqXStYuRN+QfryiWLijrGeyLVVRK4IjvF+uEEgudvMnrNsU1mHVDy3
         dhxAOP7Rdj+xjLv/mHV3SCIWFwgDOxypRtghe+af7xnfUx6wngDgPtYgChLuZHA2cm92
         WH//ad/u+CrRVkr/EWiNrYKtaN1HUZu+6PYweB05CiqwQAoLq0o/IPxhXuh+NjSUrSUz
         ESx5RrhwJvXUvUeS0K8JriDV3yxCWlH5pVq/fGEzaEXc5eLewkMy64vhnc9CFddIN8tu
         7kmol+VZbuIhKGTS92mA87xBVlpHpTGw/qj8Ci6F9jjdN+DDxfmYMnvVoYKcZRx6VoUw
         y2ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWsQBiOTCm8Jv0wtB4s0OD05lkxzHN2VdsZZvZKekKYQN0r8d4U
	yUQbnwwwsfx7YUGpZPnZfiApwU0Yt1dA6XLg08d1VieuT+f1/DzKZsB2Njrs6X0A8TVk4qcQRUX
	wXjh8u04pKHoGaO4kHzV85+BQ1+B3M/KSIO3Lmk/tTdMRRPi1+Y7nSqUIaEMeX2sH1g==
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr24895820pgi.84.1557186816131;
        Mon, 06 May 2019 16:53:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzB8J3C2+nAlM0Wx7eESQns0wAPXdJmNLxE16h9cuq6pKj1bdFSmgxiAty/KE18duRNDOW2
X-Received: by 2002:a63:cc4e:: with SMTP id q14mr24895782pgi.84.1557186815388;
        Mon, 06 May 2019 16:53:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557186815; cv=none;
        d=google.com; s=arc-20160816;
        b=MtG+r7hqjSBwOd1lrYG+WBARnp8SUHNoRcsiW8lcAtAEjT3ENlP6XN6pmobLYZWoQV
         UaG4K8Hnv80bcaJtDbknfym/LXCX3WPlhhCWO9pCgOe9DCKqPwgKsh8ajcA+2hzQvIBI
         JgQbdroaI8U0Fsik5qx5uj7qodaJpezW6CUCAvcxKQCZ7TqDvytl/uz9HnTZcERbeOIs
         XB+CMLc5qx++p2E3AkOaBQgPT5jxP+Qz0bs2+AzfK3dJmbRVCQlMK9Zqk2YiBnR+uByG
         QgNfMMODcf8+Nsmy5Zncpvwd09ECFH8nZntrcu/lGVjNztIengChn/4NBTviQhssWkNt
         urRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=a7EZldfln8O+xN6/aEzC/yGj8XySO3ehbPGaCHwyPHM=;
        b=Fs6ctHPfM8lQM6xQ3+VdiPVW3IspwIHYUVQvbVpEmoxOD9FKYKx65CYimZNAq9HW4a
         XVKP98DPqCBbQ0dvawzhNKoXeocdxqQZo9fCLsvrYmiE5x3vWCloXWOUgkL1UbVpsuuD
         3IX7NhdVp5bHWq4+bLCfsHI0f5NV7+WIFtO8Fu6aLyTtIIZ6AMxfrCX94O6nb+9tQdbA
         jfheFupPdq8A7sTpVhxZT6iL6ciYLXDG3UAxewcapEjw36opIKGVT9YdmNUGOSH/Y2at
         lJdbWBukR/J3T2QOVEzjsE7SkzJchxzdESxfgo4VMl1q+NOjt/SuX2Az8x24w1rqrhNN
         SlnA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v8si18502056plg.156.2019.05.06.16.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 16:53:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 May 2019 16:53:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,439,1549958400"; 
   d="scan'208";a="149329731"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 06 May 2019 16:53:34 -0700
Subject: [PATCH v8 04/12] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, Oscar Salvador <osalvador@suse.de>,
 linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 osalvador@suse.de, mhocko@suse.com
Date: Mon, 06 May 2019 16:39:47 -0700
Message-ID: <155718598766.130019.2843092676507694047.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Sub-section hotplug support reduces the unit of operation of hotplug
from section-sized-units (PAGES_PER_SECTION) to sub-section-sized units
(PAGES_PER_SUBSECTION). Teach shrink_{zone,pgdat}_span() to consider
PAGES_PER_SUBSECTION boundaries as the points where pfn_valid(), not
valid_section(), can toggle.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Reviewed-by: Oscar Salvador <osalvador@suse.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 mm/memory_hotplug.c |   29 ++++++++---------------------
 1 file changed, 8 insertions(+), 21 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index a76fc6a6e9fe..393ab2b9c3f7 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -325,12 +325,8 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 				     unsigned long start_pfn,
 				     unsigned long end_pfn)
 {
-	struct mem_section *ms;
-
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(start_pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -350,15 +346,12 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 				    unsigned long start_pfn,
 				    unsigned long end_pfn)
 {
-	struct mem_section *ms;
 	unsigned long pfn;
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -380,7 +373,6 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	unsigned long z = zone_end_pfn(zone); /* zone_end_pfn namespace clash */
 	unsigned long zone_end_pfn = z;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = zone_to_nid(zone);
 
 	zone_span_writelock(zone);
@@ -417,10 +409,8 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
 	 * it check the zone has only hole or not.
 	 */
 	pfn = zone_start_pfn;
-	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < zone_end_pfn; pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (page_zone(pfn_to_page(pfn)) != zone)
@@ -448,7 +438,6 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	unsigned long p = pgdat_end_pfn(pgdat); /* pgdat_end_pfn namespace clash */
 	unsigned long pgdat_end_pfn = p;
 	unsigned long pfn;
-	struct mem_section *ms;
 	int nid = pgdat->node_id;
 
 	if (pgdat_start_pfn == start_pfn) {
@@ -485,10 +474,8 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	 * has only hole or not.
 	 */
 	pfn = pgdat_start_pfn;
-	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SECTION) {
-		ms = __pfn_to_section(pfn);
-
-		if (unlikely(!valid_section(ms)))
+	for (; pfn < pgdat_end_pfn; pfn += PAGES_PER_SUBSECTION) {
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (pfn_to_nid(pfn) != nid)

