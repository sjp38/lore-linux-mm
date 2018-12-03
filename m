Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id F032F6B6BAA
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:35:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 42so15046446qtr.7
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:35:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l90si1114416qte.331.2018.12.03.15.35.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:35:37 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 01/14] mm/hms: heterogeneous memory system (sysfs infrastructure)
Date: Mon,  3 Dec 2018 18:34:56 -0500
Message-Id: <20181203233509.20671-2-jglisse@redhat.com>
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

System with complex memory topology needs a more versatile memory
topology description than just node where a node is a collection of
memory and CPU. In heterogeneous memory system we consider four
types of object:
      - target: which is any kind of memory
      - initiator: any kind of device or CPU
      - link: any kind of link that connects targets and initiators
      - bridge: a bridge between two links (for some initiators)

Properties (like bandwidth, latency, bus width, ...) are define per
bridge and per link. Property of a link apply to all initiators which
are connected to that link.

Not all initiators are connected to all links thus not all initiators
can access all targets memory (this apply to CPU too ie some CPU might
not be able to access all target memory).

Bridges allow initiators (that can use the bridge) to access targets
for which they do not have a direct link with.

Through this four types of object we can describe any kind of system
memory topology. To expose this to userspace we expose a new sysfs
hierarchy (that co-exist with the existing one):
  - /sys/bus/hms/target/ all targets in the system
  - /sys/bus/hms/initiator all initiators in the system
  - /sys/bus/hms/interconnect all inter-connects in the system
  - /sys/bus/hms/bridge all bridges in the system

Inside each link or bridge directory they are symlinks to targets and
initiators that are connected to that bridge or link. Properties are
defined inside link and bridge directory.

This patch only introduce core HMS infrastructure, each object type
is added with individual patch.

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
 Documentation/vm/hms.rst |  35 +++++++
 drivers/base/Kconfig     |  14 +++
 drivers/base/Makefile    |   1 +
 drivers/base/hms.c       | 199 +++++++++++++++++++++++++++++++++++++++
 drivers/base/init.c      |   2 +
 include/linux/hms.h      |  72 ++++++++++++++
 6 files changed, 323 insertions(+)
 create mode 100644 Documentation/vm/hms.rst
 create mode 100644 drivers/base/hms.c
 create mode 100644 include/linux/hms.h

diff --git a/Documentation/vm/hms.rst b/Documentation/vm/hms.rst
new file mode 100644
index 000000000000..dbf0f71918a9
--- /dev/null
+++ b/Documentation/vm/hms.rst
@@ -0,0 +1,35 @@
+.. hms:
+
+=================================
+Heterogeneous Memory System (HMS)
+=================================
+
+System with complex memory topology needs a more versatile memory topology
+description than just node where a node is a collection of memory and CPU.
+In heterogeneous memory system we consider four types of object::
+   - target: which is any kind of memory
+   - initiator: any kind of device or CPU
+   - inter-connect: any kind of links that connects target and initiator
+   - bridge: a link between two inter-connects
+
+Properties (like bandwidth, latency, bus width, ...) are define per bridge
+and per inter-connect. Property of an inter-connect apply to all initiators
+which are link to that inter-connect. Not all initiators are link to all
+inter-connect and thus not all initiators can access all memory (this apply
+to CPU too ie some CPU might not be able to access all memory).
+
+Bridges allow initiators (that can use the bridge) to access target for
+which they do not have a direct link with (ie they do not share a common
+inter-connect with the target).
+
+Through this four types of object we can describe any kind of system memory
+topology. To expose this to userspace we expose a new sysfs hierarchy (that
+co-exist with the existing one)::
+   - /sys/bus/hms/target* all targets in the system
+   - /sys/bus/hms/initiator* all initiators in the system
+   - /sys/bus/hms/interconnect* all inter-connects in the system
+   - /sys/bus/hms/bridge* all bridges in the system
+
+Inside each bridge or inter-connect directory they are symlinks to targets
+and initiators that are linked to that bridge or inter-connect. Properties
+are defined inside bridge and inter-connect directory.
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 3e63a900b330..d46a7d47f316 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -276,4 +276,18 @@ config GENERIC_ARCH_TOPOLOGY
 	  appropriate scaling, sysfs interface for changing capacity values at
 	  runtime.
 
