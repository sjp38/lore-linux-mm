Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2993C282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5001320663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5001320663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F2AF26B0010; Wed, 17 Apr 2019 14:53:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F02F56B0266; Wed, 17 Apr 2019 14:53:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF1DF6B0269; Wed, 17 Apr 2019 14:53:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A51B96B0010
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:24 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id z7so15190894pgc.1
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=lZbnnnZKADsTNE0g7XzWh3rYR7warp6wAZ1OsQ/E7pw=;
        b=Ef5s3LwFK0FUPWEAnPry05xe8cCVyV5azzSA6GM2NQBN7BG7WHmj+TUV32VkHc6lTF
         hWIkwJ5uyHJAodAjFNx1FfzMMg3hGSSmumlBgmLZqpJwId8Pl9jKHNC9PrJn7eQG0rwK
         D/cNfJI/eeO5dncJFByvGto3DwtJUUi+hsKSQfHrYmhrHZzk1uoytHAtrXIChroiPN/3
         wAy4bF61OQNwuMVi6/5yiDt5DN5GWcvpLIN+Ygk61uG3PXBwRi/50imJ2x7tlD86hhfK
         hkfwzXwPa15lq6n0Pcl6a8Np3wDv9m371OIscTgj6o7FJ59jMPSNq2/NjNZgbIDJTGKu
         ijaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVrDb1h3Uv6ccFwBUGreWPHyBeqAmWOd4QWd8IsjwHN48Qxlilg
	Su0meEPwrJN2N6IRCzpK0c0lDaSdyqtOYjhqEqGeXNwOPrPp0mfXR1cbh7SoVCbTXnJYxBfD5PA
	hZvUa/5cRgwn67wPOK2+eCIvSG2NXbgaaOdf1LL3ZmSZFQMpkn5TJtNgP5t4PqrxUbA==
X-Received: by 2002:a62:76c1:: with SMTP id r184mr88352362pfc.229.1555527204305;
        Wed, 17 Apr 2019 11:53:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxj3YWWvjM5+pYJV7Rchvbf0mavRV4dUg+zzRaK4yBjzIbT3PEOQExTe3Trg7NwDHQtMZIo
X-Received: by 2002:a62:76c1:: with SMTP id r184mr88352281pfc.229.1555527203220;
        Wed, 17 Apr 2019 11:53:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527203; cv=none;
        d=google.com; s=arc-20160816;
        b=nxpukbpahvufJWmQDVHwU646NCZcxld2jdy6iZEVigC0PDwFxgJov7al7/6gK4QNUE
         udx4DuMDDM+cvQHr6mb1uAiTcaRCPagXcKd/Jj+c907IECnsc2a50hIQArsGW05jWThG
         0PZDcZut5HJgbArodzmCbkrTMS8na1cyjNjtM9kg4urQ3ZSGCdNjEDI8cNvw9owGMGay
         vjKo+imeE+0HuzFUgINVkXNxpXKmH4r2UPywYrS/fm0hPU8d2/f1y/+9AvkisOECwZqg
         ZU5JIbuMcYeHMoJKrxjGTA0hGasqbVOIpxIOxBLQ4ft6PtNMGV+NUUt0wFqA09Pt7LiV
         +1Ng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=lZbnnnZKADsTNE0g7XzWh3rYR7warp6wAZ1OsQ/E7pw=;
        b=nOh7guGd7W4c6YZ1HF61927kOOi2/N6hIA9fjaGeRkWwEsS3VzBYfxgh6HLabStAuq
         7fwVxV5eGVLQRNYDRmKXgBOdG4pCJbdIA08zFCDZ3CK/8GyVEVoL0IUBg0WHH8WnBgko
         3vnM97eTe9AJfIXShxER1zwazfPqkdCFAT8S9y/hrl8SNTRalc9ZybBItoS3jqdZQkcC
         1cvbsYB42JhgBgSvIJbHyTSOymt0pqMG276i5kTgdPoKh+qzN1AtUVtbj9f5R5pYMR1g
         7bZEFFQWLsaO8LD8UwW5qp6JiKRMKSmcQTb0uO9Jl35zQtLoWoYOgPl9RaQ/u0YCNCm0
         KCQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id b41si27189133pla.241.2019.04.17.11.53.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga004.jf.intel.com ([10.7.209.38])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:22 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="292403148"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga004.jf.intel.com with ESMTP; 17 Apr 2019 11:53:22 -0700
