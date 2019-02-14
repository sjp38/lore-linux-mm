Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1246C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A89C222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A89C222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 994AF8E0007; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831058E0008; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F4FE8E0007; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7E38E0004
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id a26so5252015pff.15
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=Z+aYuS7Ck8eIDvFyaAb13+vyKQWPw2BLaJsQ5wjttQo=;
        b=g+t73DZJxzkOwzL5BPsUY3TT/osNYGvv+d1rPjx3Gyu/3r1rKDJj7lnnv0nf4ZnJo/
         0qwHFitlkso4CjxCj1pert08z0jVPY8vQqihmzXxNpr18K7hJ2vjnWyLyiG+VI6zL03w
         AKWfLM1L3x7bZ+Mi4fhVLe1yqa/2f90U97Izqk46ISzIuRNMK2nVBN3LbRnienpuGDgA
         pXYRQzcaxxjGNZpIv46/hQo+72oqrsUxJSCTZ8vsihtfgD+i3I3DOUNM82TqNktJE4Jp
         WLQgq6owKUECeC1wCTH37SZxMZwQOfznRSGY7SO0Z0ixAVOZzzcZ/KHjbV+loscc7+zt
         dBCA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuYAT4vLfRsJEKSox3JNwAi8XeC0g9qKq+a1wLNp1dAFqUp9Lcb7
	sRcoNMR2KCOaFpO+cHA8myZPvIEK7PDFqHARe5UybLDLWPlrgJkmWcJDXz8XqtB0qkr+oU9d4Hc
	ZydydE1NHsMKPliAoPLP4O+xbMf4h0DuzqoOViCODoEfvaZ496TSvWUu3IEc9l79ltw==
X-Received: by 2002:aa7:8c8c:: with SMTP id p12mr5311688pfd.0.1550164242817;
        Thu, 14 Feb 2019 09:10:42 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYWxVW5HaDjzqWjLNdDiOfYCyWAH2uEOMv7bFOFgvf712id9iiv/l8kgQby6usqXqbIj+OU
X-Received: by 2002:aa7:8c8c:: with SMTP id p12mr5311579pfd.0.1550164241419;
        Thu, 14 Feb 2019 09:10:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164241; cv=none;
        d=google.com; s=arc-20160816;
        b=d8q06oVAQYAfLNWyVHkmHZ/dWeSoKk4V05X+6ikjHFtchC3F3CdsslAJAJ4JspFcIF
         6w1y4esjr2PXTd90i1W+nrwbjaDYZi44+nORpZnYQCHWkA06NqAjpRmndqx5+l2hHqwH
         6tbH+XvRi0yePdmZZ3zr6/9NyFhKTvrtXU0l/9E/etxqkwFPKBWEbA2usqTivsFgvxVZ
         huSczn+MR8g5YRXWnwz+9BSajSPO07G6Xeo/sTaRaKUQCRXgL5PkaSsA4z5nA/rjQmpC
         My2evqCPh9JqrTr0uPuHxiMWi9IArRsvvUSgmaNW+a2YpWEmuOGLh5UPbeUWj9n+Lsc/
         OVAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=Z+aYuS7Ck8eIDvFyaAb13+vyKQWPw2BLaJsQ5wjttQo=;
        b=YlaQ7kW5MgF7WdKdD/gKZZubdOEGV+Z5ZIcbXkS1eWC217eBf3rLd2hN3LrnOGdxAp
         S6PKge0f4Hgp4hV7QNgmjz9EuNS00M1QlodBZF5OIfhqJksrUIbCR9sHUE8OvBvJAHBw
         Imcal8UnNqqgxIKiojFbJ1+9QiMh6PBuHrATPwFCWu0E4MntRKhKFUetjdodIOSwn4X0
         dnqJzjF2Fpki4CI1RcaqDykXhs7rCbg98ogVW3n++cBV9/6ihTEUvbd/gIfu1XvkmIJN
         Izrdd9IOXqwU8sYQkjIXXIFr6FET2e/00khkn4lv/xw+HZ69yivgJ8uolSOM4nd7vK0S
         G0EQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id j17si2724426pfn.271.2019.02.14.09.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Feb 2019 09:10:41 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:40 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613114"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 14 Feb 2019 09:10:40 -0800
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv6 04/10] node: Link memory nodes to their compute nodes
Date: Thu, 14 Feb 2019 10:10:11 -0700
Message-Id: <20190214171017.9362-5-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Systems may be constructed with various specialized nodes. Some nodes
may provide memory, some provide compute devices that access and use
that memory, and others may provide both. Nodes that provide memory are
referred to as memory targets, and nodes that can initiate memory access
are referred to as memory initiators.

