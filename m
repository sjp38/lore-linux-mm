Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB9CF6B6BAD
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:35:56 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z68so14924891qkb.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:35:56 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u27si7805757qtb.176.2018.12.03.15.35.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:35:56 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 04/14] mm/hms: add initiator to heterogeneous memory system infrastructure
Date: Mon,  3 Dec 2018 18:34:59 -0500
Message-Id: <20181203233509.20671-5-jglisse@redhat.com>
In-Reply-To: <20181203233509.20671-1-jglisse@redhat.com>
References: <20181203233509.20671-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, "Rafael J . Wysocki" <rafael@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>, Dave Hansen <dave.hansen@intel.com>, Haggai Eran <haggaie@mellanox.com>, Balbir Singh <balbirs@au1.ibm.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Felix Kuehling <felix.kuehling@amd.com>, Philip Yang <Philip.Yang@amd.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, Paul Blinzer <Paul.Blinzer@amd.com>, Logan Gunthorpe <logang@deltatee.com>, John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, Michal Hocko <mhocko@kernel.org>, Jonathan Cameron <jonathan.cameron@huawei.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Vivek Kini <vkini@nvidia.com>, Mel Gorman <mgorman@techsingularity.net>, Dave Airlie <airlied@redhat.com>, Ben Skeggs <bskeggs@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

From: Jérôme Glisse <jglisse@redhat.com>

An initiator is anything that can initiate memory access, either a CPU
or a device. Here CPUs and devices are treated as equals.

See HMS Documentation/vm/hms.txt for further detail..

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Rafael J. Wysocki <rafael@kernel.org>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Haggai Eran <haggaie@mellanox.com>
Cc: Balbir Singh <balbirs@au1.ibm.com>
Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Felix Kuehling <felix.kuehling@amd.com>
Cc: Philip Yang <Philip.Yang@amd.com>
Cc: Christian König <christian.koenig@amd.com>
Cc: Paul Blinzer <Paul.Blinzer@amd.com>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Jonathan Cameron <jonathan.cameron@huawei.com>
Cc: Mark Hairgrove <mhairgrove@nvidia.com>
Cc: Vivek Kini <vkini@nvidia.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Ben Skeggs <bskeggs@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
---
 drivers/base/Makefile        |   2 +-
 drivers/base/hms-initiator.c | 141 +++++++++++++++++++++++++++++++++++
 include/linux/hms.h          |  15 ++++
 3 files changed, 157 insertions(+), 1 deletion(-)
 create mode 100644 drivers/base/hms-initiator.c

diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 8e8092145f18..6a1b5ab667bd 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -12,7 +12,7 @@ obj-y			+= power/
 obj-$(CONFIG_ISA_BUS_API)	+= isa.o
 obj-y				+= firmware_loader/
 obj-$(CONFIG_NUMA)	+= node.o
-obj-$(CONFIG_HMS)	+= hms.o hms-target.o
+obj-$(CONFIG_HMS)	+= hms.o hms-target.o hms-initiator.o
 obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
 ifeq ($(CONFIG_SYSFS),y)
 obj-$(CONFIG_MODULES)	+= module.o
