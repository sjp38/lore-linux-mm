Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 888956B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:45:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l4so147385072wml.0
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:45:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ev12si13720180wjc.104.2016.08.04.06.45.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:45:44 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74DiFds012666
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 09:45:43 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kkak58tp-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 09:45:42 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 23:45:37 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 61EE82BB0057
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 23:45:35 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u74DjZIL22610084
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 23:45:35 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u74DjYhn025733
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 23:45:35 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH] fadump: Register the memory reserved by fadump
Date: Thu,  4 Aug 2016 19:12:45 +0530
Message-Id: <1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Fadump kernel reserves large chunks of memory even before the pages are
initialized. This could mean memory that corresponds to several nodes might
fall in memblock reserved regions.

Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialize
only certain size memory per node. The certain size takes into account
the dentry and inode cache sizes. Currently the cache sizes are
calculated based on the total system memory including the reserved
memory. However such a kernel when booting the same kernel as fadump
kernel will not be able to allocate the required amount of memory to
suffice for the dentry and inode caches. This results in crashes like
the below on large systems such as 32 TB systems.

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

Register the memory reserved by fadump, so that the cache sizes are
calculated based on the free memory (i.e Total memory - reserved
memory).

Suggested-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/powerpc/kernel/fadump.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
index 3cb3b02a..eae547d 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -330,6 +330,7 @@ int __init fadump_reserve_mem(void)
 	}
 	fw_dump.reserve_dump_area_start = base;
 	fw_dump.reserve_dump_area_size = size;
+	set_dma_reserve(size/PAGE_SIZE);
 	return 1;
 }
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
