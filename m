Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id E0C2B6B027D
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 13:11:34 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d22-v6so7330095pls.4
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 10:11:34 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m14-v6si6351177pgc.368.2018.07.16.10.11.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 10:11:33 -0700 (PDT)
Subject: [PATCH v2 14/14] libnvdimm,
 namespace: Publish page structure init state / control
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 16 Jul 2018 10:01:35 -0700
Message-ID: <153176049568.12695.7468849534191505277.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <153176041838.12695.3365448145295112857.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Vishal Verma <vishal.l.verma@intel.com>, Dave Jiang <dave.jiang@intel.com>, Johannes Thumshirn <jthumshirn@suse.de>, Jeff Moyer <jmoyer@redhat.com>, hch@lst.de, linux-mm@kvack.org, jack@suse.cz, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org

Applications may want to know that page structure initialization is
complete rather than be subject to delays at first DAX fault. Also,
page structure initialization consumes CPU resources impacting
application performance, so a environment may want to wait before
considering the system fully initialized.

Provide a sysfs attribute to display the current state, and when
written with 'sync' complete memmap initialization.

Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: Dave Jiang <dave.jiang@intel.com>
Cc: Johannes Thumshirn <jthumshirn@suse.de>
Cc: Jeff Moyer <jmoyer@redhat.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/nvdimm/pfn_devs.c |   49 ++++++++++++++++++++++++++++++++++-----------
 mm/page_alloc.c           |    1 +
 2 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/drivers/nvdimm/pfn_devs.c b/drivers/nvdimm/pfn_devs.c
index 147c62e2ef2b..15ab96e2a9b5 100644
--- a/drivers/nvdimm/pfn_devs.c
+++ b/drivers/nvdimm/pfn_devs.c
@@ -1,15 +1,6 @@
-/*
- * Copyright(c) 2013-2016 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of version 2 of the GNU General Public License as
- * published by the Free Software Foundation.
- *
- * This program is distributed in the hope that it will be useful, but
- * WITHOUT ANY WARRANTY; without even the implied warranty of
- * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
- * General Public License for more details.
- */
+/* SPDX-License-Identifier: GPL-2.0 */
+/* Copyright(c) 2013-2018 Intel Corporation. All rights reserved. */
+#include <linux/memory_hotplug.h>
 #include <linux/memremap.h>
 #include <linux/blkdev.h>
 #include <linux/device.h>
@@ -103,6 +94,39 @@ static ssize_t mode_store(struct device *dev,
 }
 static DEVICE_ATTR_RW(mode);
 
+static ssize_t memmap_state_show(struct device *dev,
+		struct device_attribute *attr, char *buf)
+{
+	struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
+	struct memmap_async_state *async = &nd_pfn->async;
+
+	return sprintf(buf, "%s\n", bitmap_weight(async->active,
+				NR_MEMMAP_THREADS) ? "active" : "idle");
+}
+
+static ssize_t memmap_state_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t len)
+{
+	int i;
+	struct nd_pfn *nd_pfn = to_nd_pfn_safe(dev);
+	struct memmap_async_state *async = &nd_pfn->async;
+
+	if (!sysfs_streq(buf, "sync"))
+		return -EINVAL;
+
+	for (i = 0; i < NR_MEMMAP_THREADS; i++) {
+		struct memmap_init_pages *thread = &async->page_init[i];
+
+		if (!test_bit(i, async->active))
+			continue;
+		async_synchronize_cookie_domain(thread->cookie,
+				&memmap_pages_domain);
+	}
+
+	return len;
+}
+static DEVICE_ATTR_RW(memmap_state);
+
 static ssize_t align_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -279,6 +303,7 @@ static struct attribute *nd_pfn_attributes[] = {
 	&dev_attr_resource.attr,
 	&dev_attr_size.attr,
 	&dev_attr_supported_alignments.attr,
+	&dev_attr_memmap_state.attr,
 	NULL,
 };
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b9615a59d29d..2c87165594db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5457,6 +5457,7 @@ void __ref build_all_zonelists(pg_data_t *pgdat)
 
 ASYNC_DOMAIN_EXCLUSIVE(memmap_init_domain);
 ASYNC_DOMAIN_EXCLUSIVE(memmap_pages_domain);
+EXPORT_SYMBOL_GPL(memmap_pages_domain);
 
 static void __meminit memmap_init_one(unsigned long pfn, unsigned long zone,
 		int nid, enum memmap_context context, struct dev_pagemap *pgmap)
