Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B22C3C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60F9D20645
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 13:44:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60F9D20645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6E166B0007; Thu, 28 Mar 2019 09:44:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1E5A6B0008; Thu, 28 Mar 2019 09:44:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBE426B000A; Thu, 28 Mar 2019 09:44:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 711516B0007
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 09:44:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z98so8178629ede.3
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 06:44:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=dakEYHYgkKR75qewIBTuxounAHVO6QqvHJt24fDIZmE=;
        b=K9jGcFSrBj84vSoL1p0QNHIkzZYVCl3+5r6VXACfGD+O/jnCfqOfB+NVENSEFYOaR+
         reuJIhFpFekBkExDPPQtu6Fd2kYeceRA0Ta3OtX5PVe5H48Me9AKsOCv6nwFWbMA1f+x
         KmG/cGpOq7idDmEt+hIwmfNewWKBqqM3tvxqi36eeOkBpjRjAt7IvubB512KLMJqRLfz
         ut9SYI6c+neV+Uo+o1un9+DNd81A7Y+pr/LD+F9Nc42xlJtWSoX7wf8dO3rAEldvpXkA
         ys6E9njyjLZknAnvf5KZQIwPDkRGaJ7cMlXhX3E3x2tqqXB/yfDETeKNktjp6nBU/9WA
         +oTQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWjZXA2vyXsvEAU9BSuJgkM9pYy1CzlIG41/RVZPmlI+QZ7ZzPp
	IRKbfqzsVxDFChqr76Qe8wekL3njyzbgsWZHgkxwkevXhIcBoXDa3ScqmNXmaQtKMIcvsN8dgtB
	mJcON3VjEZz8ENapbhiP7YiZuzsPQrYRKh88BNShWG6YoZnC0Bvi1fGwNY2HqFvYnaQ==
X-Received: by 2002:a17:906:a12:: with SMTP id w18mr24347926ejf.70.1553780644906;
        Thu, 28 Mar 2019 06:44:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzht6xCrSZDA5ZkzQDj70Jsgk1CXV+8YyS55HjSl0Fg5eLWaQGdxKtrJLUYwG+BLh9SmGFn
X-Received: by 2002:a17:906:a12:: with SMTP id w18mr24347867ejf.70.1553780643594;
        Thu, 28 Mar 2019 06:44:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553780643; cv=none;
        d=google.com; s=arc-20160816;
        b=yIgRPo8TRCYCX9zPZR/7+tkSayFcnn78wbsN9gqcKbMrZx02NKjqKtBw9hW5eVAuJ7
         vM8YFbLkOmyAz/TBViKDmqP4FGwrDiLnPxmFHLEvaCV258dVtuu7R4ADLI8NZsNvPPqQ
         DrpN/vntn7p/WQUyxzAusMi3G1XEd+mJwX6TG5ffgbhqoYNLiXR38Sxcn3f02BC2zcvD
         ju3w/yspmFQR248CmWdYGHhvF+9JbHeUHva9uj33+AZL+6ac1G4W03jKI9+BRQ+bYI75
         Hh2WvVmuyNDg6OMrJCc30eJTV9QoG5r9wUbjmUDX8bsUfS+FUkqBDhH93Ghb0Co7TRsD
         HcyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=dakEYHYgkKR75qewIBTuxounAHVO6QqvHJt24fDIZmE=;
        b=DxHjBB9jez6yfl5D0Yzlg3ZoRIyJv5X9OzdRRnu8tS5hXd0a22skNnRX+gI3ngp4Vf
         zWQa0oDWiqDBXRHX8DdnNnjE5MlOlK8PQI8CQWfHrTTIRLgUavX7C6eveNG+XRRhZqqH
         j6+aRGZ2isVMpqQXEOYcAe4XwJ9FJmhT/Xrc/GDt+rjeFt6ZfPVCGLMtwJi05+egPnKf
         Jw7Bkz30cqofR0BRmvPrQL+E2m3If72IiW9u3PlsmtPh0Va+AK0Z1drGuAbCrTSliE2h
         ujE/Rcqh/14X9dB9h3Wj7JearZhXhNjqOHmSbxc2YtoUpsCejvfsH6JPmDMMRSXYrN2E
         eWZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id h4si1672614edb.13.2019.03.28.06.44.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 06:44:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 28 Mar 2019 14:44:02 +0100
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
Subject: [PATCH 2/4] mm, memory_hotplug: provide a more generic restrictions for memory hotplug
Date: Thu, 28 Mar 2019 14:43:18 +0100
Message-Id: <20190328134320.13232-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190328134320.13232-1-osalvador@suse.de>
References: <20190328134320.13232-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Michal Hocko <mhocko@suse.com>

