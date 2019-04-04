Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75E9DC10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 286302075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:21:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 286302075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDE9F6B0269; Thu,  4 Apr 2019 15:21:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB12E6B026A; Thu,  4 Apr 2019 15:21:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B797D6B026B; Thu,  4 Apr 2019 15:21:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 813526B0269
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:21:20 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id s22so2381476plq.1
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:21:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=ectYJ+6tKGgJCqQL9gegx+RSdwPdyypVroqHFoHFu3U=;
        b=bCARDoL7bTDsXbX0Vc8ChXxNViW4/yxDA9UPdT9/rJLJyb5S4FM8R7DVstnELYkwk+
         5O5QUcPWfYWbgbgRtOd85R+N/ouleB8UCryiii72CYjsII3WIOlkNKZWA1ThpOKqX88T
         mc4OxAS7wAPkIn9MqXBh0YxRs4SCHwIRbmOdQStBOU981okmnMYH5ZePi6Io3Tnl6o0Z
         7XZMrAXdXwVdQfqfzRd9pTAF20riwKJNoxIc9JQyJB8HG2EKYqBNsFvFPeLf4pIhuIpT
         9OS/Vd1UYcx7xaF5kD5LJwDclZ7mYwPtKhRaRlJFGg5cVekAVk952SKMs+vqW1Sz2UdH
         M+oQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWJFebN93+xP00/cDpjvRViMw2zE8wsZSIrPqHJKhW+Cy5bKKnf
	1wkHAJtV70qFpqIN/GQhspO/VA9siVbiYZP589rIWEre72RCXTXfx9/tLKEtkaOH8OWfuChovNk
	aUx/S60mtEKVopOvP5eUEWcYpSN5ZguskWKM5t6tcnZ0Ww80jiLSZSZzoPs98AiK/EA==
X-Received: by 2002:a65:5a81:: with SMTP id c1mr7639115pgt.391.1554405680112;
        Thu, 04 Apr 2019 12:21:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqRk4HZuamdhZePCIuyFISoPmPMUVE7yUSM+B6yq4bbmz/h79P4XalwO5PiIEqJ/wId0Hb
X-Received: by 2002:a65:5a81:: with SMTP id c1mr7638998pgt.391.1554405678652;
        Thu, 04 Apr 2019 12:21:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405678; cv=none;
        d=google.com; s=arc-20160816;
        b=Yg6ZOioXNw55EgGnIJq4yfLupJS930T5iptjhZuXVEnaH4MaZNN6JM0M2TYaymazla
         Seva/eNGy82QZS0W0Vp/wZykaApnkvaunSEkppkrtKl/aKmEUHWIi495o/exp4zru1Jj
         EUYZSdvN1TwZuxL8Y3YXMsE+9EHWO8mi4hgIh4bZFBdiKF1572MTSy8C+73sLR9nP2ab
         FP/git4VP/ZJBYcg3bj2lnZkms8T9Q78Vfe1I60V8YdaaGPoTZkkXhUoAoR+xtLe/RTt
         46H7cZgbsf/v3dKUvF5vKT0YOmBbFFgHujP7gtxBrcrVWE7D/b69na+/GVwQPx3U8WXR
         Nxgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=ectYJ+6tKGgJCqQL9gegx+RSdwPdyypVroqHFoHFu3U=;
        b=Fjm1ZyIwGT4Bw58i6LS7YplHwq7FHz3FRNuaNF+2llaZLFNyWxlna59TbKZwk/l858
         7bi7qPcHdIkR2wSEWJqY/siAUcfdvn627g6hyAKkE6I5NG/aGT5erOMwd+JAeQ7MyXAB
         9IBM0+cJBk+ia0G++TtJHk02hYCpyPCjS04SsrOvXBSOGNdjwYnyyNtEac6vqnPUZsZb
         fR6+hV60X6Y9r6u5YEb4aNeXPEFjRlrjRKF1bZdPXLjt6rXT7Ag3SOF4xFu8DZ7MhEd4
         f7hbw8Y+xO4YYNCck32sdEVGpW+EDRszWzsCQa/Jb5aqpcIKHOs7FPEV3aSJgVfn4JbD
         PZwg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id e17si16187010pgo.44.2019.04.04.12.21.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:21:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 04 Apr 2019 12:21:18 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,309,1549958400"; 
   d="scan'208";a="137653465"
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by fmsmga008.fm.intel.com with ESMTP; 04 Apr 2019 12:21:18 -0700
Subject: [RFC PATCH 2/5] lib/memregion: Uplevel the pmem "region" ida to a
 global allocator
