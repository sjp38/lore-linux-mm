Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9F02C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75810218B0
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 20:03:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75810218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 833D86B0006; Thu, 21 Mar 2019 16:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BBFE6B0007; Thu, 21 Mar 2019 16:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 60D066B0008; Thu, 21 Mar 2019 16:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2653C6B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 16:02:59 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id h69so1011305pfd.21
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 13:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ZXflYn009/8re0hSvilHhjOsKnJ5N944EbzSGROrxW8=;
        b=XSVJ7LFUKYA/yWGO5bWWZYRyKej3dmSsHN1haKTbbjpU3BcgefJbn9pQ2udl5XzZ+l
         10IVmAqWC0tks0xXm8Nf93A2qRxlQqnhkp6YxXJUNRREFoaL8z2BB8kZMP/DJLPUICLT
         GTplQZOGPhB/q5nxle2zkP0YvMhRKlOSxMukGpJY3oH2RZZ+Fa0g1hi2xn5KpsjqmZZi
         g6v53ZWMODwmQlI8PIp5VO79zN2k3gqtbqrJqtP+xXsG2MWO6cwiQCRJK+mWH6ZGmBhI
         Eutqs+/k13fD2Y9EH4+v+hBA6WQd3fjaw7UoT83pxci/s1LHUULBYmVsm0rCLR4BieJa
         3uUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXv3hdko6JLVZ+j+W/bZpLoRWGl9xsE3gZzTF8YeNu/x/rfWIFs
	bmC5YLmLcovkQDFsNTF7f0PI0C3hzxZqrE/HCwU83TAXKBSNzSHU9k/y9WmZQxGc0CmHBAnULT4
	YHLj25AZSkJJFKBO8gWsRRjqBHCxPxrpfHGSAd/Rlv+sr9MBJ5cgb4dVfI5oMhJcjBQ==
X-Received: by 2002:a17:902:848e:: with SMTP id c14mr5398989plo.339.1553198578677;
        Thu, 21 Mar 2019 13:02:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPTkoq4Hw5/6XvqxuGt43MX/ISDDB/hFtQ3QTTgWMOHj8vYISeE1IiDSBBt7e+WzC00Ms0
X-Received: by 2002:a17:902:848e:: with SMTP id c14mr5398857plo.339.1553198577161;
        Thu, 21 Mar 2019 13:02:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553198577; cv=none;
        d=google.com; s=arc-20160816;
        b=U9WasszvzveInC8tWnM4aNxXC16PQSPbvoEVMm5HUMqGLEPAvR6fQTTQMr5FLN9Tsu
         /Jj2Tz/ufaQBcf1OWS1yFxeXw9pEiInhN7yemKMsrqY9rZelOFb4k1vFm2MjxVImVIQE
         pKPerpjKGhCsC5txgV1ym5cOlZGnpuFkoKeY6mHK1K970PexZrZZ2qBhNM0S4DYp9Io6
         DzgmiNuxSNq7GNbL8r4zkDfC9EKYx0uVgwYHrtkDeZUTONIdrXPtHryM7PuAscUhIf3j
         oTL5037eM2EpCnRZmKUsUAPVuWz+d3t8bFn9YKeZFgbgd2mt8KKCwZcJGwyffDVmHRJO
         DUXw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ZXflYn009/8re0hSvilHhjOsKnJ5N944EbzSGROrxW8=;
        b=zZDdSLi35a3M/pAK0S89ua2foos9naayPSrEy1ceNp+xosaFQ/45RKXR5Z3OPDd+MO
         6h0ceKhhbXI3MaxonFFZJ0v1c40eiysBJfrMGWBCKWGQEAZKbJ7mGD1Br2csEyR4J2C3
         in3Hn4xLsPeO5eu3/21VwMnzl7K8uifnWuB7BQR/VGTQewu/GLE+VJ0w4bLkI3L4Va36
         +u5maIS/uF7x7kQiyRcKAhzLSjhpatKfa1dFjWUY6Zu0rKfALFE4gMSDVQnZmAaHobHQ
         TME8WbSzGp7CsR7ZbRC6U3gR5sOqWugEK8bVP1uQ/gvG2aAhGP8gUG/wt0IkkYu23zml
         lxtg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id r25si4703408pfd.91.2019.03.21.13.02.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Mar 2019 13:02:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Mar 2019 13:02:56 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,254,1549958400"; 
   d="scan'208";a="309246233"
Received: from unknown (HELO localhost.lm.intel.com) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 21 Mar 2019 13:02:56 -0700
From: Keith Busch <keith.busch@intel.com>
To: linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nvdimm@lists.01.org
Cc: Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Keith Busch <keith.busch@intel.com>
Subject: [PATCH 1/5] node: Define and export memory migration path
Date: Thu, 21 Mar 2019 14:01:53 -0600
Message-Id: <20190321200157.29678-2-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190321200157.29678-1-keith.busch@intel.com>
References: <20190321200157.29678-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Prepare for the kernel to auto-migrate pages to other memory nodes with a
user defined node migration table. A user may create a single target for
each NUMA node to enable the kernel to do NUMA page migrations instead
of simply reclaiming colder pages. A node with no target is a "terminal
node", so reclaim acts normally there.  The migration target does not
fundamentally _need_ to be a single node, but this implementation starts
there to limit complexity.

