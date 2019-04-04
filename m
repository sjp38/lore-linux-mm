Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 996D6C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5B1B12075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5B1B12075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11AAD6B026A; Thu,  4 Apr 2019 15:21:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0CADE6B026B; Thu,  4 Apr 2019 15:21:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFAF16B026C; Thu,  4 Apr 2019 15:21:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id B298E6B026A
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:26 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f1so2157034pgv.12
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=lx2tEtGfJT03jPtriJxyerULclZQ9l500DLB1HLb0vI=;
        b=kCC25WyOu+7FT0z+s6LE4yxT4IqsUH9fF5LBgNQReG1hp5+PItt1/3GsiqGPw8QBF/
         keeX+2jQW8Mk6YWUvBoOfzxBkBilLcAZzI8zXjdDb87dxiuS+itRtGtaNG0AHxij9hpO
         jEYNo0RCo5F/P6sFjIIViFO7XHEJJ6i8eNro645SsUW4c/L6//LiXy9ndn1ESWeDK+eg
         eYSZtBvv/whRQKJ71Uf7cmUzhYOojT54nDZ3+bsYpvoicb0hcY6dBpN/PghS92wquiZX
         Qlwa5rwudjsaj9OrizTufWkOmcGXAY8lVviLQoPfIgWoeL2XS/wLS1f5r7PmVD/bPvgL
         WsNA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU7voegwDKZLjeRm5DeTKVZjhzBkVGd1YliPzhAo5ee30wiMyIf
	IFaGy5dSBYPhNPOHtDTk9FQJWP/Ct1ww6UPUceWKdTdXJsH48+lf3rdhUiNf73TLQslT5yx2tML
	rdgnq2ZZb0cJu4cumtp7YCvKXMATnqGyT9c87kFuUv147DEYmsZFkdSWhVC/JoHHMqw==
X-Received: by 2002:a63:fa54:: with SMTP id g20mr7268348pgk.242.1554405686316;
        Thu, 04 Apr 2019 12:21:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPH7+2xPdllfkh9o4X/ILv2vxsiyhvVKBxqWISkXJJxodhdwgHTufEpRg/vvDIouMjlvgX
X-Received: by 2002:a63:fa54:: with SMTP id g20mr7268257pgk.242.1554405685022;
        Thu, 04 Apr 2019 12:21:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405685; cv=none;
        d=google.com; s=arc-20160816;
        b=yHtGWIFh/F+Fd1K5VqEWmW9muOO0cA8Gb/DVNaREP9aFoAFR3innvteqLjnf3EdtVI
         DP62/BBAUo+yVUt/xBqwbrPU4LmownAOM3RxZpO1tn+APIFVXl+QayoF82RAkZ5Eaq3S
         qNlDEXLcIkzcpWgOB1fNEUPM6tFqlD1qHf6Q7540PQ0SdPGYdYvJDBBadxjZevBBY6Qa
         1uyX2oUDdgY3ALMOE+kbX3LazBg1gAtxndunkeK35zQWTa/nxP/tvmEKvVOrnR1aDQFf
         GS6aDLL4IRv277pj/OfJ59IlSwdDq5/UbL3/+f4e5QEB06/5xs0ubSdlSQuDYt04RT1p
         ikyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=lx2tEtGfJT03jPtriJxyerULclZQ9l500DLB1HLb0vI=;
        b=mEzz4JJc6+7S0ofwflEAeAa78iuPKWI0T2sKkRTfVbk5r25UinQuArEz8qCCaTxsIg
         f3ap+TKB7QtGo0uzP2uZ+hHsoDjWxaSM6/nYe/nV2y1giXVs9tPk8sIKcaHVpAyrcgGe
         ApgcsZ2Om08HSYI2Oba5jeER/1jM+KZ95CnHMfqXrnBG6/HG8jRjZHhQUIoG0Qi1T78S
         eoUd1eKQ5WxK5797YUw8IypUWkIdvAp9IJwFwr6x+t4cqcyVz+2/Ip2bX6WZajMtRyG7
         qzbyzgpw1KJ7GwJ2alJw6LBBa2Bj3hLc4WVcdFTJlnwWqYZLKNj5Eo8go+Or835Df3Yd
         89DA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 129si18458229pfz.159.2019.04.04.12.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:23 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="140174118"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga007.fm.intel.com with ESMTP; 04 Apr 2019 12:21:23 -0700
