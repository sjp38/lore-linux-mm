Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 965FEC43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4842B2085A
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 06:09:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4842B2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E340B6B000D; Thu,  2 May 2019 02:09:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE4546B000E; Thu,  2 May 2019 02:09:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6516B0010; Thu,  2 May 2019 02:09:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93AA06B000D
	for <linux-mm@kvack.org>; Thu,  2 May 2019 02:09:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id d21so704022pfr.3
        for <linux-mm@kvack.org>; Wed, 01 May 2019 23:09:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=OOqGHzrOteQ2KD1XXo5HKErQD1DIEXCq7Q2pecySPGA=;
        b=m6b2nYk1J2s/EgvyoCctrs3py7hFuLuzHxV2MHKHb1aRHMQBEqplbUv1AIRY9ZPfDq
         9q9grBVorJUonFi5HEYqrJfLtp4gtj0+c/RMmFS8OucC5vxHKmNmFVPlwRR/24wIdQTT
         5EyzuvoOt2X1o/iIdK0XMkHFgIZ/6+PtjlQQHj7udrGEP1H13fskIMeOHXtzrYok2z3G
         dppSrAL9Iu8KXSudc92Z89hlB+PkJuog1zu1UZIT1kyNb3FGdubvEJN0QTdp4INk+HCR
         zPg9cPgd4dxMWb4GRD/g5h4icc8atpippai/eZshKSoreIuZ8Hr1BodvcEU4LnqNop+s
         SyQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWxGkaQoCm6K+pcPAH0DqrL8Q+Adb5zluM8ed19JURbImWfZg8U
	l80rQYTXBlfRaLZwOJ3R0F8/51CE2kBsB8CEy72Itez8VLnc9waGtzfPU/MIzuQu6lf01/qlW8e
	2R066w5gArpnE6AWjKpRdS4WOKOG+SX/M3JG+3L6k/WRTPBNhuwtr5+0UgoQwthU8ow==
X-Received: by 2002:a62:6b44:: with SMTP id g65mr2246469pfc.27.1556777376257;
        Wed, 01 May 2019 23:09:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxbS5b3uaKh1PmJfGyV6EQTA46YoCRY9RUiF7x45KEBAtOuFPk1gmO6JTamHEQG0ZbRphuN
X-Received: by 2002:a62:6b44:: with SMTP id g65mr2246405pfc.27.1556777375423;
        Wed, 01 May 2019 23:09:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556777375; cv=none;
        d=google.com; s=arc-20160816;
        b=q7kRI+ClsfRLAcQ0dEQVtxHyZZB+HuQV+2XkEn46hP3gVb1Mgf8Qwq5yjS9z6jQ7Ht
         foxzSQy6IVq/SusZ+QT+1J39c5MDE+8jnf3eoRJBFD8U2PWc5e5R0cY5PpuqhG+erH+k
         0FP30uAb5UvmO1dzAiVrtkcGFvAV0+n/q4U6WSnrPV+/G7/BZ9Vc2DMdn8yd8y98QdWj
         c5EyRmVEJmwIJBpjz89xmt6ftkZD4sO69HBm2ziwKSn3vFILH1HjcvO8ndp3wv7gOrAY
         Jj5glQA+uujMLMIjy6SEnKwnWbDWm2aXa650lKbvWgf3TT/9pGxA6bK/Go+Aq5IaYr7k
         O3LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=OOqGHzrOteQ2KD1XXo5HKErQD1DIEXCq7Q2pecySPGA=;
        b=UU6JrI3JPoR6Yc216by/COpGGBCGWZEywVY425lYF2VJyw2wnbegxEm3KVT2lIhwsS
         NgUNysEUSaW378+raNeVnQeBrPgHY7qhbkeLQ9wvtl8/7BkdZ5AlMmhNlsOnCreZfi57
         o3QYhVAY+urlJNwBNCB23spax+WYArGFvyAVfuJgUrilxhEJxx541KlJ1wietnqceaAs
         Va7qMeCf1XpgE0Uv5tngrqZQtooo+b89N+n6ktjbUJjtRFomwUtdkgwsTfd7Ce10L00f
         oyYfdC6sK8ULTxOfo/m3LGr/cvnFZJFK/fgtj+G+2aJywQKqM2N3dp+os/vyIKWSxJw0
         Xzgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k33si44852414pld.27.2019.05.01.23.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 23:09:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 01 May 2019 23:09:34 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,420,1549958400"; 
   d="scan'208";a="166797485"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga002.fm.intel.com with ESMTP; 01 May 2019 23:09:34 -0700
Subject: [PATCH v7 05/12] mm/sparsemem: Convert kmalloc_section_memmap() to
 populate_section_memmap()
