Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id B42356B0255
	for <linux-mm@kvack.org>; Mon,  7 Mar 2016 22:56:38 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id m7so3070849obh.3
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:38 -0800 (PST)
Received: from mail-ob0-x243.google.com (mail-ob0-x243.google.com. [2607:f8b0:4003:c01::243])
        by mx.google.com with ESMTPS id q8si603648obk.65.2016.03.07.19.56.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Mar 2016 19:56:37 -0800 (PST)
Received: by mail-ob0-x243.google.com with SMTP id e7so321776obv.2
        for <linux-mm@kvack.org>; Mon, 07 Mar 2016 19:56:37 -0800 (PST)
From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH 1/2] mm: meminit: initialise more memory for inode/dentry hash tables in early boot
Date: Tue,  8 Mar 2016 11:55:53 +0800
Message-Id: <1457409354-10867-2-git-send-email-zhlcindy@gmail.com>
In-Reply-To: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
References: <1457409354-10867-1-git-send-email-zhlcindy@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, vbabka@suse.cz, mgorman@techsingularity.net, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, Li Zhang <zhlcindy@linux.vnet.ibm.com>

From: Li Zhang <zhlcindy@linux.vnet.ibm.com>

This patch is based on Mel Gorman's old patch in the mailing list,
https://lkml.org/lkml/2015/5/5/280 which is discussed but it is
fixed with a completion to wait for all memory initialised in
page_alloc_init_late(). It is to fix the OOM problem on X86
with 24TB memory which allocates memory in late initialisation.
But for Power platform with 32TB memory, it causes a call trace
in vfs_caches_init->inode_init() and inode hash table needs more
memory.
So this patch allocates 1GB for 0.25TB/node for large system
as it is mentioned in https://lkml.org/lkml/2015/5/1/627

This call trace is found on Power with 32TB memory, 1024CPUs, 16nodes.
Currently, it only allocates 2GB*16=32GB for early initialisation. But
Dentry cache hash table needes 16GB and Inode cache hash table needs
16GB. So the system have no enough memory for it.
The log from dmesg as the following:

Dentry cache hash table entries: 2147483648 (order: 18,17179869184 bytes)
vmalloc: allocation failure, allocated 16021913600 of 17179934720 bytes
swapper/0: page allocation failure: order:0,mode:0x2080020
CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-0-ppc64
Call Trace:
[c0000000012bfa00] [c0000000007c4a50].dump_stack+0xb4/0xb664 (unreliable)
[c0000000012bfa80] [c0000000001f93d4].warn_alloc_failed+0x114/0x160
[c0000000012bfb30] [c00000000023c204].__vmalloc_area_node+0x1a4/0x2b0
[c0000000012bfbf0] [c00000000023c3f4].__vmalloc_node_range+0xe4/0x110
[c0000000012bfc90] [c00000000023c460].__vmalloc_node+0x40/0x50
[c0000000012bfd10] [c000000000b67d60].alloc_large_system_hash+0x134/0x2a4
[c0000000012bfdd0] [c000000000b70924].inode_init+0xa4/0xf0
[c0000000012bfe60] [c000000000b706a0].vfs_caches_init+0x80/0x144
[c0000000012bfef0] [c000000000b35208].start_kernel+0x40c/0x4e0
[c0000000012bff90] [c000000000008cfc]start_here_common+0x20/0x4a4
Mem-Info:

Acked-by: Mel Gorman <mgorman@techsingularity.net>
Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
---
 * Fix a typo and format dmesg in change log.
 * Fix a coding stype of this patch.

 mm/page_alloc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 838ca8bb..6f77f64 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -293,13 +293,20 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
 				unsigned long *nr_initialised)
 {
+	unsigned long max_initialise;
+
 	/* Always populate low zones for address-contrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
+	/*
+	 * Initialise at least 2G of a node but also take into account that
+	 * two large system hashes that can take up 1GB for 0.25TB/node.
+	 */
+	max_initialise = max(2UL << (30 - PAGE_SHIFT),
+		(pgdat->node_spanned_pages >> 8));
 
-	/* Initialise at least 2G of the highest zone */
 	(*nr_initialised)++;
-	if (*nr_initialised > (2UL << (30 - PAGE_SHIFT)) &&
+	if ((*nr_initialised > max_initialise) &&
 	    (pfn & (PAGES_PER_SECTION - 1)) == 0) {
 		pgdat->first_deferred_pfn = pfn;
 		return false;
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