Subject: [RFC PATCH 3/5] acpi/hmat: Track target address ranges
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Keith Busch <keith.busch@intel.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>, vishal.l.verma@intel.com,
 x86@kernel.org, linux-mm@kvack.org, keith.busch@intel.com,
 vishal.l.verma@intel.com, linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:44 -0700
Message-ID: <155440492414.3190322.12683374224345847860.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155440490809.3190322.15060922240602775809.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As of ACPI 6.3 the HMAT no longer advertises the physical memory address
range for its entries. Instead, the expectation is the corresponding
entry in the SRAT is looked up by the target proximity domain.

Given there may be multiple distinct address ranges that share the same
performance profile (sparse address space), find_mem_target() is updated
to also consider the start address of the memory range. Target property
updates are also adjusted to loop over all possible 'struct target'
instances that may share the same proximity domain identification.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/hmat/hmat.c |   77 ++++++++++++++++++++++++++++++++--------------
 1 file changed, 53 insertions(+), 24 deletions(-)

diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index b275016ff648..e7ae44c8d359 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -38,6 +38,7 @@ static struct memory_locality *localities_types[4];
 
 struct memory_target {
 	struct list_head node;
+	u64 start, size;
 	unsigned int memory_pxm;
 	unsigned int processor_pxm;
 	struct node_hmem_attrs hmem_attrs;
@@ -63,12 +64,13 @@ static __init struct memory_initiator *find_mem_initiator(unsigned int cpu_pxm)
 	return NULL;
 }
 
-static __init struct memory_target *find_mem_target(unsigned int mem_pxm)
+static __init struct memory_target *find_mem_target(unsigned int mem_pxm,
+		u64 start)
 {
 	struct memory_target *target;
 
 	list_for_each_entry(target, &targets, node)
-		if (target->memory_pxm == mem_pxm)
+		if (target->memory_pxm == mem_pxm && target->start == start)
 			return target;
 	return NULL;
 }
@@ -92,14 +94,15 @@ static __init void alloc_memory_initiator(unsigned int cpu_pxm)
 	list_add_tail(&initiator->node, &initiators);
 }
 
-static __init void alloc_memory_target(unsigned int mem_pxm)
+static __init void alloc_memory_target(unsigned int mem_pxm,
+		u64 start, u64 size)
 {
 	struct memory_target *target;
 
 	if (pxm_to_node(mem_pxm) == NUMA_NO_NODE)
 		return;
 
-	target = find_mem_target(mem_pxm);
+	target = find_mem_target(mem_pxm, start);
 	if (target)
 		return;
 
@@ -109,6 +112,8 @@ static __init void alloc_memory_target(unsigned int mem_pxm)
 
 	target->memory_pxm = mem_pxm;
 	target->processor_pxm = PXM_INVAL;
+	target->start = start;
+	target->size = size;
 	list_add_tail(&target->node, &targets);
 }
 
@@ -183,8 +188,8 @@ static __init u32 hmat_normalize(u16 entry, u64 base, u8 type)
 	return value;
 }
 
