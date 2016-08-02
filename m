Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 64C1D6B0253
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:19:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w128so330611235pfd.3
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 06:19:26 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s20si3081802pao.188.2016.08.02.06.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Aug 2016 06:19:25 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u72DEmUM118505
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 09:19:25 -0400
Received: from e23smtp02.au.ibm.com (e23smtp02.au.ibm.com [202.81.31.144])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24jr4au5nv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Aug 2016 09:19:24 -0400
Received: from localhost
	by e23smtp02.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Aug 2016 23:19:22 +1000
Received: from d23relay07.au.ibm.com (d23relay07.au.ibm.com [9.190.26.37])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 5FF7A2CE8054
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 23:19:19 +1000 (EST)
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay07.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u72DJJdt24313886
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:19 +1000
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u72DJJnb023145
	for <linux-mm@kvack.org>; Tue, 2 Aug 2016 23:19:19 +1000
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: [PATCH 0/0] Disable deferred struct page initialisation on Fadump
Date: Tue,  2 Aug 2016 18:49:05 +0530
Message-Id: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux--foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>

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

This can be solved by two approaches.
1. Disable deferred struct page initialisation on fadump.

2. Detect reserved nodes and allocate accordingly.
 - Detecting nodes whose memblocks are mostly reserved.
 - Allocating extra memory in other nodes in lieu of the nodes whose
   memory is reserved.

This patchset takes the first approach.

Srikar Dronamraju (2):
  mm: Allow disabling deferred struct page initialisation
  fadump: Disable deferred page struct initialisation

 arch/powerpc/kernel/fadump.c |  1 +
 include/linux/mmzone.h       |  2 +-
 mm/page_alloc.c              | 20 ++++++++++++++++++++
 3 files changed, 22 insertions(+), 1 deletion(-)

-- 
1.8.5.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
