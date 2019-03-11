Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04D11C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB5E9214D8
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 20:55:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB5E9214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 55F3E8E0008; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BC9E8E0002; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24F718E0008; Mon, 11 Mar 2019 16:55:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF8648E0007
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 16:55:43 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d128so162400pgc.8
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=KbttTh3eqkHzrW27swTgG5x2inWkFeWu3T6cGYKjOtI=;
        b=tO8OVHwcaJNBkYhcmkMlIMTIsaWAF5ZfXEipgeuar85JUVQNmCNcbElyoE6zI/NUYd
         7ugwGo+bTSoyGxxJwtWkvVaL3TK/BIVodu/6DYluVEfRxqdk7AEjSAcoA6lukfmbSRES
         aZoy6FI2X7VSHBdfmojUS35Y8OIqiAiSw+d5URypeEL7OvYr8rpOn+9OfuZAjqDgNOZp
         GflhJjFupRMT89jWZsVTS6voJtuwBQ37mMYAsqOeGbMVj1wxqnH1+C5RYClpfXYaJY0l
         LBg/7eIefvIu1yIlhpg9TrkZEI+OcinTtJsZXIBQBz9AkHhB0QJLtDCtcJohinKv6K4q
         Qhvg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVwpytCLiYFMF51ZghcLGhkBo6kH7ABRQ3WCu77CM/EZRjT6leI
	caWxCeHwjGbQ0MS+1YXIYob9CvmXDNa2Ib9+O3rZ6/iBvItW4BnidfoEpaT5xH+f1uFYUGwkZUw
	l2lYAptLumlO4iDoqywX2Y6ftO4FwCSvjG0k+DNi/Oz1CW8Xy29nAygsJrMFMYrQolQ==
X-Received: by 2002:a63:e654:: with SMTP id p20mr14721507pgj.345.1552337743490;
        Mon, 11 Mar 2019 13:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxdY5pb4qJEHlEakC6a98UrKs77kwGLjQYpsYOuWQ884d68dMl7dpzBQB8YJjuxJhZZoE9X
X-Received: by 2002:a63:e654:: with SMTP id p20mr14721453pgj.345.1552337742261;
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552337742; cv=none;
        d=google.com; s=arc-20160816;
        b=E+0kr5dOAQ2CzRbbJcs5RujcCndokUfltDex9E/NJb2XEA4yFlzCz/h0B5+P2KwJ5f
         TdFTcietnmFJimhNvDE0C/wcnU2JslPBvE4qw2sP1seuUCi8bPHiKYHOZgOrq1x8wb4E
         FbAGBLoNdj/gerKfoxUzJmQkEMMSjXlcuo8Wu//9Ls8fbimCWWY/duk7uahfCvvKSS6w
         htVA32YubqD2NtMqXPGqGAI5CCRqyFJBQkCPr94Ym5+phh8uVC3VGJJwz9Dc+lnHNrKi
         fVZ+BxCls7pibRykWdBvxHtXCBZWlFRb36868ecFeHl9fXtJ4g0S0ZMNxzb58TSGWCxh
         v02A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=KbttTh3eqkHzrW27swTgG5x2inWkFeWu3T6cGYKjOtI=;
        b=Wx0LOwRfUQjF3fNi+VtJesvH3+0gKfOIZf03nfY+OVz1EIJx0gbf8TZYxig7Tzqkoy
         ZSM1CCqL5k5v09HTh1LE1pT0GsZN7piMBRQDkAzvrZz7Zp+guBWdDzc1dNBrzOf0CB0y
         NF29V+ffPA0btdbeoK7RPMYanyJ5axensCwBfN0VIhKUDqcjZNxwnm+/MUpVzHUG91FK
         kQGrMXTfjp038y8saRO9wAML9QsPXo+hMRqhweNfLc5R9VK6UD63SI720n6WXJ5zcZl5
         ObwT8qHrvEDqBKH7Sm+1IZI59rBrBwpjLm1GTx+eDFPPLjAegqEn8U4rJQ6lfRcw6pk+
         AGdA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id n189si5626588pga.46.2019.03.11.13.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Mar 2019 13:55:42 -0700 (PDT)
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
   d="scan'208";a="139910175"
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
Subject: [PATCHv8 05/10] node: Add heterogenous memory access attributes
Date: Mon, 11 Mar 2019 14:56:01 -0600
Message-Id: <20190311205606.11228-6-keith.busch@intel.com>
X-Mailer: git-send-email 2.13.6
In-Reply-To: <20190311205606.11228-1-keith.busch@intel.com>
References: <20190311205606.11228-1-keith.busch@intel.com>
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

Acked-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Signed-off-by: Keith Busch <keith.busch@intel.com>
---
 Documentation/ABI/stable/sysfs-devices-node | 28 ++++++++++++++
 drivers/base/Kconfig                        |  8 ++++
 drivers/base/node.c                         | 59 +++++++++++++++++++++++++++++
 include/linux/node.h                        | 26 +++++++++++++
 4 files changed, 121 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 433bcc04e542..735a40a3f9b2 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -114,3 +114,31 @@ Contact:	Keith Busch <keith.busch@intel.com>
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
index 059700ea3521..a7438a58c250 100644
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
index 6f4097680580..2de546a040a5 100644
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
index bb288817ed33..4139d728f8b3 100644
--- a/include/linux/node.h
+++ b/include/linux/node.h
@@ -20,6 +20,32 @@
 #include <linux/list.h>
 #include <linux/workqueue.h>
 
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
+
+#ifdef CONFIG_HMEM_REPORTING
+void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
+			 unsigned access);
+#else
+static inline void node_set_perf_attrs(unsigned int nid,
+				       struct node_hmem_attrs *hmem_attrs,
+				       unsigned access)
+{
+}
+#endif
+
 struct node {
 	struct device	dev;
 	struct list_head access_list;
-- 
2.14.4

