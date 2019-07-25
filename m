Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D087AC41514
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 95D962238C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 16:02:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 95D962238C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3DF76B0007; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 87EFD8E0003; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 73B0D8E0002; Thu, 25 Jul 2019 12:02:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id ECF506B000A
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 12:02:17 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i44so32440938eda.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=dYPyV2/sBc8VWNtA55oyBRVoL378fhxQLTc42Q0vxc4=;
        b=nbQelOKVZXjN3Ra+G8QZ0n6aiUyPPfdlu6dTmfzjQDiWwLQ3ZvKyHg8xbEq9amqsZ5
         C4DOllcnx20wiDjbX0MlALXOd+r3BYb2XMUDJlvGMW0uOjzfzJtRQN58rMZqIDbDeKO6
         jL5pmW1wN++ujh4Ne9sVXuyACPZmTSAf9ljYXNfh9TeQ4gETf+nyPipcTeS4JRXcG/F2
         OCzbSu14Mw1vJ51qqvDvfFgOO6PJbmXhH73FQ/DZrPMXC22gwnJB/BRyjjyEfLVnjBll
         O7uyiISqmMPTrKERsBG1F1sWlV8f9mzey1sJUF3RKQ3Y/EWcMSCE8K4nI8CGH3gYAmTy
         VhYA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVjN2vpb0qrGoq7kCK+QZ59T8kr7BCNp96cbSPGOnDLUEv6lQoa
	rdQHyIoZtCmdVE/CbkeWG8CjQYEXAsBSfAFZlUel5F3NnSDD6RyzGcDxdtdluB2DnClQ96JlIJE
	onZQ3uOCOqSJAPyy7VnEdWLY22+UydrUXeT0+GiS7iH3jgu6nEd5VOWB/LTHge16CnA==
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr69108551ejb.68.1564070537280;
        Thu, 25 Jul 2019 09:02:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxvm2vJ3D3LlMsDn9qYZ1xA3uBGtybT2UhjCROCb/CBxray3IjKXSxLdXnhjrPKWlrVbiK
X-Received: by 2002:a17:906:bcd6:: with SMTP id lw22mr69108435ejb.68.1564070535869;
        Thu, 25 Jul 2019 09:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564070535; cv=none;
        d=google.com; s=arc-20160816;
        b=uGqJ2Ooz+xaLPg1sH/aBwHRF/m463JqIHo6F9/67YXSl4Xc/c6ZvVsb1bSzIOdsx1F
         gOR8MCdUrYmSqrtAklcROZ7e6Q5fmp19qydJObvuyBlvahE79yVgV3OmeckOcPl38qBU
         joX/jGkTN7u9NddgUBs+RPGn4jgEEYHjoDk4cmw67PWkLhrOeGkC17GF+hQa828wji76
         SE4DsmjwwTCLlusczlnCUUifHY+IJNR8vPxv/l8VsnyaW84JuPTBBj+l0h7e3P22Gk3m
         PiNkCJWRYhYpWRZJ74LeSYPlCLkQEm+E88KB1xk5JqtFar50h4eaMkr0rpjvvrsdVboO
         IIVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=dYPyV2/sBc8VWNtA55oyBRVoL378fhxQLTc42Q0vxc4=;
        b=QoDj4IUyxhQh6YBI9eC8dEyEJENmDdv8h1eMpd9sEPNAO6jdTdQVVThHTOaJJ0kDIw
         qPMcav6Rg6WP9P7jq8prx06FJ3/V6YkSv0oXlV75vU+OY5UKmWisEXGLySHCUMavKK9f
         VY3HUAfsHt1CfcQV8p5JMRiZRZqzEk8Cy7APABxx22nPhfKQyovBMvbwfzjWVx6nSaXZ
         FbG/nrNCAqxulsihA2maBbyTWxD3pxGpSHRPjf+fdAfTPuF9Mb1gAkwyqfl4coQG2MbL
         1nx2YRSYVpFR01qlvXha5Yu5hqFnyWlg65KTZJ8GaBXrdyuYqeOBeGO6U/psnlcbMR4F
         B5lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t27si12488159eda.244.2019.07.25.09.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 09:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 18E10AFD4;
	Thu, 25 Jul 2019 16:02:15 +0000 (UTC)
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
Subject: [PATCH v3 1/5] mm,memory_hotplug: Introduce MHP_MEMMAP_ON_MEMORY
Date: Thu, 25 Jul 2019 18:02:03 +0200
Message-Id: <20190725160207.19579-2-osalvador@suse.de>
X-Mailer: git-send-email 2.13.7
In-Reply-To: <20190725160207.19579-1-osalvador@suse.de>
References: <20190725160207.19579-1-osalvador@suse.de>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch introduces MHP_MEMMAP_ON_MEMORY flag,
and prepares the callers that add memory to take a "flags" parameter.
This "flags" parameter will be evaluated later on in Patch#3
to init mhp_restrictions struct.

The callers are:

add_memory
__add_memory
add_memory_resource

