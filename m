Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C2C8C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 173A721530
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 173A721530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B02096B0006; Wed, 19 Jun 2019 02:06:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8CC68E0002; Wed, 19 Jun 2019 02:06:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEB28E0001; Wed, 19 Jun 2019 02:06:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 54E1B6B0006
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:03 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g9so11567194pgd.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=rBPlEcf/zda1uNkC6O2OdGpJ9KV4wxiKq/x0oVCD0uE=;
        b=rLYhf0RiPHB9OJwM5qkLkEk6gQhl1obAaFDnIjLQG6q1lgoMLvKvs1QDcFELjjUBBT
         whs5lBG8qF83Mckm0UU4069q6OU7ztkHUe5HZNglu5UHqCFc621rTI3PotA1lGoe3Oxa
         aOtWfThPsOK4BkCatfucATCcbTWy+Tsr+itMP4ZwiGOTjIjSBPb5aRfx5hSeaEduVfB9
         +VXrSTS7n/d7YEWk7MAJYrpxauRz8VDcZosO+V3QSZgss0PpzaMvkJvEcUiQJJU8f7jE
         Bd+1GRreyqbhlXfQQGkMJybZ+jvUarxAmI1qAxFP6Bc/SuTd0JLOQRPQLPN4UrvK1Y/i
         dEow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFxfViYB+usQXAQphAGQd5ZI8k55cZ13i165VmLDmU3lFiNEoe
	XfBPW2DITCwcNsgFp8Ar/mUxOcfnlpa7PYnG4+r2TjSp60q+wHadJrKg1E4pVQGUbvFL2pJ6tjJ
	zdPsHNGHQTJM1ATmJpD6VcwK51RCIKOcDxWmNRFCD4EFK6jwjlB3q+Hf/e0Hn8ojSgw==
X-Received: by 2002:a63:6245:: with SMTP id w66mr122545pgb.117.1560924362831;
        Tue, 18 Jun 2019 23:06:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTTQhpQ68jcwX3nP3F6B//E4UicAm0qbkhOCfhBb6RaGkIrbDGoTFyOibzcye+nKMvA49N
X-Received: by 2002:a63:6245:: with SMTP id w66mr122487pgb.117.1560924362001;
        Tue, 18 Jun 2019 23:06:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924361; cv=none;
        d=google.com; s=arc-20160816;
        b=x7pu9I0ZRiBqQbvDGyrnOl7Dqb+A36rsCJT/MLjgwppHw6u3o0jYUsYOg1tvN4ISkw
         9rsa2r5WZeB1Y0lFWMoza2FAkk1sQ8cMGhmFvc5d5WV9Cd+8uo460DVrTr/pbAWuAwij
         QokNweb7tFMxdsNCyBxw6GdbvhyyE/pPjxtVuoWVJF595CyVyN3GQ6yQcGj8e+ROwxg5
         /WyJYQkh6UNxnIzUsTx22vU2Gp06+DRPLcpS9CyGFfM6kACgE/N1BuMb8UrgVcY659rR
         4s3Ih01ZkEV2sDH5hAPVKRirVoD/c1XXfOlkhHB2++2AwozIuVeQQc0MGFSNQ+dU7+rK
         Bd+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=rBPlEcf/zda1uNkC6O2OdGpJ9KV4wxiKq/x0oVCD0uE=;
        b=rxMyt1qteYsbwL8d6OrtyJKMm7O2GvGeNcVsXpC7WUc2k5fB0MploamFjyCZDcEaGu
         wba/KwyE2EaVwl8nE/ZuNc55MivaE/x/gXVKTCUhWcPyJQZT6cGcMQ1k374wpzGr8nVz
         lhhtEBfbX6gGhopF4i51YY9V00uHGtdugOcE3XCB8Ye9EI4W6wyw2cbvAviNrKuJHUuE
         fASYyHTwVEqXHUB4xEDWcfCRNUqE6hXI8tPh5ypF4wnbsJUNfNSIul3Z6THs9P3XYhLk
         bHnE9fqXlw3oKWka5RC9oIvX4ctrZfMEXWM4fba9gQbwSru2B6x47hoDEvkE/uSi9J/Z
         /+zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 35si173412pgn.199.2019.06.18.23.06.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:00 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="243216408"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga001-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:00 -0700
Subject: [PATCH v10 02/13] mm/sparsemem: Introduce a SECTION_IS_EARLY flag
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Qian Cai <cai@lca.pw>, Michal Hocko <mhocko@suse.com>,
 Logan Gunthorpe <logang@deltatee.com>, David Hildenbrand <david@redhat.com>,
 Oscar Salvador <osalvador@suse.de>, Pavel Tatashin <pasha.tatashin@soleen.com>,
 linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:51:43 -0700
