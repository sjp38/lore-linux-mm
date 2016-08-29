Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id C7956830F1
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:08:03 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id x93so42008343ybh.2
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:08:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w10si23196843qta.121.2016.08.29.06.08.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:08:03 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7TD4T4L039270
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:08:02 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0b-001b2d01.pphosted.com with ESMTP id 253r8snpgr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:08:02 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 23:07:59 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id E77402BB0059
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:56 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7TD7uer59965644
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:56 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7TD7uZJ013265
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:56 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH v3 3/3] powerpc: Implement arch_reserved_kernel_pages
Date: Mon, 29 Aug 2016 18:36:50 +0530
In-Reply-To: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
References: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
Message-Id: <1472476010-4709-4-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Currently significant amount of memory is reserved only in kernel
booted to capture kernel dump using the fa_dump method.

Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialize
only certain size memory per node. The certain size takes into account
the dentry and inode cache sizes. Currently the cache sizes are
calculated based on the total system memory including the reserved
memory. However such a kernel when booting the same kernel as fadump
kernel will not be able to allocate the required amount of memory to
suffice for the dentry and inode caches. This results in crashes like

Hence only implement arch_reserved_kernel_pages() for CONFIG_FA_DUMP
configurations. The amount reserved will be reduced while calculating
the large caches and will avoid crashes like the below on large systems
such as 32 TB systems.

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

Cc: linux-mm@kvack.org
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>
Cc: Hari Bathini <hbathini@linux.vnet.ibm.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Suggested-by: Michael Ellerman <mpe@ellerman.id.au>
Signed-off-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
---
 arch/powerpc/include/asm/mmzone.h | 3 +++
 arch/powerpc/kernel/fadump.c      | 5 +++++
 2 files changed, 8 insertions(+)

diff --git a/arch/powerpc/include/asm/mmzone.h b/arch/powerpc/include/asm/mmzone.h
index 7b58917..4d52ccf 100644
--- a/arch/powerpc/include/asm/mmzone.h
+++ b/arch/powerpc/include/asm/mmzone.h
@@ -41,6 +41,9 @@ u64 memory_hotplug_max(void);
 #else
 #define memory_hotplug_max() memblock_end_of_DRAM()
 #endif /* CONFIG_NEED_MULTIPLE_NODES */
+#ifdef CONFIG_FA_DUMP
+#define __HAVE_ARCH_RESERVED_KERNEL_PAGES
+#endif
 
 #endif /* __KERNEL__ */
 #endif /* _ASM_MMZONE_H_ */
diff --git a/arch/powerpc/kernel/fadump.c b/arch/powerpc/kernel/fadump.c
index b3a6633..eeb80de 100644
--- a/arch/powerpc/kernel/fadump.c
+++ b/arch/powerpc/kernel/fadump.c
@@ -333,6 +333,11 @@ int __init fadump_reserve_mem(void)
 	return 1;
 }
 
+unsigned long __init arch_reserved_kernel_pages(void)
+{
+	return memblock_reserved_size() / PAGE_SIZE;
+}
+
 /* Look for fadump= cmdline option. */
 static int __init early_fadump_param(char *p)
 {
-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
