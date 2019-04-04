Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B97CEC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 781C02075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 781C02075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1DCC76B026C; Thu,  4 Apr 2019 15:21:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 18CFF6B026D; Thu,  4 Apr 2019 15:21:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 07DE66B026E; Thu,  4 Apr 2019 15:21:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6B9C6B026C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:36 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id f67so2383414pfh.9
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=TFnuqaXB2kmLiqax7B5YVialSPwNXuZ3lbiDMIwUJxU=;
        b=l0Db5CWT8RAlw6iS4sNdvDWC0c9naMLF4NyiVY/3FfZQAvhafgef9YsPtNzhZ3YywW
         JLlFr7G3S8oYWExb59/8YQyC3GcjUyCJO03qrETF9bxFLUJxVV3JvNpJi4zrZlkQOp7P
         tfnbJt3uz4m69Hk9LfXTPr033YKIHRdKkTZMmDbIZLG5f5PJ+4LI75cu25XH1tgKfef8
         eDMlX2oO9X7yXro/AYvVO1GQoIofL0TTH1NeFQij+6mG9pEzdvy/gtpD9wn3GDFchBfa
         OiZ+5aCbFefMtDG1avjgWyLEDwimQMyCA7g3WbgyZNmQAW2HzbxgFlMoqu1/HvkaVVT0
         ohVg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXWmiqIu1D/ZlJ2FbjBdP4LMbxm2qd+Ep3wObMcGmZzs1geGe5s
	pFi7W4gm+ruQQ37T6+n2z8eU/Oant7Mfo5WsOTzxvybC3+3yr4K+Ct/xSXkl4bUNJtY3TqWUdlH
	qoqWqVQWbGJAwfmHA82sRTR7LmdcXCcZk+332OEfDDGMP7FXAo1lKUiFUIjhIqFhzUg==
X-Received: by 2002:aa7:8d01:: with SMTP id j1mr7576775pfe.122.1554405696417;
        Thu, 04 Apr 2019 12:21:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnR06m68HkxVal79ok3sS6+cXSN1RzZ066xMejJ7js7juXNQDWEfJB24fwQ+9fV9qseo0s
X-Received: by 2002:aa7:8d01:: with SMTP id j1mr7576709pfe.122.1554405695560;
        Thu, 04 Apr 2019 12:21:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405695; cv=none;
        d=google.com; s=arc-20160816;
        b=HYxwQn+8KR41pkchVSDZDhhzOj0iucR8yn8tJCGopLqH9fXGMKkK1yoOHe05u2HAcA
         joF/huMrnCbgF1TYAqIfRPD682BCzudHr6Amnl0UcVbmOI3zfHxfcYcqCrsnvvYI7nGD
         +fPP6vfRQ2m3XZl04/461gawTvb1Il9jebfiRI/UJpTcI+VqvMp1HrPB9bUSnIEKVeXs
         MprGMhWniv8DBcsEhUJtVjjA1Rm6ViIJA0PEoO4prjZiJ54Ued1AWyHt90pDRNJiiiYL
         ikT+ZaP8S7Rc46OR4tIZxwx6BqalIh8LaUxt29n5vpRckHokdgyXYoFtlH9N8qqDcGBl
         +UQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=TFnuqaXB2kmLiqax7B5YVialSPwNXuZ3lbiDMIwUJxU=;
        b=UjZHDvispVyEmmXy9J+7x6q/GB+32u7Blm/2HYAfMTFSR73C7w17VjTdscHYPVdoBR
         lBnfa13PUO/VH66LGuE3gTvQwJ7+HOyD5DLY6YbbRAwFu9pftGO1c5EIFgRAMT+v++et
         jMMjBGZesF+z1wNbwm97mp2xXDj6Fu7G4wXC3f4tQ4bw6r7F1uUi4aIa93Wez/LGbNqO
         8P6YApaIvHeVeLyoxdGhPYhjkILH5Gc7EDSpqUJzVTOIbgwIamgq5hhQRh2Dxrde0BQ1
         UNh1OYmuWWlBaYzcdDi1Ql7OTmEL+S2YqgTSdmIVAyqNrrfRMSUYxKY2EoRqwn4W+w5U
         BY7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id u30si17890322pfl.23.2019.04.04.12.21.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:35 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="335059446"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga005.fm.intel.com with ESMTP; 04 Apr 2019 12:21:34 -0700
Subject: [RFC PATCH 5/5] device-dax: Add a driver for "hmem" devices
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Vishal Verma <vishal.l.verma@intel.com>,
 Keith Busch <keith.busch@intel.com>, Dave Jiang <dave.jiang@intel.com>,
 x86@kernel.org, linux-mm@kvack.org, keith.busch@intel.com,
 vishal.l.verma@intel.com, linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:55 -0700
Message-ID: <155440493544.3190322.10165040361847405101.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Platform firmware like EFI/ACPI may publish "hmem" platform devices.
Such a device is a performance differentiated memory range likely
reserved for an application specific use case. The driver gives access
to 100% of the capacity via a device-dax mmap instance by default.

