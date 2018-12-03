Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 35A186B6BB0
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:04 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id y83so14733007qka.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u11si101004qvl.90.2018.12.03.15.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:03 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 06/14] mm/hms: add bridge to heterogeneous memory system infrastructure
Date: Mon,  3 Dec 2018 18:35:01 -0500
Message-Id: <20181203233509.20671-7-jglisse@redhat.com>
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

A bridge connect two links with each others and apply only to listed
initiators. With links, this allows to describe any kind of system
topology ie any kind of directed graph.

Moreover with bridges the userspace can choose to use different bridges
to load balance bandwidth usage accross multiple paths between targets
memory and initiators. Note that explicit path selection is not always
under the control of user space, some system might do load balancing
in hardware.

See HMS Documentation/vm/hms.txt for detail.

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
 drivers/base/Makefile     |   2 +-
 drivers/base/hms-bridge.c | 197 ++++++++++++++++++++++++++++++++++++++
 include/linux/hms.h       |  24 +++++
 3 files changed, 222 insertions(+), 1 deletion(-)
 create mode 100644 drivers/base/hms-bridge.c

diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index b8ff678fdae9..62695fdcd32f 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -12,7 +12,7 @@ obj-y			+= power/
 obj-$(CONFIG_ISA_BUS_API)	+= isa.o
 obj-y				+= firmware_loader/
 obj-$(CONFIG_NUMA)	+= node.o
-obj-$(CONFIG_HMS)	+= hms.o hms-target.o hms-initiator.o hms-link.o
+obj-$(CONFIG_HMS)	+= hms.o hms-target.o hms-initiator.o hms-link.o hms-bridge.o
 obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
 ifeq ($(CONFIG_SYSFS),y)
 obj-$(CONFIG_MODULES)	+= module.o
