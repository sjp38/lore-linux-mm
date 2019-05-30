Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D936C28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 40CCC2630C
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 40CCC2630C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E69E46B0288; Thu, 30 May 2019 19:13:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4D26B0289; Thu, 30 May 2019 19:13:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C92BF6B028A; Thu, 30 May 2019 19:13:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 90A256B0288
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:54 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d19so4922452pls.1
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=XtiKYu/9Wz1HoJjONkoVJc8Zdc5PX4OKfafpmfTQaBQ=;
        b=UiFSNnSJKbPGECmpXCEvsEFqiaSQq1lprGRHtmAteQ0aNZG6pCDuZzMHYNuTowwiB0
         ExprK2U25MzqRMHh5/bvsjyyDLDT9xrGcmPYky8FT5YBQ1pNAAwWDp/zHTXbORsvBcI/
         D4g88dKzJeOH8tNTK00aEgnOu1SS4Q0RAi6iRyr8XTNiRIq5M5hJwp4f7twy6mN6bPNY
         o7bWhyBkSt19Prik/vPptTwlnadXH2tLQtRKKMo5GmpYcnqbXK0YNkzSZYrPvnW6cfcX
         dtYH06iyXrvaXGUUjzPDm8STPdtl4yIjyEWpngNeTmR9d6Tkxrs+k3PlSnihE9LH1M8F
         oL2w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVCJxv8Dh27ypP959zOZriaLJgT2yeNgOUXy1oCiyCEcljfCc2B
	dRr9sGzTSvDYnXcd5aydKaT2X5jz1dqFO91CHmjewXy64JBSZWEwqjqxRzwton3INe7gcEep7Iy
	qSvWlrAPRXId8/85+K1kCJoR6CYy9KNZvj0pP2w3dPK1/R9i+qr2zZMt8noDlePqY6Q==
X-Received: by 2002:a17:902:a708:: with SMTP id w8mr5665918plq.162.1559258034069;
        Thu, 30 May 2019 16:13:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLxj2CEONZ2Ar4zXiqSohC+NAU6tFCWJOmqkDX2LF5eWjCDc8si44EfCpF4iIFC1s9yE0U
X-Received: by 2002:a17:902:a708:: with SMTP id w8mr5665847plq.162.1559258032848;
        Thu, 30 May 2019 16:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258032; cv=none;
        d=google.com; s=arc-20160816;
        b=XoByC1Xeg19BV/sT+kZrUCAU/CSJNitZ+e8bkGnRybgCZU4CiWAb3tidq1jElCmGnb
         VvWEAP+WTjHBtIuMLHosCvfCzPtFUW3Sp3UHQ2zlfNU8qMvPbWxExGqxGBT+2c8307CJ
         z3v7Gf6isHwMAD+/lMeuSTs1t1nA7wf+W3ZLQOBnQHD8+YrpjxAXXbZ4ci7EmFRs0CC2
         l1jVvZD1Vs60lARTXJiZRP781zxmFn2fEcc2J8QNA4cKzMP5M6U97PrT3pDWGBeF7rXn
         Icwnq28hdy1joxUZXzHUqWMtB4lX6jIMmpvfBRMaiTCGS4vR73QaK+S3lFy1gtFh/o/H
         unog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=XtiKYu/9Wz1HoJjONkoVJc8Zdc5PX4OKfafpmfTQaBQ=;
        b=qMeo7gQAIEubn7w0+BD6s3aIRzMlJBscPEOYNkz55uEeooWTDVUMBGZQvQ3oG9a3Ew
         tKh/3EUw3uAM5x1CIC5vQobIpoEfwCqs5cRpVJVDeXGvhwoDSGThOvvAm4XdxN78JCWi
         wFMJVyc15HLES84n/oior2SIIkuXy/ffZzi4WxNsyrCHli/WuFj6ISie4kNb6nhUHKa2
         zEH9nA64Ro3rZpGHgNFoDqpw9ZVCBp5vD4IVcRn6SijxBZZrflYtqTIVEnbVwyF3/yy9
         d/1f6itGvqhxHEEuOIAT8t+tLLPjs2VLCUDJ68J52otUW7mJrso+6EaMAgrEgyRPAN2l
         uhfw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id y8si4057486plt.202.2019.05.30.16.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) client-ip=192.55.52.88;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.88 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga101.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:51 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 30 May 2019 16:13:51 -0700
