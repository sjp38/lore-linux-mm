Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E22FC10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1700421734
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:59:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1700421734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F3266B0006; Thu,  4 Apr 2019 08:59:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8546F6B0007; Thu,  4 Apr 2019 08:59:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 62CE86B0008; Thu,  4 Apr 2019 08:59:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1125F6B0006
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 08:59:42 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n24so1357953edd.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 05:59:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sEALbQJdLFXDpIrcz5vOD04lEWNB/c+oAZmm2+ZeLTI=;
        b=YvFOKbdaYUcMUHzrly8kV83Ba3UcHLOWbW9rQa3W1/g0stUE8NCv5hCBa86AWInjlG
         04vfQyh/cpc1T9K4sMkW8LPitdVosGVTtd6l0jYgeJj1URmB25ugknN1IbK+b/Ogmv3a
         I4r6mlZzaoBrh47vhiGYOJtE2ikcoeTzFSlXN3R5zSS6wLS07vQiItANJPAzenzgIi5M
         Tn8/4fWQSjKXfqMdUFQyl+WNK4RABigdtcg9wRlMnHwcN/prv6oIv7Hc3SXGkC8LAUO0
         8nwgop6P2nUWCRN8G9UGmrd3HihTzMdfkMcf1aDWpbuWm+rX0Dpoo2SEBH+Kyz+r6RK/
         xicw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAX01j8pqZXqopMoy4Da2wNsOYOSgZqTUWSzTth/3ltCQ4CKhmQc
	WXEK08HGv8jtYpBLgVe8YRovtUUQsOzCmq9B73LqeM/VJBv/vroEiftDNinHStEnUXv+tiJ1Ckz
	gyHMSYjDUQa7U2grY8izNt3tpa+7ikArH37k0NTn+75D35fUYIfZH6FVIjTiP1BOdig==
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr3591443ejb.64.1554382781589;
        Thu, 04 Apr 2019 05:59:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj7sC52pXo1go99alXrbN/3yoBuFN0MpekuKh3UFL2TFe5R/hnNGJKq3154yJ+h1vgYadp
X-Received: by 2002:a17:906:1347:: with SMTP id x7mr3591371ejb.64.1554382780228;
        Thu, 04 Apr 2019 05:59:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554382780; cv=none;
        d=google.com; s=arc-20160816;
        b=XEVwV8Jf/KQBlXogWxUbWoBDGseUvo593LGqPQE14K8h+Vet2nZS9w04QSdTiRU7rp
         IxJxM3ogAHTs+BSa7M7aNFr2oSYspPVvZWPObNJ8i6/F6EUfb9m9hIIXV5f0x5aDbJja
         qEi008wpXYZMrxCT/VreYb+HF2SXqF+DPFSauPBmX7frI7lt840ava8cGXbsv8T1gzyD
         17r/cO8QUnGoUUBH/ShlTI7+6xI7ZkI969H+wyRhobN6uq4rA0dYXOYqIKD1Ykv6uSGq
         wbqOLLxAHh8Dd67oTIhS7Xl8wJE4YcXburMPyD3H/7VxuXBFt6tMsELxgQB0we0qevg2
         reww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sEALbQJdLFXDpIrcz5vOD04lEWNB/c+oAZmm2+ZeLTI=;
        b=HKDcy6Jm6iCq63YhYqTUWk61hnRNlUmJ2xpuAgJwSLQjw3lH9tUhL95SPA2V+FubNC
         LPjZC7LX4VchEgSdpuhMDTityQetw2ZUvwyqLKJX2c28482V+ger5XoDFz313qJaXAsz
         s+UVEmAxpTpNKcIk2T5XHLnmKCtJuA0OwnJ2SnO6M88PH4nISD7rweOgYAvQNHi+Fh+5
         2xnydY9gcaOaLE3hPWiDvi7+q2NmK+MHLI6niNzO6aMux+vHhNoQT3HZInqF9aJbWbfH
         5rEMxPHi9HsPXxW7VI9wFxknoDTIWPcFqe5z0+TAKV0I+bQI+oI3WchwfwAV0qwo4Y+0
         81zA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id dc6si5453139ejb.212.2019.04.04.05.59.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 05:59:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 04 Apr 2019 14:59:39 +0200
Received: from d104.suse.de (nwb-a10-snat.microfocus.com [10.120.13.202])
	by emea4-mta.ukb.novell.com with ESMTP (NOT encrypted); Thu, 04 Apr 2019 13:59:34 +0100
From: Oscar Salvador <osalvador@suse.de>
To: akpm@linux-foundation.org
Cc: mhocko@suse.com,
	david@redhat.com,
	dan.j.williams@intel.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Oscar Salvador <osalvador@suse.de>
