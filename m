Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id AAEB86B0265
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:33 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so24182324wmg.1
        for <linux-mm@kvack.org>; Sun, 23 Oct 2016 21:32:33 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 136si10077555wma.71.2016.10.23.21.32.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Oct 2016 21:32:32 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9O4T2YR085764
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:31 -0400
Received: from e28smtp04.in.ibm.com (e28smtp04.in.ibm.com [125.16.236.4])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2689219869-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 00:32:31 -0400
Received: from localhost
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 10:02:27 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 86572E0040
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:14 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u9O4WNPM34996370
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:23 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u9O4WLHj021040
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 10:02:23 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [RFC 8/8] mm: Add N_COHERENT_DEVICE node type into node_states[]
Date: Mon, 24 Oct 2016 10:01:57 +0530
In-Reply-To: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1477283517-2504-9-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

Add a new member N_COHERENT_DEVICE into node_states[] nodemask array to
enlist all those nodes which contain only coherent device memory. Also
creates a new sysfs interface /sys/devices/system/node/is_coherent_device
to list down all those nodes which has coherent device memory.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 Documentation/ABI/stable/sysfs-devices-node |  7 +++++++
 drivers/base/node.c                         |  6 ++++++
 include/linux/nodemask.h                    |  3 +++
 mm/memory_hotplug.c                         | 10 ++++++++++
 4 files changed, 26 insertions(+)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 5b2d0f0..5538791 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -29,6 +29,13 @@ Description:
 		Nodes that have regular or high memory.
 		Depends on CONFIG_HIGHMEM.
 
+What:		/sys/devices/system/node/is_coherent_device
+Date:		October 2016
+Contact:	Linux Memory Management list <linux-mm@kvack.org>
+Description:
+		Lists the nodemask of nodes that have coherent memory.
+		Depends on CONFIG_COHERENT_DEVICE.
+
 What:		/sys/devices/system/node/nodeX
 Date:		October 2002
 Contact:	Linux Memory Management list <linux-mm@kvack.org>
diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f96..5b5dd89 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -661,6 +661,9 @@ static struct node_attr node_state_attr[] = {
 	[N_MEMORY] = _NODE_ATTR(has_memory, N_MEMORY),
 #endif
 	[N_CPU] = _NODE_ATTR(has_cpu, N_CPU),
+#ifdef CONFIG_COHERENT_DEVICE
+	[N_COHERENT_DEVICE] = _NODE_ATTR(is_coherent_device, N_COHERENT_DEVICE),
+#endif
 };
 
 static struct attribute *node_state_attrs[] = {
@@ -674,6 +677,9 @@ static struct attribute *node_state_attrs[] = {
 	&node_state_attr[N_MEMORY].attr.attr,
 #endif
 	&node_state_attr[N_CPU].attr.attr,
+#ifdef CONFIG_COHERENT_DEVICE
+	&node_state_attr[N_COHERENT_DEVICE].attr.attr,
+#endif
 	NULL
 };
 
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index f746e44..605cb0d 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -393,6 +393,9 @@ enum node_states {
 	N_MEMORY = N_HIGH_MEMORY,
 #endif
 	N_CPU,		/* The node has one or more cpus */
+#ifdef CONFIG_COHERENT_DEVICE
+	N_COHERENT_DEVICE,	/* The node has coherent device memory */
+#endif
 	NR_NODE_STATES
 };
 
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9629273..8f03962 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -1044,6 +1044,11 @@ static void node_states_set_node(int node, struct memory_notify *arg)
 	if (arg->status_change_nid_high >= 0)
 		node_set_state(node, N_HIGH_MEMORY);
 
+#ifdef CONFIG_COHERENT_DEVICE
+	if (isolated_cdm_node(node))
+		node_set_state(node, N_COHERENT_DEVICE);
+#endif
+
 	node_set_state(node, N_MEMORY);
 }
 
@@ -1858,6 +1863,11 @@ static void node_states_clear_node(int node, struct memory_notify *arg)
 	if ((N_MEMORY != N_HIGH_MEMORY) &&
 	    (arg->status_change_nid >= 0))
 		node_clear_state(node, N_MEMORY);
+
+#ifdef CONFIG_COHERENT_DEVICE
+	if (isolated_cdm_node(node))
+		node_clear_state(node, N_COHERENT_DEVICE);
+#endif
 }
 
 static int __ref __offline_pages(unsigned long start_pfn,
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
