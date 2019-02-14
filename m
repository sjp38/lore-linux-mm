Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 64001C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1E09A222D7
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 17:10:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1E09A222D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E9B9E8E0008; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E46A78E0004; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C72C98E0008; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA258E0004
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 12:10:43 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id g9so5253601pfe.7
        for <linux-mm@kvack.org>; Thu, 14 Feb 2019 09:10:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ocaJkawRpMJqSCtZ0KZGuMjYQxsTMNTIjLHCfaSASoc=;
        b=p4+UxyzaiC/2XgXQSrsZocDLpp4qXmjrplB4vMRV3LZhnG8uxZ6HqPxwnqO0ImJycQ
         lYgKstyOv1OhLOooRiUjF2pZ3/GOh0iPT17o6qbdXCi3e3Wz1SXcUxRW1OejiJG4YLkP
         7vQVoezeX/59Zm+7KmZX6gzMnzWx+6i2P1bWLYw39cms4wWrPmhs6KcWhF97WcYss9qq
         7W28zktMB5pZcE1Xhq6OtL/wB/MwuBtS4rGPedUOlv/qxT8PBzRFPo/GduHMs4VOQmCr
         LPDdkJsWYAXL8xA9dnNtF2f3GPyZNBdlfz4Nx9SOiCrEZ058Sqq3qt2rE8qSy2WYVgB8
         S9rw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuawtdKQIV1NtYvAF60oZCxyeh89VUQF7Y0+Fc/K1+7e05wrHiru
	duKB8nSawg3+z8RtQFE/wacZWaLt+78ee6bTge6/0L5pXADNe2c3TdXWTG3LfKmaXEhx0iJ5rjn
	pd7VYJgfLPmhuymhh4pUmSNAt/byiPhpTUBtvdxnM0es2/pkEJYqnd9+A82Xt/1vzlQ==
X-Received: by 2002:a17:902:8f98:: with SMTP id z24mr5191346plo.40.1550164243074;
        Thu, 14 Feb 2019 09:10:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaV1wYNXVL+r5VuaW6Q4Op0yfKjLHcJqJBFLeH+QRqXbPJ3R6TXQ88t6dsNbPH8UmW+oWxv
X-Received: by 2002:a17:902:8f98:: with SMTP id z24mr5191270plo.40.1550164241977;
        Thu, 14 Feb 2019 09:10:41 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550164241; cv=none;
        d=google.com; s=arc-20160816;
        b=sJXSeSJeMar701F9UBVhR4t8rDLEEdIZcw5SjIF3w3djv5wbeur72WB7BwYXPSwEKN
         PVK7HcqtndzRN9GaAjn+ROYD2hi/zMKNkNpQDJz2y5g9WNzbkHQ+iVrI2FnfEJsBUjah
         1R7zI7xa40Usc6eAyU8Id+BQq1S116EybyDY5H8zpsonchJ62Ge6LQJRw/sqx9UiD0qF
         jrY7NSOuwbvLongoITwFG0tmcl5I7ERgKHwUKnmSkyCtVVqCRxyC1cK8gioiyydsrvHh
         S5Cc/sO64f3SqLIafbLBYaSfvhX4d3hhLpgYEPnLmHic0KxXLirCTeJh9eYSP2wyNNaI
         s4Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ocaJkawRpMJqSCtZ0KZGuMjYQxsTMNTIjLHCfaSASoc=;
        b=UEAqDL3ZeWlX+HO1dtL5EhXDypdrIMp6Ko2O2869eYPFbZIMM4JaMhW7xM7YHW+PUp
         Fr7V/Qla29V46529i1/HwuuYLUvfRV/k6YX1n3uor7GHBwmYF0tCmlfGpcZr3dXKetdz
         s+TIs8LPkaDeiYKfxlQBd4wM1kWnuWAPJqrZ8v2lvXuQMkaKnfenRT6uNx4xv+W3mCd3
         jUE2I22gnoaFDgkh8men6Y+IfXYAsrh4EL2wrLMYRaKTCSVs/+g6hm6oTttvnjj9muoJ
         esHAXBscG0M87mgRYkle/PvoquJ5NXCX8gx1gWWo53VHfYDXAzchbzMaGuuDL394vj3v
         132w==
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
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 14 Feb 2019 09:10:41 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,369,1544515200"; 
   d="scan'208";a="133613118"
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
Subject: [PATCHv6 05/10] node: Add heterogenous memory access attributes
Date: Thu, 14 Feb 2019 10:10:12 -0700
Message-Id: <20190214171017.9362-6-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190214171017.9362-1-keith.busch@intel.com>
References: <20190214171017.9362-1-keith.busch@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Heterogeneous memory systems provide memory nodes with different latency
and bandwidth performance attributes. Provide a new kernel interface
for subsystems to register the attributes under the memory target
node's initiator access class. If the system provides this information,
applications may query these attributes when deciding which node to
request memory.