Unfortunately, we do not have a single entry point to add memory, as depending
on the requisites of the caller, they want to hook up in different places,
(e.g: Xen reserve_additional_memory()), so we have to spread the parameter
in the three callers.

MHP_MEMMAP_ON_MEMORY flag parameter will specify to allocate memmaps
from the hot-added range.
If callers wants memmaps to be allocated per memory block, it will
have to call add_memory() variants in memory-block granularity
spanning the whole range, while if it wants to allocate memmaps
per whole memory range, just one call will do.

Want to add 384MB (3 sections, 3 memory-blocks)
e.g:

	add_memory(0x1000, size_memory_block);
	add_memory(0x2000, size_memory_block);
	add_memory(0x3000, size_memory_block);

	[memblock#0  ]
	[0 - 511 pfns      ] - vmemmaps for section#0
	[512 - 32767 pfns  ] - normal memory

	[memblock#1 ]
	[32768 - 33279 pfns] - vmemmaps for section#1
	[33280 - 65535 pfns] - normal memory

	[memblock#2 ]
	[65536 - 66047 pfns] - vmemmap for section#2
	[66048 - 98304 pfns] - normal memory

or
	add_memory(0x1000, size_memory_block * 3);

	[memblock #0 ]
        [0 - 1533 pfns    ] - vmemmap for section#{0-2}
        [1534 - 98304 pfns] - normal memory

When using larger memory blocks (1GB or 2GB), the principle is the same.

Of course, per whole-range granularity is nicer when it comes to have a large
contigous area, while per memory-block granularity allows us to have flexibility
when removing the memory.

Signed-off-by: Oscar Salvador <osalvador@suse.de>
---
 drivers/acpi/acpi_memhotplug.c |  2 +-
 drivers/base/memory.c          |  2 +-
 drivers/dax/kmem.c             |  2 +-
 drivers/hv/hv_balloon.c        |  2 +-
 drivers/s390/char/sclp_cmd.c   |  2 +-
 drivers/xen/balloon.c          |  2 +-
 include/linux/memory_hotplug.h | 25 ++++++++++++++++++++++---
 mm/memory_hotplug.c            | 10 +++++-----
 8 files changed, 33 insertions(+), 14 deletions(-)

diff --git a/drivers/acpi/acpi_memhotplug.c b/drivers/acpi/acpi_memhotplug.c
index e294f44a7850..d91b3584d4b2 100644
--- a/drivers/acpi/acpi_memhotplug.c
+++ b/drivers/acpi/acpi_memhotplug.c
@@ -207,7 +207,7 @@ static int acpi_memory_enable_device(struct acpi_memory_device *mem_device)
 		if (node < 0)
 			node = memory_add_physaddr_to_nid(info->start_addr);
 
-		result = __add_memory(node, info->start_addr, info->length);
+		result = __add_memory(node, info->start_addr, info->length, 0);
 
 		/*
 		 * If the memory block has been used by the kernel, add_memory()
diff --git a/drivers/base/memory.c b/drivers/base/memory.c
index 154d5d4a0779..d30d0f6c8ad0 100644
--- a/drivers/base/memory.c
+++ b/drivers/base/memory.c
@@ -521,7 +521,7 @@ static ssize_t probe_store(struct device *dev, struct device_attribute *attr,
 
 	nid = memory_add_physaddr_to_nid(phys_addr);
 	ret = __add_memory(nid, phys_addr,
-			   MIN_MEMORY_BLOCK_SIZE * sections_per_block);
+			   MIN_MEMORY_BLOCK_SIZE * sections_per_block, 0);
 
 	if (ret)
 		goto out;
diff --git a/drivers/dax/kmem.c b/drivers/dax/kmem.c
index 3d0a7e702c94..e159184e0ba0 100644
--- a/drivers/dax/kmem.c
+++ b/drivers/dax/kmem.c
@@ -65,7 +65,7 @@ int dev_dax_kmem_probe(struct device *dev)
 	new_res->flags = IORESOURCE_SYSTEM_RAM;
 	new_res->name = dev_name(dev);
 
-	rc = add_memory(numa_node, new_res->start, resource_size(new_res));
+	rc = add_memory(numa_node, new_res->start, resource_size(new_res), 0);
 	if (rc) {
 		release_resource(new_res);
 		kfree(new_res);
diff --git a/drivers/hv/hv_balloon.c b/drivers/hv/hv_balloon.c
index 6fb4ea5f0304..beb92bc56186 100644
--- a/drivers/hv/hv_balloon.c
+++ b/drivers/hv/hv_balloon.c
@@ -731,7 +731,7 @@ static void hv_mem_hot_add(unsigned long start, unsigned long size,
 
 		nid = memory_add_physaddr_to_nid(PFN_PHYS(start_pfn));
 		ret = add_memory(nid, PFN_PHYS((start_pfn)),
-				(HA_CHUNK << PAGE_SHIFT));
+				(HA_CHUNK << PAGE_SHIFT), 0);
 
 		if (ret) {
 			pr_err("hot_add memory failed error is %d\n", ret);
diff --git a/drivers/s390/char/sclp_cmd.c b/drivers/s390/char/sclp_cmd.c
index 37d42de06079..f61026c7db7e 100644
--- a/drivers/s390/char/sclp_cmd.c
+++ b/drivers/s390/char/sclp_cmd.c
@@ -406,7 +406,7 @@ static void __init add_memory_merged(u16 rn)
 	if (!size)
 		goto skip_add;
 	for (addr = start; addr < start + size; addr += block_size)
-		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size);
+		add_memory(numa_pfn_to_nid(PFN_DOWN(addr)), addr, block_size, 0);
 skip_add:
 	first_rn = rn;
 	num = 1;
diff --git a/drivers/xen/balloon.c b/drivers/xen/balloon.c
index 4e11de6cde81..e4934ce40478 100644
--- a/drivers/xen/balloon.c
+++ b/drivers/xen/balloon.c
@@ -349,7 +349,7 @@ static enum bp_state reserve_additional_memory(void)
 	mutex_unlock(&balloon_mutex);
 	/* add_memory_resource() requires the device_hotplug lock */
 	lock_device_hotplug();
-	rc = add_memory_resource(nid, resource);
+	rc = add_memory_resource(nid, resource, 0);
 	unlock_device_hotplug();
 	mutex_lock(&balloon_mutex);
 
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f46ea71b4ffd..45dece922d7c 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -54,6 +54,25 @@ enum {
 };
 
 /*
+ * We want memmap (struct page array) to be allocated from the hotadded range.
+ * To do so, there are two possible ways depending on what the caller wants.
+ * 1) Allocate memmap pages whole hot-added range.
+ *    Here the caller will only call any add_memory() variant with the whole
+ *    memory address.
+ * 2) Allocate memmap pages per memblock
+ *    Here, the caller will call any add_memory() variant per memblock
+ *    granularity.
+ * The former implies that we will use the beginning of the hot-added range
+ * to store the memmap pages of the whole range, while the latter implies
+ * that we will use the beginning of each memblock to store its own memmap
+ * pages.
+ *
+ * Please note that this is only a hint, not a guarantee. Only selected
+ * architectures support it with SPARSE_VMEMMAP.
+ */
+#define MHP_MEMMAP_ON_MEMORY	(1UL<<1)
+
+/*
  * Restrictions for the memory hotplug:
  * flags:  MHP_ flags
  * altmap: alternative allocator for memmap array
@@ -340,9 +359,9 @@ static inline void __remove_memory(int nid, u64 start, u64 size) {}
 #endif /* CONFIG_MEMORY_HOTREMOVE */
 
 extern void __ref free_area_init_core_hotplug(int nid);
-extern int __add_memory(int nid, u64 start, u64 size);
-extern int add_memory(int nid, u64 start, u64 size);
-extern int add_memory_resource(int nid, struct resource *resource);
+extern int __add_memory(int nid, u64 start, u64 size, unsigned long flags);
+extern int add_memory(int nid, u64 start, u64 size, unsigned long flags);
+extern int add_memory_resource(int nid, struct resource *resource, unsigned long flags);
 extern void move_pfn_range_to_zone(struct zone *zone, unsigned long start_pfn,
 		unsigned long nr_pages, struct vmem_altmap *altmap);
 extern bool is_memblock_offlined(struct memory_block *mem);
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9a82e12bd0e7..3d97c3711333 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1046,7 +1046,7 @@ static int online_memory_block(struct memory_block *mem, void *arg)
  *
  * we are OK calling __meminit stuff here - we have CONFIG_MEMORY_HOTPLUG
  */
-int __ref add_memory_resource(int nid, struct resource *res)
+int __ref add_memory_resource(int nid, struct resource *res, unsigned long flags)
 {
 	struct mhp_restrictions restrictions = {};
 	u64 start, size;
@@ -1123,7 +1123,7 @@ int __ref add_memory_resource(int nid, struct resource *res)
 }
 
 /* requires device_hotplug_lock, see add_memory_resource() */
-int __ref __add_memory(int nid, u64 start, u64 size)
+int __ref __add_memory(int nid, u64 start, u64 size, unsigned long flags)
 {
 	struct resource *res;
 	int ret;
@@ -1132,18 +1132,18 @@ int __ref __add_memory(int nid, u64 start, u64 size)
 	if (IS_ERR(res))
 		return PTR_ERR(res);
 
-	ret = add_memory_resource(nid, res);
+	ret = add_memory_resource(nid, res, flags);
 	if (ret < 0)
 		release_memory_resource(res);
 	return ret;
 }
 
-int add_memory(int nid, u64 start, u64 size)
+int add_memory(int nid, u64 start, u64 size, unsigned long flags)
 {
 	int rc;
 
 	lock_device_hotplug();
-	rc = __add_memory(nid, start, size);
+	rc = __add_memory(nid, start, size, flags);
 	unlock_device_hotplug();
 
 	return rc;
-- 
2.12.3

