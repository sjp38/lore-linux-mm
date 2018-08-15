Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8F9566B000A
	for <linux-mm@kvack.org>; Wed, 15 Aug 2018 18:21:38 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 33-v6so1426698plf.19
        for <linux-mm@kvack.org>; Wed, 15 Aug 2018 15:21:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id h8-v6si25209409pgr.379.2018.08.15.15.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Aug 2018 15:21:37 -0700 (PDT)
Date: Wed, 15 Aug 2018 15:21:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/4] mm/memory_hotplug: Make
 register_mem_sect_under_node a cb of walk_memory_range
Message-Id: <20180815152135.4f755e25c865af2054cfaf02@linux-foundation.org>
In-Reply-To: <20180622111839.10071-4-osalvador@techadventures.net>
References: <20180622111839.10071-1-osalvador@techadventures.net>
	<20180622111839.10071-4-osalvador@techadventures.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: osalvador@techadventures.net
Cc: mhocko@suse.com, vbabka@suse.cz, pasha.tatashin@oracle.com, Jonathan.Cameron@huawei.com, arbab@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Oscar Salvador <osalvador@suse.de>

On Fri, 22 Jun 2018 13:18:38 +0200 osalvador@techadventures.net wrote:

> From: Oscar Salvador <osalvador@suse.de>
> 
> link_mem_sections() and walk_memory_range() share most of the code,
> so we can use convert link_mem_sections() into a dummy function that calls
> walk_memory_range() with a callback to register_mem_sect_under_node().
> 
> This patch converts register_mem_sect_under_node() in order to
> match a walk_memory_range's callback, getting rid of the
> check_nid argument and checking instead if the system is still
> boothing, since we only have to check for the nid if the system
> is in such state.
> 
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>

We have two tested-by's bu no reviewers or ackers?

From: Oscar Salvador <osalvador@suse.de>
Subject: mm/memory_hotplug.c: make register_mem_sect_under_node() a callback of walk_memory_range()

link_mem_sections() and walk_memory_range() share most of the code, so we
can use convert link_mem_sections() into a dummy function that calls
walk_memory_range() with a callback to register_mem_sect_under_node().

This patch converts register_mem_sect_under_node() in order to match a
walk_memory_range's callback, getting rid of the check_nid argument and
checking instead if the system is still boothing, since we only have to
check for the nid if the system is in such state.

Link: http://lkml.kernel.org/r/20180622111839.10071-4-osalvador@techadventures.net
Signed-off-by: Oscar Salvador <osalvador@suse.de>
Suggested-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Tested-by: Reza Arbab <arbab@linux.vnet.ibm.com>
Tested-by: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/base/node.c  |   44 +++++------------------------------------
 include/linux/node.h |   12 ++++++-----
 mm/memory_hotplug.c  |    5 ----
 3 files changed, 14 insertions(+), 47 deletions(-)

--- a/drivers/base/node.c~mm-memory_hotplug-make-register_mem_sect_under_node-a-cb-of-walk_memory_range
+++ a/drivers/base/node.c
@@ -399,10 +399,9 @@ static int __ref get_nid_for_pfn(unsigne
 }
 
 /* register memory section under specified node if it spans that node */
