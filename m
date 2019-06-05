Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7A5ADC28CC6
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 310312075B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 22:12:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 310312075B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D648B6B0276; Wed,  5 Jun 2019 18:12:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D3A1C6B0277; Wed,  5 Jun 2019 18:12:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C02646B0278; Wed,  5 Jun 2019 18:12:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8837D6B0276
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 18:12:56 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d125so291810pfd.3
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 15:12:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ppDn4NbXCYcwgcq7IflsAAu6CLujpPkaxxXGcE+TDd0=;
        b=q/RIg7wiYnwamfdfK2vF5x/by/vmxEkGUVgAvoVvp+CXJ3J3KQWr9cL89DHevOD30+
         5UQ8YZV4nLE4DMeNvtRjpMxEHFBnIxKh0FxVQfgT7tibeiMf4BM6zSzCoMs8TrKpXBbu
         3QV7M4lc8beJbNOVo0F4ptQLQel9EegF/O43lGp5WyC9nfpi2Q2z8PoYb3DG890NQoWg
         tJpUSZFC1yni/T4N1tLHRrq0s24vsE1Q0NGcKwJSBLocTD/DLf+Ra/ymk2d5je85BQ8h
         m1o17QkuZgtjcPYw4S4O/rqJC/ldJ33cHOqip+V+BvLcFoyNIUmokMrX6lyfNAZAZ0DM
         pGeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVUES2f0S8jmSqAvNlYCeSXhJBMZVCUxkZyu9al7vQKzb5Ae4To
	SOz4K7VeEqYdbHfGbeqADT9g//B/y+Hq+Axurdx1BNApPDfs46oUjBWHj6nfFZt/79+aveuLQqG
	lE/mkLghppMBDLSjEIF5U6N/lXt3aw/yy9SfDj5O54SmJ3KwXKtYTHhgmyY7eoyUP3A==
X-Received: by 2002:a62:5801:: with SMTP id m1mr50098009pfb.32.1559772776051;
        Wed, 05 Jun 2019 15:12:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx8y7huiaBqUKwAbJXIJ/Z18pw3FC9/8mzw2/6R/YDwE9C0oezE17A6LoVwXdOUNDsY4C8s
X-Received: by 2002:a62:5801:: with SMTP id m1mr50097879pfb.32.1559772775041;
        Wed, 05 Jun 2019 15:12:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559772775; cv=none;
        d=google.com; s=arc-20160816;
        b=kVgKxpeYE7hPTDsWDojdO4LE3Q+brMfRGIZMTLtlb6Mmibyt10euJ34+1VkY1Lumoo
         viFaF+m/hLkJ1H46KL9YJn7mRiuacGJH/QkUL0Vt2lm/yqyYzQIUKXR1EGJqonmT4Lo2
         8KM++0e3ILws6B5J2aLMDMAUSQ1t+HPhQeWDPSWqzFSaO2EDvhb7z7mhgVURAvuM6/I0
         iQ22w0gHDF4t5oUMzJrDSFehTFQBpSYMA+Gsrol6ZtV8LW4BFtip+3K9fbEAtB9wnu52
         tv5VFTtkG0uVvBGJsgifqkK+VplxPbOz+ua+cQ+CdOy91MxPGm8KyyJnsnPyVWMKL1eY
         HqpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ppDn4NbXCYcwgcq7IflsAAu6CLujpPkaxxXGcE+TDd0=;
        b=GUiUbB+frjJqRYJo1qwE0aQuhHo3Rx2k/nN2uc9gblwaSlpm+8M3wd2S1HyKHN0/Ql
         bJQVMvuRjqVwHCAIYBCbK3C3vepJG0xNAk5qGMw7rjQ4AoKnsU9l2+leazQaWwlxNfav
         S3Ly4o89dUFpshrAJSJezIEPAzB2o4SjYCxsuQKAvUInPQcHXFSJ8j00ixHIIU7Z1aSr
         hV/pwtwd2/6O67SQIgYEgMYU+jREK4gsVXyu2TmlfMJhJXLibsExlPLMnXzmAev+5Mqa
         kB+iQMnA+Jq1Gj9wJCNASAJGKNYOhtBkeAIU2H0SfQvH9XqiSWM030/pYZNnf0MDfnZq
         RN5w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id b19si33554198pfi.23.2019.06.05.15.12.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 15:12:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 05 Jun 2019 15:12:54 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 05 Jun 2019 15:12:54 -0700
Subject: [PATCH v9 07/12] mm/sparsemem: Prepare for sub-section ranges
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 05 Jun 2019 14:58:37 -0700
Message-ID: <155977191770.2443951.1506588644989416699.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Prepare the memory hot-{add,remove} paths for handling sub-section
ranges by plumbing the starting page frame and number of pages being
handled through arch_{add,remove}_memory() to
sparse_{add,remove}_one_section().

This is simply plumbing, small cleanups, and some identifier renames. No
intended functional changes.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Oscar Salvador <osalvador@suse.de>
Reviewed-by: Pavel Tatashin <pasha.tatashin@soleen.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 include/linux/memory_hotplug.h |    5 +-
 mm/memory_hotplug.c            |  114 +++++++++++++++++++++++++---------------
 mm/sparse.c                    |   15 ++---
 3 files changed, 81 insertions(+), 53 deletions(-)

diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 79e0add6a597..3ab0282b4fe5 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -348,9 +348,10 @@ extern int add_memory_resource(int nid, struct resource *resource);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
-extern int sparse_add_one_section(int nid, unsigned long start_pfn,
-				  struct vmem_altmap *altmap);
+extern int sparse_add_section(int nid, unsigned long pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern void sparse_remove_one_section(struct mem_section *ms,
+		unsigned long pfn, unsigned long nr_pages,
 		unsigned long map_offset, struct vmem_altmap *altmap);
 extern struct page *sparse_decode_mem_map(unsigned long coded_mem_map,
 					  unsigned long pnum);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 4b882c57781a..399bf78bccc5 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -252,51 +252,84 @@ void __init register_page_bootmem_info_node(struct pglist_data *pgdat)
 }
 #endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
-static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
-				   struct vmem_altmap *altmap)
+static int __meminit __add_section(int nid, unsigned long pfn,
+		unsigned long nr_pages,	struct vmem_altmap *altmap)
 {
 	int ret;
 
-	if (pfn_valid(phys_start_pfn))
+	if (pfn_valid(pfn))
 		return -EEXIST;
 
-	ret = sparse_add_one_section(nid, phys_start_pfn, altmap);
+	ret = sparse_add_section(nid, pfn, nr_pages, altmap);
 	return ret < 0 ? ret : 0;
 }
 
+static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
+		const char *reason)
+{
+	/*
+	 * Disallow all operations smaller than a sub-section and only
+	 * allow operations smaller than a section for
+	 * SPARSEMEM_VMEMMAP. Note that check_hotplug_memory_range()
+	 * enforces a larger memory_block_size_bytes() granularity for
+	 * memory that will be marked online, so this check should only
+	 * fire for direct arch_{add,remove}_memory() users outside of
+	 * add_memory_resource().
+	 */
+	unsigned long min_align;
+
+	if (IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP))
+		min_align = PAGES_PER_SUBSECTION;
+	else
+		min_align = PAGES_PER_SECTION;
+	if (!IS_ALIGNED(pfn, min_align)
+			|| !IS_ALIGNED(nr_pages, min_align)) {
+		WARN(1, "Misaligned __%s_pages start: %#lx end: #%lx\n",
+				reason, pfn, pfn + nr_pages - 1);
+		return -EINVAL;
+	}
+	return 0;
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
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
 
+	err = check_pfn_span(pfn, nr_pages, "add");
+	if (err)
+		return err;
+
+	start_sec = pfn_to_section_nr(pfn);
+	end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
 	for (i = start_sec; i <= end_sec; i++) {
-		err = __add_section(nid, section_nr_to_pfn(i), altmap);
+		unsigned long pfns;
+
+		pfns = min(nr_pages, PAGES_PER_SECTION
+				- (pfn & ~PAGE_SECTION_MASK));
+		err = __add_section(nid, pfn, pfns, altmap);
+		pfn += pfns;
+		nr_pages -= pfns;
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -309,7 +342,6 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
-out:
 	return err;
 }
 
@@ -487,10 +519,10 @@ static void shrink_pgdat_span(struct pglist_data *pgdat,
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
@@ -499,27 +531,23 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
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
 
-	scn_nr = __section_nr(ms);
-	start_pfn = section_nr_to_pfn((unsigned long)scn_nr);
-	__remove_zone(zone, start_pfn);
-
-	sparse_remove_one_section(ms, map_offset, altmap);
+	__remove_zone(zone, pfn, nr_pages);
+	sparse_remove_one_section(ms, pfn, nr_pages, map_offset, altmap);
 }
 
 /**
  * __remove_pages() - remove sections of pages from a zone
  * @zone: zone from which pages need to be removed
- * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
+ * @pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
  * @altmap: alternative device page map or %NULL if default memmap is used
  *
@@ -528,31 +556,31 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
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
 
 	if (altmap)
 		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 
-	/*
-	 * We can only remove entire sections
-	 */
-	BUG_ON(phys_start_pfn & ~PAGE_SECTION_MASK);
-	BUG_ON(nr_pages % PAGES_PER_SECTION);
+	if (check_pfn_span(pfn, nr_pages, "remove"))
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
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 2093c662a5f7..f65206deaf49 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -739,8 +739,8 @@ static void free_map_bootmem(struct page *memmap)
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
@@ -848,8 +848,9 @@ static void free_section_usage(struct page *memmap,
 		free_map_bootmem(memmap);
 }
 
-void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
-			       struct vmem_altmap *altmap)
+void sparse_remove_one_section(struct mem_section *ms, unsigned long pfn,
+		unsigned long nr_pages, unsigned long map_offset,
+		struct vmem_altmap *altmap)
 {
 	struct page *memmap = NULL;
 	struct mem_section_usage *usage = NULL;
@@ -862,9 +863,7 @@ void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
 		ms->usage = NULL;
 	}
 
-	clear_hwpoisoned_pages(memmap + map_offset,
-			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage, section_nr_to_pfn(__section_nr(ms)),
-			PAGES_PER_SECTION, altmap);
+	clear_hwpoisoned_pages(memmap + map_offset, nr_pages - map_offset);
+	free_section_usage(memmap, usage, pfn, nr_pages, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */

