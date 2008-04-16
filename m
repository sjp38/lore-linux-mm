Message-Id: <20080416113719.092060936@skyscraper.fehenstaub.lan>
References: <20080416113629.947746497@skyscraper.fehenstaub.lan>
Date: Wed, 16 Apr 2008 13:36:31 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [RFC][patch 2/5] mm: Node-setup agnostic free_bootmem()
Content-Disposition: inline; filename=mm-node-setup-agnostic-free_bootmem.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Yasunori Goto <y-goto@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Make free_bootmem() look up the node holding the specified address
range which lets it work transparently on single-node and multi-node
configurations.

If the address range exceeds the node range, it well be marked free
across node boundaries, too.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
CC: Ingo Molnar <mingo@elte.hu>
CC: Andi Kleen <andi@firstfloor.org>
CC: Yinghai Lu <yhlu.kernel@gmail.com>
CC: Yasunori Goto <y-goto@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Christoph Lameter <clameter@sgi.com>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/bootmem.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

Index: tree-linus/mm/bootmem.c
===================================================================
--- tree-linus.orig/mm/bootmem.c
+++ tree-linus/mm/bootmem.c
@@ -421,7 +421,32 @@ int __init reserve_bootmem(unsigned long
 
 void __init free_bootmem(unsigned long addr, unsigned long size)
 {
-	free_bootmem_core(NODE_DATA(0)->bdata, addr, size);
+	bootmem_data_t *bdata;
+	unsigned long pos = addr;
+	unsigned long partsize = size;
+
+	list_for_each_entry(bdata, &bdata_list, list) {
+		unsigned long remainder = 0;
+
+		if (pos < bdata->node_boot_start)
+			continue;
+
+		if (PFN_DOWN(pos + partsize) > bdata->node_low_pfn) {
+			remainder = PFN_DOWN(pos + partsize) - bdata->node_low_pfn;
+			partsize -= remainder;
+		}
+
+		free_bootmem_core(bdata, pos, partsize);
+
+		if (!remainder)
+			return;
+
+		pos = PFN_PHYS(bdata->node_low_pfn + 1);
+	}
+	printk(KERN_ERR "free_bootmem: request: addr=%lx, size=%lx, "
+			"state: pos=%lx, partsize=%lx\n", addr, size,
+			pos, partsize);
+	BUG();
 }
 
 unsigned long __init free_all_bootmem(void)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