arch_add_memory, __add_pages take a want_memblock which controls whether
the newly added memory should get the sysfs memblock user API (e.g.
ZONE_DEVICE users do not want/need this interface). Some callers even
want to control where do we allocate the memmap from by configuring
altmap.

Add a more generic hotplug context for arch_add_memory and __add_pages.
struct mhp_restrictions contains flags which contains additional
features to be enabled by the memory hotplug (MHP_MEMBLOCK_API
currently) and altmap for alternative memmap allocator.

Please note that the complete altmap propagation down to vmemmap code
is still not done in this patch. It will be done in the follow up to
reduce the churn here.

This patch shouldn't introduce any functional change.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c            |  5 ++---
 arch/ia64/mm/init.c            |  5 ++---
 arch/powerpc/mm/mem.c          |  6 +++---
 arch/s390/mm/init.c            |  6 +++---
 arch/sh/mm/init.c              |  6 +++---
 arch/x86/mm/init_32.c          |  6 +++---
 arch/x86/mm/init_64.c          | 10 +++++-----
 include/linux/memory_hotplug.h | 29 +++++++++++++++++++++++------
 kernel/memremap.c              |  9 ++++++---
 mm/memory_hotplug.c            | 10 ++++++----
 10 files changed, 56 insertions(+), 36 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e97f018ff740..8c0d5484b38c 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1046,8 +1046,7 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		    bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct mhp_restrictions *restrictions)
 {
 	int flags = 0;
 
@@ -1058,6 +1057,6 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
 
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
-			   altmap, want_memblock);
+							restrictions);
 }
 #endif
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index e49200e31750..7af16f5d5ca6 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -666,14 +666,13 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size, struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	if (ret)
 		printk("%s: Problem encountered in __add_pages() as ret=%d\n",
 		       __func__,  ret);
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index f6787f90e158..76bcc29fa3e1 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -109,8 +109,8 @@ int __weak remove_section_mapping(unsigned long start, unsigned long end)
 	return -ENODEV;
 }
 
-int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int __meminit arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -127,7 +127,7 @@ int __meminit arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *
 	}
 	flush_inval_dcache_range(start, start + size);
 
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 3e82f66d5c61..9ae71a82e9e1 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -224,8 +224,8 @@ device_initcall(s390_cma_mem_init);
 
 #endif /* CONFIG_CMA */
 
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -235,7 +235,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, restrictions);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 70621324db41..32798bd4c32f 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -416,15 +416,15 @@ void free_initrd_mem(unsigned long start, unsigned long end)
 #endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
 	/* We only have ZONE_NORMAL, so this is easy.. */
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	if (unlikely(ret))
 		printk("%s: Failed, __add_pages() == %d\n", __func__, ret);
 
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 85c94f9a87f8..755dbed85531 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -850,13 +850,13 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 
 #ifdef CONFIG_MEMORY_HOTREMOVE
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index bccff68e3267..db42c11b48fb 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -777,11 +777,11 @@ static void update_end_of_memory_vars(u64 start, u64 size)
 }
 
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock)
+				struct mhp_restrictions *restrictions)
 {
 	int ret;
 
-	ret = __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	ret = __add_pages(nid, start_pfn, nr_pages, restrictions);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
@@ -791,15 +791,15 @@ int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
 	return ret;
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
 	init_memory_mapping(start, start + size);
 
-	return add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 
 #define PAGE_INUSE 0xFD
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index 42ba7199f701..119a012d43b8 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -117,20 +117,37 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+/*
+ * Do we want sysfs memblock files created. This will allow userspace to online
+ * and offline memory explicitly. Lack of this bit means that the caller has to
+ * call move_pfn_range_to_zone to finish the initialization.
+ */
+
+#define MHP_MEMBLOCK_API               1<<0
+
+/*
+ * Restrictions for the memory hotplug:
+ * flags:  MHP_ flags
+ * altmap: alternative allocator for memmap array
+ */
+struct mhp_restrictions {
+	unsigned long flags;
+	struct vmem_altmap *altmap;
+};
+
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+					struct mhp_restrictions *restrictions);
 
 #ifndef CONFIG_ARCH_HAS_ADD_PAGES
 static inline int add_pages(int nid, unsigned long start_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		unsigned long nr_pages, struct mhp_restrictions *restrictions)
 {
-	return __add_pages(nid, start_pfn, nr_pages, altmap, want_memblock);
+	return __add_pages(nid, start_pfn, nr_pages, restrictions);
 }
 #else /* ARCH_HAS_ADD_PAGES */
 int add_pages(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		struct vmem_altmap *altmap, bool want_memblock);
