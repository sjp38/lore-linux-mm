Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B3AB6C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 463B020823
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 463B020823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C70876B000A; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD31D6B000C; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A4F876B000D; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC086B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:44:08 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id h27so8082163eda.8
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:44:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ss+ZR6mD0hp+GaYNWPET5X3YtSVA9ogADcDBL+98yzQ=;
        b=X2ihnCDv/5+DPlq0wwSrUuZsUtsfb8zvm6nSPgMiJ2Z/q9ggzflzFTHQvnVvodOWYC
         24Rxw7WVueQMSmyFmHdK/GPaPM9L45A5m6VR+TcUBhqtg41BWPaDE3klgy2UgDucr/AV
         /L/RW5vxL6ps/GOSwpUBwIVM/9wxrSEJgqIhWxW1ARLyijIOZjihIgA3NY76btGCqc6f
         DH8ffL43ONITB0uI54s2LJ/aMqafDZcBvPFouBadtagn6zy60/8hoG168JNkmYRsobGl
         dmJZWWSo29dN44TmArLIkVDz45YVs9ApEqx6KmvyLqrO+hLd/IB7B/OKZFj9v3SmuVbQ
         vcZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWay4fHGA8wZwCoXWGXEIXqvTWPvMvo/0vSUEohMJl0uVK0gNMP
	pnDWchP9JyGDYUgdDwM7xUqmWwnuMIfsm6tCpskpdFh06TGLRM8fKcRB3CXbbEj0sXCwJYLWcK0
	M12smZ/BE9fe4D6Df6WZVBVXJzVNK0DtvR+bRhEKi2KIplxPG4RL48qRMyVumJ8p9Cg==
X-Received: by 2002:a17:906:892:: with SMTP id n18mr24510170eje.136.1553780647550;
        Thu, 28 Mar 2019 06:44:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwM2lYsb9jO30EwdZdlw47P14M3QzhlemAvUdOKGNvLT60Yh4KG45ra3Q464FlM3I8PO6FX
X-Received: by 2002:a17:906:892:: with SMTP id n18mr24510050eje.136.1553780645034;
        Thu, 28 Mar 2019 06:44:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780645; cv=none;
        d=google.com; s=arc-20160816;
        b=usCkShrpnv0TetSfls/nIrvOphGUKdVxqQDQcis+e5rqIKetO0TPxbKvOnoS5GZZHP
         TaCn+qPd1rZZE5H/C+rQDNPYCfWCjUMw0owaymFaHFLhVKCnODZ8SxqTt+OTcTHKmuER
         eDatEyMlOufNTnseNU3/j42beobfl/2OsWtCDkY6qQ+jt+29sMM2unYFfU80YoE9qIAz
         YxZqW5iICNurwqHTAgtevjSTz+IUeE8lSJguKy2wKvSu7fShbyG4IGvX45FnZnmZ50oe
         5R1LlAHNs49HLlMOh/CFcMILXXRDPGRWlJPbxaedPEqFJKDfNU7pzyE6xXzkub38vR0w
         O/+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ss+ZR6mD0hp+GaYNWPET5X3YtSVA9ogADcDBL+98yzQ=;
        b=OiSlZpB5OYq9DlgUnXnk3x9qo6dKu5SLdHhE/LrWyee1gA3Qt6fM86oA6VmTfM+J+l
         6UHlKpA7+63km2XDSYemoD2ULBz774iPa0h622Iw21NEoBtpfmSAqzq3PmBXh/nMIdYr
         YJUJfxPE+7TTNIohO03Ruod4h35lx7Q890J0v+MHUFnaKAT27e5JKGwCTyeIZQbCKe+x
         8X1cm4+E/+lKY1hdVs5jVHPU9VB4ZejVPFnVgUs4U58tOLSs5+x4Z5fMjLSvK3VCAdym
         5NAJGjXTM6/IlndZtRdC2fqM2+o8C6/qLs1FIjxWryHJtGvZn/mC2V6wRSpj/P4PqtcY
         3m2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g18si3222405edc.193.2019.03.28.06.44.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:44:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 28 Mar 2019 14:44:04 +0100
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 28 Mar 2019 13:43:31 +0000
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	Jonathan.Cameron@huawei.com,
	anshuman.khandual@arm.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 3/4] mm, memory_hotplug: allocate memmap from the added memory range for sparse-vmemmap