-static __init void hmat_update_target_access(struct memory_target *target,
-					     u8 type, u32 value)
+static __init void __hmat_update_target_access(struct memory_target *target,
+		u8 type, u32 value)
 {
 	switch (type) {
 	case ACPI_HMAT_ACCESS_LATENCY:
@@ -212,6 +217,20 @@ static __init void hmat_update_target_access(struct memory_target *target,
 	}
 }
 
+static __init void hmat_update_target_access(int memory_pxm, int processor_pxm,
+		u8 type, u32 value)
+{
+	struct memory_target *target;
+
+	list_for_each_entry(target, &targets, node) {
+		if (target->processor_pxm != processor_pxm)
+			continue;
+		if (target->memory_pxm != memory_pxm)
+			continue;
+		__hmat_update_target_access(target, type, value);
+	}
+}
+
 static __init void hmat_add_locality(struct acpi_hmat_locality *hmat_loc)
 {
 	struct memory_locality *loc;
@@ -255,7 +274,6 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				      const unsigned long end)
 {
 	struct acpi_hmat_locality *hmat_loc = (void *)header;
-	struct memory_target *target;
 	unsigned int init, targ, total_size, ipds, tpds;
 	u32 *inits, *targs, value;
 	u16 *entries;
@@ -296,11 +314,9 @@ static __init int hmat_parse_locality(union acpi_subtable_headers *header,
 				inits[init], targs[targ], value,
 				hmat_data_type_suffix(type));
 
-			if (mem_hier == ACPI_HMAT_MEMORY) {
-				target = find_mem_target(targs[targ]);
-				if (target && target->processor_pxm == inits[init])
-					hmat_update_target_access(target, type, value);
-			}
+			if (mem_hier == ACPI_HMAT_MEMORY)
+				hmat_update_target_access(targs[targ],
+						inits[init], type, value);
 		}
 	}
 
@@ -367,6 +383,7 @@ static int __init hmat_parse_proximity_domain(union acpi_subtable_headers *heade
 {
 	struct acpi_hmat_proximity_domain *p = (void *)header;
 	struct memory_target *target = NULL;
+	bool found = false;
 
 	if (p->header.length != sizeof(*p)) {
 		pr_notice("HMAT: Unexpected address range header length: %d\n",
@@ -382,23 +399,34 @@ static int __init hmat_parse_proximity_domain(union acpi_subtable_headers *heade
 		pr_info("HMAT: Memory Flags:%04x Processor Domain:%d Memory Domain:%d\n",
 			p->flags, p->processor_PD, p->memory_PD);
 
-	if (p->flags & ACPI_HMAT_MEMORY_PD_VALID) {
-		target = find_mem_target(p->memory_PD);
-		if (!target) {
-			pr_debug("HMAT: Memory Domain missing from SRAT\n");
-			return -EINVAL;
-		}
-	}
-	if (target && p->flags & ACPI_HMAT_PROCESSOR_PD_VALID) {
-		int p_node = pxm_to_node(p->processor_PD);
+	if ((p->flags & ACPI_HMAT_MEMORY_PD_VALID) == 0)
+		return 0;
+
+	list_for_each_entry(target, &targets, node) {
+		int p_node;
+
+		if (target->memory_pxm != p->memory_PD)
+			continue;
+		found = true;
 
+		if ((p->flags & ACPI_HMAT_PROCESSOR_PD_VALID) == 0)
+			continue;
+
+		p_node = pxm_to_node(p->processor_PD);
 		if (p_node == NUMA_NO_NODE) {
-			pr_debug("HMAT: Invalid Processor Domain\n");
+			pr_debug("HMAT: Invalid Processor Domain: %d\n",
+					p->processor_PD);
 			return -EINVAL;
 		}
+
 		target->processor_pxm = p_node;
 	}
 
+	if (!found) {
+		pr_debug("HMAT: Memory Domain missing from SRAT for pxm: %d\n",
+				p->memory_PD);
+		return -EINVAL;
+	}
 	return 0;
 }
 
@@ -431,7 +459,7 @@ static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
 		return -EINVAL;
 	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
 		return 0;
-	alloc_memory_target(ma->proximity_domain);
+	alloc_memory_target(ma->proximity_domain, ma->base_address, ma->length);
 	return 0;
 }
 
@@ -568,7 +596,8 @@ static __init void hmat_register_target_initiators(struct memory_target *target)
 				clear_bit(initiator->processor_pxm, p_nodes);
 		}
 		if (best)
-			hmat_update_target_access(target, loc->hmat_loc->data_type, best);
+			__hmat_update_target_access(target,
+					loc->hmat_loc->data_type, best);
 	}
 
 	for_each_set_bit(i, p_nodes, MAX_NUMNODES) {