+				struct mhp_restrictions *restrictions);
 #endif /* ARCH_HAS_ADD_PAGES */
 
 #ifdef CONFIG_NUMA
@@ -332,7 +349,7 @@ extern int __add_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
 extern int arch_add_memory(int nid, u64 start, u64 size,
-		struct vmem_altmap *altmap, bool want_memblock);
+			struct mhp_restrictions *restrictions);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..d42f11673979 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -149,6 +149,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	struct resource *res = &pgmap->res;
 	struct dev_pagemap *conflict_pgmap;
 	pgprot_t pgprot = PAGE_KERNEL;
+	struct mhp_restrictions restrictions = {};
 	int error, nid, is_ram;
 
 	if (!pgmap->ref || !pgmap->kill)
@@ -199,6 +200,9 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	if (error)
 		goto err_pfn_remap;
 
+	/* We do not want any optional features only our own memmap */
+	restrictions.altmap = altmap;
+
 	mem_hotplug_begin();
 
 	/*
@@ -214,7 +218,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	 */
 	if (pgmap->type == MEMORY_DEVICE_PRIVATE) {
 		error = add_pages(nid, align_start >> PAGE_SHIFT,
-				align_size >> PAGE_SHIFT, NULL, false);
+				align_size >> PAGE_SHIFT, &restrictions);
 	} else {
 		error = kasan_add_zero_shadow(__va(align_start), align_size);
 		if (error) {
@@ -222,8 +226,7 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 			goto err_kasan;
 		}
 
-		error = arch_add_memory(nid, align_start, align_size, altmap,
-				false);
+		error = arch_add_memory(nid, align_start, align_size, &restrictions);
 	}
 
 	if (!error) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 5139b3bfd8b0..836cb026ed7b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -273,12 +273,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
  * add the new pages.
  */
 int __ref __add_pages(int nid, unsigned long phys_start_pfn,
-		unsigned long nr_pages, struct vmem_altmap *altmap,
-		bool want_memblock)
+		unsigned long nr_pages, struct mhp_restrictions *restrictions)
 {
 	unsigned long i;
 	int err = 0;
 	int start_sec, end_sec;
+	struct vmem_altmap *altmap = restrictions->altmap;
 
 	/* during initialize mem_map, align hot-added range to section */
 	start_sec = pfn_to_section_nr(phys_start_pfn);
@@ -299,7 +299,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				want_memblock);
+				restrictions->flags & MHP_MEMBLOCK_API);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1099,6 +1099,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	u64 start, size;
 	bool new_node = false;
 	int ret;
+	struct mhp_restrictions restrictions = {};
 
 	start = res->start;
 	size = resource_size(res);
@@ -1123,7 +1124,8 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	new_node = ret;
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, NULL, true);
+	restrictions.flags = MHP_MEMBLOCK_API;
+	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
 		goto error;
 
-- 
2.13.7