Subject: [PATCH v6 08/12] mm/sparsemem: Prepare for sub-section ranges
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:37 -0700
Message-ID: <155552637717.2015392.6818206043460116960.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 include/linux/memory_hotplug.h |    7 ++-
 mm/memory_hotplug.c            |  103 ++++++++++++++++++++++++----------------
 mm/sparse.c                    |    7 ++-
 3 files changed, 71 insertions(+), 46 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 31b768bd1268..70dd3b4d9ceb 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -355,9 +355,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
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
index 055cea62be6e..6622c4d06ac3 100644
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
+		struct mhp_restrictions *restrictions, const char *reason)
+{
+	/*
+	 * Only allow partial section hotplug for !memblock ranges,
+	 * since register_new_memory() requires section alignment, and
+	 * CONFIG_SPARSEMEM_VMEMMAP=n requires sections to be fully
+	 * populated.
+	 */
+	if ((!IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP)
+				|| (restrictions->flags & MHP_MEMBLOCK_API))
+			&& ((pfn & ~PAGE_SECTION_MASK)
+				|| (nr_pages & ~PAGE_SECTION_MASK))) {
+		WARN(1, "Sub-section hot-%s incompatible with %s\n", reason,
+				(restrictions->flags & MHP_MEMBLOCK_API)
+				? "memblock api" : "!CONFIG_SPARSEMEM_VMEMMAP");
+		return -EINVAL;
+	}
+	return 0;
 }
 
 /*
@@ -275,23 +297,19 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  * call this function after deciding the zone to which to
  * add the new pages.
  */
-int __ref __add_pages(int nid, unsigned long phys_start_pfn,
-		unsigned long nr_pages, struct mhp_restrictions *restrictions)
+int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
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
 			err = -EINVAL;
@@ -300,9 +318,17 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		altmap->alloc = 0;
 	}
 
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
@@ -507,10 +533,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
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
@@ -519,29 +545,26 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
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
  * @restrictions: optional alternative device page map and other features
  *
@@ -550,11 +573,10 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		unsigned long nr_pages, struct mhp_restrictions *restrictions)
+void __remove_pages(struct zone *zone, unsigned long pfn,
+		 unsigned long nr_pages, struct mhp_restrictions *restrictions)
 {
-	unsigned long i;
-	int sections_to_remove;
+	int i, start_sec, end_sec;
 	unsigned long map_offset = 0;
 	struct vmem_altmap *altmap = restrictions->altmap;
 
@@ -563,19 +585,20 @@ void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
 
 	clear_zone_contiguous(zone);
 
-	/*
-	 * We can only remove entire sections
-	 */
-	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
-	BUG_ON(nr_pages % PAGES_PER_SECTION);
+	if (subsection_check(pfn, nr_pages, restrictions, "remove"))
+		return;
 
-	sections_to_remove = nr_pages / PAGES_PER_SECTION;
-	for (i = 0; i < sections_to_remove; i++) {
-		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;
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
 
@@ -1830,7 +1853,7 @@ static void __release_memory_resource(u64 start, u64 size)
  */
 void __ref __remove_memory(int nid, u64 start, u64 size)
 {
-	struct mhp_restrictions restrictions = { 0 };
+	struct mhp_restrictions restrictions = { .flags = MHP_MEMBLOCK_API };
 	int ret;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
diff --git a/mm/sparse.c b/mm/sparse.c
index 98408c0da060..bd45bff78ca1 100644
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

