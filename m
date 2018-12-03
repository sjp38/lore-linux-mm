Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id C79156B6BAE
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:00 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k203so14975907qke.2
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p45si5826356qta.144.2018.12.03.15.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:35:59 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 05/14] mm/hms: add link to heterogeneous memory system infrastructure
Date: Mon,  3 Dec 2018 18:35:00 -0500
Message-Id: <20181203233509.20671-6-jglisse@redhat.com>
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

A link connect initiators (CPUs or devices) and targets memory with
each others. It does necessarily match one to one with a physical
inter-connect ie a given physical inter-connect by be presented as
multiple links or multiple physical inter-connect can be presented
as just one link.

What matters is that the properties associated with the links applies
to all initiators and targets listed as connected to that link.

For example you can consider the PCIE bus if all initiators can peer
to peer with each others than it can be presented as just one link
with all the PCIE devices in it and the local CPU (ie CPU from which
the PCIE lanes are coming from). If not all PCIE device can peer to
peer than a link per peer to peer group is created and corresponding
CPU is added to each.

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
 drivers/base/Makefile   |   2 +-
 drivers/base/hms-link.c | 183 ++++++++++++++++++++++++++++++++++++++++
 include/linux/hms.h     |  23 +++++
 3 files changed, 207 insertions(+), 1 deletion(-)
 create mode 100644 drivers/base/hms-link.c

diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 6a1b5ab667bd..b8ff678fdae9 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -12,7 +12,7 @@ obj-y			+= power/
 obj-$(CONFIG_ISA_BUS_API)	+= isa.o
 obj-y				+= firmware_loader/
 obj-$(CONFIG_NUMA)	+= node.o
-obj-$(CONFIG_HMS)	+= hms.o hms-target.o hms-initiator.o
+obj-$(CONFIG_HMS)	+= hms.o hms-target.o hms-initiator.o hms-link.o
 obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
 ifeq ($(CONFIG_SYSFS),y)
 obj-$(CONFIG_MODULES)	+= module.o
