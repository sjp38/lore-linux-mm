Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2481C28CC3
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B73F126306
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 23:13:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B73F126306
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A0776B0285; Thu, 30 May 2019 19:13:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 651266B0286; Thu, 30 May 2019 19:13:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 53FE56B0287; Thu, 30 May 2019 19:13:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1CA196B0285
	for <linux-mm@kvack.org>; Thu, 30 May 2019 19:13:39 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b69so4912990plb.9
        for <linux-mm@kvack.org>; Thu, 30 May 2019 16:13:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:date:message-id:in-reply-to:references:user-agent
         :mime-version:content-transfer-encoding;
        bh=833GLhxPx8+W+AWCCBxBUiPBUhE9Sjsn7ePhU9KVSRs=;
        b=EqaN/RBbBSOwWD7LjoEDAXT6TdltKxpb/Hg3qxCdLeLNarXcBWjQ1jc01X9Tczkq38
         6h3rZYIXUkl1hQsOCuWqLtRJ/PjvHKXSRV6Zlse/VzMwAkSce2ZL5JtOzJAlqLcZJEC0
         aODaEvEWbwJVPKvEdsi2QzqAOx1n+XQcrpcdUhgZEugHCQ9I1yJbSE9kgi4LihEeUf3G
         d/ZfNufE1gIqPc8+DNO221Ca+JbuwpZmOcYauQB7ikIMPuxBD3/Hc4c4ZlHKBJ+9/DWG
         hY37rSxJ646/qzGMGkgswQ6kk/we89PYDjMGcFy+KKG26vL5FkBFs2ndEd55s59pjeOT
         eo2g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVgTOWIQQGEklkcC0dKDIAYmxncCRlUCU2NRmLjojh+Yv1EXPo8
	YaM0TZF2UP3glbjY9QzsjrPI9PQwud1uf5Kbt//6zHo+wzkzr13OA13mM97KPMLyJUyfvPR7Mpg
	LqwLsNTgo11klv6CP6QqKqMlMRD3NRzjwdb1HjFM/8+UCa/xFCONjcY9Vy7zuK0Rn6Q==
X-Received: by 2002:a17:902:a40b:: with SMTP id p11mr5989564plq.175.1559258018731;
        Thu, 30 May 2019 16:13:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxRiWY2UxVHru1ZT1HLLLr3ahv8PDcMRK6nHWiLZ2ND3MCW1McH5JI5AyapOhlOvJeRekJF
X-Received: by 2002:a17:902:a40b:: with SMTP id p11mr5989479plq.175.1559258017306;
        Thu, 30 May 2019 16:13:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559258017; cv=none;
        d=google.com; s=arc-20160816;
        b=UPfU3huljtdFau241pYcnCbX1dklqH+kHdSIdqYW3RSsxW1wFPHC/8EluzEbR8T8ak
         UYSR40x6cIWNKfq2uCamP3wDsN1bWb68Ky6Mn9LEnQGFcfV2BGaYmO/b3iY6AJiIwPOA
         RcnrQVv2lnB+NYXDLxaiU8uthL3nDtsH3NBJgNC4gEy/niGC11s1RBhNgV6kmGF+9XAB
         S/DyiCP8288GRXcAad0txhc36HhTG63AFFPpvdYN7duGwlBgE/Rh7GumBU5V3V66BAtc
         H9/15NN5L/bAdRQJl5V5w3CgdgL07csutaAxN/Z6255Zni4v/0o46+8qEHhw4kVomZnM
         HyPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject;
        bh=833GLhxPx8+W+AWCCBxBUiPBUhE9Sjsn7ePhU9KVSRs=;
        b=Z85GFPn2Al3Scq5yo6W/ZnytcmnM9XfsMVhf+HXzQvTZPUk2JYzkGlJpaM8Wn1pNju
         caESF0itaIIvgiOX6MYXSSONYysbxYqdA9ly3rIpbnW+7Bj2MIwYZFFswQXAE8927Ca5
         LfxXpzu+lIQW8GwQ15REk/7qTFg8npR++NKH141BZzdEvZuHdo7p2JQe/bEfbC6I8yRW
         LqMmGWRaihF23Q6K3llcuwmTb9d/Vgp24Mj3FhpQuF51tO5DG/Zt9bvepCXw9RVJ8zut
         HO95f44SWMc151qlyCT15CXZz/Gf0VZZLd9tPM0DMyF6ay6TPA3HcFPca3GNlFAOagMy
         +TOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id e6si752774pfn.273.2019.05.30.16.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 16:13:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 30 May 2019 16:13:36 -0700
