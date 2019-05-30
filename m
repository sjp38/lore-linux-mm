Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91657C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 531E92630D
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 531E92630D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA5E66B0286; Thu, 30 May 2019 19:13:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D56346B0287; Thu, 30 May 2019 19:13:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1D9F6B0288; Thu, 30 May 2019 19:13:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D07C6B0286
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:43 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 21so3318020pgl.5
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=UCa3fSyiqlwrDpLod135rZpcU+wyxyzgxJdHWmkgxng=;
        b=lf6FcmxLmyWVdq6sdHyrKGaxtDgnLNT24eogjiUOKPJGorlSqQLAnm7UYb2FOQg1In
         fvRcnqH3Ie3GpP3mjSdpKyIHQb6oRXtQs5rguQtKmhXImvTGuXrQtU9IuhVS+a3GTP+N
         GvoMhFXuQ0evwRHwobIVNm99Pu8fLxj75FOLnC8s7j+5R+4g+zC/hAxDo0JAbcdvs6rW
         hVN5HvIEvXFGypNRsXxc4m1r/O/pD4dnmgMC4666N31B98j3EFtGtS+PGoIF7sMeBoST
         6ocvz2qZcN9Hn2tEuQ74n/GFNxoP3BDsY6BhwPa/gTJpT8kGyiZwcpoHeilO85RinTgp
         a5Uw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWTjpSTijweuI3A/1Z1R+oRKdQAfzoNEelEMyVT0mNpvQRlhR1p
	2rXQ1JSXe3a+2QcS7oRt5H44bKBPR9IxZpmW0Eytci9iEpHdRk41Nzbmc9f64L2khOd0lzjChqt
	GUgApSvB/wL69h0iKpi7CFfbK1Nkt7GjNhoZ6BvabI3GHcrgX4FVn8ihI7KNm2lJa4g==
X-Received: by 2002:a17:902:f215:: with SMTP id gn21mr6246305plb.194.1559258023164;
        Thu, 30 May 2019 16:13:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+xoFUlCiw0cER/jBFDvpJQWxiU79wl6+QaM74q5VWd7FLfPP3itiLG/0pZ6bwRsctWpiL
X-Received: by 2002:a17:902:f215:: with SMTP id gn21mr6246255plb.194.1559258022281;
        Thu, 30 May 2019 16:13:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258022; cv=none;
        d=google.com; s=arc-20160816;
        b=GgIB85WfKZsS0+Rwt4l0OivzKpbwZJEKPPFhWUvlSbr3ZmtYjY/VTpPOBjv6URwyjO
         YH1XYkJP+cKq9+U9U+Y0iLB0xHHWr7OnCaovvzsn6QnSCx6DRmWSF0kJqxQ2sB/Y9gC5
         KRAteOfqi1I9af3ix0rUiMObDPSUk4nZrI+p7Ctms+/4QxR1ZBQBy8Qi75AxKCjK3x+h
         zALkphYjGb9qLamPRMn0wEKBucCIYCN8B+ECi37+DZKS9JnScxuzMd1IeKTte0j4ZfSy
         vrniG31WLRDVSjWpvZaVBa9MuORxqWboX8Kve7zCv8EMgFRxPe3ZEN8otMlbgSzs38cf
         KaAw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=UCa3fSyiqlwrDpLod135rZpcU+wyxyzgxJdHWmkgxng=;
        b=j3uBzBpbtAVCDLej0htuRTe56L2NqcvSa6rQyDfJtFKP7D8UyksRPRkwZg0I5bMgcY
         +OISgsAjHBFVAuLlA1UG0Crg33SoeV+3uHTUh3UdCLt0QIMQiHffTEmtG8HmGzD8KqPR
         t2NfXAf7f6wdCVoUEoZGWFHUOE0ygvyIvJvrijjIFSj+axKgJB58H0XPQmUW8f8YxlBn
         yL6Pdq/74Fkw8ZZfVjI0+1YTsN9Ktg23py3D5amb18oF2cU1w0nPiTTfEbBecJ1rrJDq
         hUyR17rPSUPts8CNi9StkqIgMhSpuePWljOiM82kd8PN6StZSRWjQeWHP81oxDtCPidX
         avtQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id y12si4094562pgr.329.2019.05.30.16.13.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:41 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga005.jf.intel.com with ESMTP; 30 May 2019 16:13:41 -0700
Subject: [PATCH v2 6/8] device-dax: Add a driver for "hmem" devices
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Vishal Verma <vishal.l.verma@intel.com>,
 Keith Busch <keith.busch@intel.com>, Dave Jiang <dave.jiang@intel.com>,
 kbuild test robot <lkp@intel.com>, ard.biesheuvel@linaro.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org,
 linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:53 -0700
Message-ID: <155925719374.3775979.16707226817593415735.stgit@dwillia2-desk3.amr.corp.intel.com>
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

Platform firmware like EFI/ACPI may publish "hmem" platform devices.
Such a device is a performance differentiated memory range likely
reserved for an application specific use case. The driver gives access
to 100% of the capacity via a device-dax mmap instance by default.

However, if over-subscription and other kernel memory management is
desired the resulting dax device can be assigned to the core-mm via the
kmem driver.

This consumes "hmem" devices the producer of "hmem" devices is saved for
a follow-on patch so that it can reference the new CONFIG_DEV_DAX_HMEM
symbol to gate performing the enumeration work.

Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Reported-by: kbuild test robot <lkp@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dax/Kconfig       |   27 +++++++++++++++++----
 drivers/dax/Makefile      |    2 ++
 drivers/dax/hmem.c        |   58 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/memregion.h |    3 ++
 4 files changed, 85 insertions(+), 5 deletions(-)
 create mode 100644 drivers/dax/hmem.c

diff --git a/drivers/dax/Kconfig b/drivers/dax/Kconfig
index f33c73e4af41..9d653dfcd425 100644
--- a/drivers/dax/Kconfig
+++ b/drivers/dax/Kconfig
@@ -32,19 +32,36 @@ config DEV_DAX_PMEM
 
 	  Say M if unsure
 
+config DEV_DAX_HMEM
+	tristate "HMEM DAX: direct access to 'specific purpose' memory"
+	depends on EFI_SPECIFIC_DAX
+	default DEV_DAX
+	help
+	  EFI 2.8 platforms, and others, may advertise 'specific purpose'
+	  memory.  For example, a high bandwidth memory pool. The
+	  indication from platform firmware is meant to reserve the
+	  memory from typical usage by default.  This driver creates
+	  device-dax instances for these memory ranges, and that also
+	  enables the possibility to assign them to the DEV_DAX_KMEM
+	  driver to override the reservation and add them to kernel
+	  "System RAM" pool.
+
+	  Say M if unsure.
+
 config DEV_DAX_KMEM
 	tristate "KMEM DAX: volatile-use of persistent memory"
 	default DEV_DAX
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
index 000000000000..741f2c222271
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
+	struct dev_pagemap pgmap = { NULL };
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
diff --git a/include/linux/memregion.h b/include/linux/memregion.h
index ba03c70f98d2..920fb300a98b 100644
--- a/include/linux/memregion.h
+++ b/include/linux/memregion.h
@@ -3,6 +3,9 @@
 #define _MEMREGION_H_
 #include <linux/types.h>
 
+struct memregion_info {
+	int target_node;
+};
 int memregion_alloc(gfp_t gfp);
 void memregion_free(int id);
 #endif /* _MEMREGION_H_ */