+config HMS
+	bool "Heterogeneous memory system"
+	depends on STAGING
+	default n
+	help
+	  THIS IS AN EXPERIMENTAL API DO NOT RELY ON IT ! IT IS UNSTABLE !
+	
+	  Select HMS if you want to expose heterogeneous memory system to user
+	  space. This will expose a new directory under /sys/class/bus/hms that
+	  provide a description of heterogeneous memory system.
+	
+	  See Documentations/vm/hms.rst for further informations.
+
+
 endmenu
diff --git a/drivers/base/Makefile b/drivers/base/Makefile
index 704f44295810..92ebfacbf0dc 100644
--- a/drivers/base/Makefile
+++ b/drivers/base/Makefile
@@ -12,6 +12,7 @@ obj-y			+= power/
 obj-$(CONFIG_ISA_BUS_API)	+= isa.o
 obj-y				+= firmware_loader/
 obj-$(CONFIG_NUMA)	+= node.o
+obj-$(CONFIG_HMS)	+= hms.o
 obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
 ifeq ($(CONFIG_SYSFS),y)
 obj-$(CONFIG_MODULES)	+= module.o
diff --git a/drivers/base/hms.c b/drivers/base/hms.c
new file mode 100644
index 000000000000..a145f00a3683
--- /dev/null
+++ b/drivers/base/hms.c
@@ -0,0 +1,199 @@
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
+#define HMS_CLASS_NAME "hms"
+
+static DEFINE_MUTEX(hms_sysfs_mutex);
+
+static struct bus_type hms_subsys = {
+	.name = HMS_CLASS_NAME,
+	.dev_name = NULL,
+};
+
+void hms_object_release(struct hms_object *object)
+{
+	put_device(object->parent);
+}
+
+int hms_object_init(struct hms_object *object, struct device *parent,
+		    enum hms_type type, unsigned version,
+		    void (*device_release)(struct device *device),
+		    const struct attribute_group **device_group)
+{
+	static unsigned uid = 0;
+	int ret;
+
+	mutex_lock(&hms_sysfs_mutex);
+
+	/*
+	 * For now assume we are not going to have more that (2^31)-1 objects
+	 * in a system.
+	 *
+	 * FIXME use something little less naive ...
+	 */
+	object->uid = uid++;
+
+	switch (type) {
+	case HMS_TARGET:
+		dev_set_name(&object->device, "v%u-%u-target",
+			     version, object->uid);
+		break;
+	case HMS_BRIDGE:
+		dev_set_name(&object->device, "v%u-%u-bridge",
+			     version, object->uid);
+		break;
+	case HMS_INITIATOR:
+		dev_set_name(&object->device, "v%u-%u-initiator",
+			     version, object->uid);
+		break;
+	case HMS_LINK:
+		dev_set_name(&object->device, "v%u-%u-link",
+			     version, object->uid);
+		break;
+	default:
+		mutex_unlock(&hms_sysfs_mutex);
+		return -EINVAL;
+	}
+
+	object->type = type;
+	object->version = version;
+	object->device.id = object->uid;
+	object->device.bus = &hms_subsys;
+	object->device.groups = device_group;
+	object->device.release = device_release;
+
+	ret = device_register(&object->device);
+	if (ret)
+		put_device(&object->device);
+	mutex_unlock(&hms_sysfs_mutex);
+
+	if (!ret && parent) {
+		object->parent = parent;
+		get_device(parent);
+
+		sysfs_create_link(&object->device.kobj, &parent->kobj,
+				  kobject_name(&parent->kobj));
+	}
+
+	return ret;
+}
+
+int hms_object_link(struct hms_object *objecta,
+		    struct hms_object *objectb)
+{
+	int ret;
+
+	ret = sysfs_create_link(&objecta->device.kobj,
+				&objectb->device.kobj,
+				kobject_name(&objectb->device.kobj));
+	if (ret)
+		return ret;
+	ret = sysfs_create_link(&objectb->device.kobj,
+				&objecta->device.kobj,
+				kobject_name(&objecta->device.kobj));
+	if (ret) {
+		sysfs_remove_link(&objecta->device.kobj,
+				  kobject_name(&objectb->device.kobj));
+		return ret;
+	}
+
+	return 0;
+}
+
+void hms_object_unlink(struct hms_object *objecta,
+		       struct hms_object *objectb)
+{
+	sysfs_remove_link(&objecta->device.kobj,
+			  kobject_name(&objectb->device.kobj));
+	sysfs_remove_link(&objectb->device.kobj,
+			  kobject_name(&objecta->device.kobj));
+}
+
+struct hms_object *hms_object_get(struct hms_object *object)
+{
+	if (object == NULL)
+		return NULL;
+
+	get_device(&object->device);
+	return object;
+}
+
+void hms_object_put(struct hms_object *object)
+{
+	put_device(&object->device);
+}
+
+void hms_object_unregister(struct hms_object *object)
+{
+	mutex_lock(&hms_sysfs_mutex);
+	device_unregister(&object->device);
+	mutex_unlock(&hms_sysfs_mutex);
+}
+
+struct hms_object *hms_object_find_locked(unsigned uid)
+{
+	struct device *device;
+
+	device = subsys_find_device_by_id(&hms_subsys, uid, NULL);
+	return device ? to_hms_object(device) : NULL;
+}
+
+struct hms_object *hms_object_find(unsigned uid)
+{
+	struct hms_object *object;
+
+	mutex_lock(&hms_sysfs_mutex);
+	object = hms_object_find_locked(uid);
+	mutex_unlock(&hms_sysfs_mutex);
+	return object;
+}
+
+
+static struct attribute *hms_root_attrs[] = {
+	NULL
+};
+
+static struct attribute_group hms_root_attr_group = {
+	.attrs = hms_root_attrs,
+};
+
+static const struct attribute_group *hms_root_attr_groups[] = {
+	&hms_root_attr_group,
+	NULL,
+};
+
+int __init hms_init(void)
+{
+	int ret;
+
+	ret = subsys_system_register(&hms_subsys, hms_root_attr_groups);
+	if (ret)
+		pr_err("%s() failed: %d\n", __func__, ret);
+
+	return ret;
+}
diff --git a/drivers/base/init.c b/drivers/base/init.c
index 908e6520e804..3b40d5899d66 100644
--- a/drivers/base/init.c
+++ b/drivers/base/init.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/memory.h>
 #include <linux/of.h>
