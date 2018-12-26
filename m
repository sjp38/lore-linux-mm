Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id B0ECC8E0003
	for <linux-mm@kvack.org>; Wed, 26 Dec 2018 08:37:06 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id s22so15223468pgv.8
        for <linux-mm@kvack.org>; Wed, 26 Dec 2018 05:37:06 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e68si15371744pfb.101.2018.12.26.05.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Dec 2018 05:37:05 -0800 (PST)
Message-Id: <20181226133351.463947436@intel.com>
Date: Wed, 26 Dec 2018 21:14:53 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [RFC][PATCH v2 07/21] mm: export node type {pmem|dram} under /sys/bus/node
References: <20181226131446.330864849@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=0005-Export-node-type-pmem-ram-in-sys-bus-node.patch
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Fan Du <fan.du@intel.com>, Fengguang Wu <fengguang.wu@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Yao Yuan <yuan.yao@intel.com>, Peng Dong <dongx.peng@intel.com>, Huang Ying <ying.huang@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, Zhang Yi <yi.z.zhang@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

From: Fan Du <fan.du@intel.com>

User space migration daemon could check
/sys/bus/node/devices/nodeX/type for node type.

Software can interrogate node type for node memory type and distance
to get desirable target node in migration.

grep -r . /sys/devices/system/node/*/type
/sys/devices/system/node/node0/type:dram
/sys/devices/system/node/node1/type:dram
/sys/devices/system/node/node2/type:pmem
/sys/devices/system/node/node3/type:pmem

Along with next patch which export `peer_node`, migration daemon
could easily find the memory type of current node, and the target
node in case of migration.

grep -r . /sys/devices/system/node/*/peer_node
/sys/devices/system/node/node0/peer_node:2
/sys/devices/system/node/node1/peer_node:3
/sys/devices/system/node/node2/peer_node:0
/sys/devices/system/node/node3/peer_node:1

Signed-off-by: Fan Du <fan.du@intel.com>
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 drivers/base/node.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- linux.orig/drivers/base/node.c	2018-12-23 19:39:04.763414931 +0800
+++ linux/drivers/base/node.c	2018-12-23 19:39:04.763414931 +0800
@@ -233,6 +233,15 @@ static ssize_t node_read_distance(struct
 }
 static DEVICE_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+static ssize_t type_show(struct device *dev,
+			struct device_attribute *attr, char *buf)
+{
+	int nid = dev->id;
+
+	return sprintf(buf, is_node_pmem(nid) ? "pmem\n" : "dram\n");
+}
+static DEVICE_ATTR(type, S_IRUGO, type_show, NULL);
+
 static struct attribute *node_dev_attrs[] = {
 	&dev_attr_cpumap.attr,
 	&dev_attr_cpulist.attr,
@@ -240,6 +249,7 @@ static struct attribute *node_dev_attrs[
 	&dev_attr_numastat.attr,
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
+	&dev_attr_type.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);