The following example shows the new sysfs hierarchy for a node exporting
performance attributes:

  # tree -P "read*|write*"/sys/devices/system/node/nodeY/accessZ/initiators/
  /sys/devices/system/node/nodeY/accessZ/initiators/
  |-- read_bandwidth
  |-- read_latency
  |-- write_bandwidth
  `-- write_latency

The bandwidth is exported as MB/s and latency is reported in
nanoseconds. The values are taken from the platform as reported by the
manufacturer.

Memory accesses from an initiator node that is not one of the memory's
access "Z" initiator nodes linked in the same directory may observe
different performance than reported here. When a subsystem makes use
of this interface, initiators of a different access number may not have
the same performance relative to initiators in other access numbers, or
omitted from the any access class' initiators.

Descriptions for memory access initiator performance access attributes
are added to sysfs stable documentation.

Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 31 ++++++++++++++-
 drivers/base/Kconfig                        |  8 ++++
 drivers/base/node.c                         | 59 +++++++++++++++++++++++++++++
 include/linux/node.h                        | 19 ++++++++++
 4 files changed, 116 insertions(+), 1 deletion(-)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index fb843222a281..cd64b62152ba 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -106,7 +106,8 @@ Description:
 		nodes that have class "Y" access to this target node's
 		memory. CPUs and other memory initiators in nodes not in
 		the list accessing this node's memory may have different
-		performance.
+		performance. This directory also provides the performance
+		attributes if they exist.
 
 What:		/sys/devices/system/node/nodeX/classY/targets/
 Date:		December 2018
@@ -114,3 +115,31 @@ Contact:	Keith Busch <keith.busch@intel.com>
 Description:
 		The directory containing symlinks to memory targets that
 		this initiator node has class "Y" access.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read bandwidth in MB/s when accessed from
+		nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/read_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's read latency in nanoseconds when accessed
+		from nodes found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_bandwidth
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write bandwidth in MB/s when accessed from
+		found in this access class's linked initiators.
+
+What:		/sys/devices/system/node/nodeX/accessY/initiators/write_latency
+Date:		December 2018
+Contact:	Keith Busch <keith.busch@intel.com>
+Description:
+		This node's write latency in nanoseconds when access
+		from nodes found in this class's linked initiators.
diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 3e63a900b330..32dc81bd7056 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -149,6 +149,14 @@ config DEBUG_TEST_DRIVER_REMOVE
 	  unusable. You should say N here unless you are explicitly looking to
 	  test this functionality.
 
+config HMEM_REPORTING
+	bool
+	default n
+	depends on NUMA
+	help
+	  Enable reporting for heterogenous memory access attributes under
+	  their non-uniform memory nodes.
+
 source "drivers/base/test/Kconfig"
 
 config SYS_HYPERVISOR
diff --git a/drivers/base/node.c b/drivers/base/node.c
index d1ec38db4e77..a1795c9c9f7d 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -71,6 +71,9 @@ struct node_access_nodes {
 	struct device		dev;
 	struct list_head	list_node;
 	unsigned		access;
+#ifdef CONFIG_HMEM_REPORTING
+	struct node_hmem_attrs	hmem_attrs;
+#endif
 };
 #define to_access_nodes(dev) container_of(dev, struct node_access_nodes, dev)
 
@@ -148,6 +151,62 @@ static struct node_access_nodes *node_init_node_access(struct node *node,
 	return NULL;
 }
 
+#ifdef CONFIG_HMEM_REPORTING
+#define ACCESS_ATTR(name) 						   \
+static ssize_t name##_show(struct device *dev,				   \
+			   struct device_attribute *attr,		   \
+			   char *buf)					   \
+{									   \
+	return sprintf(buf, "%u\n", to_access_nodes(dev)->hmem_attrs.name); \
+}									   \
+static DEVICE_ATTR_RO(name);
+
+ACCESS_ATTR(read_bandwidth)
+ACCESS_ATTR(read_latency)
+ACCESS_ATTR(write_bandwidth)
+ACCESS_ATTR(write_latency)
+
+static struct attribute *access_attrs[] = {
+	&dev_attr_read_bandwidth.attr,
+	&dev_attr_read_latency.attr,
+	&dev_attr_write_bandwidth.attr,
+	&dev_attr_write_latency.attr,
+	NULL,
+};
+
+/**
+ * node_set_perf_attrs - Set the performance values for given access class
+ * @nid: Node identifier to be set
+ * @hmem_attrs: Heterogeneous memory performance attributes
+ * @access: The access class the for the given attributes
+ */
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access)
+{
+	struct node_access_nodes *c;
+	struct node *node;
+	int i;
+
+	if (WARN_ON_ONCE(!node_online(nid)))
+		return;
+
+	node = node_devices[nid];
+	c = node_init_node_access(node, access);
+	if (!c)
+		return;
+
+	c->hmem_attrs = *hmem_attrs;
+	for (i = 0; access_attrs[i] != NULL; i++) {
+		if (sysfs_add_file_to_group(&c->dev.kobj, access_attrs[i],
+					    "initiators")) {
+			pr_info("failed to add performance attribute to node %d\n",
+				nid);
+			break;
+		}
+	}
+}
+#endif
+
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 static ssize_t node_read_meminfo(struct device *dev,
 			struct device_attribute *attr, char *buf)
diff --git a/include/linux/node.h b/include/linux/node.h
index f34688a203c1..2db077363d9c 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -20,6 +20,25 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 
+#ifdef CONFIG_HMEM_REPORTING
+/**
+ * struct node_hmem_attrs - heterogeneous memory performance attributes
+ *
+ * @read_bandwidth:	Read bandwidth in MB/s
+ * @write_bandwidth:	Write bandwidth in MB/s
+ * @read_latency:	Read latency in nanoseconds
+ * @write_latency:	Write latency in nanoseconds
+ */
+struct node_hmem_attrs {
+	unsigned int read_bandwidth;
+	unsigned int write_bandwidth;
+	unsigned int read_latency;
+	unsigned int write_latency;
+};
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access);
+#endif
+
 struct node {
 	struct device	dev;
 	struct list_head access_list;
-- 
2.14.4