-int register_mem_sect_under_node(struct memory_block *mem_blk, int nid,
-				 bool check_nid)
+int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
 {
-	int ret;
+	int ret, nid = *(int *)arg;
 	unsigned long pfn, sect_start_pfn, sect_end_pfn;
 
 	if (!mem_blk)
@@ -433,7 +432,7 @@ int register_mem_sect_under_node(struct
 		 * case, during hotplug we know that all pages in the memory
 		 * block belong to the same node.
 		 */
-		if (check_nid) {
+		if (system_state == SYSTEM_BOOTING) {
 			page_nid = get_nid_for_pfn(pfn);
 			if (page_nid < 0)
 				continue;
@@ -490,41 +489,10 @@ int unregister_mem_sect_under_nodes(stru
 	return 0;
 }
 
-int link_mem_sections(int nid, unsigned long start_pfn, unsigned long nr_pages,
-		      bool check_nid)
+int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long end_pfn = start_pfn + nr_pages;
-	unsigned long pfn;
-	struct memory_block *mem_blk = NULL;
-	int err = 0;
-
-	for (pfn = start_pfn; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-		unsigned long section_nr = pfn_to_section_nr(pfn);
-		struct mem_section *mem_sect;
-		int ret;
-
-		if (!present_section_nr(section_nr))
-			continue;
-		mem_sect = __nr_to_section(section_nr);
-
-		/* same memblock ? */
-		if (mem_blk)
-			if ((section_nr >= mem_blk->start_section_nr) &&
-			    (section_nr <= mem_blk->end_section_nr))
-				continue;
-
-		mem_blk = find_memory_block_hinted(mem_sect, mem_blk);
-
-		ret = register_mem_sect_under_node(mem_blk, nid, check_nid);
-		if (!err)
-			err = ret;
-
-		/* discard ref obtained in find_memory_block() */
-	}
-
-	if (mem_blk)
-		kobject_put(&mem_blk->dev.kobj);
-	return err;
+	return walk_memory_range(start_pfn, end_pfn, (void *)&nid,
+					register_mem_sect_under_node);
 }
 
 #ifdef CONFIG_HUGETLBFS
--- a/include/linux/node.h~mm-memory_hotplug-make-register_mem_sect_under_node-a-cb-of-walk_memory_range
+++ a/include/linux/node.h
@@ -33,10 +33,10 @@ typedef  void (*node_registration_func_t
 
 #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_NUMA)
 extern int link_mem_sections(int nid, unsigned long start_pfn,
-			     unsigned long nr_pages, bool check_nid);
+			     unsigned long end_pfn);
 #else
 static inline int link_mem_sections(int nid, unsigned long start_pfn,
-				    unsigned long nr_pages, bool check_nid)
+				    unsigned long end_pfn)
 {
 	return 0;
 }
@@ -54,12 +54,14 @@ static inline int register_one_node(int
 
 	if (node_online(nid)) {
 		struct pglist_data *pgdat = NODE_DATA(nid);
+		unsigned long start_pfn = pgdat->node_start_pfn;
+		unsigned long end_pfn = start_pfn + pgdat->node_spanned_pages;
 
 		error = __register_one_node(nid);
 		if (error)
 			return error;
 		/* link memory sections under this node */
-		error = link_mem_sections(nid, pgdat->node_start_pfn, pgdat->node_spanned_pages, true);
+		error = link_mem_sections(nid, start_pfn, end_pfn);
 	}
 
 	return error;
@@ -69,7 +71,7 @@ extern void unregister_one_node(int nid)
 extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
 extern int register_mem_sect_under_node(struct memory_block *mem_blk,
-						int nid, bool check_nid);
+						void *arg);
 extern int unregister_mem_sect_under_nodes(struct memory_block *mem_blk,
 					   unsigned long phys_index);
 
@@ -99,7 +101,7 @@ static inline int unregister_cpu_under_n
 	return 0;
 }
 static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
-							int nid, bool check_nid)
+							void *arg)
 {
 	return 0;
 }
--- a/mm/memory_hotplug.c~mm-memory_hotplug-make-register_mem_sect_under_node-a-cb-of-walk_memory_range
+++ a/mm/memory_hotplug.c
@@ -1123,7 +1123,6 @@ int __ref add_memory_resource(int nid, s
 	u64 start, size;
 	bool new_node = false;
 	int ret;
-	unsigned long start_pfn, nr_pages;
 
 	start = res->start;
 	size = resource_size(res);
@@ -1164,9 +1163,7 @@ int __ref add_memory_resource(int nid, s
 	}
 
 	/* link memory sections under this node.*/
-	start_pfn = start >> PAGE_SHIFT;
-	nr_pages = size >> PAGE_SHIFT;
-	ret = link_mem_sections(nid, start_pfn, nr_pages, false);
+	ret = link_mem_sections(nid, PFN_DOWN(start), PFN_UP(start + size - 1));
 	BUG_ON(ret);
 
 	/* create new memmap entry */
_