From: Dan Williams <dan.j.williams@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, vishal.l.verma@intel.com,
 x86@kernel.org, linux-mm@kvack.org, keith.busch@intel.com,
 vishal.l.verma@intel.com, linux-nvdimm@lists.01.org
Date: Thu, 04 Apr 2019 12:08:38 -0700
Message-ID: <155440491849.3190322.17551464505265122881.stgit@dwillia2-desk3.amr.corp.intel.com>
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

In preparation for handling platform differentiated memory types beyond
persistent memory, uplevel the "region" identifier to a global number
space. This enables a device-dax instance to be registered to any memory
type with guaranteed unique names.

Cc: Keith Busch <keith.busch@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/Kconfig       |    1 +
 drivers/nvdimm/core.c        |    1 -
 drivers/nvdimm/nd-core.h     |    1 -
 drivers/nvdimm/region_devs.c |   13 ++++---------
 include/linux/memregion.h    |    6 ++++++
 lib/Kconfig                  |    6 ++++++
 lib/Makefile                 |    1 +
 lib/memregion.c              |   22 ++++++++++++++++++++++
 8 files changed, 40 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/memregion.h
 create mode 100644 lib/memregion.c

diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
index 5e27918e4624..bf26cc5f6d67 100644
--- a/drivers/nvdimm/Kconfig
+++ b/drivers/nvdimm/Kconfig
@@ -3,6 +3,7 @@ menuconfig LIBNVDIMM
 	depends on PHYS_ADDR_T_64BIT
 	depends on HAS_IOMEM
 	depends on BLK_DEV
+	select MEMREGION
 	help
 	  Generic support for non-volatile memory devices including
 	  ACPI-6-NFIT defined resources.  On platforms that define an
diff --git a/drivers/nvdimm/core.c b/drivers/nvdimm/core.c
index acce050856a8..75fe651d327d 100644
--- a/drivers/nvdimm/core.c
+++ b/drivers/nvdimm/core.c
@@ -463,7 +463,6 @@ static __exit void libnvdimm_exit(void)
 	nd_region_exit();
 	nvdimm_exit();
 	nvdimm_bus_exit();
-	nd_region_devs_exit();
 	nvdimm_devs_exit();
 }
 
diff --git a/drivers/nvdimm/nd-core.h b/drivers/nvdimm/nd-core.h
index e5ffd5733540..17561302dfec 100644
--- a/drivers/nvdimm/nd-core.h
+++ b/drivers/nvdimm/nd-core.h
@@ -133,7 +133,6 @@ struct nvdimm_bus *walk_to_nvdimm_bus(struct device *nd_dev);
 int __init nvdimm_bus_init(void);
 void nvdimm_bus_exit(void);
 void nvdimm_devs_exit(void);
-void nd_region_devs_exit(void);
 void nd_region_probe_success(struct nvdimm_bus *nvdimm_bus, struct device *dev);
 struct nd_region;
 void nd_region_create_ns_seed(struct nd_region *nd_region);
diff --git a/drivers/nvdimm/region_devs.c b/drivers/nvdimm/region_devs.c
index b4ef7d9ff22e..eefdfd2565dd 100644
--- a/drivers/nvdimm/region_devs.c
+++ b/drivers/nvdimm/region_devs.c
@@ -11,6 +11,7 @@
  * General Public License for more details.
  */
 #include <linux/scatterlist.h>
