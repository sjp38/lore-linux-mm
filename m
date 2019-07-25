Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 632B1C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0DEA22238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0DEA22238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542728E0003; Thu, 25 Jul 2019 12:02:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F2E46B026B; Thu, 25 Jul 2019 12:02:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3956C8E0003; Thu, 25 Jul 2019 12:02:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id B55846B026A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:20 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so32390006edr.8
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=f7UUvJsfXZXodHTfIDUHMCaAGiYivhzT6pUIeqGM2J0=;
        b=MC5xqpTipo+J0i2U4qQ6jeGqpxLvBESopzDqElrDnmmi/NRz2kowqGyqeMUSppA+jh
         12W6sHnj2xdTUkkktJorBTYASEk5T7SAT2Z2wGX9YyStHRIHtexvHP6QDGOuk1rykNd7
         6BMujhsqbAzccsSnIjXhaKNGhbfznO0MHyr4C7s73kFGefgnabMa6Lf6tFRpVkKL0XnU
         9E3FYdqME79M5bpNcZu0rOowXZSEAiz+ULydsPE6C/xNchOBUi3fvtuHZu1Jpy9xnN/y
         P9xcV2Zz9pVDOSOEXyPpT/l0Ebqdl/TBT2TO/7SQwRFquoPIqxHNUM+hHGZcLAgbbjxf
         /MLA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUZJFYkRy/kqIfD3QSmhS/E6JB4OM0pLkJ6YLjh/2L0Kdpo/Wkl
	HxL1DuThDH9nCG1EZBLamZpHtJM5nY3wiBV8IMfj9oaLfBY5kCHdFZ8YnWVopAvN4wJX8wn4pNj
	vbo9CuBDhwPTZKThW/h/zhCxLDtlnIvJO4CuHxGiuUh27R5Fe+4S5Cs3kBjWlfyOCKA==
X-Received: by 2002:a17:906:c459:: with SMTP id ck25mr67563012ejb.32.1564070540225;
        Thu, 25 Jul 2019 09:02:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxlqoP91n67XZ2JoBztBRn0hDSg8Q+61OzMpeSENN+HtaHpInf9Yf8j0bhPphm7DoLMNdyK
X-Received: by 2002:a17:906:c459:: with SMTP id ck25mr67562775ejb.32.1564070537558;
        Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070537; cv=none;
        d=google.com; s=arc-20160816;
        b=Vr25dGesPX9uORLKC5GNojQcVdYMBdLM1akUBPn5W1Y6CtDc/+wj0f5tpU1ZuFn559
         U17QuZtStwAy6AEW0pKjATCEW9l8Yfha+NpssbzmDH4qPFQiYLKZ+8tbvmWevfLZx+1q
         Cq96LLJUkAklz7UF9Oeb7+zBZqvrLsPzOenWYc1j/XP/bmkpGqaM+TxgacNu96JZI6Fh
         xXyeH7e/pjIkjgyPhUwF/kOVYTFFBwsa3z9Rc9RQmUWn/YDotVskopqfyrMusUqBn1rN
         0GfY9po+Tj6byJfFwGMUr/5Bd53Q0krOSCMVlBucN4R5CBo0xcghyHfCVcJ17rMuShuE
         xW9Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=f7UUvJsfXZXodHTfIDUHMCaAGiYivhzT6pUIeqGM2J0=;
        b=M+u12nxynlUCNW0FGU2Thw2mFJTJX+2jiif87jN+B1uHJKEGuNnx7tYiR/jfBRgeV0
         Mp4VMlDYIDmX0ehmUMw7dkTGDjQ/D6FV/yWKuPNS4YujnP5nrJPe8Geg8qGg6yciQgvR
         aHoPdZvJvxJoDsH6p9SEknJjuepKwrS64vWywClOlCo5+lCbkqK+rtpj/gZFpIiJhbno
         1gtYQtXJJisxR7SIuMgUCNjUXLWcIfPdMNLDe2lRE1IchnEgh9AQFX+oRdBmJE5UOQ5T
         hg6ZuoHZ5mtNAfYPsvBF1jYrrC5kqkjwhYnqXCQcLNkzRkNQ1hK2A4tsSs8HrajZsR67
         bY8w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z7si11339955edc.200.2019.07.25.09.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0E131AFE2;
	Thu, 25 Jul 2019 16:02:17 +0000 (UTC)
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: dan.j.williams@intel.com,
	david@redhat.com,
	pasha.tatashin@soleen.com,
	mhocko@suse.com,
	anshuman.khandual@arm.com,
	Jonathan.Cameron@huawei.com,
	vbabka@suse.cz,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH v3 4/5] mm,memory_hotplug: Allocate memmap from the added memory range for sparse-vmemmap