Date: Thu, 28 Mar 2019 14:43:19 +0100
Message-Id: <20190328134320.13232-4-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
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
the memory consumed during physical hotadd consumes enough memory to push
system to OOM. 31bc3858ea3e ("memory-hotplug: add automatic onlining
policy for the newly added memory") has been added to workaround that
problem.

I have also seen hot-add operations failing on powerpc due to the fact
that we try to use order-8 pages. If the base page size is 64KB, this
gives us 16MB, and if we run out of those, we simply fail.
One could arge that we can fall back to basepages as we do in x86_64.

But we can do much better when CONFIG_SPARSEMEM_VMEMMAP=y because vmemap
page tables can map arbitrary memory. That means that we can simply
use the beginning of each memory section and map struct pages there.
struct pages which back the allocated space then just need to be treated
carefully.

Add {_Set,_Clear}PageVmemmap helpers to distinguish those pages in pfn
walkers. We do not have any spare page flag for this purpose so use the
combination of PageReserved bit which already tells that the page should
be ignored by the core mm code and store VMEMMAP_PAGE (which sets all
bits but PAGE_MAPPING_FLAGS) into page->mapping.

There is one case where we cannot check for PageReserved, and that is
when we have poisoning enabled + VM_BUG_ON_PGFLAGS is on + the page
is not initialized.
This happens in __init_single_page, where we do have to preserve the
state of PageVmemmap pages, so we cannot zero the page.
I added __PageVmemmap for that purpose, as it only checks for the
page->mapping field.
It should be enough as these pages are not yet onlined.

On the memory hotplug front add a new MHP_MEMMAP_FROM_RANGE restriction
flag. User is supposed to set the flag if the memmap should be allocated
from the hotadded range.
Right now, this is passed to add_memory(), __add_memory() and
add_memory_resource().
Unfortunately we do not have a single entry point, as Hyper-V, Acpi, Xen
 use those three functions, so all those users have to
specifiy if they want the memmap array allocated from the hot-added range.
For the time being, only ACPI enabled it.

Implementation wise we reuse vmem_altmap infrastructure to override
the default allocator used by __vmemap_populate. Once the memmap is
allocated we need a way to mark altmap pfns used for the allocation.
If MHP_MEMMAP_FROM_RANGE was passed, we set up the layout of the altmap
structure at the beginning of __add_pages(), and then we call
mark_vmemmap_pages() after the memory has been added.
mark_vmemmap_pages marks the pages as vmemmap and sets some metadata:

The current layout of the Vmemmap pages are:

- There is a head Vmemmap (first page), which has the following fields set:
  * page->_refcount: number of sections that used this altmap
  * page->private: total number of vmemmap pages
- The remaining vmemmap pages have:
  * page->freelist: pointer to the head vmemmap page

This is done to easy the computation we need in some places.

E.g:
Let us say we hot-add 9GB on x86_64:

head->_refcount = 72 sections
head->private = 36864 vmemmap pages
tail's->freelist = head

We keep a _refcount of the used sections to know how much do we have to defer
the call to vmemmap_free().
The thing is that the first pages of the hot-added range are used to create
the memmap mapping, so we cannot remove those first, otherwise we would blow up.

What we do is that since when we hot-remove a memory-range, sections are being
removed sequentially, we wait until we hit the last section, and then we free
the hole range to vmemmap_free backwards.
We know that it is the last section because in every pass we
decrease head->_refcount, and when it reaches 0, we got our last section.

We also have to be careful about those pages during online and offline
operations. They are simply skipped, so online will keep them
reserved and so unusable for any other purpose and offline ignores them
so they do not block the offline operation.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c                             |   5 +-
 arch/powerpc/mm/init_64.c                       |   7 ++
 arch/powerpc/platforms/powernv/memtrace.c       |   2 +-
 arch/powerpc/platforms/pseries/hotplug-memory.c |   2 +-
 arch/s390/mm/init.c                             |   6 ++
 arch/x86/mm/init_64.c                           |  10 +++
 drivers/acpi/acpi_memhotplug.c                  |   2 +-
 drivers/base/memory.c                           |   2 +-
 drivers/dax/kmem.c                              |   2 +-
 drivers/hv/hv_balloon.c                         |   2 +-
 drivers/s390/char/sclp_cmd.c                    |   2 +-
 drivers/xen/balloon.c                           |   2 +-
 include/linux/memory_hotplug.h                  |  22 ++++-
 include/linux/memremap.h                        |   2 +-
 include/linux/page-flags.h                      |  34 +++++++
 mm/compaction.c                                 |   6 ++
 mm/memory_hotplug.c                             | 115 ++++++++++++++++++++----
 mm/page_alloc.c                                 |  19 +++-
 mm/page_isolation.c                             |  11 +++
 mm/sparse.c                                     |  88 ++++++++++++++++++
 mm/util.c                                       |   2 +
 21 files changed, 309 insertions(+), 34 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 8c0d5484b38c..9607d4a3fc6b 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -746,7 +746,10 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 		if (pmd_none(READ_ONCE(*pmdp))) {
 			void *p = NULL;
 
-			p = vmemmap_alloc_block_buf(PMD_SIZE, node);
+			if (altmap)
+				p = altmap_alloc_block_buf(PMD_SIZE, altmap);
+			else
+				p = vmemmap_alloc_block_buf(PMD_SIZE, node);
 			if (!p)
 				return -ENOMEM;
 
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index a4c155af1597..94bf60c1b388 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -294,6 +294,13 @@ void __ref vmemmap_free(unsigned long start, unsigned long end,
 
 		if (base_pfn >= alt_start && base_pfn < alt_end) {
 			vmem_altmap_free(altmap, nr_pages);
+		} else if (PageVmemmap(page)) {
+			/*
+			 * runtime vmemmap pages are residing inside the memory
+			 * section so they do not have to be freed anywhere.
+			 */
+			while (PageVmemmap(page))
+				__ClearPageVmemmap(page++);
 		} else if (PageReserved(page)) {
 			/* allocated from bootmem */
 			if (page_size < PAGE_SIZE) {
diff --git a/arch/powerpc/platforms/powernv/memtrace.c b/arch/powerpc/platforms/powernv/memtrace.c
index 248a38ad25c7..6aa07ef19849 100644
--- a/arch/powerpc/platforms/powernv/memtrace.c
+++ b/arch/powerpc/platforms/powernv/memtrace.c
@@ -233,7 +233,7 @@ static int memtrace_online(void)
 			ent->mem = 0;
 		}
 
-		if (add_memory(ent->nid, ent->start, ent->size)) {
+		if (add_memory(ent->nid, ent->start, ent->size, true)) {
 			pr_err("Failed to add trace memory to node %d\n",
 				ent->nid);
 			ret += 1;
diff --git a/arch/powerpc/platforms/pseries/hotplug-memory.c b/arch/powerpc/platforms/pseries/hotplug-memory.c
index d291b618a559..ffe02414248d 100644
--- a/arch/powerpc/platforms/pseries/hotplug-memory.c
+++ b/arch/powerpc/platforms/pseries/hotplug-memory.c
@@ -670,7 +670,7 @@ static int dlpar_add_lmb(struct drmem_lmb *lmb)
 	nid = memory_add_physaddr_to_nid(lmb->base_addr);
 
 	/* Add the memory */
-	rc = __add_memory(nid, lmb->base_addr, block_sz);
+	rc = __add_memory(nid, lmb->base_addr, block_sz, true);
 	if (rc) {
 		invalidate_lmb_associativity_index(lmb);
 		return rc;
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 9ae71a82e9e1..75e96860a9ac 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -231,6 +231,12 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	unsigned long size_pages = PFN_DOWN(size);
 	int rc;
 
+	/*
+	 * Physical memory is added only later during the memory online so we
+	 * cannot use the added range at this stage unfortunately.
+	 */
+	restrictions->flags &= ~MHP_MEMMAP_FROM_RANGE;
+
 	rc = vmem_add_mapping(start, size);
 	if (rc)
 		return rc;
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index db42c11b48fb..2e40c9e637b9 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -809,6 +809,16 @@ static void __meminit free_pagetable(struct page *page, int order)
 	unsigned long magic;
 	unsigned int nr_pages = 1 << order;
 
+	/*
+	 * runtime vmemmap pages are residing inside the memory section so
+	 * they do not have to be freed anywhere.
+	 */
+	if (PageVmemmap(page)) {
+		while (nr_pages--)
+			__ClearPageVmemmap(page++);
+		return;
+	}
+
 	/* bootmem page has reserved flag */
 	if (PageReserved(page)) {
 		__ClearPageReserved(page);
diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index 8fe0960ea572..ff9d78def208 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -228,7 +228,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length);
+		result = __add_memory(node, info->start_addr, info->length, true);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index cb8347500ce2..28fd2a5cc0c9 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -510,7 +510,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+			   MIN_MEMORY_BLOCK_SIZE * sections_per_block, true);
 
 	if (ret)
 		goto out;
diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index a02318c6d28a..904371834390 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -65,7 +65,7 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->flags = IORESOURCE_SYSTEM_RAM;
 	new_res->name = dev_name(dev);
 
-	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
+	rc = add_memory(numa_node, new_res->start, resource_size(new_res), false);
 	if (rc)
 		return rc;
 
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index dd475f3bcc8a..c88f32964b5f 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -741,7 +741,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
-				(HA_CHUNK << PAGE_SHIFT));
+				(HA_CHUNK << PAGE_SHIFT), false);
 
 		if (ret) {
 			pr_err("hot_add memory failed error is %d\n", ret);
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index 37d42de06079..b021c96cb5c7 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -406,7 +406,7 @@ static void __init add_memory_merged(u16 rn)
 	if (!size)
 		goto skip_add;
 	for (addr = start; addr < start + size; addr += block_size)
-		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size, false);
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index d37dd5bb7a8f..59f25f3a91d0 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -352,7 +352,7 @@ static enum bp_state reserve_additional_memory(void)
 	mutex_unlock(&balloon_mutex);
 	/* add_memory_resource() requires the device_hotplug lock */
 	lock_device_hotplug();
-	rc = add_memory_resource(nid, resource);
+	rc = add_memory_resource(nid, resource, false);
 	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 119a012d43b8..c304c2f529da 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -126,6 +126,14 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 #define MHP_MEMBLOCK_API               1<<0
 
 /*
+ * Do we want memmap (struct page array) allocated from the hotadded range.
+ * Please note that only SPARSE_VMEMMAP implements this feature and some
+ * architectures might not support it even for that memory model (e.g. s390)
+ */
+
+#define MHP_MEMMAP_FROM_RANGE          1<<1
+
+/*
  * Restrictions for the memory hotplug:
  * flags:  MHP_ flags
  * altmap: alternative allocator for memmap array
@@ -345,9 +353,9 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
 extern void __ref free_area_init_core_hotplug(int nid);
 extern int walk_memory_range(unsigned long start_pfn, unsigned long end_pfn,
 		void *arg, int (*func)(struct memory_block *, void *));
-extern int __add_memory(int nid, u64 start, u64 size);
-extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource);
+extern int __add_memory(int nid, u64 start, u64 size, bool use_vmemmap);
+extern int add_memory(int nid, u64 start, u64 size, bool use_vmemmap);
+extern int add_memory_resource(int nid, struct resource *resource, bool use_vmemmap);
 extern int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
@@ -363,4 +371,12 @@ extern bool allow_online_pfn_range(int nid, unsigned long pfn, unsigned long nr_
 		int online_type);
 extern struct zone *zone_for_pfn_range(int online_type, int nid, unsigned start_pfn,
 		unsigned long nr_pages);
+
+#ifdef CONFIG_SPARSEMEM_VMEMMAP
+extern void mark_vmemmap_pages(struct vmem_altmap *self,
+				struct mhp_restrictions *r);
+#else
+static inline void mark_vmemmap_pages(struct vmem_altmap *self,
+					struct mhp_restrictions *r) {}
+#endif
 #endif /* __LINUX_MEMORY_HOTPLUG_H */
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f0628660d541..cfde1c1febb7 100644
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
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..6718f6f04676 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -466,6 +466,40 @@ static __always_inline int __PageMovable(struct page *page)
 				PAGE_MAPPING_MOVABLE;
 }
 
+#define VMEMMAP_PAGE ~PAGE_MAPPING_FLAGS
+static __always_inline int PageVmemmap(struct page *page)
+{
+	return PageReserved(page) && (unsigned long)page->mapping == VMEMMAP_PAGE;
+}
+
+static __always_inline int __PageVmemmap(struct page *page)
+{
+	return (unsigned long)page->mapping == VMEMMAP_PAGE;
+}
+
+static __always_inline void __ClearPageVmemmap(struct page *page)
+{
+	__ClearPageReserved(page);
+	page->mapping = NULL;
+}
+
+static __always_inline void __SetPageVmemmap(struct page *page)
+{
+	__SetPageReserved(page);
+	page->mapping = (void *)VMEMMAP_PAGE;
+}
+
+static __always_inline struct page *vmemmap_get_head(struct page *page)
+{
+	return (struct page *)page->freelist;
+}
+
+static __always_inline unsigned long get_nr_vmemmap_pages(struct page *page)
+{
+       struct page *head = vmemmap_get_head(page);
+       return head->private - (page - head);
+}
+
 #ifdef CONFIG_KSM
 /*
  * A KSM page is one of those write-protected "shared pages" or "merged pages"
diff --git a/mm/compaction.c b/mm/compaction.c
index f171a83707ce..926b1b424de8 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -850,6 +850,12 @@ isolate_migratepages_block(struct compact_control *cc, unsigned long low_pfn,
 		page = pfn_to_page(low_pfn);
 
 		/*
+		 * Vmemmap pages cannot be migrated.
+		 */
+		if (PageVmemmap(page))
+			goto isolate_fail;
+
+		/*
 		 * Check if the pageblock has already been marked skipped.
 		 * Only the aligned PFN is checked as the caller isolates
 		 * COMPACT_CLUSTER_MAX at a time so the second call must
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 836cb026ed7b..0eb60c80b8bc 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -96,6 +96,11 @@ void mem_hotplug_done(void)
 	cpus_read_unlock();
 }
 
+static inline bool can_use_vmemmap(void)
+{
+	return IS_ENABLED(CONFIG_SPARSEMEM_VMEMMAP);
+}
+
 u64 max_mem_size = U64_MAX;
 
 /* add this memory to iomem resource */
@@ -278,7 +283,16 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
-	struct vmem_altmap *altmap = restrictions->altmap;
+	struct vmem_altmap *altmap;
+	struct vmem_altmap __memblk_altmap = {};
+
+	if (restrictions->flags & MHP_MEMMAP_FROM_RANGE) {
+		__memblk_altmap.base_pfn = phys_start_pfn;
+		__memblk_altmap.free = nr_pages;
+		restrictions->altmap = &__memblk_altmap;
+	}
+
+	altmap = restrictions->altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
@@ -312,6 +326,10 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 		cond_resched();
 	}
 	vmemmap_populate_print_last();
+
+	if (restrictions->flags & MHP_MEMMAP_FROM_RANGE)
+		mark_vmemmap_pages(altmap, restrictions);
+
 out:
 	return err;
 }
@@ -677,6 +695,13 @@ static int online_pages_blocks(unsigned long start, unsigned long nr_pages)
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
 		(*online_page_callback)(pfn_to_page(start), order);
 
 		onlined_pages += (1UL << order);
@@ -689,13 +714,33 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
 	unsigned long onlined_pages = *(unsigned long *)arg;
+	unsigned long pfn = start_pfn;
+	unsigned long nr_vmemmap_pages = 0;
+	bool skip_online = false;
+
+	if (PageVmemmap(pfn_to_page(start_pfn))) {
+		/*
+		 * We do not want to send Vmemmap pages to the buddy allocator.
+		 * Skip them.
+		 */
+		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
+		nr_vmemmap_pages = min(nr_vmemmap_pages, nr_pages);
+		pfn += nr_vmemmap_pages;
+		if (nr_vmemmap_pages == nr_pages)
+			/*
+			 * If the entire memblock contains only vmemmap pages,
+			 * we do not have pages to free to the buddy allocator.
+			 */
+			skip_online = true;
+	}
 
-	if (PageReserved(pfn_to_page(start_pfn)))
-		onlined_pages += online_pages_blocks(start_pfn, nr_pages);
+	if (!skip_online && PageReserved(pfn_to_page(pfn)))
+		onlined_pages += online_pages_blocks(pfn,
+					nr_pages - nr_vmemmap_pages);
 
 	online_mem_sections(start_pfn, start_pfn + nr_pages);
 
-	*(unsigned long *)arg = onlined_pages;
+	*(unsigned long *)arg = onlined_pages + nr_vmemmap_pages;
 	return 0;
 }
 