Subject: [PATCH 2/2] mm, memory_hotplug: provide a more generic restrictions for memory hotplug
Date: Thu,  4 Apr 2019 14:59:16 +0200
Message-Id: <20190404125916.10215-3-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190404125916.10215-1-osalvador@suse.de>
References: <20190404125916.10215-1-osalvador@suse.de>
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

This patch shouldn't introduce any functional change.

Signed-off-by: Michal Hocko <mhocko@suse.com>
Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 arch/arm64/mm/mmu.c            |  6 +++---
 arch/ia64/mm/init.c            |  6 +++---
 arch/powerpc/mm/mem.c          |  6 +++---
 arch/s390/mm/init.c            |  6 +++---
 arch/sh/mm/init.c              |  6 +++---
 arch/x86/mm/init_32.c          |  6 +++---
 arch/x86/mm/init_64.c          | 10 +++++-----
 include/linux/memory_hotplug.h | 29 +++++++++++++++++++++++------
 kernel/memremap.c              | 10 +++++++---
 mm/memory_hotplug.c            | 10 ++++++----
 10 files changed, 59 insertions(+), 36 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e6acfa7be4c7..db509550329d 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1046,8 +1046,8 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		    bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
 {
 	int flags = 0;
 
@@ -1058,6 +1058,6 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
 
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
-			   altmap, want_memblock);
+							restrictions);
 }
 #endif
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index e49200e31750..379eb1f9adc9 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -666,14 +666,14 @@ mem_init (void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
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
index 1aa27aac73c5..76deaa8525db 100644
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
index 25e3113091ea..f5db961ad792 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -216,8 +216,8 @@ device_initcall(s390_cma_mem_init);
 
 #endif /* CONFIG_CMA */
 
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+		struct mhp_restrictions *restrictions)
 {
 	unsigned long start_pfn = PFN_DOWN(start);
 	unsigned long size_pages = PFN_DOWN(size);
@@ -227,7 +227,7 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 	if (rc)
 		return rc;
 
-	rc = __add_pages(nid, start_pfn, size_pages, altmap, want_memblock);
+	rc = __add_pages(nid, start_pfn, size_pages, restrictions);
 	if (rc)
 		vmem_remove_mapping(start, size);
 	return rc;
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index 8e004b2f1a6a..168d3a6b9358 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -404,15 +404,15 @@ void __init mem_init(void)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
-int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
-		bool want_memblock)
+int arch_add_memory(int nid, u64 start, u64 size,
+			struct mhp_restrictions *restrictions)
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
index 3c8cf347804c..5bd4b56f639c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -118,20 +118,37 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages, struct vmem_altmap *altmap);
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
+/*
+ * Do we want sysfs memblock files created. This will allow userspace to online
+ * and offline memory explicitly. Lack of this bit means that the caller has to
+ * call move_pfn_range_to_zone to finish the initialization.
+ */
+
+#define MHP_MEMBLOCK_API               (1<<0)
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
@@ -333,7 +350,7 @@ extern int __add_memory(int nid, u64 start, u64 size);
 extern int add_memory(int nid, u64 start, u64 size);
 extern int add_memory_resource(int nid, struct resource *resource);
 extern int arch_add_memory(int nid, u64 start, u64 size,
-		struct vmem_altmap *altmap, bool want_memblock);
+			struct mhp_restrictions *restrictions);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
diff --git a/kernel/memremap.c b/kernel/memremap.c
index a856cb5ff192..cc5e3e34417d 100644
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
@@ -222,8 +226,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 			goto err_kasan;
 		}
 
-		error = arch_add_memory(nid, align_start, align_size, altmap,
-				false);
+		error = arch_add_memory(nid, align_start, align_size,
+							&restrictions);
 	}
 
 	if (!error) {
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index d8a3e9554aec..50f77e059457 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -274,12 +274,12 @@ static int __meminit __add_section(int nid, unsigned long phys_start_pfn,
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
@@ -300,7 +300,7 @@ int __ref __add_pages(int nid, unsigned long phys_start_pfn,
 
 	for (i = start_sec; i <= end_sec; i++) {
 		err = __add_section(nid, section_nr_to_pfn(i), altmap,
-				want_memblock);
+				restrictions->flags & MHP_MEMBLOCK_API);
 
 		/*
 		 * EEXIST is finally dealt with by ioresource collision
@@ -1102,6 +1102,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	u64 start, size;
 	bool new_node = false;
 	int ret;
+	struct mhp_restrictions restrictions = {};
 
 	start = res->start;
 	size = resource_size(res);
@@ -1126,7 +1127,8 @@ int __ref add_memory_resource(int nid, struct resource *res)
 	new_node = ret;
 
 	/* call arch's memory hotadd */
-	ret = arch_add_memory(nid, start, size, NULL, true);
+	restrictions.flags = MHP_MEMBLOCK_API;
+	ret = arch_add_memory(nid, start, size, &restrictions);
 	if (ret < 0)
 		goto error;
 
-- 
2.13.7