Message-ID: <156092350358.979959.5817209875548072819.stgit@dwillia2-desk3.amr.corp.intel.com>
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

In preparation for sub-section hotplug, track whether a given section
was created during early memory initialization, or later via memory
hotplug.  This distinction is needed to maintain the coarse expectation
that pfn_valid() returns true for any pfn within a given section even if
that section has pages that are reserved from the page allocator.

For example one of the of goals of subsection hotplug is to support
cases where the system physical memory layout collides System RAM and
PMEM within a section. Several pfn_valid() users expect to just check if
a section is valid, but they are not careful to check if the given pfn
is within a "System RAM" boundary and instead expect pgdat information
to further validate the pfn.

Rather than unwind those paths to make their pfn_valid() queries more
precise a follow on patch uses the SECTION_IS_EARLY flag to maintain the
traditional expectation that pfn_valid() returns true for all early
sections.

Link: https://lore.kernel.org/lkml/1560366952-10660-1-git-send-email-cai@lca.pw/
Reported-by: Qian Cai <cai@lca.pw>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/mmzone.h |    8 +++++++-
 mm/sparse.c            |   20 +++++++++-----------
 2 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 179680c94262..d081c9a1d25d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1261,7 +1261,8 @@ extern size_t mem_section_usage_size(void);
 #define	SECTION_MARKED_PRESENT	(1UL<<0)
 #define SECTION_HAS_MEM_MAP	(1UL<<1)
 #define SECTION_IS_ONLINE	(1UL<<2)
-#define SECTION_MAP_LAST_BIT	(1UL<<3)
+#define SECTION_IS_EARLY	(1UL<<3)
+#define SECTION_MAP_LAST_BIT	(1UL<<4)
 #define SECTION_MAP_MASK	(~(SECTION_MAP_LAST_BIT-1))
 #define SECTION_NID_SHIFT	3
 
@@ -1287,6 +1288,11 @@ static inline int valid_section(struct mem_section *section)
 	return (section && (section->section_mem_map & SECTION_HAS_MEM_MAP));
 }
 
+static inline int early_section(struct mem_section *section)
+{
+	return (section && (section->section_mem_map & SECTION_IS_EARLY));
+}
+
 static inline int valid_section_nr(unsigned long nr)
 {
 	return valid_section(__nr_to_section(nr));
diff --git a/mm/sparse.c b/mm/sparse.c
index 71da15cc7432..2031a0694f35 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -288,11 +288,11 @@ struct page *sparse_decode_mem_map(unsigned long coded_mem_map, unsigned long pn
 
 static void __meminit sparse_init_one_section(struct mem_section *ms,
 		unsigned long pnum, struct page *mem_map,
-		struct mem_section_usage *usage)
+		struct mem_section_usage *usage, unsigned long flags)
 {
 	ms->section_mem_map &= ~SECTION_MAP_MASK;
-	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum) |
-							SECTION_HAS_MEM_MAP;
+	ms->section_mem_map |= sparse_encode_mem_map(mem_map, pnum)
+		| SECTION_HAS_MEM_MAP | flags;
 	ms->usage = usage;
 }
 
@@ -497,7 +497,8 @@ static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
 			goto failed;
 		}
 		check_usemap_section_nr(nid, usage);
-		sparse_init_one_section(__nr_to_section(pnum), pnum, map, usage);
+		sparse_init_one_section(__nr_to_section(pnum), pnum, map, usage,
+				SECTION_IS_EARLY);
 		usage = (void *) usage + mem_section_usage_size();
 	}
 	sparse_buffer_fini();
@@ -731,7 +732,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	page_init_poison(memmap, sizeof(struct page) * PAGES_PER_SECTION);
 
 	section_mark_present(ms);
-	sparse_init_one_section(ms, section_nr, memmap, usage);
+	sparse_init_one_section(ms, section_nr, memmap, usage, 0);
 
 out:
 	if (ret < 0) {
@@ -771,19 +772,16 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 }
 #endif
 
-static void free_section_usage(struct page *memmap,
+static void free_section_usage(struct mem_section *ms, struct page *memmap,
 		struct mem_section_usage *usage, struct vmem_altmap *altmap)
 {
-	struct page *usage_page;
-
 	if (!usage)
 		return;
 
-	usage_page = virt_to_page(usage);
 	/*
 	 * Check to see if allocation came from hot-plug-add
 	 */
-	if (PageSlab(usage_page) || PageCompound(usage_page)) {
+	if (!early_section(ms)) {
 		kfree(usage);
 		if (memmap)
 			__kfree_section_memmap(memmap, altmap);
@@ -815,6 +813,6 @@ void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage, altmap);
+	free_section_usage(ms, memmap, usage, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */

