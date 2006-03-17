Date: Fri, 17 Mar 2006 17:20:33 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 002/017]Memory hotplug for new nodes v.4.(change name old add_memory() to arch_add_memory()) 
Message-Id: <20060317162757.C63B.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This patch changes name of old add_memory() to arch_add_memory.
and use node id to get pgdat for the node at NODE_DATA().

Note: Powerpc's old add_memory() is defined as __devinit. However,
      add_memory() is usually called only after bootup. 
      I suppose it may be redundant. But, I'm not sure about powerpc.
      So, I keep it. (But, __meminit is better than __devinit at least.)

Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 arch/i386/mm/init.c   |    2 +-
 arch/ia64/mm/init.c   |    4 ++--
 arch/powerpc/mm/mem.c |    4 +---
 arch/x86_64/mm/init.c |    4 ++--
 4 files changed, 6 insertions(+), 8 deletions(-)

Index: pgdat8/arch/i386/mm/init.c
===================================================================
--- pgdat8.orig/arch/i386/mm/init.c	2006-03-17 12:15:27.574691472 +0900
+++ pgdat8/arch/i386/mm/init.c	2006-03-17 12:16:06.189821080 +0900
@@ -652,7 +652,7 @@ void __init mem_init(void)
  * memory to the highmem for now.
  */
 #ifndef CONFIG_NEED_MULTIPLE_NODES
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata = &contig_page_data;
 	struct zone *zone = pgdata->node_zones + MAX_NR_ZONES-1;
Index: pgdat8/arch/ia64/mm/init.c
===================================================================
--- pgdat8.orig/arch/ia64/mm/init.c	2006-03-17 12:15:27.574691472 +0900
+++ pgdat8/arch/ia64/mm/init.c	2006-03-17 12:16:06.190820928 +0900
@@ -646,7 +646,7 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
 	pg_data_t *pgdat;
 	struct zone *zone;
@@ -654,7 +654,7 @@ int add_memory(u64 start, u64 size)
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	pgdat = NODE_DATA(0);
+	pgdat = NODE_DATA(nid);
 
 	zone = pgdat->node_zones + ZONE_NORMAL;
 	ret = __add_pages(zone, start_pfn, nr_pages);
Index: pgdat8/arch/powerpc/mm/mem.c
===================================================================
--- pgdat8.orig/arch/powerpc/mm/mem.c	2006-03-17 12:15:27.575691320 +0900
+++ pgdat8/arch/powerpc/mm/mem.c	2006-03-17 12:16:06.190820928 +0900
@@ -114,15 +114,13 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int __devinit add_memory(u64 start, u64 size)
+int __meminit arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
 	struct zone *zone;
-	int nid;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 
-	nid = hot_add_scn_to_nid(start);
 	pgdata = NODE_DATA(nid);
 
 	start = __va(start);
Index: pgdat8/arch/x86_64/mm/init.c
===================================================================
--- pgdat8.orig/arch/x86_64/mm/init.c	2006-03-17 12:15:27.575691320 +0900
+++ pgdat8/arch/x86_64/mm/init.c	2006-03-17 12:16:06.191820776 +0900
@@ -493,9 +493,9 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
-int add_memory(u64 start, u64 size)
+int arch_add_memory(int nid, u64 start, u64 size)
 {
-	struct pglist_data *pgdat = NODE_DATA(0);
+	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct zone *zone = pgdat->node_zones + MAX_NR_ZONES-2;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
