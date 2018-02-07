Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 054B56B02C0
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 22:43:19 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id t64so2324712pfi.13
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 19:43:18 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id m26-v6si420279pli.564.2018.02.06.19.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Feb 2018 19:43:17 -0800 (PST)
Subject: [PATCH] memremap: fix softlockup reports at teardown
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Feb 2018 19:34:11 -0800
Message-ID: <151797445154.29778.16795392483399217682.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, =?utf-8?b?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>

The cond_resched() currently in the setup path needs to be duplicated in
the teardown path. Rather than require each instance of
for_each_device_pfn() to open code the same sequence, embed it in the
helper.

Link: https://github.com/intel/ixpdimm_sw/issues/11
Cc: "JA(C)rA'me Glisse" <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: <stable@vger.kernel.org>
Fixes: 71389703839e ("mm, zone_device: Replace {get, put}_zone_device_page()...")
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 kernel/memremap.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/kernel/memremap.c b/kernel/memremap.c
index 4849be5f9b3c..4dd4274cabe2 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -275,8 +275,15 @@ static unsigned long pfn_end(struct dev_pagemap *pgmap)
 	return (res->start + resource_size(res)) >> PAGE_SHIFT;
 }
 
+static unsigned long pfn_next(unsigned long pfn)
+{
+	if (pfn % 1024 == 0)
+		cond_resched();
+	return pfn + 1;
+}
+
 #define for_each_device_pfn(pfn, map) \
-	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn++)
+	for (pfn = pfn_first(map); pfn < pfn_end(map); pfn = pfn_next(pfn))
 
 static void devm_memremap_pages_release(void *data)
 {
@@ -337,10 +344,10 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 	resource_size_t align_start, align_size, align_end;
 	struct vmem_altmap *altmap = pgmap->altmap_valid ?
 			&pgmap->altmap : NULL;
+	struct resource *res = &pgmap->res;
 	unsigned long pfn, pgoff, order;
 	pgprot_t pgprot = PAGE_KERNEL;
-	int error, nid, is_ram, i = 0;
-	struct resource *res = &pgmap->res;
+	int error, nid, is_ram;
 
 	align_start = res->start & ~(SECTION_SIZE - 1);
 	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
@@ -409,8 +416,6 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
 		list_del(&page->lru);
 		page->pgmap = pgmap;
 		percpu_ref_get(pgmap->ref);
-		if (!(++i % 1024))
-			cond_resched();
 	}
 
 	devm_add_action(dev, devm_memremap_pages_release, pgmap);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
