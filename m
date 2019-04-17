Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A35BAC282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5095820663
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 18:53:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5095820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF2696B000D; Wed, 17 Apr 2019 14:53:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA1986B000E; Wed, 17 Apr 2019 14:53:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1C196B0010; Wed, 17 Apr 2019 14:53:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 885886B000D
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 14:53:15 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id x9so16008846pln.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:53:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=IQHg6CwmC/uiN5b4Q03OBpjZcUGL4204JoFqmheTvXA=;
        b=DYyA7dm39Pv3wZMwYpJQSqqaiJ9zHsk6anQFBAYhLRp0O2Hpv/7lD9Um11aaOyPqRw
         2/hUGFO83CjpQTSCe4SxrDG06R63mhSXqUtZwGzQEO31rBJdELtQnWfHKLN0pTbNTrEp
         8S8X72w1rT2+l8Be7DYwjSqs8UV15rFVyLxaX3CbHQI1ot+cR1deuq+gJAVqQIbIK8BE
         lLRBn47pAKIfy6aItSJe1X0QNWCaPGQz6PXf8/dXwIDD/mi/2pjYIrwubDrnTnq8S0xM
         VNPxcJcR0inZ4IzZ4Jcl75k1AIkLK7py/z+f89t/ws7QlX68+He4cH2KKsJ0QDNXPZBZ
         JdXA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXqnQWVELrwcdemjUU+iJLt75IQfkMLpPGw56HWiaNlV637I1sk
	k3JSX3yqS8lhKFvm0oxit1YUmVV383xkJMPnQvmqwYpMoGEufYI9YLf3X1sGlArS1qrBhYrbsPb
	sRBQi3jYMUcSFnAVmDzLkoWU6WzVHCmExU277DXlJPudzTC3gl2qCnG0Whz2Lff4oug==
X-Received: by 2002:a63:5846:: with SMTP id i6mr1318440pgm.423.1555527195172;
        Wed, 17 Apr 2019 11:53:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4MA00G2BDrlJLoX3F0YYsI+Y0puWmihH6l4xdO9HYKYHmGcsP6HLKfZ9VDGRvG/Zr04lX
X-Received: by 2002:a63:5846:: with SMTP id i6mr1318385pgm.423.1555527194276;
        Wed, 17 Apr 2019 11:53:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555527194; cv=none;
        d=google.com; s=arc-20160816;
        b=e+ldmQBoBLprbvBNG/N915fsnBKzwuVodsuOtEWrwJPZgdGdAM643GA3fCMETYRn85
         zAvNQ0Q3NfiBGkIYxmWTgSDfHPecWi5I5eSyk9/GUW6w40X8vbTMjoRti9KGHG8KDSnt
         I0uwwe7RmjRdmGVZpI8cSl5ieHLkF6zAEEYq4VU/y0doT/oX2kXQ8GtPZjaLE6gu2Zlg
         TJzAZeAOydZ6OILOU/gVAfGb3gTvosYSdigHj7XNrb4Jt8BE5HUsruh50Y4a0mSNeVRv
         Evs+AmA+JQKbr6N9T+TM2xRBDboevt771aKiuMyd2s9JFVwYCFts/3U0KKSXkDo5O+jN
         dwTg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=IQHg6CwmC/uiN5b4Q03OBpjZcUGL4204JoFqmheTvXA=;
        b=WarFByhl4/oPoxWgSZkKdCL8YjWUEiQ4RRrPMkZop0efFWJq3F+W4uv4JSTv4aub/R
         hq8stS5Is6ocgjDcX5sEjPda7xYjlZx91D0pdGtHAP0wOMTzYuG+MpH452CojItywOBJ
         lk47oLEaUTGq9GUt4bVjgrPlVF3KhglgoHqmP7N+znWiIcHVRrFWI7QtUveMN9/bJyoq
         nZPLHJRKQn3er0wdpsTTADLLQApc+Mf5489Ev/DFsP5QjmgYyO525ZEtN2jXsr8gXugk
         n4Sqv/NE1+UA8+IEoZJBLzYGCTJVI00hDeBMZzWB87yFHlacgHx79q4fcm5nopZJ6eW6
         NoLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id g67si30470460plb.375.2019.04.17.11.53.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 11:53:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 11:53:12 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="316812583"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga005.jf.intel.com with ESMTP; 17 Apr 2019 11:53:12 -0700
