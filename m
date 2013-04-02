Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0F6C16B0002
	for <linux-mm@kvack.org>; Tue,  2 Apr 2013 06:12:46 -0400 (EDT)
From: Lin Feng <linfeng@cn.fujitsu.com>
Subject: [PATCH] x86: numa: mm: kill double initialization for NODE_DATA
Date: Tue, 2 Apr 2013 18:14:35 +0800
Message-Id: <1364897675-15523-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, yinghai@kernel.org, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, Lin Feng <linfeng@cn.fujitsu.com>

We initialize node_id, node_start_pfn and node_spanned_pages for NODE_DATA in
initmem_init() while the later two members are kept unused and will be
recaculated soon in paging_init(), so remove the useless assignments.

PS. For clarifying calling chains are showed as follows:
setup_arch()
  ...
  initmem_init()
    x86_numa_init()
      numa_init()
        numa_register_memblks()
          setup_node_data()
            NODE_DATA(nid)->node_id = nid;
            NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
            NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
  ...
  x86_init.paging.pagetable_init()
  paging_init()
    ...
    sparse_init()
      sparse_early_usemaps_alloc_node()
        sparse_early_usemaps_alloc_pgdat_section()
          ___alloc_bootmem_node_nopanic()
            __alloc_memory_core_early(pgdat->node_id,...)
    ...
    zone_sizes_init()
      free_area_init_nodes()
        free_area_init_node()
          pgdat->node_id = nid;
          pgdat->node_start_pfn = node_start_pfn;
          calculate_node_totalpages();
            pgdat->node_spanned_pages = totalpages;


Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
---
 arch/x86/mm/numa.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index 72fe01e..efdd08f 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -230,8 +230,6 @@ static void __init setup_node_data(int nid, u64 start, u64 end)
 	node_data[nid] = nd;
 	memset(NODE_DATA(nid), 0, sizeof(pg_data_t));
 	NODE_DATA(nid)->node_id = nid;
-	NODE_DATA(nid)->node_start_pfn = start >> PAGE_SHIFT;
-	NODE_DATA(nid)->node_spanned_pages = (end - start) >> PAGE_SHIFT;
 
 	node_set_online(nid);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
