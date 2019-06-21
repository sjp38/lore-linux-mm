Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8450FC48BE3
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 00:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B6AB2075E
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 00:21:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B6AB2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962816B0005; Thu, 20 Jun 2019 20:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9123C8E0002; Thu, 20 Jun 2019 20:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 801648E0001; Thu, 20 Jun 2019 20:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4A78D6B0005
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 20:21:06 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id a13so2869536pgw.19
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 17:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:user-agent:mime-version
         :content-transfer-encoding;
        bh=D9Q5TsLk9YzDlLRbdmdW0VUV//YWXj5oXBPnNGb9G/s=;
        b=c9faTF1Y8xnKK06goZext6q6XeGgxBD9INS3wd/iZUh6F6cnxDhjev8feheQP0Nz2Z
         CPrX7Sf/x5ecCfItiexAqmagM6duSRyXpdInvdbkxgNnyls+yOgB+F+uyxJC09IKtk9w
         apxIqPXPoad3bWZeqSu4ogHi/Bzz423wa6OJAuQ034pKCYltNEnmhf/EQLkbo7cMQfy6
         nEk/zJ/k3//KMljGrWaE7o+47YThow44QM+87a773AbnWESBoSZBNEyCpEeEFocIiGwa
         W5+sy4gMTA3Xw7V0XX5zKh9PkqEqmqSGnQzGzY9AKdYVwvqI6D9eIEZYmoh67DoAnMd9
         X8XA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXssuDmojskTlWHu4HX/YaCn1tp31UNp7gOgXR42y0xRPt3yjrK
	JVfLq6t1uAgGb0RPjsHWE68rKRRkaF+i+aBU4ajog9jquHA4sNA888+mQKLrAYAV1u3Lx35K7aC
	TwYwTAWBrbloiRQfzPERzaMJf+KSiJ7HCd8EqdQ4UQW7QuoglgwQEiBrMi7j113ksnA==
X-Received: by 2002:a63:224a:: with SMTP id t10mr15197945pgm.289.1561076465766;
        Thu, 20 Jun 2019 17:21:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyktDw29Ew/8P7RWKn2dgbgrjbrey4o0lvwZ+mN68V1ENAdJ+K/0jU0zb9IeoxIr9DPn79/
X-Received: by 2002:a63:224a:: with SMTP id t10mr15197879pgm.289.1561076464868;
        Thu, 20 Jun 2019 17:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561076464; cv=none;
        d=google.com; s=arc-20160816;
        b=KnpxkrU9oFwlme11pwQ2T6kZlqtMmJ/apgecGoXl172dRJtsXLPNxzS4Kbm8jmST6w
         LGcrhhxE3Ui/oV2Rky4LacDLN3yVt7SmAR4q+QT4H5B5bg5V68InywnhNI59+iNsPZQt
         R7OxmxJMTQeQFifWGwwO4IIa0AE5zES0jM2PA/ZIIjBWHbxfntSAiOF/hG+bpXH/lFOX
         ja2L3mXb02lUVLK6ING5eoaKUvFAIm6Xwqfex40aQEsGYKmWsOWTKq2csR2Y8db46hfp
         x5QjZECRzY247ul7TdrVr25JBdee6LHsN0i7xg29UPnXSiGOn0PSOudkx1aYGoF86GLU
         uovQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject;
        bh=D9Q5TsLk9YzDlLRbdmdW0VUV//YWXj5oXBPnNGb9G/s=;
        b=WN6sT75BLqBLCPT5rpQPjs/1TF5AH9EeW1jYQbxi+j0TpX9+An53hvA0yOOtJpaTlg
         u79VM+ic38o8GqoAM8z3Uzc/ysxfVN7VPMw9D7VNXEhOKqSAZGP4mp9BAs07AuNYSQkP
         k7W5uSJA8KQCI1P+hxyjNQH4Lubd3rFJ1ZMeS7HbOBl9NV4rgYhIDsnxkwfCCqfrr62C
         GpGQxVzLXIw8Dfpbzu8V4q1q9g0fLH+fbBgIb/PIPJ0eLB22r9ueuLeY7p6PQtW4rJpH
         DsRtuqUVgWO3A1NcN90jxyJXfDo3zOwFgyjAde0ySgTE1dRHNdX7J8cM+I2SGIyRH7I9
         TbBg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g1si1048645plp.406.2019.06.20.17.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 17:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 17:21:04 -0700