Memory targets will often have varying access characteristics from
different initiators, and platforms may have ways to express those
relationships. In preparation for these systems, provide interfaces for
the kernel to export the memory relationship among different nodes memory
targets and their initiators with symlinks to each other.

If a system provides access locality for each initiator-target pair, nodes
may be grouped into ranked access classes relative to other nodes. The
new interface allows a subsystem to register relationships of varying
classes if available and desired to be exported.

A memory initiator may have multiple memory targets in the same access
class. The target memory's initiators in a given class indicate the
node's access characteristics share the same performance relative to other
linked initiator nodes. Each target within an initiator's access class,
though, do not necessarily perform the same as each other.

A memory target node may have multiple memory initiators. All linked
initiators in a target's class have the same access characteristics to
that target.

The following example show the nodes' new sysfs hierarchy for a memory
target node 'Y' with access class 0 from initiator node 'X':

  # symlinks -v /sys/devices/system/node/nodeX/access0/
  relative: /sys/devices/system/node/nodeX/access0/targets/nodeY -> ../../nodeY

  # symlinks -v /sys/devices/system/node/nodeY/access0/
  relative: /sys/devices/system/node/nodeY/access0/initiators/nodeX -> ../../nodeX

The new attributes are added to the sysfs stable documentation.

Reviewed-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
 drivers/base/node.c                         | 141 +++++++++++++++++++++++++++-
 include/linux/node.h                        |   7 +-
 3 files changed, 170 insertions(+), 3 deletions(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 3e90e1f3bf0a..fb843222a281 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,27 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/admin-guide/mm/hugetlbpage.rst
\ No newline at end of file
+		See Documentation/admin-guide/mm/hugetlbpage.rst
+
+What:		/sys/devices/system/node/nodeX/accessY/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The node's relationship to other nodes for access class "Y".
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The directory containing symlinks to memory initiator
+		nodes that have class "Y" access to this target node's
+		memory. CPUs and other memory initiators in nodes not in
+		the list accessing this node's memory may have different
+		performance.
+
+What:		/sys/devices/system/node/nodeX/classY/targets/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The directory containing symlinks to memory targets that
+		this initiator node has class "Y" access.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..d1ec38db4e77 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -17,6 +17,7 @@
 #include <linux/nodemask.h>
 #include <linux/cpu.h>
 #include <linux/device.h>
+#include <linux/pm_runtime.h>
 #include <linux/swap.h>
 #include <linux/slab.h>
 
@@ -59,6 +60,94 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
+/**
+ * struct node_access_nodes - Access class device to hold user visible
+ * 			      relationships to other nodes.
+ * @dev:	Device for this memory access class
+ * @list_node:	List element in the node's access list
+ * @access:	The access class rank
+ */
+struct node_access_nodes {
+	struct device		dev;
+	struct list_head	list_node;
+	unsigned		access;
+};
+#define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
+
+static struct attribute *node_init_access_node_attrs[] = {
+	NULL,
+};
+
+static struct attribute *node_targ_access_node_attrs[] = {
+	NULL,
+};
+
+static const struct attribute_group initiators = {
+	.name	= "initiators",
+	.attrs	= node_init_access_node_attrs,
+};
+
+static const struct attribute_group targets = {
+	.name	= "targets",
+	.attrs	= node_targ_access_node_attrs,
+};
+
+static const struct attribute_group *node_access_node_groups[] = {
+	&initiators,
+	&targets,
+	NULL,
+};
+
+static void node_remove_accesses(struct node *node)
+{
+	struct node_access_nodes *c, *cnext;
+
+	list_for_each_entry_safe(c, cnext, &node->access_list, list_node) {
+		list_del(&c->list_node);
+		device_unregister(&c->dev);
+	}
+}
+
+static void node_access_release(struct device *dev)
+{
+	kfree(to_access_nodes(dev));
+}
+
+static struct node_access_nodes *node_init_node_access(struct node *node,
+						       unsigned access)
+{
+	struct node_access_nodes *access_node;
+	struct device *dev;
+
+	list_for_each_entry(access_node, &node->access_list, list_node)
+		if (access_node->access == access)
+			return access_node;
+
+	access_node = kzalloc(sizeof(*access_node), GFP_KERNEL);
+	if (!access_node)
+		return NULL;
+
+	access_node->access = access;
+	dev = &access_node->dev;
+	dev->parent = &node->dev;
+	dev->release = node_access_release;
+	dev->groups = node_access_node_groups;
+	if (dev_set_name(dev, "access%u", access))
+		goto free;
+
+	if (device_register(dev))
+		goto free_name;
+
+	pm_runtime_no_callbacks(dev);
+	list_add_tail(&access_node->list_node, &node->access_list);
+	return access_node;
+free_name:
+	kfree_const(dev->kobj.name);
+free:
+	kfree(access_node);
+	return NULL;
+}
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
@@ -340,7 +429,7 @@ static int register_node(struct node *node, int num)
 void unregister_node(struct node *node)
 {
 	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
-
+	node_remove_accesses(node);
 	device_unregister(&node->dev);
 }
 
@@ -372,6 +461,55 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
 				 kobject_name(&node_devices[nid]->dev.kobj));
 }
 