Date: Thu, 25 Jul 2019 18:02:06 +0200
Message-Id: <20190725160207.19579-5-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
References: <20190725160207.19579-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Physical memory hotadd has to allocate a memmap (struct page array) for
the newly added memory section. Currently, alloc_pages_node() is used
for those allocations.

This has some disadvantages:
 a) an existing memory is consumed for that purpose
    (~2MB per 128MB memory section on x86_64)
 b) if the whole node is movable then we have off-node struct pages
    which has performance drawbacks.

a) has turned out to be a problem for memory hotplug based ballooning
   because the userspace might not react in time to online memory while
   the memory consumed during physical hotadd consumes enough memory to
   push system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
   policy for the newly added memory") has been added to workaround that
   problem.

This can be improved when CONFIG_SPARSEMEM_VMEMMAP is enabled.

Vmemap page tables can map arbitrary memory.
That means that we can simply use the beginning of each memory section and
map struct pages there.
struct pages which back the allocated space then just need to be treated
carefully.

Implementation wise we will reuse vmem_altmap infrastructure to override
the default allocator used by __vmemap_populate. Once the memmap is
allocated, we are going to need a way to mark altmap pfns used for the allocation.
If MHP_MEMMAP_ON_MEMORY flag was passed, we will set up the layout of the
altmap structure at the beginning of __add_pages(), and then we will call
mhp_mark_vmemmap_pages() to do the proper marking.

mhp_mark_vmemmap_pages() marks the pages as vmemmap and sets some metadata:

Vmemmap's pages layout is as follows:

        * Layout:
        * Head:
        *      head->vmemmap_pages     : nr of vmemmap pages
        *      head->vmemmap_sections  : nr of sections used by this altmap
        * Tail:
        *      tail->vmemmap_head      : head
        * All:
        *      page->type              : Vmemmap

E.g:
When hot-add 1GB on x86_64 :

head->vmemmap_pages = 4096
head->vmemmap_sections = 8

We keep this information within the struct pages as we need them in certain
stages like offline, online and hot-remove.

head->vmemmap_sections is a kind of refcount, because when using MHP_MEMMAP_ON_MEMORY,
we need to know how much do we have to defer the call to vmemmap_free().
The thing is that the first pages of the memory range are used to store the
memmap mapping, so we cannot remove those first, otherwise we would blow up
when accessing the other pages.

So, instead of actually removing the section (with vmemmap_free), we wait
until we remove the last one, and then we call vmemmap_free() for all
batched sections.

We also have to be careful about those pages during online and offline
operations. They are simply skipped, so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

In offline operation we only have to check for one particularity.
Depending on the way the hot-added range was added, it might be that,
that one or more of memory blocks from the beginning are filled with
only vmemmap pages.
We just need to check for this case and skip 1) isolating 2) migrating,
because those pages do not need to be migrated anywhere, as they are
self-hosted.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/powerpc/mm/init_64.c      |   7 +++
 arch/s390/mm/init.c            |   6 ++
 arch/x86/mm/init_64.c          |  10 +++
 drivers/acpi/acpi_memhotplug.c |   3 +-
 include/linux/memory_hotplug.h |   6 ++
 include/linux/memremap.h       |   2 +-
 mm/compaction.c                |   7 +++
 mm/memory_hotplug.c            | 136 ++++++++++++++++++++++++++++++++++++++---
 mm/page_alloc.c                |  26 +++++++-
 mm/page_isolation.c            |  14 ++++-
 mm/sparse.c                    | 107 ++++++++++++++++++++++++++++++++
 11 files changed, 309 insertions(+), 15 deletions(-)

diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a44f6281ca3a..f19aa006ca6d 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -292,6 +292,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 
 		if (base_pfn >= alt_start && base_pfn < alt_end) {
 			vmem_altmap_free(altmap, nr_pages);
+		} else if (PageVmemmap(page)) {
+			/*
+			 * runtime vmemmap pages are residing inside the memory
+			 * section so they do not have to be freed anywhere.
+			 */
+			while (PageVmemmap(page))
+				ClearPageVmemmap(page++);
 		} else if (PageReserved(page)) {
 			/* allocated from bootmem */
 			if (page_size < PAGE_SIZE) {
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 20340a03ad90..adb04f3977eb 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -278,6 +278,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunately.
+	 */
+	restrictions->flags &= ~restrictions->flags;
+
 	if (WARN_ON_ONCE(restrictions->altmap))
 		return -EINVAL;
 
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a6b5c653727b..f9f720a28b3e 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -876,6 +876,16 @@ static void __meminit free_pagetable(struct page *page, int order)
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
+	/*
+	 * Runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page)) {
+		while (nr_pages--)
+			ClearPageVmemmap(page++);
+		return;
+	}
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index d91b3584d4b2..e0148dde5313 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -207,7 +207,8 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length, 0);
+		result = __add_memory(node, info->start_addr, info->length,
+				      MHP_MEMMAP_ON_MEMORY);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 6b20008d9297..e1e8abf22a80 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -377,4 +377,10 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
 		int online_type);
 extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 		unsigned long nr_pages);
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+extern void mhp_mark_vmemmap_pages(struct vmem_altmap *self);
+#else
+static inline void mhp_mark_vmemmap_pages(struct vmem_altmap *self) {}
+#endif
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 2cfc3c289d01..0a7355b8c1cf 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -16,7 +16,7 @@ struct device;
  * @alloc: track pages consumed, private to vmemmap_populate()
  */
 struct vmem_altmap {
-	const unsigned long base_pfn;
+	unsigned long base_pfn;
 	const unsigned long reserve;
 	unsigned long free;
 	unsigned long align;
diff --git a/mm/compaction.c b/mm/compaction.c
index ac4ead029b4a..2faf769375c4 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -857,6 +857,13 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		nr_scanned++;
 
 		page = pfn_to_page(low_pfn);
+		/*
+		 * Vmemmap pages do not need to be isolated.
+		 */
+		if (PageVmemmap(page)) {
+			low_pfn += vmemmap_nr_pages(page) - 1;
+			continue;
+		}
 
 		/*
 		 * Check if the pageblock has already been marked skipped.
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c2338703ce80..09d41339cd11 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -278,6 +278,13 @@ static int check_pfn_span(unsigned long pfn, unsigned long nr_pages,
 	return 0;
 }
 
+static void mhp_init_altmap(unsigned long pfn, unsigned long nr_pages,
+			    struct vmem_altmap *altmap)
+{
+	altmap->free = nr_pages;
+	altmap->base_pfn = pfn;
+}
+
 /*
  * Reasonably generic function for adding memory.  It is
  * expected that archs that support memory hotplug will
@@ -289,8 +296,18 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 {
 	int err;
 	unsigned long nr, start_sec, end_sec;
-	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap *altmap;
+	struct vmem_altmap mhp_altmap = {};
+	unsigned long mhp_flags = restrictions->flags;
+	bool vmemmap_section = false;
+
+	if (mhp_flags) {
+		mhp_init_altmap(pfn, nr_pages, &mhp_altmap);
+		restrictions->altmap = &mhp_altmap;
+		vmemmap_section = true;
+	}
 
+	altmap = restrictions->altmap;
 	if (altmap) {
 		/*
 		 * Validate altmap is within bounds of the total request
@@ -314,7 +331,7 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 
 		pfns = min(nr_pages, PAGES_PER_SECTION
 				- (pfn & ~PAGE_SECTION_MASK));
-		err = sparse_add_section(nid, pfn, pfns, altmap, 0);
+		err = sparse_add_section(nid, pfn, pfns, altmap, vmemmap_section);
 		if (err)
 			break;
 		pfn += pfns;
@@ -322,6 +339,10 @@ int __ref __add_pages(int nid, unsigned long pfn, unsigned long nr_pages,
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
+
+	if (mhp_flags)
+		mhp_mark_vmemmap_pages(altmap);
+
 	return err;
 }
 
@@ -640,6 +661,14 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	while (start < end) {
 		order = min(MAX_ORDER - 1,
 			get_order(PFN_PHYS(end) - PFN_PHYS(start)));
+		/*
+		 * Check if the pfn is aligned to its order.
+		 * If not, we decrement the order until it is,
+		 * otherwise __free_one_page will bug us.
+		 */
+		while (start & ((1 << order) - 1))
+			order--;
+
 		(*online_page_callback)(pfn_to_page(start), order);
 
 		onlined_pages += (1UL << order);
@@ -648,17 +677,51 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
 	return onlined_pages;
 }
 
+static bool vmemmap_skip_block(unsigned long pfn, unsigned long nr_pages,
+		       unsigned long *nr_vmemmap_pages)
+{
+	bool skip = false;
+	unsigned long vmemmap_pages = 0;
+
+	/*
+	 * This function gets called from {online,offline}_pages.
+	 * It has two goals:
+	 *
+	 * 1) Account number of vmemmap pages within the range
+	 * 2) Check if the whole range contains only vmemmap_pages.
+	 */
+
+	if (PageVmemmap(pfn_to_page(pfn))) {
+		struct page *page = pfn_to_page(pfn);
+
+		vmemmap_pages = min(vmemmap_nr_pages(page), nr_pages);
+		if (vmemmap_pages == nr_pages)
+			skip = true;
+	}
+
+	*nr_vmemmap_pages = vmemmap_pages;
+	return skip;
+}
+
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
 	unsigned long onlined_pages = *(unsigned long *)arg;
-
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
-
+	unsigned long pfn = start_pfn;
+	unsigned long nr_vmemmap_pages = 0;
+	bool skip;
+
+	skip = vmemmap_skip_block(pfn, nr_pages, &nr_vmemmap_pages);
+	if (skip)
+		goto skip_online_pages;
+
+	pfn += nr_vmemmap_pages;
+	if (PageReserved(pfn_to_page(pfn)))
+		onlined_pages += online_pages_blocks(pfn, nr_pages - nr_vmemmap_pages);
+skip_online_pages:
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-	*(unsigned long *)arg = onlined_pages;
+	*(unsigned long *)arg = onlined_pages + nr_vmemmap_pages;
 	return 0;
 }
 
@@ -1040,6 +1103,19 @@ static int online_memory_block(struct memory_block *mem, void *arg)
 	return device_online(&mem->dev);
 }
 