From: Dan Williams <dan.j.williams@intel.com>
To: akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, David Hildenbrand <david@redhat.com>,
 Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, osalvador@suse.de,
 mhocko@suse.com
Date: Wed, 01 May 2019 22:55:48 -0700
Message-ID: <155677654842.2336373.17000900051843592636.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Allow sub-section sized ranges to be added to the memmap.
populate_section_memmap() takes an explict pfn range rather than
assuming a full section, and those parameters are plumbed all the way
through to vmmemap_populate(). There should be no sub-section usage in
current deployments. New warnings are added to clarify which memmap
allocation paths are sub-section capable.

Cc: Michal Hocko <mhocko@suse.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init_64.c |    4 ++-
 include/linux/mm.h    |    4 ++-
 mm/sparse-vmemmap.c   |   21 +++++++++++------
 mm/sparse.c           |   61 +++++++++++++++++++++++++++++++------------------
 4 files changed, 57 insertions(+), 33 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 20d14254b686..bb018d09d2dc 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1457,7 +1457,9 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 {
 	int err;
 
-	if (boot_cpu_has(X86_FEATURE_PSE))
+	if (end - start < PAGES_PER_SECTION * sizeof(struct page))
+		err = vmemmap_populate_basepages(start, end, node);
+	else if (boot_cpu_has(X86_FEATURE_PSE))
 		err = vmemmap_populate_hugepages(start, end, node, altmap);
 	else if (altmap) {
 		pr_err_once("%s: no cpu support for altmap allocations\n",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..5360a0e4051d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2748,8 +2748,8 @@ const char * arch_vma_name(struct vm_area_struct *vma);
 void print_vma_addr(char *prefix, unsigned long rip);
 
 void *sparse_buffer_alloc(unsigned long size);
-struct page *sparse_mem_map_populate(unsigned long pnum, int nid,
-		struct vmem_altmap *altmap);
+struct page * __populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid, struct vmem_altmap *altmap);
 pgd_t *vmemmap_pgd_populate(unsigned long addr, int node);
 p4d_t *vmemmap_p4d_populate(pgd_t *pgd, unsigned long addr, int node);
 pud_t *vmemmap_pud_populate(p4d_t *p4d, unsigned long addr, int node);
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 7fec05796796..dcb023aa23d1 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -245,19 +245,26 @@ int __meminit vmemmap_populate_basepages(unsigned long start,
 	return 0;
 }
 
-struct page * __meminit sparse_mem_map_populate(unsigned long pnum, int nid,
-		struct vmem_altmap *altmap)
+struct page * __meminit __populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
 	unsigned long start;
 	unsigned long end;
-	struct page *map;
 
-	map = pfn_to_page(pnum * PAGES_PER_SECTION);
-	start = (unsigned long)map;
-	end = (unsigned long)(map + PAGES_PER_SECTION);
+	/*
+	 * The minimum granularity of memmap extensions is
+	 * SECTION_ACTIVE_SIZE as allocations are tracked in the
+	 * 'map_active' bitmap of the section.
+	 */
+	end = ALIGN(pfn + nr_pages, PHYS_PFN(SECTION_ACTIVE_SIZE));
+	pfn &= PHYS_PFN(SECTION_ACTIVE_MASK);
+	nr_pages = end - pfn;
+
+	start = (unsigned long) pfn_to_page(pfn);
+	end = start + nr_pages * sizeof(struct page);
 
 	if (vmemmap_populate(start, end, nid, altmap))
 		return NULL;
 
-	return map;
+	return pfn_to_page(pfn);
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 8d4f28e2c25e..ed26761327bf 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -452,8 +452,8 @@ static unsigned long __init section_map_size(void)
 	return PAGE_ALIGN(sizeof(struct page) * PAGES_PER_SECTION);
 }
 
-struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
-		struct vmem_altmap *altmap)
+struct page __init *__populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
 	unsigned long size = section_map_size();
 	struct page *map = sparse_buffer_alloc(size);
@@ -534,10 +534,13 @@ static void __init sparse_init_nid(int nid, unsigned long pnum_begin,
 	}
 	sparse_buffer_init(map_count * section_map_size(), nid);
 	for_each_present_section_nr(pnum_begin, pnum) {
+		unsigned long pfn = section_nr_to_pfn(pnum);
+
 		if (pnum >= pnum_end)
 			break;
 
-		map = sparse_mem_map_populate(pnum, nid, NULL);
+		map = __populate_section_memmap(pfn, PAGES_PER_SECTION,
+				nid, NULL);
 		if (!map) {
 			pr_err("%s: node[%d] memory map backing failed. Some memory will not be available.",
 			       __func__, nid);
@@ -637,17 +640,17 @@ void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
-		struct vmem_altmap *altmap)
+static struct page *populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
-	/* This will make the necessary allocations eventually. */
-	return sparse_mem_map_populate(pnum, nid, altmap);
+	return __populate_section_memmap(pfn, nr_pages, nid, altmap);
 }