Subject: [PATCH v2 8/8] acpi/hmat: Register "specific purpose" memory as an
 "hmem" device
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Len Brown <lenb@kernel.org>, Keith Busch <keith.busch@intel.com>,
 "Rafael J. Wysocki" <rjw@rjwysocki.net>,
 Vishal Verma <vishal.l.verma@intel.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>, ard.biesheuvel@linaro.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org,
 linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 16:00:04 -0700
Message-ID: <155925720396.3775979.9430953493521643811.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155925716254.3775979.16716824941364738117.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: StGit/0.18-2-gc94f
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Memory that has been tagged EFI_MEMORY_SP, and has performance
properties described by the ACPI HMAT is expected to have an application
specific consumer.

Those consumers may want 100% of the memory capacity to be reserved from
any usage by the kernel. By default, with this enabling, a platform
device is created to represent this differentiated resource.

The device-dax "hmem" driver claims these devices by default and
provides an mmap interface for the target application.  If the
administrator prefers, the hmem resource range can be made available to
the core-mm via the device-dax hotplug facility, kmem, to online the
memory with its own numa node.

This was tested with an emulated HMAT produced by qemu (with the pending
HMAT enabling patches), and "efi_fake_mem=8G@9G:0x40000" on the kernel
command line to mark the memory ranges associated with node2 and node3
as EFI_MEMORY_SP.

qemu numa configuration options:

-numa node,mem=4G,cpus=0-19,nodeid=0
-numa node,mem=4G,cpus=20-39,nodeid=1
-numa node,mem=4G,nodeid=2
-numa node,mem=4G,nodeid=3
-numa dist,src=0,dst=0,val=10
-numa dist,src=0,dst=1,val=21
-numa dist,src=0,dst=2,val=21
-numa dist,src=0,dst=3,val=21
-numa dist,src=1,dst=0,val=21
-numa dist,src=1,dst=1,val=10
-numa dist,src=1,dst=2,val=21
-numa dist,src=1,dst=3,val=21
-numa dist,src=2,dst=0,val=21
-numa dist,src=2,dst=1,val=21
-numa dist,src=2,dst=2,val=10
-numa dist,src=2,dst=3,val=21
-numa dist,src=3,dst=0,val=21
-numa dist,src=3,dst=1,val=21
-numa dist,src=3,dst=2,val=21
-numa dist,src=3,dst=3,val=10
-numa hmat-lb,initiator=0,target=0,hierarchy=memory,data-type=access-latency,base-lat=10,latency=5
-numa hmat-lb,initiator=0,target=0,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=5
-numa hmat-lb,initiator=0,target=1,hierarchy=memory,data-type=access-latency,base-lat=10,latency=10
-numa hmat-lb,initiator=0,target=1,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=10
-numa hmat-lb,initiator=0,target=2,hierarchy=memory,data-type=access-latency,base-lat=10,latency=15
-numa hmat-lb,initiator=0,target=2,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=15
-numa hmat-lb,initiator=0,target=3,hierarchy=memory,data-type=access-latency,base-lat=10,latency=20
-numa hmat-lb,initiator=0,target=3,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=20
-numa hmat-lb,initiator=1,target=0,hierarchy=memory,data-type=access-latency,base-lat=10,latency=10
-numa hmat-lb,initiator=1,target=0,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=10
-numa hmat-lb,initiator=1,target=1,hierarchy=memory,data-type=access-latency,base-lat=10,latency=5
-numa hmat-lb,initiator=1,target=1,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=5
-numa hmat-lb,initiator=1,target=2,hierarchy=memory,data-type=access-latency,base-lat=10,latency=15
-numa hmat-lb,initiator=1,target=2,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=15
-numa hmat-lb,initiator=1,target=3,hierarchy=memory,data-type=access-latency,base-lat=10,latency=20
-numa hmat-lb,initiator=1,target=3,hierarchy=memory,data-type=access-bandwidth,base-bw=20,bandwidth=20