+static unsigned long mhp_check_flags(unsigned long flags)
+{
+	if (!flags)
+		return 0;
+
+	if (flags != MHP_MEMMAP_ON_MEMORY) {
+		WARN(1, "Wrong flags value (%lx). Ignoring flags.\n", flags);
+		return 0;
+	}
+
+	return flags;
+}
+
 /*
  * NOTE: The caller must call lock_device_hotplug() to serialize hotplug
  * and online/offline operations (triggered e.g. by sysfs).
@@ -1075,6 +1151,8 @@ int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags
 		goto error;
 	new_node = ret;
 
+	restrictions.flags = mhp_check_flags(flags);
+
 	/* call arch's memory hotadd */
 	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
@@ -1502,12 +1580,14 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages;
 	unsigned long offlined_pages = 0;
+	unsigned long nr_vmemmap_pages = 0;
 	int ret, node, nr_isolate_pageblock;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
 	char *reason;
+	bool skip = false;
 
 	mem_hotplug_begin();
 
@@ -1524,8 +1604,10 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
+	skip = vmemmap_skip_block(start_pfn, nr_pages, &nr_vmemmap_pages);
+
 	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn,
+	ret = start_isolate_page_range(start_pfn + nr_vmemmap_pages, end_pfn,
 				       MIGRATE_MOVABLE,
 				       SKIP_HWPOISON | REPORT_FAILURE);
 	if (ret < 0) {
@@ -1545,6 +1627,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal_isolated;
 	}
 