+/**
+ * register_memory_node_under_compute_node - link memory node to its compute
+ *					     node for a given access class.
+ * @mem_node:	Memory node number
+ * @cpu_node:	Cpu  node number
+ * @access:	Access class to register
+ *
+ * Description:
+ * 	This function will export node relationships linking which memory
+ * 	initiator nodes can access memory targets at a given ranked access
+ * 	class.
+ */
+int register_memory_node_under_compute_node(unsigned int mem_nid,
+					    unsigned int cpu_nid,
+					    unsigned access)
+{
+	struct node *init_node, *targ_node;
+	struct node_access_nodes *initiator, *target;
+	int ret;
+
+	if (!node_online(cpu_nid) || !node_online(mem_nid))
+		return -ENODEV;
+
+	init_node = node_devices[cpu_nid];
+	targ_node = node_devices[mem_nid];
+	initiator = node_init_node_access(init_node, access);
+	target = node_init_node_access(targ_node, access);
+	if (!initiator || !target)
+		return -ENOMEM;
+
+	ret = sysfs_add_link_to_group(&initiator->dev.kobj, "targets",
+				      &targ_node->dev.kobj,
+				      dev_name(&targ_node->dev));
+	if (ret)
+		return ret;
+
+	ret = sysfs_add_link_to_group(&target->dev.kobj, "initiators",
+				      &init_node->dev.kobj,
+				      dev_name(&init_node->dev));
+	if (ret)
+		goto err;
+
+	return 0;
+ err:
+	sysfs_remove_link_from_group(&initiator->dev.kobj, "targets",
+				     dev_name(&targ_node->dev));
+	return ret;
+}
+
 int unregister_cpu_under_node(unsigned int cpu, unsigned int nid)
 {
 	struct device *obj;
@@ -580,6 +718,7 @@ int __register_one_node(int nid)
 			register_cpu_under_node(cpu, nid);
 	}
 
+	INIT_LIST_HEAD(&node_devices[nid]->access_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..f34688a203c1 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -17,11 +17,12 @@
 
 #include <linux/device.h>
 #include <linux/cpumask.h>
+#include <linux/list.h>
 #include <linux/workqueue.h>
 
 struct node {
 	struct device	dev;
-
+	struct list_head access_list;
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
 #endif
@@ -75,6 +76,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
+extern int register_memory_node_under_compute_node(unsigned int mem_nid,
+						   unsigned int cpu_nid,
+						   unsigned access);
+
 #ifdef CONFIG_HUGETLBFS
 extern void register_hugetlbfs_with_node(node_registration_func_t doregister,
 					 node_registration_func_t unregister);
-- 
2.14.4