diff --git a/drivers/base/hms-bridge.c b/drivers/base/hms-bridge.c
new file mode 100644
index 000000000000..64732e923fba
--- /dev/null
+++ b/drivers/base/hms-bridge.c
@@ -0,0 +1,197 @@
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
+static inline struct hms_bridge *hms_object_to_bridge(struct hms_object *object)
+{
+	if (object == NULL)
+		return NULL;
+
+	if (object->type != HMS_BRIDGE)
+		return NULL;
+	return container_of(object, struct hms_bridge, object);
+}
+
+static inline struct hms_bridge *device_to_hms_bridge(struct device *device)
+{
+	if (device == NULL)
+		return NULL;
+
+	return hms_object_to_bridge(to_hms_object(device));
+}
+
+struct hms_bridge *hms_bridge_find_locked(unsigned uid)
+{
+	struct hms_object *object = hms_object_find_locked(uid);
+	struct hms_bridge *bridge;
+
+	bridge = hms_object_to_bridge(object);
+	if (bridge)
+		return bridge;
+	hms_object_put(object);
+	return NULL;
+}
+
+struct hms_bridge *hms_bridge_find(unsigned uid)
+{
+	struct hms_object *object = hms_object_find(uid);
+	struct hms_bridge *bridge;
+
+	bridge = hms_object_to_bridge(object);
+	if (bridge)
+		return bridge;
+	hms_object_put(object);
+	return NULL;
+}
+
+static void hms_bridge_release(struct device *device)
+{
+	struct hms_bridge *bridge = device_to_hms_bridge(device);
+
+	hms_object_put(&bridge->linka->object);
+	hms_object_put(&bridge->linkb->object);
+	hms_object_release(&bridge->object);
+	kfree(bridge);
+}
+
+static ssize_t hms_bridge_show_uid(struct device *device,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct hms_bridge *bridge = device_to_hms_bridge(device);
+
+	if (bridge == NULL)
+		return -EINVAL;
+
+	return sprintf(buf, "%d\n", bridge->object.uid);
+}
+
+static DEVICE_ATTR(uid, 0444, hms_bridge_show_uid, NULL);
+
+static struct attribute *hms_bridge_attrs[] = {
+	&dev_attr_uid.attr,
+	NULL
+};
+
+static struct attribute_group hms_bridge_attr_group = {
+	.attrs = hms_bridge_attrs,
+};
+
+static const struct attribute_group *hms_bridge_attr_groups[] = {
+	&hms_bridge_attr_group,
+	NULL,
+};
+
+void hms_bridge_register(struct hms_bridge **bridgep,
+			 struct device *parent,
+			 struct hms_link *linka,
+			 struct hms_link *linkb,
+			 unsigned version)
+{
+	struct hms_bridge *bridge;
+	int ret;
+
+	*bridgep = NULL;
+
+	if (linka == NULL || linkb == NULL)
+		return;
+	linka = hms_object_to_link(hms_object_get(&linka->object));
+	linkb = hms_object_to_link(hms_object_get(&linkb->object));
+	if (linka == NULL || linkb == NULL)
+		goto error;
+
+	bridge = kzalloc(sizeof(*bridge), GFP_KERNEL);
+	if (bridge == NULL)
+		goto error;
+
+	if (hms_object_init(&bridge->object, parent, HMS_BRIDGE, version,
+			    hms_bridge_release, hms_bridge_attr_groups)) {
+		kfree(bridge);
+		goto error;
+	}
+
+	bridge->linka = linka;
+	bridge->linkb = linkb;
+
+	ret = hms_object_link(&bridge->object, &linka->object);
+	if (ret) {
+		hms_bridge_unregister(&bridge);
+		return;
+	}
+
+	ret = hms_object_link(&bridge->object, &linkb->object);
+	if (ret) {
+		hms_bridge_unregister(&bridge);
+		return;
+	}
+
+	*bridgep = bridge;
+	return;
+
+error:
+	hms_object_put(&linka->object);
+	hms_object_put(&linkb->object);
+}
+EXPORT_SYMBOL(hms_bridge_register);
+
+void hms_unbridge_initiator(struct hms_bridge *bridge,
+			    struct hms_initiator *initiator)
+{
+	if (bridge == NULL || initiator == NULL)
+		return;
+	if (bridge->object.type != HMS_BRIDGE)
+		return;
+	if (initiator->object.type != HMS_INITIATOR)
+		return;
+	hms_object_unlink(&bridge->object, &initiator->object);
+}
+EXPORT_SYMBOL(hms_unbridge_initiator);
+
+int hms_bridge_initiator(struct hms_bridge *bridge,
+			 struct hms_initiator *initiator)
+{
+	if (bridge == NULL || initiator == NULL)
+		return -EINVAL;
+	if (bridge->object.type != HMS_BRIDGE)
+		return -EINVAL;
+	if (initiator->object.type != HMS_INITIATOR)
+		return -EINVAL;
+	return hms_object_link(&bridge->object, &initiator->object);
+}
+EXPORT_SYMBOL(hms_bridge_initiator);
+
+void hms_bridge_unregister(struct hms_bridge **bridgep)
+{
+	struct hms_bridge *bridge = *bridgep;
+
+	*bridgep = NULL;
+	if (bridge == NULL)
+		return;
+
+	hms_object_unregister(&bridge->object);
+}
+EXPORT_SYMBOL(hms_bridge_unregister);
diff --git a/include/linux/hms.h b/include/linux/hms.h
index 2a9e49a2d771..511b5363d8f2 100644
--- a/include/linux/hms.h
+++ b/include/linux/hms.h
@@ -115,6 +115,24 @@ void hms_link_register(struct hms_link **linkp, struct device *parent,
 void hms_link_unregister(struct hms_link **linkp);
 
 
+struct hms_bridge {
+	struct hms_object object;
+	struct hms_link *linka;
+	struct hms_link *linkb;
+};
+
+void hms_unbridge_initiator(struct hms_bridge *bridge,
+			    struct hms_initiator *initiator);
+int hms_bridge_initiator(struct hms_bridge *bridge,
+			 struct hms_initiator *initiator);
+void hms_bridge_register(struct hms_bridge **bridgep,
+			 struct device *parent,
+			 struct hms_link *linka,
+			 struct hms_link *linkb,
+			 unsigned version);
+void hms_bridge_unregister(struct hms_bridge **bridgep);
+
+
 int hms_init(void);
 
 
@@ -139,6 +157,12 @@ int hms_init(void);
 #define hms_link_unregister(linkp)
 
 
+#define hms_unbridge_initiator(bridge, initiator)
+#define hms_bridge_initiator(bridge, initiator)
+#define hms_bridge_register(bridgep)
+#define hms_bridge_unregister(bridgep)
+
+
 static inline int hms_init(void)
 {
 	return 0;
-- 
2.17.2