X-IronPort-AV: E=Sophos;i="5.63,398,1557212400"; 
   d="scan'208";a="168671081"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga003-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 17:21:03 -0700
Subject: [PATCH] mm/sparsemem: Cleanup 'section number' data types
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Oscar Salvador <osalvador@suse.de>,
 David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Thu, 20 Jun 2019 17:06:46 -0700
Message-ID: <156107543656.1329419.11505835211949439815.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

David points out that there is a mixture of 'int' and 'unsigned long'
usage for section number data types. Update the memory hotplug path to
use 'unsigned long' consistently for section numbers.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Reported-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
Hi Andrew,

This patch belatedly fixes up David's review feedback about moving over
to 'unsigned long' for section numbers. Let me know if you want me to
respin the full series, or if you'll just apply / fold this patch on
top.

 mm/memory_hotplug.c |   10 +++++-----
 mm/sparse.c         |    8 ++++----
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4e8e65954f31..92bc44a73fc5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -288,8 +288,8 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
 int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 		struct mhp_restrictions *restrictions)
 {
-	unsigned long i;
-	int start_sec, end_sec, err;
+	int err;
+	unsigned long nr, start_sec, end_sec;
 	struct vmem_altmap *altmap = restrictions->altmap;
 
 	if (altmap) {
@@ -310,7 +310,7 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 
 	start_sec = pfn_to_section_nr(pfn);
 	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
-	for (i = start_sec; i <= end_sec; i++) {
+	for (nr = start_sec; nr <= end_sec; nr++) {
 		unsigned long pfns;
 
 		pfns = min(nr_pages, PAGES_PER_SECTION
@@ -541,7 +541,7 @@ void __remove_pages(struct zone *zone, unsigned long pfn,
 		    unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long map_offset = 0;
-	int i, start_sec, end_sec;
+	unsigned long nr, start_sec, end_sec;
 
 	if (altmap)
 		map_offset = vmem_altmap_offset(altmap);
@@ -553,7 +553,7 @@ void __remove_pages(struct zone *zone, unsigned long pfn,
 
 	start_sec = pfn_to_section_nr(pfn);
 	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
-	for (i = start_sec; i <= end_sec; i++) {
+	for (nr = start_sec; nr <= end_sec; nr++) {
 		unsigned long pfns;
 
 		cond_resched();
diff --git a/mm/sparse.c b/mm/sparse.c
index b77ca21a27a4..6c4eab2b2bb0 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -229,21 +229,21 @@ void subsection_mask_set(unsigned long *map, unsigned long pfn,
 void __init subsection_map_init(unsigned long pfn, unsigned long nr_pages)
 {
 	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
-	int i, start_sec = pfn_to_section_nr(pfn);
+	unsigned long nr, start_sec = pfn_to_section_nr(pfn);
 
 	if (!nr_pages)
 		return;
 
-	for (i = start_sec; i <= end_sec; i++) {
+	for (nr = start_sec; nr <= end_sec; nr++) {
 		struct mem_section *ms;
 		unsigned long pfns;
 
 		pfns = min(nr_pages, PAGES_PER_SECTION
 				- (pfn & ~PAGE_SECTION_MASK));
-		ms = __nr_to_section(i);
+		ms = __nr_to_section(nr);
 		subsection_mask_set(ms->usage->subsection_map, pfn, pfns);
 
-		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, i,
+		pr_debug("%s: sec: %d pfns: %ld set(%d, %d)\n", __func__, nr,
 				pfns, subsection_map_index(pfn),
 				subsection_map_index(pfn + pfns - 1));
 