+#include <linux/memregion.h>
 #include <linux/highmem.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -27,7 +28,6 @@
  */
 #include <linux/io-64-nonatomic-hi-lo.h>
 
-static DEFINE_IDA(region_ida);
 static DEFINE_PER_CPU(int, flush_idx);
 
 static int nvdimm_map_flush(struct device *dev, struct nvdimm *nvdimm, int dimm,
@@ -141,7 +141,7 @@ static void nd_region_release(struct device *dev)
 		put_device(&nvdimm->dev);
 	}
 	free_percpu(nd_region->lane);
-	ida_simple_remove(&region_ida, nd_region->id);
+	memregion_free(nd_region->id);
 	if (is_nd_blk(dev))
 		kfree(to_nd_blk_region(dev));
 	else
@@ -1036,7 +1036,7 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 
 	if (!region_buf)
 		return NULL;
-	nd_region->id = ida_simple_get(&region_ida, 0, 0, GFP_KERNEL);
+	nd_region->id = memregion_alloc();
 	if (nd_region->id < 0)
 		goto err_id;
 
@@ -1090,7 +1090,7 @@ static struct nd_region *nd_region_create(struct nvdimm_bus *nvdimm_bus,
 	return nd_region;
 
  err_percpu:
-	ida_simple_remove(&region_ida, nd_region->id);
+	memregion_free(nd_region->id);
  err_id:
 	kfree(region_buf);
 	return NULL;
@@ -1237,8 +1237,3 @@ int nd_region_conflict(struct nd_region *nd_region, resource_size_t start,
 
 	return device_for_each_child(&nvdimm_bus->dev, &ctx, region_conflict);
 }
-
-void __exit nd_region_devs_exit(void)
-{
-	ida_destroy(&region_ida);
-}
diff --git a/include/linux/memregion.h b/include/linux/memregion.h
new file mode 100644
index 000000000000..99fa47793b49
--- /dev/null
+++ b/include/linux/memregion.h
@@ -0,0 +1,6 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _MEMREGION_H_
+#define _MEMREGION_H_
+int memregion_alloc(void);
+void memregion_free(int id);
+#endif /* _MEMREGION_H_ */
diff --git a/lib/Kconfig b/lib/Kconfig
index a9e56539bd11..0b765d9a1145 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -318,6 +318,12 @@ config DECOMPRESS_LZ4
 config GENERIC_ALLOCATOR
 	bool
 
+#
+# Generic IDA for memory regions
+#
+config MEMREGION
+	bool
+
 #
 # reed solomon support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index 3b08673e8881..6e237c4071af 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -122,6 +122,7 @@ obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_CRC8)	+= crc8.o
 obj-$(CONFIG_XXHASH)	+= xxhash.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
+obj-$(CONFIG_MEMREGION) += memregion.o
 
 obj-$(CONFIG_842_COMPRESS) += 842/
 obj-$(CONFIG_842_DECOMPRESS) += 842/
diff --git a/lib/memregion.c b/lib/memregion.c
new file mode 100644
index 000000000000..21f5ff96c2eb
--- /dev/null
+++ b/lib/memregion.c
@@ -0,0 +1,22 @@
+#include <linux/idr.h>
+#include <linux/module.h>
+
+static DEFINE_IDA(region_ida);
+
+int memregion_alloc(void)
+{
+	return ida_simple_get(&region_ida, 0, 0, GFP_KERNEL);
+}
+EXPORT_SYMBOL(memregion_alloc);
+
+void memregion_free(int id)
+{
+	ida_simple_remove(&region_ida, id);
+}
+EXPORT_SYMBOL(memregion_free);
+
+static void __exit memregion_exit(void)
+{
+	ida_destroy(&region_ida);
+}
+module_exit(memregion_exit);