If you consider the migration path as a graph, cycles (loops) in the graph
are disallowed.  This avoids wasting resources by constantly migrating
(A->B, B->A, A->B ...).  The expectation is that cycles will never be
allowed.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 11 ++++-
 drivers/base/node.c                         | 73 +++++++++++++++++++++++++++++
 include/linux/node.h                        |  6 +++
 3 files changed, 89 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 3e90e1f3bf0a..7439e1845e5d 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,13 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/admin-guide/mm/hugetlbpage.rst
\ No newline at end of file
+		See Documentation/admin-guide/mm/hugetlbpage.rst
+
+What:		/sys/devices/system/node/nodeX/migration_path
+Data		March 2019
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		Defines which node the kernel should attempt to migrate this
+		node's pages to when this node requires memory reclaim. A
+		negative value means this is a terminal node and memory can not
+		be reclaimed through kernel managed migration.
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 86d6cd92ce3d..20a90905555f 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -59,6 +59,10 @@ static inline ssize_t node_read_cpulist(struct device *dev,
 static DEVICE_ATTR(cpumap,  S_IRUGO, node_read_cpumask, NULL);
 static DEVICE_ATTR(cpulist, S_IRUGO, node_read_cpulist, NULL);
 
+#define TERMINAL_NODE -1
+static int node_migration[MAX_NUMNODES] = {[0 ...  MAX_NUMNODES - 1] = TERMINAL_NODE};
+static DEFINE_SPINLOCK(node_migration_lock);
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
@@ -233,6 +237,74 @@ static ssize_t node_read_distance(struct device *dev,
 }
 static DEVICE_ATTR(distance, S_IRUGO, node_read_distance, NULL);
 
+static ssize_t migration_path_show(struct device *dev,
+				   struct device_attribute *attr,
+				   char *buf)
+{
+	return sprintf(buf, "%d\n", node_migration[dev->id]);
+}
+
+static ssize_t migration_path_store(struct device *dev,
+				    struct device_attribute *attr,
+				    const char *buf, size_t count)
+{
+	int i, err, nid = dev->id;
+	nodemask_t visited = NODE_MASK_NONE;
+	long next;
+
+	err = kstrtol(buf, 0, &next);
+	if (err)
+		return -EINVAL;
+
+	if (next < 0) {
+		spin_lock(&node_migration_lock);
+		WRITE_ONCE(node_migration[nid], TERMINAL_NODE);
+		spin_unlock(&node_migration_lock);
+		return count;
+	}
+	if (next > MAX_NUMNODES || !node_online(next))
+		return -EINVAL;
+
+	/*
+	 * Follow the entire migration path from 'nid' through the point where
+	 * we hit a TERMINAL_NODE.
+	 *
+	 * Don't allow looped migration cycles in the path.
+	 */
+	node_set(nid, visited);
+	spin_lock(&node_migration_lock);
+	for (i = next; node_migration[i] != TERMINAL_NODE;
+	     i = node_migration[i]) {
+		/* Fail if we have visited this node already */
+		if (node_test_and_set(i, visited)) {
+			spin_unlock(&node_migration_lock);
+			return -EINVAL;
+		}
+	}
+	WRITE_ONCE(node_migration[nid], next);
+	spin_unlock(&node_migration_lock);
+
+	return count;
+}
+static DEVICE_ATTR_RW(migration_path);
+
+/**
+ * next_migration_node() - Get the next node in the migration path
+ * @current_node: The starting node to lookup the next node
+ *
+ * @returns: node id for next memory node in the migration path hierarchy from
+ * 	     @current_node; -1 if @current_node is terminal or its migration
+ * 	     node is not online.
+ */
+int next_migration_node(int current_node)
+{
+	int nid = READ_ONCE(node_migration[current_node]);
+
+	if (nid >= 0 && node_online(nid))
+		return nid;
+	return TERMINAL_NODE;
+}
+
 static struct attribute *node_dev_attrs[] = {
 	&dev_attr_cpumap.attr,
 	&dev_attr_cpulist.attr,
@@ -240,6 +312,7 @@ static struct attribute *node_dev_attrs[] = {
 	&dev_attr_numastat.attr,
 	&dev_attr_distance.attr,
 	&dev_attr_vmstat.attr,
+	&dev_attr_migration_path.attr,
 	NULL
 };
 ATTRIBUTE_GROUPS(node_dev);
diff --git a/include/linux/node.h b/include/linux/node.h
index 257bb3d6d014..af46c7a8b94f 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -67,6 +67,7 @@ static inline int register_one_node(int nid)
 	return error;
 }
 
+extern int next_migration_node(int current_node);
 extern void unregister_one_node(int nid);
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
@@ -115,6 +116,11 @@ static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
 						node_registration_func_t unreg)
 {
 }
+
+static inline int next_migration_node(int current_node)
+{
+	return -1;
+}
 #endif
 
 #define to_node(device) container_of(device, struct node, dev)
-- 
2.14.4