diff --git a/drivers/base/hms-link.c b/drivers/base/hms-link.c
new file mode 100644
index 000000000000..58f4fdd8977c
--- /dev/null
+++ b/drivers/base/hms-link.c
@@ -0,0 +1,183 @@
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
+struct hms_link *hms_object_to_link(struct hms_object *object)
+{
+	if (object == NULL)
+		return NULL;
+
+	if (object->type != HMS_LINK)
+		return NULL;
+	return container_of(object, struct hms_link, object);
+}
+
+static inline struct hms_link *device_to_hms_link(struct device *device)
+{
+	if (device == NULL)
+		return NULL;
+
+	return hms_object_to_link(to_hms_object(device));
+}
+
+struct hms_link *hms_link_find_locked(unsigned uid)
+{
+	struct hms_object *object = hms_object_find_locked(uid);
+	struct hms_link *link;
+
+	link = hms_object_to_link(object);
+	if (link)
+		return link;
+	hms_object_put(object);
+	return NULL;
+}
+
+struct hms_link *hms_link_find(unsigned uid)
+{
+	struct hms_object *object = hms_object_find(uid);
+	struct hms_link *link;
+
+	link = hms_object_to_link(object);
+	if (link)
+		return link;
+	hms_object_put(object);
+	return NULL;
+}
+
+static void hms_link_release(struct device *device)
+
+{
+	struct hms_link *link = device_to_hms_link(device);
+
+	hms_object_release(&link->object);
+	kfree(link);
+}
+
+static ssize_t hms_link_show_uid(struct device *device,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	struct hms_link *link = device_to_hms_link(device);
+
+	if (link == NULL)
+		return -EINVAL;
+
+	return sprintf(buf, "%d\n", link->object.uid);
+}
+
+static DEVICE_ATTR(uid, 0444, hms_link_show_uid, NULL);
+
+static struct attribute *hms_link_attrs[] = {
+	&dev_attr_uid.attr,
+	NULL
+};
+
+static struct attribute_group hms_link_attr_group = {
+	.attrs = hms_link_attrs,
+};
+
+static const struct attribute_group *hms_link_attr_groups[] = {
+	&hms_link_attr_group,
+	NULL,
+};
+
+void hms_link_register(struct hms_link **linkp, struct device *parent,
+		       unsigned version)
+{
+	struct hms_link *link;
+
+	*linkp = NULL;
+	link = kzalloc(sizeof(*link), GFP_KERNEL);
+	if (link == NULL)
+		return;
+
+	if (hms_object_init(&link->object, parent, HMS_LINK, version,
+			    hms_link_release, hms_link_attr_groups)) {
+		kfree(link);
+		link = NULL;
+	}
+
+	*linkp = link;
+}
+EXPORT_SYMBOL(hms_link_register);
+
+void hms_unlink_initiator(struct hms_link *link,
+			  struct hms_initiator *initiator)
+{
+	if (link == NULL || initiator == NULL)
+		return;
+	if (link->object.type != HMS_LINK)
+		return;
+	if (initiator->object.type != HMS_INITIATOR)
+		return;
+	hms_object_unlink(&link->object, &initiator->object);
+}
+EXPORT_SYMBOL(hms_unlink_initiator);
+
+void hms_unlink_target(struct hms_link *link, struct hms_target *target)
+{
+	if (link == NULL || target == NULL)
+		return;
+	if (link->object.type != HMS_LINK || target->object.type != HMS_TARGET)
+		return;
+	hms_object_unlink(&link->object, &target->object);
+}
+EXPORT_SYMBOL(hms_unlink_target);
+
+int hms_link_initiator(struct hms_link *link, struct hms_initiator *initiator)
+{
+	if (link == NULL || initiator == NULL)
+		return -EINVAL;
+	if (link->object.type != HMS_LINK)
+		return -EINVAL;
+	if (initiator->object.type != HMS_INITIATOR)
+		return -EINVAL;
+	return hms_object_link(&link->object, &initiator->object);
+}
+EXPORT_SYMBOL(hms_link_initiator);
+
+int hms_link_target(struct hms_link *link, struct hms_target *target)
+{
+	if (link == NULL || target == NULL)
+		return -EINVAL;
+	if (link->object.type != HMS_LINK || target->object.type != HMS_TARGET)
+		return -EINVAL;
+	return hms_object_link(&link->object, &target->object);
+}
+EXPORT_SYMBOL(hms_link_target);
+
+void hms_link_unregister(struct hms_link **linkp)
+{
+	struct hms_link *link = *linkp;
+
+	*linkp = NULL;
+	if (link == NULL)
+		return;
+
+	hms_object_unregister(&link->object);
+}
+EXPORT_SYMBOL(hms_link_unregister);
diff --git a/include/linux/hms.h b/include/linux/hms.h
index 7a2823493f63..2a9e49a2d771 100644
--- a/include/linux/hms.h
+++ b/include/linux/hms.h
@@ -100,6 +100,21 @@ static inline void hms_target_put(struct hms_target *target)
 }
 
 
+struct hms_link {
+	struct hms_object object;
+};
+
+struct hms_link *hms_object_to_link(struct hms_object *object);
+void hms_unlink_initiator(struct hms_link *link,
+			  struct hms_initiator *initiator);
+void hms_unlink_target(struct hms_link *link, struct hms_target *target);
+int hms_link_initiator(struct hms_link *link, struct hms_initiator *initiator);
+int hms_link_target(struct hms_link *link, struct hms_target *target);
+void hms_link_register(struct hms_link **linkp, struct device *parent,
+		       unsigned version);
+void hms_link_unregister(struct hms_link **linkp);
+
+
 int hms_init(void);
 
 
@@ -116,6 +131,14 @@ int hms_init(void);
 #define hms_target_unregister(targetp)
 
 
+#define hms_unlink_initiator(link, initiator)
+#define hms_unlink_target(link, target)
+#define hms_link_initiator(link, initiator)
+#define hms_link_target(link, target)
+#define hms_link_register(linkp)
+#define hms_link_unregister(linkp)
+
+
 static inline int hms_init(void)
 {
 	return 0;
-- 
2.17.2
