Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFE3F6B025E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 13:12:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so138004135lfg.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 10:12:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id yf9si14475332wjb.249.2016.08.04.10.12.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 10:12:30 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74H3xHl142888
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 13:12:29 -0400
Received: from e23smtp04.au.ibm.com (e23smtp04.au.ibm.com [202.81.31.146])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkajquf7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 13:12:28 -0400
Received: from localhost
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Fri, 5 Aug 2016 03:12:25 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 0EA902BB0057
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 03:12:24 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u74HCOvW29163698
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 03:12:24 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u74HCNSA017968
	for <linux-mm@kvack.org>; Fri, 5 Aug 2016 03:12:23 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH V2 2/2] fadump: Register the memory reserved by fadump
Date: Thu,  4 Aug 2016 22:42:09 +0530
In-Reply-To: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com>
Message-Id: <1470330729-6273-2-git-send-email-srikar@linux.vnet.ibm.com>
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
index 3cb3b02a..ca5ec88 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -330,6 +330,7 @@ int __init fadump_reserve_mem(void)
 	}
 	fw_dump.reserve_dump_area_start = base;
 	fw_dump.reserve_dump_area_size = size;
+	set_memory_reserve(size/PAGE_SIZE, true);
 	return 1;
 }
 
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