X-ExtLoop1: 1
Received: from dwillia2-desk3.jf.intel.com (HELO dwillia2-desk3.amr.corp.intel.com) ([10.54.39.16])
  by orsmga007.jf.intel.com with ESMTP; 30 May 2019 16:13:36 -0700
Subject: [PATCH v2 5/8] lib/memregion: Uplevel the pmem "region" ida to a
 global allocator
From: Dan Williams <dan.j.williams@intel.com>
To: linux-efi@vger.kernel.org
Cc: Keith Busch <keith.busch@intel.com>, Matthew Wilcox <willy@infradead.org>,
 vishal.l.verma@intel.com, ard.biesheuvel@linaro.org, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org
Date: Thu, 30 May 2019 15:59:48 -0700
Message-ID: <155925718863.3775979.5027759142906684801.stgit@dwillia2-desk3.amr.corp.intel.com>
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

In preparation for handling platform differentiated memory types beyond
persistent memory, uplevel the "region" identifier to a global number
space. This enables a device-dax instance to be registered to any memory
type with guaranteed unique names.

Cc: Keith Busch <keith.busch@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/Kconfig       |    1 +
 drivers/nvdimm/core.c        |    1 -
 drivers/nvdimm/nd-core.h     |    1 -
 drivers/nvdimm/region_devs.c |   13 ++++---------
 include/linux/memregion.h    |    8 ++++++++
 lib/Kconfig                  |    7 +++++++
 lib/Makefile                 |    1 +
 lib/memregion.c              |   15 +++++++++++++++
 8 files changed, 36 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/memregion.h
 create mode 100644 lib/memregion.c

diff --git a/drivers/nvdimm/Kconfig b/drivers/nvdimm/Kconfig
index 54500798f23a..4b3e66fe61c1 100644
--- a/drivers/nvdimm/Kconfig
+++ b/drivers/nvdimm/Kconfig
@@ -4,6 +4,7 @@ menuconfig LIBNVDIMM
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
index b4ef7d9ff22e..9e070363ff70 100644
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
+	nd_region->id = memregion_alloc(GFP_KERNEL);
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
index 000000000000..ba03c70f98d2
--- /dev/null
+++ b/include/linux/memregion.h
@@ -0,0 +1,8 @@
+// SPDX-License-Identifier: GPL-2.0
+#ifndef _MEMREGION_H_
+#define _MEMREGION_H_
+#include <linux/types.h>
+
+int memregion_alloc(gfp_t gfp);
+void memregion_free(int id);
+#endif /* _MEMREGION_H_ */
diff --git a/lib/Kconfig b/lib/Kconfig
index 90623a0e1942..68621a0505a6 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -335,6 +335,13 @@ config DECOMPRESS_LZ4
 config GENERIC_ALLOCATOR
 	bool
 
+#
+# Memory Region ID allocation for persistent memory and "specific
+# purpose" / performance differentiated memory ranges.
+#
+config MEMREGION
+	bool
+
 #
 # reed solomon support is select'ed if needed
 #
diff --git a/lib/Makefile b/lib/Makefile
index fb7697031a79..58cf99f68f36 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -136,6 +136,7 @@ obj-$(CONFIG_LIBCRC32C)	+= libcrc32c.o
 obj-$(CONFIG_CRC8)	+= crc8.o
 obj-$(CONFIG_XXHASH)	+= xxhash.o
 obj-$(CONFIG_GENERIC_ALLOCATOR) += genalloc.o
+obj-$(CONFIG_MEMREGION) += memregion.o
 
 obj-$(CONFIG_842_COMPRESS) += 842/
 obj-$(CONFIG_842_DECOMPRESS) += 842/
diff --git a/lib/memregion.c b/lib/memregion.c
new file mode 100644
index 000000000000..f6c6a94c7921
--- /dev/null
+++ b/lib/memregion.c
@@ -0,0 +1,15 @@
+#include <linux/idr.h>
+
+static DEFINE_IDA(region_ids);
+
+int memregion_alloc(gfp_t gfp)
+{
+	return ida_alloc(&region_ids, gfp);
+}
+EXPORT_SYMBOL(memregion_alloc);
+
+void memregion_free(int id)
+{
+	ida_free(&region_ids, id);
+}
+EXPORT_SYMBOL(memregion_free);

