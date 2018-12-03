Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC6D06B6BB2
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 18:36:11 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id z6so15158280qtj.21
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 15:36:11 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n69si2780294qkn.55.2018.12.03.15.36.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 15:36:10 -0800 (PST)
From: jglisse@redhat.com
Subject: [RFC PATCH 08/14] mm/hms: register main CPUs with heterogenenous memory system
Date: Mon,  3 Dec 2018 18:35:03 -0500
Message-Id: <20181203233509.20671-9-jglisse@redhat.com>
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

Register CPUs as initiator under HMS scheme. CPUs are registered per
node (one initiator device per node per CPU). We also add the CPU to
the node default link so it is connected to main memory for the node.
For details see Documentation/vm/hms.rst.

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
 drivers/base/cpu.c  |  5 +++++
 drivers/base/node.c | 18 +++++++++++++++++-
 include/linux/cpu.h |  4 ++++
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/base/cpu.c b/drivers/base/cpu.c
index eb9443d5bae1..160454bc5c38 100644
--- a/drivers/base/cpu.c
+++ b/drivers/base/cpu.c
@@ -76,6 +76,8 @@ void unregister_cpu(struct cpu *cpu)
 {
 	int logical_cpu = cpu->dev.id;
 
+	hms_initiator_unregister(&cpu->initiator);
+
 	unregister_cpu_under_node(logical_cpu, cpu_to_node(logical_cpu));
 
 	device_unregister(&cpu->dev);
@@ -392,6 +394,9 @@ int register_cpu(struct cpu *cpu, int num)
 	dev_pm_qos_expose_latency_limit(&cpu->dev,
 					PM_QOS_RESUME_LATENCY_NO_CONSTRAINT);
 
+	hms_initiator_register(&cpu->initiator, &cpu->dev,
+			       cpu_to_node(num), 0);
+
 	return 0;
 }
 
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 05621ba3cf13..43f1820cdadb 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -375,9 +375,19 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 	if (ret)
 		return ret;
 
-	return sysfs_create_link(&obj->kobj,
+	ret = sysfs_create_link(&obj->kobj,
 				 &node_devices[nid]->dev.kobj,
 				 kobject_name(&node_devices[nid]->dev.kobj));
+	if (ret)
+		return ret;
+
+	if (IS_ENABLED(CONFIG_HMS)) {
+		struct cpu *cpu = container_of(obj, struct cpu, dev);
+
+		hms_link_initiator(node_devices[nid]->link, cpu->initiator);
+	}
+
+	return 0;
 }
 
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
@@ -396,6 +406,12 @@ int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 	sysfs_remove_link(&obj->kobj,
 			  kobject_name(&node_devices[nid]->dev.kobj));
 
+	if (IS_ENABLED(CONFIG_HMS)) {
+		struct cpu *cpu = container_of(obj, struct cpu, dev);
+
+		hms_unlink_initiator(node_devices[nid]->link, cpu->initiator);
+	}
+
 	return 0;
 }
 
diff --git a/include/linux/cpu.h b/include/linux/cpu.h
index 218df7f4d3e1..1e3a777bfa3d 100644
--- a/include/linux/cpu.h
+++ b/include/linux/cpu.h
@@ -14,6 +14,7 @@
 #ifndef _LINUX_CPU_H_
 #define _LINUX_CPU_H_
 
+#include <linux/hms.h>
 #include <linux/node.h>
 #include <linux/compiler.h>
 #include <linux/cpumask.h>
@@ -27,6 +28,9 @@ struct cpu {
 	int node_id;		/* The node which contains the CPU */
 	int hotpluggable;	/* creates sysfs control file if hotpluggable */
 	struct device dev;
+#if defined(CONFIG_HMS)
+	struct hms_initiator *initiator;
+#endif
 };
 
 extern void boot_cpu_init(void);
-- 
2.17.2
