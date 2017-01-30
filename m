Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79E936B027C
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:56 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id c85so64801897wmi.6
        for <linux-mm@kvack.org>; Sun, 29 Jan 2017 19:38:56 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t2si11704605wma.79.2017.01.29.19.38.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 29 Jan 2017 19:38:55 -0800 (PST)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0U3YOg0106663
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:53 -0500
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 289c9uhbuy-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 29 Jan 2017 22:38:53 -0500
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Mon, 30 Jan 2017 13:38:50 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 79CA32BB0057
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:48 +1100 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0U3cebe25100308
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:48 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0U3cGE3021481
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 14:38:16 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 13/21] powerpc/mm: Identify coherent device memory nodes during platform init
Date: Mon, 30 Jan 2017 09:05:54 +0530
In-Reply-To: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
Message-Id: <20170130033602.12275-14-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com

Coherent device memory nodes will have "ibm,hotplug-aperture" as one of the
compatible properties in their respective device nodes in the device tree.
Detect them early during NUMA platform initialization and mark them as such
in the node_to_phys_device_map[] array which in turn is used to support the
arch_check_cdm_node() function for the core VM.

Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
---
 arch/powerpc/mm/numa.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/mm/numa.c b/arch/powerpc/mm/numa.c
index 9c73fbe..6def078 100644
--- a/arch/powerpc/mm/numa.c
+++ b/arch/powerpc/mm/numa.c
@@ -41,10 +41,12 @@
 #include <asm/setup.h>
 #include <asm/vdso.h>
 
+static int node_to_phys_device_map[MAX_NUMNODES];
+
 #ifdef CONFIG_COHERENT_DEVICE
 int arch_check_node_cdm(int nid)
 {
-	return 0;
+	return node_to_phys_device_map[nid];
 }
 #endif
 
@@ -790,6 +792,9 @@ static int __init parse_numa_properties(void)
 		if (nid < 0)
 			nid = default_nid;
 
+		if (of_device_is_compatible(memory, "ibm,hotplug-aperture"))
+			node_to_phys_device_map[nid] = 1;
+
 		fake_numa_create_new_node(((start + size) >> PAGE_SHIFT), &nid);
 		node_set_online(nid);
 
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
