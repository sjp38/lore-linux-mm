Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C4652C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87B262075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87B262075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D87E6B026B; Thu,  4 Apr 2019 15:21:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389D06B026C; Thu,  4 Apr 2019 15:21:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2778A6B026D; Thu,  4 Apr 2019 15:21:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id E5FD56B026B
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:31 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y2so2365652pfl.16
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=8i4u1ApnkiA3xu2i//e05uMGEJN//RYP0N3yUrZNBY0=;
        b=CSoM21QMiIbLlEhYJbCzRNXT7NJ2BUWX73VBraVBi8pDwvP52vLWL2cZCYQRXL7sCX
         aa8gfEVzTFBGCyAI6o5McVWfp3wRo0VWA9oH0Q/OI6FZX0SrLJMbsJ1yczUkldMdPxA2
         KILtd2RXxjSPEXHKN8PE1PzMSKws1GTSOaDYUb3COZQIUuIXvX3t8ClKVbsVjeA3PY5L
         6XF5tA29uUvnkUN7/wi81DfRwxPGQ/FNZMul5XQncepANIQTNQWfRTz3+tL1kT40toN0
         FQfOsyqGIcOxKtnLavmOaeF5pjQqozD8B9h93gIP4hqZxzGlE+y2/WyIFxu48SuC/7z/
         oxVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXAsyO5sVp6GXwU88QOwI6n5AD9y3+sVPTmW1PXJDfnivk2x6O8
	b+2bsYyiQClNWFFB0vAYrZ1wkjeFAaHOCC37MEqNS/aSDQs8Y5D4QmPdCdrX//EGtwEPLUdqJkI
	EZeYO6S3UWfPctcsYqM127hlQvJZpg4FHSTiJRc/d0L7yyAZZtmMgz/vVHcI5dls5/A==
X-Received: by 2002:a65:6283:: with SMTP id f3mr7463990pgv.125.1554405691540;
        Thu, 04 Apr 2019 12:21:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAeR6zA2KauzwzW+CtEREzP1k8RuXQsBs00omvmYwLBzbeigBrH2Cg0vaMomkfgkcfn679
X-Received: by 2002:a65:6283:: with SMTP id f3mr7463904pgv.125.1554405690275;
        Thu, 04 Apr 2019 12:21:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405690; cv=none;
        d=google.com; s=arc-20160816;
        b=XNaNMYPN0cc15p3UnM1FEG2sprGLhWZS1SLo6vQIE2js0arNiRRUm+n0rmPl0yL2fN
         FQQ1KKyCPuo8EEi/Ic5uwTe0kJdx2jylMg2pE5w1suwXqrqaVR22BUwhPFHt3RvfU8rq
         3uQKTRa2uC47YrmC4ZbJ6TTatnVf6E1QzBCzMcM0sseD8rN7zFE3XivRinabDsoMcRUI
         kUWffgg6QYjsKUpKTQEzYvKnxPQbDdYn26NQqRlIqg7JHvfCdCu6MIXn4xapm8A2wIq7
         9OVKpdIEijt328anH1osHqIjSCySBg/r/wYdfe5bYYIi+rwHwCn4b40NhHKmeyKsjY8Y
         p5Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=8i4u1ApnkiA3xu2i//e05uMGEJN//RYP0N3yUrZNBY0=;
        b=y7fcIv7X4PjbqXlnuYD+mcju5WEUb8TXtS4f0fus3dGFdgYzS9uXkoX8Fh9zkupOju
         rM+nHTORU39yxFN9hfwYY4CICOe+ODTDZJvKXs2h7CcmSWxEIjK0p2wHCy6UjVG4KwLc
         87AFNfRsVW4m74S2fh3vwdwbLmcI1YP749QvfPFogdSGocFLZsRcpcsUwCksmf8ZtJ1S
         3YvbEXbPbqspkQGJrx8p6HWH7cA6VEYOGvxFE53CoiqG++FiqFZzYlEJmuYOC7kT9zl2
         FLXHphBWG8mnd6W6cP8kQ4dVh3+1BpOZ+AQMH5BVs539Xymy7jjVriLKtGsKoUK8mcbz
         IiYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id f5si4479618plo.13.2019.04.04.12.21.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:29 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="146656209"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by FMSMGA003.fm.intel.com with ESMTP; 04 Apr 2019 12:21:29 -0700
Subject: [RFC PATCH 4/5] acpi/hmat: Register special purpose memory as a
 device
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>,
 Keith Busch <keith.busch@intel.com>,
 Jonathan Cameron <Jonathan.Cameron@huawei.com>, vishal.l.verma@intel.com,
 x86@kernel.org, linux-mm@kvack.org, keith.busch@intel.com,
 vishal.l.verma@intel.com, linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:49 -0700