Subject: [PATCH v6 06/12] mm/hotplug: Add mem-hotplug restrictions for
 remove_memory()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Logan Gunthorpe <logang@deltatee.com>,
 David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@suse.com,
 david@redhat.com
Date: Wed, 17 Apr 2019 11:39:27 -0700
Message-ID: <155552636696.2015392.12612320706815016081.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Teach the arch_remove_memory() path to consult the same 'struct
mhp_restrictions' context as was specified at arch_add_memory() time.

No functional change, this is a preparation step for teaching
__remove_pages() about how and when to allow sub-section hot-remove, and
a cleanup for an unnecessary "is_dev_zone()" special case.

Cc: Michal Hocko <mhocko@suse.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: David Hildenbrand <david@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/ia64/mm/init.c            |    4 ++--
 arch/powerpc/mm/mem.c          |    5 +++--
 arch/s390/mm/init.c            |    2 +-
 arch/sh/mm/init.c              |    4 ++--
 arch/x86/mm/init_32.c          |    4 ++--
 arch/x86/mm/init_64.c          |    5 +++--
 include/linux/memory_hotplug.h |    5 +++--
 kernel/memremap.c              |   14 ++++++++------
 mm/memory_hotplug.c            |   17 ++++++++---------
 9 files changed, 32 insertions(+), 28 deletions(-)

diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d28e29103bdb..86c69c87e7e8 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -683,14 +683,14 @@ int arch_add_memory(int nid, u64 start, u64 size,
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void arch_remove_memory(int nid, u64 start, u64 size,
-			struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(zone, start_pfn, nr_pages, restrictions);
 }
 #endif
 #endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index cc9425fb9056..ccab989f397d 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -132,10 +132,11 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size,
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void __meminit arch_remove_memory(int nid, u64 start, u64 size,
-				  struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
+	struct vmem_altmap *altmap = restrictions->altmap;
 	struct page *page;
 	int ret;
 
@@ -147,7 +148,7 @@ void __meminit arch_remove_memory(int nid, u64 start, u64 size,
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 
-	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
+	__remove_pages(page_zone(page), start_pfn, nr_pages, restrictions);
 
 	/* Remove htab bolted mappings for this section of memory */
 	start = (unsigned long)__va(start);
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 31b1071315d7..3af7b99af1b1 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -235,7 +235,7 @@ int arch_add_memory(int nid, u64 start, u64 size,
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void arch_remove_memory(int nid, u64 start, u64 size,
-			struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
 	/*
 	 * There is no hardware or firmware interface which could trigger a
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 5aeb4d7099a1..3cff7e4723e6 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -430,14 +430,14 @@ EXPORT_SYMBOL_GPL(memory_add_physaddr_to_nid);
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void arch_remove_memory(int nid, u64 start, u64 size,
-			struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(zone, start_pfn, nr_pages, restrictions);
 }
 #endif
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 075e568098f2..ba888fd38f5d 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -861,14 +861,14 @@ int arch_add_memory(int nid, u64 start, u64 size,
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 void arch_remove_memory(int nid, u64 start, u64 size,
-			struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
 	zone = page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(zone, start_pfn, nr_pages, restrictions);
 }
 #endif
 #endif
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bb018d09d2dc..4071632be007 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1142,8 +1142,9 @@ kernel_physical_mapping_remove(unsigned long start, unsigned long end)
 }
 
 void __ref arch_remove_memory(int nid, u64 start, u64 size,
-			      struct vmem_altmap *altmap)
+		struct mhp_restrictions *restrictions)
 {
+	struct vmem_altmap *altmap = restrictions->altmap;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct page *page = pfn_to_page(start_pfn);
@@ -1153,7 +1154,7 @@ void __ref arch_remove_memory(int nid, u64 start, u64 size,
 	if (altmap)
 		page += vmem_altmap_offset(altmap);
 	zone = page_zone(page);
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(zone, start_pfn, nr_pages, restrictions);
 	kernel_physical_mapping_remove(start, start + size);
 }
 #endif
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index ae892eef8b82..31b768bd1268 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -125,9 +125,10 @@ static inline bool movable_node_is_enabled(void)
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
 extern void arch_remove_memory(int nid, u64 start, u64 size,
-			       struct vmem_altmap *altmap);
+		struct mhp_restrictions *restrictions);
 extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
-			   unsigned long nr_pages, struct vmem_altmap *altmap);
+		unsigned long nr_pages,
+		struct mhp_restrictions *restrictions);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 /*
diff --git a/kernel/memremap.c b/kernel/memremap.c
index f355586ea54a..33475e211568 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -108,8 +108,11 @@ static void devm_memremap_pages_release(void *data)
 		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
 				align_size >> PAGE_SHIFT, NULL);
 	} else {
-		arch_remove_memory(nid, align_start, align_size,
-				pgmap->altmap_valid ? &pgmap->altmap : NULL);
+		struct mhp_restrictions restrictions = {
+			.altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL,
+		};
+
+		arch_remove_memory(nid, align_start, align_size, &restrictions);
 		kasan_remove_zero_shadow(__va(align_start), align_size);
 	}
 	mem_hotplug_done();
@@ -142,15 +145,14 @@ static void devm_memremap_pages_release(void *data)
 void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 {
 	resource_size_t align_start, align_size, align_end;
-	struct vmem_altmap *altmap = pgmap->altmap_valid ?
-			&pgmap->altmap : NULL;
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
 	struct mhp_restrictions restrictions = {
 		/*
 		 * We do not want any optional features only our own memmap
 		*/
-		.altmap = altmap,
+
+		.altmap = pgmap->altmap_valid ? &pgmap->altmap : NULL,
 	};
 	pgprot_t pgprot = PAGE_KERNEL;
 	int error, nid, is_ram;
@@ -235,7 +237,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 
 		zone = &NODE_DATA(nid)->node_zones[ZONE_DEVICE];
 		move_pfn_range_to_zone(zone, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, altmap);
+				align_size >> PAGE_SHIFT, restrictions.altmap);
 	}
 
 	mem_hotplug_done();
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d5874f9d4043..055cea62be6e 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -543,7 +543,7 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
  * @zone: zone from which pages need to be removed
  * @phys_start_pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section size)
- * @altmap: alternative device page map or %NULL if default memmap is used
+ * @restrictions: optional alternative device page map and other features
  *
  * Generic helper function to remove section mappings and sysfs entries
  * for the section of the memory we are removing. Caller needs to make
@@ -551,17 +551,15 @@ static void __remove_section(struct zone *zone, struct mem_section *ms,
  * calling offline_pages().
  */
 void __remove_pages(struct zone *zone, unsigned long phys_start_pfn,
-		    unsigned long nr_pages, struct vmem_altmap *altmap)
+		unsigned long nr_pages, struct mhp_restrictions *restrictions)
 {
 	unsigned long i;
-	unsigned long map_offset = 0;
 	int sections_to_remove;
+	unsigned long map_offset = 0;
+	struct vmem_altmap *altmap = restrictions->altmap;
 
-	/* In the ZONE_DEVICE case device driver owns the memory region */
-	if (is_dev_zone(zone)) {
-		if (altmap)
-			map_offset = vmem_altmap_offset(altmap);
-	}
+	if (altmap)
+		map_offset = vmem_altmap_offset(altmap);
 
 	clear_zone_contiguous(zone);
 
@@ -1832,6 +1830,7 @@ static void __release_memory_resource(u64 start, u64 size)
  */
 void __ref __remove_memory(int nid, u64 start, u64 size)
 {
+	struct mhp_restrictions restrictions = { 0 };
 	int ret;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
@@ -1853,7 +1852,7 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
 	memblock_free(start, size);
 	memblock_remove(start, size);
 
-	arch_remove_memory(nid, start, size, NULL);
+	arch_remove_memory(nid, start, size, &restrictions);
 	__release_memory_resource(start, size);
 
 	try_offline_node(nid);

