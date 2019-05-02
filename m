Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3948AC04AA9
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D8EAA2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D8EAA2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 841206B0269; Thu,  2 May 2019 02:09:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F1E26B026A; Thu,  2 May 2019 02:09:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E1366B026B; Thu,  2 May 2019 02:09:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 339D96B0269
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:53 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id a5so721664plh.14
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=goWyNnY+juBPLit62pAaX1kxWdLRVjU36SDXYB0DhtE=;
        b=t11EFP1G7N1ddmJHykb6HrOrvlNkXuZ564KRNx87o0+2YKhfnW9z+EKHbHUyM1/fpN
         Ymx1jVELfK91Rkx9mJMbAMuQGEyr97sWINAMtQtsGN56RM+niZYeAPU0jLfreudZCvkb
         2U0BsvV9P2KHw4NDt8ocwy7aP6fzLuQeYZQNNGYgDJt8BV3U0ZpwzkZ+aXAPfeNI+eJH
         MQAyKLN8eiq+VQoDxlckBm+WoZjJNSODKFyBpzqQ2b2umHDGZiHR600cFAu/p98exnJ5
         DBHHm2Jf4ZIfBIUZywj0bn+qiAcokAutPgeP6JYR9w31R4ifDCOqgZU/YKN44TrMq9zA
         ADSw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXMsmNKOB8yhzphAoFa/VqyScaHFwk7m411BSEFDr7uHYpt8X0Q
	pVeYEacGhoNuAyH1Ls0pJoRIJs7MA2nx6PIzqq/cIexgrVv3RrwWmR94OGOpwGZb5iYoGurOcrd
	WFo9nhAnPFHCsui/WXRyhNujCA/mDzFfN2EypmJvJ7dXHpbcyTw+/795GbLtJOWuG9g==
X-Received: by 2002:a63:f712:: with SMTP id x18mr2189433pgh.293.1556777392760;
        Wed, 01 May 2019 23:09:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRARXrg+m3RO4kssO6HzFtQZmSfUU50zsVhxm12vOMeSNAQqGRnVN3XbrsRdXOAwpNNfMA
X-Received: by 2002:a63:f712:: with SMTP id x18mr2189345pgh.293.1556777391823;
        Wed, 01 May 2019 23:09:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777391; cv=none;
        d=google.com; s=arc-20160816;
        b=nyiPEmBAvsSGiAyH9TbKbvN5TUaWuj4PxI0Nuc12sQ9V+lSRJInKoQ8XhXMTlsGytq
         hFBDIXWDIjjTpwKZXHn/C0dIp/479kBcO3N3RdHR/tYsgtFPLhDkHbX8aUKYbrKeJ1cm
         XY9smuPIs8aLdYpmoZB9IcefvE960soWUgCd1ue5VkerUNsoErBq9AYoKAv0XkwCR5Lb
         eAzUEbkJttJmJTApXL2ya2C/ClyBw+tYk6nf/snMR6YVIHopMQIukL9pNpkz3tVEun4E
         Y13UVTYjEb9QM6Z3hYgLDYNhYxo/W5u8st4DYjXX5jwxIaTZNQ4wDezY82JuHupRtjYM
         Tqpw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=goWyNnY+juBPLit62pAaX1kxWdLRVjU36SDXYB0DhtE=;
        b=R0U/9pb+yjxGqw7bqzC46PU/x2FNKaJIYUlY6trYPNlhAIQRwQxmgnRavQ3mR2ASy+
         0w5NmBSKDC9KJS8AozAx7go2QDuEzFP3A8JXNkX2viGYTIBve+eGLNpoDREy3A1C41dC
         FB7jf3CyGgSHZrWzIrUe20ez1YvXRh6U21bw1b1PB3vHtqik6iYkXKPHSb2+XDyk5Qxl
         2ylu72TtSF9oBt1iSlGBRJVsa90AmGsFmkI1sHNRF3cZFqKRjn27RvLzzJCqUi5RQDGW
         y6hetGgayKdvJw2KMHxQLv7s5xUusl4atH1YGrZO5cj0zmZol9qhKp3bo7sJhokmGbLm
         ZJ5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id x32si12568728pld.16.2019.05.01.23.09.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:51 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="139200250"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga008.jf.intel.com with ESMTP; 01 May 2019 23:09:51 -0700
Subject: [PATCH v7 08/12] mm/sparsemem: Prepare for sub-section ranges
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 01 May 2019 22:56:05 -0700
Message-ID: <155677656509.2336373.4432941742094481750.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Prepare the memory hot-{add,remove} paths for handling sub-section
ranges by plumbing the starting page frame and number of pages being
handled through arch_{add,remove}_memory() to
sparse_{add,remove}_one_section().

This is simply plumbing, small cleanups, and some identifier renames. No
intended functional changes.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memory_hotplug.h |    7 +-
 mm/memory_hotplug.c            |  118 +++++++++++++++++++++++++---------------
 mm/sparse.c                    |    7 +-
 3 files changed, 83 insertions(+), 49 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..835a94650ee3 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -354,9 +354,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern int sparse_add_one_section(int nid, unsigned long start_pfn,
-				  struct vmem_altmap *altmap);
-extern void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+extern int sparse_add_section(int nid, unsigned long pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap);
+extern void sparse_remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 108380e20d8f..9f73332af910 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -251,22 +251,44 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 }
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
-static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-		struct vmem_altmap *altmap, bool want_memblock)
+static int __meminit __add_section(int nid, unsigned long pfn,
+		unsigned long nr_pages,	struct vmem_altmap *altmap,
+		bool want_memblock)
 {
 	int ret;
 
-	if (pfn_valid(phys_start_pfn))
+	if (pfn_valid(pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
+	ret = sparse_add_section(nid, pfn, nr_pages, altmap);
 	if (ret < 0)
 		return ret;
 
 	if (!want_memblock)
 		return 0;
 
-	return hotplug_memory_register(nid, __pfn_to_section(phys_start_pfn));
+	return hotplug_memory_register(nid, __pfn_to_section(pfn));
+}
+
+static int subsection_check(unsigned long pfn, unsigned long nr_pages,
+		unsigned long flags, const char *reason)
+{
+	/*
+	 * Only allow partial section hotplug for !memblock ranges,
+	 * since register_new_memory() requires section alignment, and
+	 * CONFIG_SPARSEMEM_VMEMMAP=n requires sections to be fully
+	 * populated.
+	 */
+	if ((!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
+				|| (flags & MHP_MEMBLOCK_API))
+			&& ((pfn & ~PAGE_SECTION_MASK)
+				|| (nr_pages & ~PAGE_SECTION_MASK))) {
+		WARN(1, "Sub-section hot-%s incompatible with %s\n", reason,
+				(flags & MHP_MEMBLOCK_API)
+				? "memblock api" : "!CONFIG_SPARSEMEM_VMEMMAP");
+		return -EINVAL;
+	}
+	return 0;
 }
 
 /*
@@ -275,34 +297,40 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, unsigned long phys_start_pfn,
-		unsigned long nr_pages, struct mhp_restrictions *restrictions)
+int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long i;
-	int err = 0;
-	int start_sec, end_sec;
+	int start_sec, end_sec, err;
 	struct vmem_altmap *altmap = restrictions->altmap;
 
-	/* during initialize mem_map, align hot-added range to section */
-	start_sec = pfn_to_section_nr(phys_start_pfn);
-	end_sec = pfn_to_section_nr(phys_start_pfn + nr_pages - 1);
-
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
 		 */
-		if (altmap->base_pfn != phys_start_pfn
+		if (altmap->base_pfn != pfn
 				|| vmem_altmap_offset(altmap) > nr_pages) {
 			pr_warn_once("memory add fail, invalid altmap\n");
-			err = -EINVAL;
-			goto out;
+			return -EINVAL;
 		}
 		altmap->alloc = 0;
 	}
 
+	err = subsection_check(pfn, nr_pages, restrictions->flags, "add");
+	if (err)
+		return err;
+
+	start_sec = pfn_to_section_nr(pfn);
+	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap,
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		err = __add_section(nid, pfn, pfns, altmap,
 				restrictions->flags & MHP_MEMBLOCK_API);
+		pfn += pfns;
+		nr_pages -= pfns;
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -315,7 +343,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
-out:
 	return err;
 }
 
@@ -494,10 +521,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
 	pgdat->node_spanned_pages = 0;
 }
 