Message-ID: <155440492988.3190322.4475460421334178449.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Memory that has been tagged EFI_SPECIAL_PURPOSE, and has performance
properties described by the ACPI HMAT is expected to have an application
specific consumer.

Those consumers may want 100% of the memory capacity to be reserved from
any usage by the kernel. By default, with this enabling, a platform
device is created to represent this differentiated resource.

A follow on change arranges for device-dax to claim these devices by
default and provide an mmap interface for the target application.
However, if the administrator prefers that some or all of the special
purpose memory is made available to the core-mm the device-dax hotplug
facility can be used to online the memory with its own numa node.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <lenb@kernel.org>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/acpi/hmat/Kconfig |    1 +
 drivers/acpi/hmat/hmat.c  |   63 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/memregion.h |    3 ++
 3 files changed, 67 insertions(+)

diff --git a/drivers/acpi/hmat/Kconfig b/drivers/acpi/hmat/Kconfig
index 95a29964dbea..4fcf76e8aa1d 100644
--- a/drivers/acpi/hmat/Kconfig
+++ b/drivers/acpi/hmat/Kconfig
@@ -3,6 +3,7 @@ config ACPI_HMAT
 	bool "ACPI Heterogeneous Memory Attribute Table Support"
 	depends on ACPI_NUMA
 	select HMEM_REPORTING
+	select MEMREGION
 	help
 	 If set, this option has the kernel parse and report the
 	 platform's ACPI HMAT (Heterogeneous Memory Attributes Table),
diff --git a/drivers/acpi/hmat/hmat.c b/drivers/acpi/hmat/hmat.c
index e7ae44c8d359..482360004ea0 100644
--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -13,6 +13,9 @@
 #include <linux/device.h>
 #include <linux/init.h>
 #include <linux/list.h>
+#include <linux/mm.h>
+#include <linux/memregion.h>
+#include <linux/platform_device.h>
 #include <linux/list_sort.h>
 #include <linux/node.h>
 #include <linux/sysfs.h>
@@ -612,6 +615,65 @@ static __init void hmat_register_target_perf(struct memory_target *target)
 	node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
 }
 
+static __init void hmat_register_target_device(struct memory_target *target)
+{
+	struct memregion_info info;
+	struct resource res = {
+		.start = target->start,
+		.end = target->start + target->size - 1,
+		.flags = IORESOURCE_MEM,
+		.desc = IORES_DESC_APPLICATION_RESERVED,
+	};
+	struct platform_device *pdev;
+	int rc, id;
+
+	if (region_intersects(target->start, target->size, IORESOURCE_MEM,
+				IORES_DESC_APPLICATION_RESERVED)
+			!= REGION_INTERSECTS)
+		return;
+
+	id = memregion_alloc();
+	if (id < 0) {
+		pr_err("acpi/hmat: memregion allocation failure for %pr\n", &res);
+		return;
+	}
+
+	pdev = platform_device_alloc("hmem", id);
+	if (!pdev) {
+		pr_err("acpi/hmat: hmem device allocation failure for %pr\n", &res);
+		goto out_pdev;
+	}
+
+	pdev->dev.numa_node = acpi_map_pxm_to_online_node(target->processor_pxm);
+	info = (struct memregion_info) {
+		.target_node = acpi_map_pxm_to_node(target->memory_pxm),
+	};
+	rc = platform_device_add_data(pdev, &info, sizeof(info));
+	if (rc < 0) {
+		pr_err("acpi/hmat: hmem memregion_info allocation failure for %pr\n", &res);
+		goto out_pdev;
+	}
+
+	rc = platform_device_add_resources(pdev, &res, 1);
+	if (rc < 0) {
+		pr_err("acpi/hmat: hmem resource allocation failure for %pr\n", &res);
+		goto out_resource;
+	}
+
+	rc = platform_device_add(pdev);
+	if (rc < 0) {
+		dev_err(&pdev->dev, "acpi/hmat: device add failed for %pr\n", &res);
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
 static __init void hmat_register_targets(void)
 {
 	struct memory_target *target;
@@ -619,6 +681,7 @@ static __init void hmat_register_targets(void)
 	list_for_each_entry(target, &targets, node) {
 		hmat_register_target_initiators(target);
 		hmat_register_target_perf(target);
+		hmat_register_target_device(target);
 	}
 }
 
diff --git a/include/linux/memregion.h b/include/linux/memregion.h
index 99fa47793b49..5de2ac7fcf5e 100644
--- a/include/linux/memregion.h
+++ b/include/linux/memregion.h
@@ -1,6 +1,9 @@
 // SPDX-License-Identifier: GPL-2.0
 #ifndef _MEMREGION_H_
 #define _MEMREGION_H_
+struct memregion_info {
+	int target_node;
+};
 int memregion_alloc(void);
 void memregion_free(int id);
 #endif /* _MEMREGION_H_ */

