Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A269C10F03
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1E4221900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 17:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1E4221900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 899E76B000A; Fri, 22 Mar 2019 13:10:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 847AB6B000C; Fri, 22 Mar 2019 13:10:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 762D46B000D; Fri, 22 Mar 2019 13:10:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 32D7E6B000A
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 13:10:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id u8so2909615pfm.6
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 10:10:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=4laCd5MFQsasg3wAcoeizAGd9ZCiY08UnTwXQ4jobr8=;
        b=S2+FmuCD9QK2/adybvoKaaIHZoL1+AlvmEV+PEjthH1cEeWpF4aOXsJ5kyKj/vY+9c
         JYxwjy8MIHFhKtpR2xcU5Wz0AuR7A4z26D6n3+g9rc/72r/NTrfh1cyXCarzF2GaJ1Hn
         KYGePAtBa5N2wWp6ipqx4VyNxXk/inT/cTXZRIhj0NYDOomC8b4ILtjxQpFTqddzp697
         easO90h64MpN5p7NqMLTJA+vPEkLe1gA5JmQ7uZtjjbOvx5AxlFAfABhIsZ//EN23S1N
         +r3m3vZxXFRgz1qdTSwrCkaZ7ltoqPQCZ1tp+iH+13Za+NifpdL7l76h3OUmoqyddBns
         6BUg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQDz5wjf0073Yb/sEwNFmpN2RDh5Q6mHKXfuuJN3jhylHqxSOd
	xZilShwBBwvG1qKLnsoNkNGx8yCoszHYQOjLh6zn8glCAIyYL7RMOTb+VTM73WoUHOInZtvfvIN
	DhBChtJI6zardrwTV5mX2sHTEQrFM2M1TiXrXgtZLcjeuf6twS7dreoVSgxzfvQVYlA==
X-Received: by 2002:a17:902:b788:: with SMTP id e8mr310624pls.339.1553274655877;
        Fri, 22 Mar 2019 10:10:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2oqWlgj1JMMdHYU+04AGUMpF6XrZgcIMfJ7LXFaGW+iYUxqvQyw2wqYNxez0bwaY9Gr8w
X-Received: by 2002:a17:902:b788:: with SMTP id e8mr310571pls.339.1553274655197;
        Fri, 22 Mar 2019 10:10:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553274655; cv=none;
        d=google.com; s=arc-20160816;
        b=xBUIMd6uATrLL/d5BWnScP3RaP2tls1ZwfdAiUJrMapwX80gNVUsbKm4u/KUBGUKad
         kKfnpimJEs4pGSC/alJjDM3M7y2/lPHvQdJJdae4cihtNPpVoOCkWJQTYRI8N7Bi8I/R
         Zv0g9MLUlGeXfodQKPSXZ47r7iAdoaIzVD9K3NSN/sfVxCjUgvZYJbNFGOVRsFG0iI3j
         ZzwZmEZPbGJuIXUyeQowr9cerzmx7730XY/mr5HVD8Oh5E+RHvL7hXgQcmWhVmwHmNIP
         8vIez6LDulhEsLBO2qvT73IpOif0EhLjW550liYu/qTQ1t/tm2aDF2V9hCHXE0Pn4i7m
         KiZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=4laCd5MFQsasg3wAcoeizAGd9ZCiY08UnTwXQ4jobr8=;
        b=QMeOX8cwe/Xqf5omflgcy3cF6jkWj/Cu0Ajz68CqmqLZVpdbO37U1a7VOCjHRP3B4e
         ki8PcfGobCzWjpNiWj2ZIhKpvvQM7wdNOKmS6+usVdlS1oScdSZFZEXZ7Xj7w7d4SOHx
         gUTamjXr40C5KSMVEUJEjyY1cftxNAPKzXKFYxNMCa3KQCevtIy6dmuO5Bw4LBQj60Lv
         J+04ZooFHZYWe7s8u0BRZ806zEEobvFkkV9qTw+PVPlV67su1rETJ1ctVi8tZqeawCPz
         SK0zgy8VNwewF5vBGc8jSoEnQG4ZJMRYe6xZdYhiH2JzQ/isHf6uP8L2JvisKFv6Ngt4
         zlqQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id s4si6966753pgs.566.2019.03.22.10.10.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Mar 2019 10:10:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Mar 2019 10:10:54 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,256,1549958400"; 
   d="scan'208";a="136390571"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga003.jf.intel.com with ESMTP; 22 Mar 2019 10:10:54 -0700
Subject: [PATCH v5 04/10] mm/hotplug: Prepare shrink_{zone,
 pgdat}_span for sub-section removal
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Fri, 22 Mar 2019 09:58:15 -0700
Message-ID: <155327389539.225273.8758677172387750805.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155327387405.225273.9325594075351253804.stgit@dwillia2-desk3.amr.corp.intel.com>
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
index ae4aa7f63d2e..067ee217c692 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1111,6 +1111,8 @@ static inline unsigned long section_nr_to_pfn(unsigned long sec)
 
 #define SECTION_ACTIVE_SIZE ((1UL << SECTION_SIZE_BITS) / BITS_PER_LONG)
 #define SECTION_ACTIVE_MASK (~(SECTION_ACTIVE_SIZE - 1))
+#define PAGES_PER_SUB_SECTION (SECTION_ACTIVE_SIZE / PAGE_SIZE)
+#define PAGE_SUB_SECTION_MASK (~(PAGES_PER_SUB_SECTION-1))
 
 struct mem_section_usage {
 	/*
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 2541a3a15854..0ea3bb58d223 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -326,10 +326,10 @@ static unsigned long find_smallest_section_pfn(int nid, struct zone *zone,
 {
 	struct mem_section *ms;
 
-	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SECTION) {
+	for (; start_pfn < end_pfn; start_pfn += PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(start_pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(start_pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(start_pfn) != nid))
@@ -354,10 +354,10 @@ static unsigned long find_biggest_section_pfn(int nid, struct zone *zone,
 
 	/* pfn is the end pfn of a memory section. */
 	pfn = end_pfn - 1;
-	for (; pfn >= start_pfn; pfn -= PAGES_PER_SECTION) {
+	for (; pfn >= start_pfn; pfn -= PAGES_PER_SUB_SECTION) {
 		ms = __pfn_to_section(pfn);
 
-		if (unlikely(!valid_section(ms)))
+		if (unlikely(!pfn_valid(pfn)))
 			continue;
 
 		if (unlikely(pfn_to_nid(pfn) != nid))
@@ -416,10 +416,10 @@ static void shrink_zone_span(struct zone *zone, unsigned long start_pfn,
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
@@ -484,10 +484,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
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