However, if over-subscription and other kernel memory management is
desired the resulting dax device can be assigned to the core-mm via the
kmem driver.

Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/Kconfig  |   26 ++++++++++++++++++----
 drivers/dax/Makefile |    2 ++
 drivers/dax/hmem.c   |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 81 insertions(+), 5 deletions(-)
 create mode 100644 drivers/dax/hmem.c

diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index 5ef624fe3934..b3886f43dd77 100644
--- a/drivers/dax/Kconfig
+++ b/drivers/dax/Kconfig
@@ -38,16 +38,32 @@ config DEV_DAX_KMEM
 	depends on DEV_DAX
 	depends on MEMORY_HOTPLUG # for add_memory() and friends
 	help
-	  Support access to persistent memory as if it were RAM.  This
-	  allows easier use of persistent memory by unmodified
-	  applications.
+	  Support access to persistent, or other performance
+	  differentiated memory as if it were System RAM. This allows
+	  easier use of persistent memory by unmodified applications, or
+	  adds core kernel memory services to heterogeneous memory types
+	  (HMEM) marked "reserved" by platform firmware.
 
 	  To use this feature, a DAX device must be unbound from the
-	  device_dax driver (PMEM DAX) and bound to this kmem driver
-	  on each boot.
+	  device_dax driver and bound to this kmem driver on each boot.
 
 	  Say N if unsure.
 
+config DEV_DAX_HMEM
+	tristate "HMEM DAX: generic support for 'special purpose' memory"
+	default DEV_DAX
+	help
+	  EFI 2.8 platforms, and others, may advertise 'special purpose'
+	  memory.  For example, a high bandwidth memory pool. The
+	  indication from platform firmware is meant to reserve the
+	  memory from typical usage by default.  This driver creates
+	  device-dax instances for these memory ranges, and that also
+	  enables the possibility to assign them to the DEV_DAX_KMEM
+	  driver to override the reservation and add them to kernel
+	  "System RAM" pool.
+
+	  Say Y if unsure.
+
 config DEV_DAX_PMEM_COMPAT
 	tristate "PMEM DAX: support the deprecated /sys/class/dax interface"
 	depends on DEV_DAX_PMEM
diff --git a/drivers/dax/Makefile b/drivers/dax/Makefile
index 81f7d54dadfb..80065b38b3c4 100644
--- a/drivers/dax/Makefile
+++ b/drivers/dax/Makefile
@@ -2,9 +2,11 @@
 obj-$(CONFIG_DAX) += dax.o
 obj-$(CONFIG_DEV_DAX) += device_dax.o
 obj-$(CONFIG_DEV_DAX_KMEM) += kmem.o
+obj-$(CONFIG_DEV_DAX_HMEM) += dax_hmem.o
 
 dax-y := super.o
 dax-y += bus.o
 device_dax-y := device.o
+dax_hmem-y := hmem.o
 
 obj-y += pmem/
diff --git a/drivers/dax/hmem.c b/drivers/dax/hmem.c
new file mode 100644
index 000000000000..b01cf9c65329
--- /dev/null
+++ b/drivers/dax/hmem.c
@@ -0,0 +1,58 @@
+// SPDX-License-Identifier: GPL-2.0
+#include <linux/platform_device.h>
+#include <linux/memregion.h>
+#include <linux/memremap.h>
+#include <linux/module.h>
+#include <linux/pfn_t.h>
+#include "bus.h"
+
+static int dax_hmem_probe(struct platform_device *pdev)
+{
+	struct dev_pagemap pgmap = { 0 };
+	struct device *dev = &pdev->dev;
+	struct dax_region *dax_region;
+	struct memregion_info *mri;
+	struct dev_dax *dev_dax;
+	struct resource *res;
+
+	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!res)
+		return -ENOMEM;
+
+	mri = dev->platform_data;
+	pgmap.dev = dev;
+	memcpy(&pgmap.res, res, sizeof(*res));
+
+	dax_region = alloc_dax_region(dev, pdev->id, res, mri->target_node,
+			PMD_SIZE, PFN_DEV|PFN_MAP);
+	if (!dax_region)
+		return -ENOMEM;
+
+	dev_dax = devm_create_dev_dax(dax_region, 0, &pgmap);
+	if (IS_ERR(dev_dax))
+		return PTR_ERR(dev_dax);
+
+	/* child dev_dax instances now own the lifetime of the dax_region */
+	dax_region_put(dax_region);
+	return 0;
+}
+
+static int dax_hmem_remove(struct platform_device *pdev)
+{
+	/* devm handles teardown */
+	return 0;
+}
+
+static struct platform_driver dax_hmem_driver = {
+	.probe = dax_hmem_probe,
+	.remove = dax_hmem_remove,
+	.driver = {
+		.name = "hmem",
+	},
+};
+
+module_platform_driver(dax_hmem_driver);
+
+MODULE_ALIAS("platform:hmem*");
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Intel Corporation");