Result:

# daxctl list -RDu
[
  {
    "path":"\/platform\/hmem.1",
    "id":1,
    "size":"4.00 GiB (4.29 GB)",
    "align":2097152,
    "devices":[
      {
        "chardev":"dax1.0",
        "size":"4.00 GiB (4.29 GB)"
      }
    ]
  },
  {
    "path":"\/platform\/hmem.0",
    "id":0,
    "size":"4.00 GiB (4.29 GB)",
    "align":2097152,
    "devices":[
      {
        "chardev":"dax0.0",
        "size":"4.00 GiB (4.29 GB)"
      }
    ]
  }
]

# cat /proc/iomem
[..]
240000000-43fffffff : Application Reserved
  240000000-33fffffff : hmem.0
    240000000-33fffffff : dax0.0
  340000000-43fffffff : hmem.1
    340000000-43fffffff : dax1.0

Cc: Len Brown <lenb@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/Kconfig |    1 
 drivers/acpi/hmat.c  |  133 ++++++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 123 insertions(+), 11 deletions(-)

diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
index ec8691e4152f..a4e67b7dcc9d 100644
--- a/drivers/acpi/Kconfig
+++ b/drivers/acpi/Kconfig
@@ -480,6 +480,7 @@ config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
 	select HMEM_REPORTING
+	select MEMREGION
 	help
 	 If set, this option has the kernel parse and report the
 	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
diff --git a/drivers/acpi/hmat.c b/drivers/acpi/hmat.c
index 1d329c4af3bf..5c714e6e5293 100644
--- a/drivers/acpi/hmat.c
+++ b/drivers/acpi/hmat.c
@@ -8,11 +8,17 @@
  * the applicable attributes with the node's interfaces.
  */
 
+#define pr_fmt(fmt) "acpi/hmat: " fmt
+#define dev_fmt(fmt) "acpi/hmat: " fmt
+
 #include <linux/acpi.h>
 #include <linux/bitops.h>
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/memregion.h>
+#include <linux/platform_device.h>
 #include <linux/list_sort.h>
 #include <linux/node.h>
 #include <linux/sysfs.h>
@@ -40,6 +46,7 @@ struct memory_target {
 	struct list_head node;
 	unsigned int memory_pxm;
 	unsigned int processor_pxm;
+	struct resource memregions;
 	struct node_hmem_attrs hmem_attrs;
 };
 
@@ -92,21 +99,35 @@ static __init void alloc_memory_initiator(unsigned int cpu_pxm)
 	list_add_tail(&initiator->node, &initiators);
 }
 
-static __init void alloc_memory_target(unsigned int mem_pxm)
+static __init void alloc_memory_target(unsigned int mem_pxm,
+		resource_size_t start, resource_size_t len)
 {
 	struct memory_target *target;
 
 	target = find_mem_target(mem_pxm);
-	if (target)
-		return;
-
-	target = kzalloc(sizeof(*target), GFP_KERNEL);
-	if (!target)
-		return;
+	if (!target) {
+		target = kzalloc(sizeof(*target), GFP_KERNEL);
+		if (!target)
+			return;
+		target->memory_pxm = mem_pxm;
+		target->processor_pxm = PXM_INVAL;
+		target->memregions = (struct resource) {
+			.name	= "ACPI mem",
+			.start	= 0,
+			.end	= -1,
+			.flags	= IORESOURCE_MEM,
+		};
+		list_add_tail(&target->node, &targets);
+	}
 
-	target->memory_pxm = mem_pxm;
-	target->processor_pxm = PXM_INVAL;
-	list_add_tail(&target->node, &targets);
+	/*
+	 * There are potentially multiple ranges per PXM, so record each
+	 * in the per-target memregions resource tree.
+	 */
+	if (!__request_region(&target->memregions, start, len, "memory target",
+				IORESOURCE_MEM))
+		pr_warn("failed to reserve %#llx - %#llx in pxm: %d\n",
+				start, start + len, mem_pxm);
 }
 
 static __init const char *hmat_data_type(u8 type)