+#include <linux/hms.h>
 
 #include "base.h"
 
@@ -34,5 +35,6 @@ void __init driver_init(void)
 	platform_bus_init();
 	cpu_dev_init();
 	memory_dev_init();
+	hms_init();
 	container_dev_init();
 }
diff --git a/include/linux/hms.h b/include/linux/hms.h
new file mode 100644
index 000000000000..1ab288df0158
--- /dev/null
+++ b/include/linux/hms.h
@@ -0,0 +1,72 @@
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
+#ifndef HMS_H
+#define HMS_H
+#if IS_ENABLED(CONFIG_HMS)
+
+
+#include <linux/device.h>
+
+
+#define to_hms_object(device) container_of(device, struct hms_object, device)
+
+enum hms_type {
+	HMS_BRIDGE,
+	HMS_INITIATOR,
+	HMS_LINK,
+	HMS_TARGET,
+};
+
+struct hms_object {
+	struct device *parent;
+	struct device device;
+	enum hms_type type;
+	unsigned version;
+	unsigned uid;
+};
+
+void hms_object_release(struct hms_object *object);
+int hms_object_init(struct hms_object *object, struct device *parent,
+		    enum hms_type type, unsigned version,
+		    void (*device_release)(struct device *device),
+		    const struct attribute_group **device_group);
+int hms_object_link(struct hms_object *objecta,
+		    struct hms_object *objectb);
+void hms_object_unlink(struct hms_object *objecta,
+		       struct hms_object *objectb);
+struct hms_object *hms_object_get(struct hms_object *object);
+void hms_object_put(struct hms_object *object);
+void hms_object_unregister(struct hms_object *object);
+struct hms_object *hms_object_find_locked(unsigned uid);
+struct hms_object *hms_object_find(unsigned uid);
+
+
+int hms_init(void);
+
+
+#else /* IS_ENABLED(CONFIG_HMS) */
+
+
+static inline int hms_init(void)
+{
+	return 0;
+}
+
+
+#endif /* IS_ENABLED(CONFIG_HMS) */
+#endif /* HMS_H */
-- 
2.17.2
