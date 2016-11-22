Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6FFB86B026B
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:12 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g186so30631123pgc.2
        for <linux-mm@kvack.org>; Tue, 22 Nov 2016 06:20:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o189si15903761pgo.333.2016.11.22.06.20.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Nov 2016 06:20:11 -0800 (PST)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAMEJDD1087197
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:11 -0500
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26vnp9tpn5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 22 Nov 2016 09:20:10 -0500
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 23 Nov 2016 00:20:08 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id DB00A2BB0055
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:05 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uAMEK51i35979308
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:05 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uAMEK5W8016055
	for <linux-mm@kvack.org>; Wed, 23 Nov 2016 01:20:05 +1100
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: [DEBUG 05/12] powerpc/mm: Identify coherent device memory nodes during platform init
Date: Tue, 22 Nov 2016 19:49:41 +0530
In-Reply-To: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
References: <1479824388-30446-1-git-send-email-khandual@linux.vnet.ibm.com>
Message-Id: <1479824388-30446-6-git-send-email-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com

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
index 31efc27..b625e0e 100644
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
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