-static void __remove_zone(struct zone *zone, unsigned long start_pfn)
+static void __remove_zone(struct zone *zone, unsigned long start_pfn,
+		unsigned long nr_pages)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
-	int nr_pages = PAGES_PER_SECTION;
 	unsigned long flags;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
@@ -506,29 +533,26 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 	pgdat_resize_unlock(zone->zone_pgdat, &flags);
 }
 
-static void __remove_section(struct zone *zone, struct mem_section *ms,
-			     unsigned long map_offset,
-			     struct vmem_altmap *altmap)
+static void __remove_section(struct zone *zone, unsigned long pfn,
+		unsigned long nr_pages, unsigned long map_offset,
+		struct vmem_altmap *altmap)
 {
-	unsigned long start_pfn;
-	int scn_nr;
+	struct mem_section *ms = __nr_to_section(pfn_to_section_nr(pfn));
 
 	if (WARN_ON_ONCE(!valid_section(ms)))
 		return;
 
 	unregister_memory_section(ms);
 
-	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-	__remove_zone(zone, start_pfn);
+	__remove_zone(zone, pfn, nr_pages);
 
-	sparse_remove_one_section(zone, ms, map_offset, altmap);
+	sparse_remove_section(zone, ms, pfn, nr_pages, map_offset, altmap);
 }
 
 /**
  * __remove_pages() - remove sections of pages from a zone
  * @zone: zone from which pages need to be removed
- * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
+ * @pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
  * @altmap: alternative device page map or %NULL if default memmap is used
  *
@@ -537,31 +561,39 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
+void __remove_pages(struct zone *zone, unsigned long pfn,
 		    unsigned long nr_pages, struct vmem_altmap *altmap)
 {
-	unsigned long i;
 	unsigned long map_offset = 0;
-	int sections_to_remove;
+	int i, start_sec, end_sec;
+	struct memory_block *mem;
+	unsigned long flags = 0;
 
 	if (altmap)
 		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 
-	/*
-	 * We can only remove entire sections
-	 */
-	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
-	BUG_ON(nr_pages % PAGES_PER_SECTION);
+	mem = find_memory_block(__pfn_to_section(pfn));
+	if (mem) {
+		flags |= MHP_MEMBLOCK_API;
+		put_device(&mem->dev);
+	}
 
-	sections_to_remove = nr_pages / PAGES_PER_SECTION;
-	for (i = 0; i < sections_to_remove; i++) {
-		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
+	if (subsection_check(pfn, nr_pages, flags, "remove"))
+		return;
+
+	start_sec = pfn_to_section_nr(pfn);
+	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
+	for (i = start_sec; i <= end_sec; i++) {
+		unsigned long pfns;
 
 		cond_resched();
-		__remove_section(zone, __pfn_to_section(pfn), map_offset,
-				 altmap);
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		__remove_section(zone, pfn, pfns, map_offset, altmap);
+		pfn += pfns;
+		nr_pages -= pfns;
 		map_offset = 0;
 	}
 
diff --git a/mm/sparse.c b/mm/sparse.c
index ed26761327bf..198371e5fc87 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -756,8 +756,8 @@ static void free_map_bootmem(struct page *memmap)
  * * -EEXIST	- Section has been present.
  * * -ENOMEM	- Out of memory.
  */
-int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
-				     struct vmem_altmap *altmap)
+int __meminit sparse_add_section(int nid, unsigned long start_pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	unsigned long section_nr = pfn_to_section_nr(start_pfn);
 	struct mem_section_usage *usage;
@@ -866,7 +866,8 @@ static void free_section_usage(struct page *memmap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
+void sparse_remove_section(struct zone *zone, struct mem_section *ms,
+		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;