+	if (skip)
+		goto skip_migration;
+
 	do {
 		for (pfn = start_pfn; pfn;) {
 			if (signal_pending(current)) {
@@ -1581,6 +1666,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 					    NULL, check_pages_isolated_cb);
 	} while (ret);
 
+skip_migration:
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	walk_system_ram_range(start_pfn, end_pfn - start_pfn,
@@ -1596,7 +1682,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	spin_unlock_irqrestore(&zone->lock, flags);
 
 	/* removal success */
-	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
+	if (offlined_pages)
+		adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
+	offlined_pages += nr_vmemmap_pages;
 	zone->present_pages -= offlined_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
@@ -1739,11 +1827,41 @@ static void __release_memory_resource(resource_size_t start,
 	}
 }
 
+static int check_hotplug_granularity(u64 start, u64 size)
+{
+	unsigned long pfn = PHYS_PFN(start);
+
+	/*
+	 * Sanity check in case the range used MHP_MEMMAP_ON_MEMORY.
+	 */
+	if (vmemmap_section(__pfn_to_section(pfn))) {
+		struct page *page = pfn_to_page(pfn);
+		unsigned long nr_pages = size >> PAGE_SHIFT;
+		unsigned long sections;
+
+		/*
+		 * The start of the memory range is not correct.
+		 */
+		if (!PageVmemmap(page) || (vmemmap_head(page) != page))
+			return -EINVAL;
+
+		sections = vmemmap_nr_sections(page);
+		if (sections * PAGES_PER_SECTION != nr_pages)
+			/*
+			 * Check that granularity is the same.
+			 */
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int __ref try_remove_memory(int nid, u64 start, u64 size)
 {
 	int rc = 0;
 
 	BUG_ON(check_hotplug_memory_range(start, size));
+	BUG_ON(check_hotplug_granularity(start, size));
 
 	mem_hotplug_begin();
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d3bb601c461b..7c7d7130b627 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1340,14 +1340,21 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
+	if (PageVmemmap(page))
+		/*
+		 * Vmemmap pages need to preserve their state.
+		 */
+		goto preserve_state;
+
 	mm_zero_struct_page(page);
-	set_page_links(page, zone, nid, pfn);
-	init_page_count(page);
 	page_mapcount_reset(page);
+	INIT_LIST_HEAD(&page->lru);
+preserve_state:
+	init_page_count(page);
+	set_page_links(page, zone, nid, pfn);
 	page_cpupid_reset_last(page);
 	page_kasan_tag_reset(page);
 
-	INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
 	/* The shift won't overflow because ZONE_NORMAL is below 4G. */
 	if (!is_highmem_idx(zone))
@@ -8184,6 +8191,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		/*
+		 * Vmemmap pages are not needed to be moved around.
+		 */
+		if (PageVmemmap(page)) {
+			iter += vmemmap_nr_pages(page) - 1;
+			continue;
+		}
+
 		if (PageReserved(page))
 			goto unmovable;
 
@@ -8551,6 +8566,11 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+
+		if (PageVmemmap(page)) {
+			pfn += vmemmap_nr_pages(page);
+			continue;
+		}
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 89c19c0feadb..ee26ea41c9eb 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -146,7 +146,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 static inline struct page *
 __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 {
-	int i;
+	unsigned long i;
 
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page;
@@ -154,6 +154,10 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 		page = pfn_to_online_page(pfn + i);
 		if (!page)
 			continue;
+		if (PageVmemmap(page)) {
+			i += vmemmap_nr_pages(page) - 1;
+			continue;
+		}
 		return page;
 	}
 	return NULL;
@@ -267,6 +271,14 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		/*
+		 * Vmemmap pages are not isolated. Skip them.
+		 */
+		if (PageVmemmap(page)) {
+			pfn += vmemmap_nr_pages(page);
+			continue;
+		}
+
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
diff --git a/mm/sparse.c b/mm/sparse.c
index 09cac39e39d9..2cc2e5af1986 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -645,18 +645,125 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+static void vmemmap_init_page(struct page *page, struct page *head)
+{
+	page_mapcount_reset(page);
+	SetPageVmemmap(page);
+	page->vmemmap_head = (unsigned long)head;
+}
+
+static void vmemmap_init_head(struct page *page, unsigned long nr_sections,
+			      unsigned long nr_pages)
+{
+	page->vmemmap_sections = nr_sections;
+	page->vmemmap_pages = nr_pages;
+}
+
+void mhp_mark_vmemmap_pages(struct vmem_altmap *self)
+{
+	unsigned long pfn = self->base_pfn + self->reserve;
+	unsigned long nr_pages = self->alloc;
+	unsigned long nr_sects = self->free / PAGES_PER_SECTION;
+	unsigned long i;
+	struct page *head;
+
+	if (!nr_pages)
+		return;
+
+	/*
+	 * All allocations for the memory hotplug are the same sized so align
+	 * should be 0.
+	 */
+	WARN_ON(self->align);
+
+	memset(pfn_to_page(pfn), 0, sizeof(struct page) * nr_pages);
+
+	/*
+	 * Mark pages as Vmemmap pages
+	 * Layout:
+	 * Head:
+	 * 	head->vmemmap_pages	: nr of vmemmap pages
+	 *	head->mhp_flags    	: MHP_flags
+	 *	head->vmemmap_sections	: nr of sections used by this altmap
+	 * Tail:
+	 *	tail->vmemmap_head	: head
+	 * All:
+	 *	page->type		: Vmemmap
+	 */
+	head = pfn_to_page(pfn);
+	for (i = 0; i < nr_pages; i++) {
+		struct page *page = head + i;
+
+		vmemmap_init_page(page, head);
+	}
+	vmemmap_init_head(head, nr_sects, nr_pages);
+}
+
+/*
+ * If the range we are trying to remove was hot-added with vmemmap pages
+ * using MHP_MEMMAP_*, we need to keep track of it to know how much
+ * do we have do defer the free up.
+ * Since sections are removed sequentally in __remove_pages()->
+ * __remove_section(), we just wait until we hit the last section.
+ * Once that happens, we can trigger free_deferred_vmemmap_range to actually
+ * free the whole memory-range.
+ */
+static struct page *__vmemmap_head = NULL;
+
 static struct page *populate_section_memmap(unsigned long pfn,
 		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
 	return __populate_section_memmap(pfn, nr_pages, nid, altmap);
 }
 
+static void vmemmap_free_deferred_range(unsigned long start,
+					unsigned long end)
+{
+	unsigned long nr_pages = end - start;
+	unsigned long first_section;
+
+	first_section = (unsigned long)__vmemmap_head;
+	while (start >= first_section) {
+		vmemmap_free(start, end, NULL);
+		end = start;
+		start -= nr_pages;
+	}
+	__vmemmap_head = NULL;
+}
+
+static inline bool vmemmap_dec_and_test(void)
+{
+	__vmemmap_head->vmemmap_sections--;
+	return !__vmemmap_head->vmemmap_sections;
+}
+
+static void vmemmap_defer_free(unsigned long start, unsigned long end)
+{
+	if (vmemmap_dec_and_test())
+		vmemmap_free_deferred_range(start, end);
+}
+
+static inline bool should_defer_freeing(unsigned long start)
+{
+	if (PageVmemmap((struct page *)start) || __vmemmap_head) {
+		if (!__vmemmap_head)
+			__vmemmap_head = (struct page *)start;
+		return true;
+	}
+	return false;
+}
+
 static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
 		struct vmem_altmap *altmap)
 {
 	unsigned long start = (unsigned long) pfn_to_page(pfn);
 	unsigned long end = start + nr_pages * sizeof(struct page);
 
+	if (should_defer_freeing(start)) {
+		vmemmap_defer_free(start, end);
+		return;
+	}
+
 	vmemmap_free(start, end, altmap);
 }
 static void free_map_bootmem(struct page *memmap)
-- 
2.12.3