-static void __kfree_section_memmap(struct page *memmap,
+
+static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
 		struct vmem_altmap *altmap)
 {
-	unsigned long start = (unsigned long)memmap;
-	unsigned long end = (unsigned long)(memmap + PAGES_PER_SECTION);
+	unsigned long start = (unsigned long) pfn_to_page(pfn);
+	unsigned long end = start + nr_pages * sizeof(struct page);
 
 	vmemmap_free(start, end, altmap);
 }
@@ -661,11 +664,18 @@ static void free_map_bootmem(struct page *memmap)
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #else
-static struct page *__kmalloc_section_memmap(void)
+struct page *populate_section_memmap(unsigned long pfn,
+		unsigned long nr_pages, int nid, struct vmem_altmap *altmap)
 {
 	struct page *page, *ret;
 	unsigned long memmap_size = sizeof(struct page) * PAGES_PER_SECTION;
 
+	if ((pfn & ~PAGE_SECTION_MASK) || nr_pages != PAGES_PER_SECTION) {
+		WARN(1, "%s: called with section unaligned parameters\n",
+				__func__);
+		return NULL;
+	}
+
 	page = alloc_pages(GFP_KERNEL|__GFP_NOWARN, get_order(memmap_size));
 	if (page)
 		goto got_map_page;
@@ -682,15 +692,17 @@ static struct page *__kmalloc_section_memmap(void)
 	return ret;
 }
 
-static inline struct page *kmalloc_section_memmap(unsigned long pnum, int nid,
+static void depopulate_section_memmap(unsigned long pfn, unsigned long nr_pages,
 		struct vmem_altmap *altmap)
 {
-	return __kmalloc_section_memmap();
-}
+	struct page *memmap = pfn_to_page(pfn);
+
+	if ((pfn & ~PAGE_SECTION_MASK) || nr_pages != PAGES_PER_SECTION) {
+		WARN(1, "%s: called with section unaligned parameters\n",
+				__func__);
+		return;
+	}
 
-static void __kfree_section_memmap(struct page *memmap,
-		struct vmem_altmap *altmap)
-{
 	if (is_vmalloc_addr(memmap))
 		vfree(memmap);
 	else
@@ -761,12 +773,13 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 	if (ret < 0 && ret != -EEXIST)
 		return ret;
 	ret = 0;
-	memmap = kmalloc_section_memmap(section_nr, nid, altmap);
+	memmap = populate_section_memmap(start_pfn, PAGES_PER_SECTION, nid,
+			altmap);
 	if (!memmap)
 		return -ENOMEM;
 	usage = kzalloc(mem_section_usage_size(), GFP_KERNEL);
 	if (!usage) {
-		__kfree_section_memmap(memmap, altmap);
+		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
 		return -ENOMEM;
 	}
 
@@ -788,7 +801,7 @@ int __meminit sparse_add_one_section(int nid, unsigned long start_pfn,
 out:
 	if (ret < 0) {
 		kfree(usage);
-		__kfree_section_memmap(memmap, altmap);
+		depopulate_section_memmap(start_pfn, PAGES_PER_SECTION, altmap);
 	}
 	return ret;
 }
@@ -825,7 +838,8 @@ static inline void clear_hwpoisoned_pages(struct page *memmap, int nr_pages)
 #endif
 
 static void free_section_usage(struct page *memmap,
-		struct mem_section_usage *usage, struct vmem_altmap *altmap)
+		struct mem_section_usage *usage, unsigned long pfn,
+		unsigned long nr_pages, struct vmem_altmap *altmap)
 {
 	struct page *usage_page;
 
@@ -839,7 +853,7 @@ static void free_section_usage(struct page *memmap,
 	if (PageSlab(usage_page) || PageCompound(usage_page)) {
 		kfree(usage);
 		if (memmap)
-			__kfree_section_memmap(memmap, altmap);
+			depopulate_section_memmap(pfn, nr_pages, altmap);
 		return;
 	}
 
@@ -868,7 +882,8 @@ void sparse_remove_one_section(struct zone *zone, struct mem_section *ms,
 
 	clear_hwpoisoned_pages(memmap + map_offset,
 			PAGES_PER_SECTION - map_offset);
-	free_section_usage(memmap, usage, altmap);
+	free_section_usage(memmap, usage, section_nr_to_pfn(__section_nr(ms)),
+			PAGES_PER_SECTION, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 #endif /* CONFIG_MEMORY_HOTPLUG */

