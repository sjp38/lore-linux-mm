Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55E01C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01AE4214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01AE4214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2546B8E0007; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1694F8E0002; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E58768E0008; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A6DEB8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 23so393135pfj.18
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=cpR3OpYE195Vh/Fe4KM3ys5RMhW3S64GKi84HFN56dw=;
        b=Wrv9VMrjBEKNO7v37YjhxwsPXYPY76117CwGw8NagxLIA3d8kZ0elCMbmU74tgdgXb
         aVqycgEtF54P62U8FH48Hp9jILa616kPztRiutVAu+rYsGse7gWYxb6WGUQRlnq2x/m5
         n0P7AUqSqzcF9GUCcvTLF2EwKggxC81O2IEkCabsAxE6PqHjz3KLIxRKC83iJO2k1N4w
         AY1M5mSgI4dUA2uPbDLtihpwuaUoeQWfJ3r+GsT4RJZ+HACl94a0z1Ah19Mbt6hKc+2j
         EzF8M2kdhWCrTwesWe3+quytk5wR7A0w7TP63pXNqpcUyv14XM4VdsBfJ83E7AeCizjF
         CS3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXIfJQ1WVLK6/y2XVEcYQQWDnuDNkzc33Qe1m7CH+mB6Q6SVkst
	Hd9W/wx7lcfzwSNobyg4KpIz5Q2VW/GIiFbNVSAuS7ZV2cBkSrKAKNNs8jgJ9hIRD2w5wf2/PPf
	5alolWm9DrnsghLy60aG39SDCI6RqrKqkOFI3StMpyhtuTtvcwSQlB7bFcwiAnwaSPA==
X-Received: by 2002:a17:902:4081:: with SMTP id c1mr36112788pld.297.1552337743276;
        Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhaU/jDZZEgPfbXiTBYoVuT3bLIOy40oy9vcSkQk321VM4aRU+y4OXWwqQveQ/YIkvzc6a
X-Received: by 2002:a17:902:4081:: with SMTP id c1mr36112708pld.297.1552337741747;
        Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337741; cv=none;
        d=google.com; s=arc-20160816;
        b=XyKHidVCYXDSjMAbMHCU5RVKyrdMp19nndRQbcyTAqkfjL9LKVkFLmuRMHpc13vJ1r
         Pr9Q8tqJtd6jw7n3WDOhIRilZ8FEnqyvo6c8O68JL/UVTCsv7PqIIJULrk2rCsQyX9Zi
         U6m6/sjblR8gft8qA8jGLUc+pCYZJNAkwk/gDg2PXBcxJrUTtY84sGGOF3hKK9o66Q2u
         j1ol0omqK+3QyzkKgRetpz6Tr73pN+hxzeOCOCgfDKYJtZw8RD97Gr58ZMwBBZFKzShB
         DqiO1EeKq1CH09/trkC0fWl2twUsrt4/BaNX02NbazKc8TxwCEV7NIWLKFKfX5XHAw5E
         wbAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=cpR3OpYE195Vh/Fe4KM3ys5RMhW3S64GKi84HFN56dw=;
        b=Uj7u3fMuxiXc9GmzvlYYTbXTLyZsGvnqOwlMbhE32Wzvtd4QdAhvYW8JKMwoJVJU5f
         xeY1bUNGxKkeTLeQgTXHCcZsW0FpSqa41A0FskQoaGiQE4nRQSf41HIU+rHzO/28XQJb
         12Ulhcn9/7w7wTJHX586e2q7058J83u7cApUANb/oH7wA2AVomVxAeQd81KHyZOkdLm7
         MpkuhxTaBIlFjJN9NxNcuISW21/rdXb0W20WKUfN3xdHqX3okwZVvpCQjRhwLtZpKONr
         jylu8GnUPfHfdE5+/2V7Da8BWNRmFVchcfsSB3pKGIfqqqB4q+8MF1grpPugLsZOUN/8
         mJjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 11 Mar 2019 13:55:41 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,468,1544515200"; 
   d="scan'208";a="139910171"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 11 Mar 2019 13:55:41 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-acpi@vger.kernel.org,
	linux-mm@kvack.org,
	linux-api@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Jonathan Cameron <jonathan.cameron@huawei.com>,
	Brice Goglin <Brice.Goglin@inria.fr>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCHv8 04/10] node: Link memory nodes to their compute nodes
Date: Mon, 11 Mar 2019 14:56:00 -0600
Message-Id: <20190311205606.11228-5-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
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
nodes access characteristics share the same performance relative to other
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

Reviewed-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  25 ++++-
 drivers/base/node.c                         | 142 +++++++++++++++++++++++++++-
 include/linux/node.h                        |   6 ++
 3 files changed, 171 insertions(+), 2 deletions(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 3e90e1f3bf0a..433bcc04e542 100644
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
+What:		/sys/devices/system/node/nodeX/accessY/targets/
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		The directory containing symlinks to memory targets that
+		this initiator node has class "Y" access.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..6f4097680580 100644
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
 
@@ -372,6 +461,56 @@ int register_cpu_under_node(unsigned int cpu, unsigned int nid)
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
+ * 	For use with platforms that may have separate memory and compute nodes.
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
@@ -580,6 +719,7 @@ int __register_one_node(int nid)
 			register_cpu_under_node(cpu, nid);
 	}
 
+	INIT_LIST_HEAD(&node_devices[nid]->access_list);
 	/* initialize work queue for memory hot plug */
 	init_node_hugetlb_work(nid);
 
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..bb288817ed33 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -17,10 +17,12 @@
 
 #include <linux/device.h>
 #include <linux/cpumask.h>
+#include <linux/list.h>
 #include <linux/workqueue.h>
 
 struct node {
 	struct device	dev;
+	struct list_head access_list;
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
 	struct work_struct	node_work;
@@ -75,6 +77,10 @@ extern int register_mem_sect_under_node(struct memory_block *mem_blk,
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