diff --git a/drivers/base/hms-initiator.c b/drivers/base/hms-initiator.c
new file mode 100644
index 000000000000..08aa519427d6
--- /dev/null
+++ b/drivers/base/hms-initiator.c
@@ -0,0 +1,141 @@
+/*
+ * Copyright 2018 Red Hat Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * Authors:
+ * Jérôme Glisse <jglisse@redhat.com>
+ */
+/* Heterogeneous memory system (HMS) see Documentation/vm/hms.rst */
+#include <linux/capability.h>
+#include <linux/topology.h>
+#include <linux/uaccess.h>
+#include <linux/device.h>
+#include <linux/module.h>
+#include <linux/mutex.h>
+#include <linux/slab.h>
+#include <linux/init.h>
+#include <linux/hms.h>
+
+
+static inline struct hms_initiator *hms_object_to_initiator(struct hms_object *object)
+{
+	if (object == NULL)
+		return NULL;
+
+	if (object->type != HMS_INITIATOR)
+		return NULL;
+	return container_of(object, struct hms_initiator, object);
+}
+
+static inline struct hms_initiator *device_to_hms_initiator(struct device *device)
+{
+	if (device == NULL)
+		return NULL;
+
+	return hms_object_to_initiator(to_hms_object(device));
+}
+
+struct hms_initiator *hms_initiator_find_locked(unsigned uid)
+{
+	struct hms_object *object = hms_object_find_locked(uid);
+	struct hms_initiator *initiator;
+
+	initiator = hms_object_to_initiator(object);
+	if (initiator)
+		return initiator;
+	hms_object_put(object);
+	return NULL;
+}
+
+struct hms_initiator *hms_initiator_find(unsigned uid)
+{
+	struct hms_object *object = hms_object_find(uid);
+	struct hms_initiator *initiator;
+
+	initiator = hms_object_to_initiator(object);
+	if (initiator)
+		return initiator;
+	hms_object_put(object);
+	return NULL;
+}
+
+static void hms_initiator_release(struct device *device)
+{
+	struct hms_initiator *initiator = device_to_hms_initiator(device);
+
+	hms_object_release(&initiator->object);
+	kfree(initiator);
+}
+
+static ssize_t hms_initiator_show_uid(struct device *device,
+				      struct device_attribute *attr,
+				      char *buf)
+{
+	struct hms_initiator *initiator = device_to_hms_initiator(device);
+
+	if (initiator == NULL)
+		return -EINVAL;
+
+	return sprintf(buf, "%d\n", initiator->object.uid);
+}
+
+static DEVICE_ATTR(uid, 0444, hms_initiator_show_uid, NULL);
+
+static struct attribute *hms_initiator_attrs[] = {
+	&dev_attr_uid.attr,
+	NULL
+};
+
+static struct attribute_group hms_initiator_attr_group = {
+	.attrs = hms_initiator_attrs,
+};
+
+static const struct attribute_group *hms_initiator_attr_groups[] = {
+	&hms_initiator_attr_group,
+	NULL,
+};
+
+void hms_initiator_register(struct hms_initiator **initiatorp,
+			    struct device *parent, int nid,
+			    unsigned version)
+{
+	struct hms_initiator *initiator;
+
+	*initiatorp = NULL;
+	initiator = kzalloc(sizeof(*initiator), GFP_KERNEL);
+	if (initiator == NULL)
+		return;
+
+	initiator->nid = nid;
+
+	if (hms_object_init(&initiator->object, parent, HMS_INITIATOR, version,
+			    hms_initiator_release, hms_initiator_attr_groups))
+	{
+		kfree(initiator);
+		initiator = NULL;
+	}
+
+	*initiatorp = initiator;
+}
+EXPORT_SYMBOL(hms_initiator_register);
+
+void hms_initiator_unregister(struct hms_initiator **initiatorp)
+{
+	struct hms_initiator *initiator = *initiatorp;
+
+	*initiatorp = NULL;
+	if (initiator == NULL)
+		return;
+
+	hms_object_unregister(&initiator->object);
+}
+EXPORT_SYMBOL(hms_initiator_unregister);
diff --git a/include/linux/hms.h b/include/linux/hms.h
index 0568fdf6d479..7a2823493f63 100644
--- a/include/linux/hms.h
+++ b/include/linux/hms.h
@@ -67,6 +67,17 @@ struct hms_object *hms_object_find_locked(unsigned uid);
 struct hms_object *hms_object_find(unsigned uid);
 
 
+struct hms_initiator {
+	struct hms_object object;
+	int nid;
+};
+
+void hms_initiator_register(struct hms_initiator **initiatorp,
+			    struct device *parent, int nid,
+			    unsigned version);
+void hms_initiator_unregister(struct hms_initiator **initiatorp);
+
+
 struct hms_target {
 	const struct hms_target_hbind *hbind;
 	struct hms_object object;
@@ -95,6 +106,10 @@ int hms_init(void);
 #else /* IS_ENABLED(CONFIG_HMS) */
 
 
+#define hms_initiator_register(initiatorp)
+#define hms_initiator_unregister(initiatorp)
+
+
 #define hms_target_add_memory(target, size)
 #define hms_target_remove_memory(target, size)
 #define hms_target_register(targetp, nid, size)
-- 
2.17.2
