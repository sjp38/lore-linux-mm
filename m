Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 74D75830EF
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o124so304135347pfg.1
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 06:07:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y6si39122182pfy.74.2016.08.29.06.07.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 06:07:53 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7TD4Vag090614
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:53 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 253713f24y-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 09:07:52 -0400
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 29 Aug 2016 23:07:50 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 1ED3C2BB0054
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:48 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7TD7mrb5374386
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:48 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7TD7lXt013041
	for <linux-mm@kvack.org>; Mon, 29 Aug 2016 23:07:47 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH v3 0/3] Account reserved memory when allocating system hash
Date: Mon, 29 Aug 2016 18:36:47 +0530
Message-Id: <1472476010-4709-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, Mahesh Salgaonkar <mahesh@linux.vnet.ibm.com>, Hari Bathini <hbathini@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>

Fadump kernel reserves large chunks of memory even before the pages are
initialised. This could mean memory that corresponds to several nodes might
fall in memblock reserved regions.

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

This patchset solves this problem by accounting the size of reserved memory
when calculating the size of large system hashes.

While this patchset applies on v4.8-rc3, it cannot be tested on v4.8-rc3
because of http://lkml.kernel.org/r/20160829093844.GA2592@linux.vnet.ibm.com
However it has been tested on v4.7/v4.6 and v4.4

v2: http://lkml.kernel.org/r/1470330729-6273-1-git-send-email-srikar@linux.vnet.ibm.com 

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
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

Srikar Dronamraju (3):
  mm: Introduce arch_reserved_kernel_pages()
  mm/memblock: Expose total reserved memory
  powerpc: Implement arch_reserved_kernel_pages

 arch/powerpc/include/asm/mmzone.h |  3 +++
 arch/powerpc/kernel/fadump.c      |  5 +++++
 include/linux/memblock.h          |  1 +
 include/linux/mm.h                |  3 +++
 mm/memblock.c                     |  5 +++++
 mm/page_alloc.c                   | 12 ++++++++++++
 6 files changed, 29 insertions(+)

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
