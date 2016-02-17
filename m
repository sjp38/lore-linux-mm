Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id A4DB96B0005
	for <linux-mm@kvack.org>; Wed, 17 Feb 2016 23:49:53 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id g6so5643667igt.1
        for <linux-mm@kvack.org>; Wed, 17 Feb 2016 20:49:53 -0800 (PST)
Received: from cindy.local ([124.126.226.234])
        by mx.google.com with ESMTP id 99si10239739iot.188.2016.02.17.20.49.52
        for <linux-mm@kvack.org>;
        Wed, 17 Feb 2016 20:49:52 -0800 (PST)
From: Li Zhang <zhlcindy@linux.vnet.ibm.com>
Subject: [PATCH 1/1] mm: meminit: initialise more memory for inode/dentry hash tables in early boot
Date: Wed, 17 Feb 2016 16:56:44 +0800
Message-Id: <1455699404-67837-1-git-send-email-zhlcindy@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, zhlcindy@gmail.com, Li Zhang <zhlcindy@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>

This patch is based on Mel Gorman's old patch in the mailing list,
https://lkml.org/lkml/2015/5/5/280 which is dicussed but it is
fixed with a completion to wait for all memory initialised in
page_alloc_init_late(). The solution in upstream is to fix the
OOM problem on X86 with 24TB memory which allocates memory in 
page late initialisation.
But for Power platform with 32TB memory, page paralle initilisation
still causes a call trace in vfs_caches_init->inode_init() and
inode hash table needs more memory.
So this patch allocates 1GB for 0.25TB/node for large system as
it is mentioned in https://lkml.org/lkml/2015/5/1/627.

This call trace is found on Power with 32TB memory, 1024CPUs, 16nodes.
The log from dmesg as the following:

[    0.091780] Dentry cache hash table entries: 2147483648 (order: 18,
17179869184 bytes)
[    2.891012] vmalloc: allocation failure, allocated 16021913600 of
17179934720 bytes
[    2.891034] swapper/0: page allocation failure: order:0,
mode:0x2080020
[    2.891038] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 4.4.0-0-ppc64
[    2.891041] Call Trace:
[    2.891046] [c0000000012bfa00] [c0000000007c4a50]
                .dump_stack+0xb4/0xb664 (unreliable)
[    2.891051] [c0000000012bfa80] [c0000000001f93d4]
                .warn_alloc_failed+0x114/0x160
[    2.891054] [c0000000012bfb30] [c00000000023c204]
                .__vmalloc_area_node+0x1a4/0x2b0
[    2.891058] [c0000000012bfbf0] [c00000000023c3f4]
                .__vmalloc_node_range+0xe4/0x110
[    2.891061] [c0000000012bfc90] [c00000000023c460]
                .__vmalloc_node+0x40/0x50
[    2.891065] [c0000000012bfd10] [c000000000b67d60]
                .alloc_large_system_hash+0x134/0x2a4
[    2.891068] [c0000000012bfdd0] [c000000000b70924]
                .inode_init+0xa4/0xf0
[    2.891071] [c0000000012bfe60] [c000000000b706a0]
                .vfs_caches_init+0x80/0x144
[    2.891074] [c0000000012bfef0] [c000000000b35208]
                .start_kernel+0x40c/0x4e0
[    2.891078] [c0000000012bff90] [c000000000008cfc]
                start_here_common+0x20/0x4a4
[    2.891080] Mem-Info:

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Li Zhang <zhlcindy@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 838ca8bb..4847f25 100644
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
+	* Initialise at least 2G of a node but also take into account that
+	* two large system hashes that can take up 1GB for 0.25TB/node.
+	*/
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
