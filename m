From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [Patch 004/005](memory hotplug)allocate usemap on the section with pgdat
Date: Thu, 03 Apr 2008 14:44:22 +0900
Message-ID: <20080403144159.D1FE.E1E9C6FF@jp.fujitsu.com>
References: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760607AbYDCFpo@vger.kernel.org>
In-Reply-To: <20080403140221.D1F2.E1E9C6FF@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>, Yinghai Lu <yhlu.kernel@gmail.com>, linux-mm <linux-mm@kvack.org>
List-Id: linux-mm.kvack.org



Usemaps are allocated on the section which has pgdat by this.

Because usemap size is very small, many usemaps for sections
are allocated on only one page. The page will be quite hard to
be removed until removing all other sections.
This dependency is not desirable for memory removing.

Pgdat has similar feature. If sections has pgdat area, it 
must be the last section for removing on the node.

This is to collect the cause pages of its dependency on one section.
If other sections doesn't have any dependency, this section will
be able to be removed finally.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


 mm/sparse.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

Index: current/mm/sparse.c
===================================================================
--- current.orig/mm/sparse.c	2008-04-01 20:59:07.000000000 +0900
+++ current/mm/sparse.c	2008-04-01 20:59:09.000000000 +0900
@@ -238,13 +238,23 @@
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
 
-static unsigned long *__init sparse_early_usemap_alloc(unsigned long pnum)
+static unsigned long *__init sparse_early_usemap_alloc(int pnum)
 {
-	unsigned long *usemap;
+	unsigned long *usemap, section_nr;
 	struct mem_section *ms = __nr_to_section(pnum);
 	int nid = sparse_early_nid(ms);
+	struct pglist_data *pgdat = NODE_DATA(nid);
+
+	/*
+	 * This is allocated on same section of pgdat.
+	 * It will not be freed until other sections hot-removing on the node.
+	 * Pgdat has same feature. This collects all usemap on the same
+	 * section.
+	 */
+
+	section_nr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
+	usemap = alloc_bootmem_section(usemap_size(), section_nr);
 
-	usemap = alloc_bootmem_node(NODE_DATA(nid), usemap_size());
 	if (usemap)
 		return usemap;
 

-- 
Yasunori Goto 