@@ -1094,7 +1139,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  *
  * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
  */
-int __ref add_memory_resource(int nid, struct resource *res)
+int __ref add_memory_resource(int nid, struct resource *res, bool use_vmemmap)
 {
 	u64 start, size;
 	bool new_node = false;
@@ -1125,6 +1170,9 @@ int __ref add_memory_resource(int nid, struct resource *res)
 
 	/* call arch's memory hotadd */
 	restrictions.flags = MHP_MEMBLOCK_API;
+	if (can_use_vmemmap() && use_vmemmap)
+		restrictions.flags |= MHP_MEMMAP_FROM_RANGE;
+
 	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
 		goto error;
@@ -1166,7 +1214,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 }
 
 /* requires device_hotplug_lock, see add_memory_resource() */
-int __ref __add_memory(int nid, u64 start, u64 size)
+int __ref __add_memory(int nid, u64 start, u64 size, bool use_vmemmap)
 {
 	struct resource *res;
 	int ret;
@@ -1175,18 +1223,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res);
+	ret = add_memory_resource(nid, res, use_vmemmap);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
 }
 
-int add_memory(int nid, u64 start, u64 size)
+int add_memory(int nid, u64 start, u64 size, bool use_vmemmap)
 {
 	int rc;
 
 	lock_device_hotplug();
-	rc = __add_memory(nid, start, size);
+	rc = __add_memory(nid, start, size, use_vmemmap);
 	unlock_device_hotplug();
 
 	return rc;
@@ -1554,15 +1602,31 @@ static int __ref __offline_pages(unsigned long start_pfn,
 {
 	unsigned long pfn, nr_pages;
 	unsigned long offlined_pages = 0;
-	int ret, node, nr_isolate_pageblock;
+	int ret, node, nr_isolate_pageblock = 0;
 	unsigned long flags;
 	unsigned long valid_start, valid_end;
 	struct zone *zone;
 	struct memory_notify arg;
 	char *reason;
+	unsigned long nr_vmemmap_pages = 0;
+	bool skip_block = false;
 
 	mem_hotplug_begin();
 
+	if (PageVmemmap(pfn_to_page(start_pfn))) {
+		nr_vmemmap_pages = get_nr_vmemmap_pages(pfn_to_page(start_pfn));
+		if (start_pfn + nr_vmemmap_pages >= end_pfn) {
+			/*
+			 * Depending on how large was the hot-added range,
+			 * an entire memblock can only contain vmemmap pages.
+			 * Should be that the case, just skip isolation and
+			 * migration.
+			 */
+			nr_vmemmap_pages = end_pfn - start_pfn;
+			skip_block = true;
+		}
+	}
+
 	/* This makes hotplug much easier...and readable.
 	   we assume this for now. .*/
 	if (!test_pages_in_a_zone(start_pfn, end_pfn, &valid_start,
@@ -1576,15 +1640,17 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	node = zone_to_nid(zone);
 	nr_pages = end_pfn - start_pfn;
 
-	/* set above range as isolated */
-	ret = start_isolate_page_range(start_pfn, end_pfn,
-				       MIGRATE_MOVABLE,
-				       SKIP_HWPOISON | REPORT_FAILURE);
-	if (ret < 0) {
-		reason = "failure to isolate range";
-		goto failed_removal;
+	if (!skip_block) {
+		/* set above range as isolated */
+		ret = start_isolate_page_range(start_pfn, end_pfn,
+					       MIGRATE_MOVABLE,
+					       SKIP_HWPOISON | REPORT_FAILURE);
+		if (ret < 0) {
+			reason = "failure to isolate range";
+			goto failed_removal;
+		}
+		nr_isolate_pageblock = ret;
 	}
-	nr_isolate_pageblock = ret;
 
 	arg.start_pfn = start_pfn;
 	arg.nr_pages = nr_pages;
@@ -1597,6 +1663,9 @@ static int __ref __offline_pages(unsigned long start_pfn,
 		goto failed_removal_isolated;
 	}
 
+	if (skip_block)
+		goto no_migration;
+
 	do {
 		for (pfn = start_pfn; pfn;) {
 			if (signal_pending(current)) {
@@ -1633,6 +1702,7 @@ static int __ref __offline_pages(unsigned long start_pfn,
 							check_pages_isolated_cb);
 	} while (ret);
 
+no_migration:
 	/* Ok, all of our target is isolated.
 	   We cannot do rollback at this point. */
 	walk_system_ram_range(start_pfn, end_pfn - start_pfn, &offlined_pages,
@@ -1649,6 +1719,12 @@ static int __ref __offline_pages(unsigned long start_pfn,
 
 	/* removal success */
 	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
+
+	/*
+	 * Vmemmap pages are not being accounted to managed_pages but to
+	 * present_pages.
+	 */
+	offlined_pages += nr_vmemmap_pages;
 	zone->present_pages -= offlined_pages;
 
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
@@ -1677,7 +1753,8 @@ static int __ref __offline_pages(unsigned long start_pfn,
 	return 0;
 
 failed_removal_isolated:
-	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
+	if (!skip_block)
+		undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
 	memory_notify(MEM_CANCEL_OFFLINE, &arg);
 failed_removal:
 	pr_debug("memory offlining [mem %#010llx-%#010llx] failed due to %s\n",
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d128f53888b8..6c026690a0b2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1273,9 +1273,12 @@ static void free_one_page(struct zone *zone,
 static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 				unsigned long zone, int nid)
 {
-	mm_zero_struct_page(page);
+	if (!__PageVmemmap(page)) {
+		mm_zero_struct_page(page);
+		init_page_count(page);
+	}
+
 	set_page_links(page, zone, nid, pfn);
-	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
 	page_kasan_tag_reset(page);
@@ -8033,6 +8036,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 
 		page = pfn_to_page(check);
 
+		if (PageVmemmap(page)) {
+			/*
+			 * Vmemmap pages are marked reserved, so skip them here.
+			 */
+			iter += get_nr_vmemmap_pages(page) - 1;
+			continue;
+                }
+
 		if (PageReserved(page))
 			goto unmovable;
 
@@ -8401,6 +8412,10 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (PageVmemmap(page)) {
+			pfn += get_nr_vmemmap_pages(page);
+			continue;
+		}
 		/*
 		 * The HWPoisoned page may be not in buddy system, and
 		 * page_count() is not 0.
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 019280712e1b..0081ab74c1ba 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -156,6 +156,10 @@ __first_valid_page(unsigned long pfn, unsigned long nr_pages)
 		page = pfn_to_online_page(pfn + i);
 		if (!page)
 			continue;
+		if (PageVmemmap(page)) {
+			i += get_nr_vmemmap_pages(page) - 1;
+			continue;
+		}
 		return page;
 	}
 	return NULL;
@@ -270,6 +274,13 @@ __test_page_isolated_in_pageblock(unsigned long pfn, unsigned long end_pfn,
 			continue;
 		}
 		page = pfn_to_page(pfn);
+		if (PageVmemmap(page)) {
+			/*
+			 * Vmemmap pages are not isolated. Skip them.
+			 */
+			pfn += get_nr_vmemmap_pages(page);
+			continue;
+		}
 		if (PageBuddy(page))
 			/*
 			 * If the page is on a free list, it has to be on
diff --git a/mm/sparse.c b/mm/sparse.c
index 56e057c432f9..82c7b119eb1d 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -590,6 +590,89 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+void mark_vmemmap_pages(struct vmem_altmap *self, struct mhp_restrictions *r)
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
+	/*
+	 * Mark these pages as Vmemmap pages.
+	 * Layout:
+	 * [Head->refcount] : Nr sections used by this altmap
+	 * [Head->private]  : Nr of vmemmap pages
+	 * [Tail->freelist] : Pointer to the head page
+	 */
+
+	/*
+	 * Head, first vmemmap page
+	 */
+	head = pfn_to_page(pfn);
+	for (i = 0; i < nr_pages; i++, pfn++) {
+		struct page *page = pfn_to_page(pfn);
+
+		mm_zero_struct_page(page);
+		__SetPageVmemmap(page);
+		page->freelist = head;
+		init_page_count(page);
+	}
+	set_page_count(head, (int)nr_sects);
+	set_page_private(head, nr_pages);
+}
+
+/*
+ * If the range we are trying to remove was hot-added with vmemmap pages,
+ * we need to keep track of it to know how much do we have do defer the
+ * free up. Since sections are removed sequentally in __remove_pages()->
+ * __remove_section(), we just wait until we hit the last section.
+ * Once that happens, we can trigger free_deferred_vmemmap_range to actually
+ * free the whole memory-range.
+ */
+static struct page *head_vmemmap_page;
+static bool in_vmemmap_range;
+
+static inline bool vmemmap_dec_and_test(void)
+{
+	return page_ref_dec_and_test(head_vmemmap_page);
+}
+
+static void free_deferred_vmemmap_range(unsigned long start,
+					unsigned long end)
+{
+	unsigned long nr_pages = end - start;
+	unsigned long first_section = (unsigned long)head_vmemmap_page;
+
+	while (start >= first_section) {
+		vmemmap_free(start, end, NULL);
+		end = start;
+		start -= nr_pages;
+	}
+	head_vmemmap_page = NULL;
+	in_vmemmap_range = false;
+}
+
+static void deferred_vmemmap_free(unsigned long start, unsigned long end)
+{
+	if (!in_vmemmap_range) {
+		in_vmemmap_range = true;
+		head_vmemmap_page = (struct page *)start;
+	}
+
+	if (vmemmap_dec_and_test())
+		free_deferred_vmemmap_range(start, end);
+}
+
 static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
 		struct vmem_altmap *altmap)
 {
@@ -602,6 +685,11 @@ static void __kfree_section_memmap(struct page *memmap,
 	unsigned long start = (unsigned long)memmap;
 	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
 
+	if (PageVmemmap(memmap) || in_vmemmap_range) {
+		deferred_vmemmap_free(start, end);
+		return;
+	}
+
 	vmemmap_free(start, end, altmap);
 }
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/mm/util.c b/mm/util.c
index d559bde497a9..5521d0a6c9e3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -531,6 +531,8 @@ struct address_space *page_mapping(struct page *page)
 	mapping = page->mapping;
 	if ((unsigned long)mapping & PAGE_MAPPING_ANON)
 		return NULL;
+	if ((unsigned long)mapping == VMEMMAP_PAGE)
+		return NULL;
 
 	return (void *)((unsigned long)mapping & ~PAGE_MAPPING_FLAGS);
 }
-- 
2.13.7

