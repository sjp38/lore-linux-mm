Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 15F7C6B025F
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:19:32 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so94511254lfw.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:19:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b73si3189931wmi.47.2016.08.02.06.19.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:19:30 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u72DEpBS054326
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 09:19:29 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24gre2hp7p-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:19:29 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Aug 2016 23:19:26 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 2A5EA2CE802D
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 23:19:25 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u72DJPS924313900
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:25 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u72DJOEA023235
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:25 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mm: Allow disabling deferred struct page initialisation
Date: Tue,  2 Aug 2016 18:49:06 +0530
In-Reply-To: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
Message-Id: <1470143947-24443-2-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialise
only certain size memory per node. The certain size takes into account
the dentry and inode cache sizes. However such a kernel when booting a
secondary kernel will not be able to allocate the required amount of
memory to suffice for the dentry and inode caches. This results in
crashes like the below on large systems such as 32 TB systems.

Dentry cache hash table entries: 536870912 (order: 16, 4294967296 bytes)
vmalloc: allocation failure, allocated 4097114112 of 17179934720 bytes
swapper/0: page allocation failure: order:0, mode:0x2080020(GFP_ATOMIC)
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.6-master+ #3
Call Trace:
[c00000000108fb10] [c0000000007fac88] dump_stack+0xb0/0xf0 (unreliable)
[c00000000108fb50] [c000000000235264] warn_alloc_failed+0x114/0x160
[c00000000108fbf0] [c000000000281484] __vmalloc_node_range+0x304/0x340
[c00000000108fca0] [c00000000028152c] __vmalloc+0x6c/0x90
[c00000000108fd40] [c000000000aecfb0]
alloc_large_system_hash+0x1b8/0x2c0
[c00000000108fe00] [c000000000af7240] inode_init+0x94/0xe4
[c00000000108fe80] [c000000000af6fec] vfs_caches_init+0x8c/0x13c
[c00000000108ff00] [c000000000ac4014] start_kernel+0x50c/0x578
[c00000000108ff90] [c000000000008c6c] start_here_common+0x20/0xa8

Allow such kernels to disable deferred page struct initialisation.

Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 include/linux/mmzone.h |  2 +-
 mm/page_alloc.c        | 20 ++++++++++++++++++++
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c60df92..1c55200 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1203,7 +1203,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #else
 #define pfn_valid_within(pfn) (1)
 #endif
-
+void disable_deferred_meminit(void);
 #ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
 /*
  * pfn_valid() is meant to be able to tell if a given PFN has valid memmap
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c1069ef..dc6ebac 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -301,6 +301,19 @@ static inline bool early_page_nid_uninitialised(unsigned long pfn, int nid)
 }
 
 /*
+ * Deferred struct page initialisation may not work on a multinode machine,
+ * if a significant amount of memory is reserved at early boot.  Allow apis
+ * that reserve significant memory to disable deferred struct page
+ * initialisation.
+ */
+static bool defer_init_disabled;
+
+void disable_deferred_meminit(void)
+{
+	defer_init_disabled = true;
+}
+
+/*
  * Returns false when the remaining initialisation should be deferred until
  * later in the boot cycle when it can be parallelised.
  */
@@ -313,6 +326,9 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 	/* Always populate low zones for address-contrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
+
+	if (defer_init_disabled)
+		return true;
 	/*
 	 * Initialise at least 2G of a node but also take into account that
 	 * two large system hashes that can take up 1GB for 0.25TB/node.
@@ -350,6 +366,10 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 {
 	return true;
 }
+void disable_deferred_meminit(void)
+{
+}
+
 #endif
 
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