@@ -428,7 +449,7 @@ static __init int srat_parse_mem_affinity(union acpi_subtable_headers *header,
 		return -EINVAL;
 	if (!(ma->flags & ACPI_SRAT_MEM_ENABLED))
 		return 0;
-	alloc_memory_target(ma->proximity_domain);
+	alloc_memory_target(ma->proximity_domain, ma->base_address, ma->length);
 	return 0;
 }
 
@@ -580,6 +601,81 @@ static __init void hmat_register_target_perf(struct memory_target *target)
 	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
 }
 
+static __init void hmat_register_target_device(struct memory_target *target,
+		struct resource *r)
+{
+	/* define a clean / non-busy resource for the platform device */
+	struct resource res = {
+		.start = r->start,
+		.end = r->end,
+		.flags = IORESOURCE_MEM,
+	};
+	struct platform_device *pdev;
+	struct memregion_info info;
+	int rc, id;
+
+	rc = region_intersects(res.start, resource_size(&res), IORESOURCE_MEM,
+			IORES_DESC_APPLICATION_RESERVED);
+	if (rc != REGION_INTERSECTS)
+		return;
+
+	id = memregion_alloc(GFP_KERNEL);
+	if (id < 0) {
+		pr_err("memregion allocation failure for %pr\n", &res);
+		return;
+	}
+
+	pdev = platform_device_alloc("hmem", id);
+	if (!pdev) {
+		pr_err("hmem device allocation failure for %pr\n", &res);
+		goto out_pdev;
+	}
+
+	pdev->dev.numa_node = acpi_map_pxm_to_online_node(target->memory_pxm);
+	info = (struct memregion_info) {
+		.target_node = acpi_map_pxm_to_node(target->memory_pxm),
+	};
+	rc = platform_device_add_data(pdev, &info, sizeof(info));
+	if (rc < 0) {
+		pr_err("hmem memregion_info allocation failure for %pr\n", &res);
+		goto out_pdev;
+	}
+
+	rc = platform_device_add_resources(pdev, &res, 1);
+	if (rc < 0) {
+		pr_err("hmem resource allocation failure for %pr\n", &res);
+		goto out_resource;
+	}
+
+	rc = platform_device_add(pdev);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "device add failed for %pr\n", &res);
+		goto out_resource;
+	}
+
+	return;
+
+out_resource:
+	put_device(&pdev->dev);
+out_pdev:
+	memregion_free(id);
+}
+
+static __init void hmat_register_target_devices(struct memory_target *target)
+{
+	struct resource *res;
+
+	/*
+	 * Do not bother creating devices if no driver is available to
+	 * consume them.
+	 */
+	if (!IS_ENABLED(CONFIG_DEV_DAX_HMEM))
+		return;
+
+	for (res = target->memregions.child; res; res = res->sibling)
+		hmat_register_target_device(target, res);
+}
+
 static __init void hmat_register_targets(void)
 {
 	struct memory_target *target;
@@ -587,6 +683,12 @@ static __init void hmat_register_targets(void)
 	list_for_each_entry(target, &targets, node) {
 		int nid = pxm_to_node(target->memory_pxm);
 
+		/*
+		 * Devices may belong to either an offline or online
+		 * node, so unconditionally add them.
+		 */
+		hmat_register_target_devices(target);
+
 		/*
 		 * Skip offline nodes. This can happen when memory
 		 * marked EFI_MEMORY_SP, "specific purpose", is applied
@@ -608,7 +710,16 @@ static __init void hmat_free_structures(void)
 	struct memory_initiator *initiator, *inext;
 
 	list_for_each_entry_safe(target, tnext, &targets, node) {
+		struct resource *res, *res_next;
+
 		list_del(&target->node);
+		res = target->memregions.child;
+		while (res) {
+			res_next = res->sibling;
+			__release_region(&target->memregions, res->start,
+					resource_size(res));
+			res = res_next;
+		}
 		kfree(target);
 	}
 

