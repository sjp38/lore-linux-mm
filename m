Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F246EC46477
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A463E20679
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:06:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A463E20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5AA076B000E; Wed, 19 Jun 2019 02:06:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 55D118E0002; Wed, 19 Jun 2019 02:06:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 424988E0001; Wed, 19 Jun 2019 02:06:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 07F926B000E
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:06:37 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 71so9213369pld.17
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:06:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=yjul3cXNe+Ots4bECSmwFa4bwz15EUcOCkpt7FBWuQ8=;
        b=kjKfm35zF01obVjtN+L82ce9xWbbuPFnCzsfFxkXxCq9mPTBfboc09EnnrmnH/10W8
         DMzQEJS18xB7ic5jDKsAN87sywtOy/Dr0FCmE6y9iDhCao2F4CcrE8FoJ/hjYv+Uvwmv
         30d30LOEU3MZW9yMHbCm7zONwhFki4qHHZUh6C9Ct6YDbgSy5dssXUtUahy5jBVIp2i+
         /HNOc7cyl+Ud9oxzW5jgFCGGVftje9GuH+yZcO/0osFl0E5IQa9aJlWa362pco0OrkY8
         vY107cWGih+cusXJ9VnMhs+zlX64UyHqZn30Rw04CULszJX7K4P7lEBAivJXd8J6MDs6
         ZESw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkJGx+RQe+EVROWxfw8t51enBS/tlPR7zuLYg7Ks35gWEJBLVo
	A+wjxtpVsBhD7LICkCfBvR0kz3oLbjh+lrRGRc//sHkfwM2nNSQnHDIOIIADkOTflHzwwEDlBY0
	ItvPiraSdYHzIWLygTsNuelTzUgp2GwMP80lu5YQeNbI2mqME3b+udM8iMmAJSVFbzQ==
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr9066620pjq.69.1560924396675;
        Tue, 18 Jun 2019 23:06:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/VZACt39guHWKabY5OUIzPIfuK0kMPl7ozJM7Yk0yTT5mz7eKUHS0JIsIBOnPlIxZlMht
X-Received: by 2002:a17:90a:1b4c:: with SMTP id q70mr9066572pjq.69.1560924395912;
        Tue, 18 Jun 2019 23:06:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560924395; cv=none;
        d=google.com; s=arc-20160816;
        b=Bl/hNCHc/K+Q7L8bqT5F9Fefzeh/G2Odh+MNHPGTXtdi5sj99u+sgxGsphx/HX1W0R
         dnrih8aMhveSKI3cnQtLDXVZXHqqL4xKX6Pzd88hIT36jGQGdMcKQHdq+KyQDk/5sdAX
         G40+6pBnUsNji1xOvWYe69xHpnrHcqFpgqzQ8r8rR1gB0TN2NdcOiiIGxJ8M838HHNvh
         TYJRZKC1ztGvewpbf6ZbUllgXIJL5zfLY88iBWGWlDIZGl8FusBM0XiVU5+di7TtAOxc
         R6nxMSxuMwhLX0U1j5JL7PFpasH+TyTApfIuLpZWl/oybYL3YZd3gJE2ASh9QD+DwTC2
         aBcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=yjul3cXNe+Ots4bECSmwFa4bwz15EUcOCkpt7FBWuQ8=;
        b=l3BiQNjC6EcmNYl6dDvRdx2KcHfxeDlvh8wML6m8DNUohaQ3pLJohPJC0I9RKvo2kd
         jYeFcDVBe7DM7F/HjgBAEknhfcfBc08qpRlzcB6UxBZAN6Q10pD1V6ToI72Z9Q5rleuc
         iexW3qna3HbO7EUisAz5w2clJ+VrddiKKGtKkT7WsOua3D6s9M7JTS9fbw/KV+Kx2Ys7
         VEM2HguQipLbWGW7IufDmMX5T2WlBiGhuG2sJLBQQZCpC5EW4Om0mYcDe+14Cxc7a8t5
         8fzGVpvgD0SodB5tdLopjbevXizdIlwHdV4rT2uHVIgEssbappkfjwPG5jGttdK529CX
         /QmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id w2si2220288pgr.396.2019.06.18.23.06.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:06:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:35 -0700
X-IronPort-AV: E=Sophos;i="5.63,392,1557212400"; 
   d="scan'208";a="168146307"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga003-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 18 Jun 2019 23:06:34 -0700
Subject: [PATCH v10 08/13] mm/sparsemem: Prepare for sub-section ranges
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>,
 Logan Gunthorpe <logang@deltatee.com>, Oscar Salvador <osalvador@suse.de>,
 Pavel Tatashin <pasha.tatashin@soleen.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org
Date: Tue, 18 Jun 2019 22:52:17 -0700
Message-ID: <156092353780.979959.9713046515562743194.stgit@dwillia2-desk3.amr.corp.intel.com>
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
 mm/sparse.c                    |   16 ++----
 3 files changed, 81 insertions(+), 54 deletions(-)

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
index 49f0c03d15a3..ad47e25c8f94 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -728,8 +728,8 @@ static void free_map_bootmem(struct page *memmap)
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
@@ -834,8 +834,9 @@ static void free_section_usage(struct mem_section *ms, struct page *memmap,
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
@@ -848,10 +849,7 @@ void sparse_remove_one_section(struct mem_section *ms, unsigned long map_offset,
 		ms->usage = NULL;
 	}
 
-	clear_hwpoisoned_pages(memmap + map_offset,
-			PAGES_PER_SECTION - map_offset);
-	free_section_usage(ms, memmap, usage,
-			section_nr_to_pfn(__section_nr(ms)),
-			PAGES_PER_SECTION, altmap);
+	clear_hwpoisoned_pages(memmap + map_offset, nr_pages - map_offset);
+	free_section_usage(ms, memmap, usage, pfn, nr_pages, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */

