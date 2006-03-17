Date: Fri, 17 Mar 2006 17:20:53 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: [PATCH: 003/017]Memory hotplug for new nodes v.4.(get node id at probe memory)
Message-Id: <20060317162835.C63D.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: "Luck, Tony" <tony.luck@intel.com>, Andi Kleen <ak@suse.de>, Linux Kernel ML <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

When CONFIG_NUMA && CONFIG_ARCH_MEMORY_PROBE, nid should be defined
before calling add_memory(nid, start, size).

Each arch , which supports CONFIG_NUMA && ARCH_MEMORY_PROBE, should
define arch_nid_probe(paddr);

Powerpc has nice function. X86_64 has not.....

Note:
If memory is hot-plugged by firmware, there is another *good* information
like pxm.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>

 arch/powerpc/mm/mem.c          |    5 +++++
 drivers/base/memory.c          |    3 ++-
 include/linux/memory_hotplug.h |    9 +++++++++
 3 files changed, 16 insertions(+), 1 deletion(-)

Index: pgdat8/arch/powerpc/mm/mem.c
===================================================================
--- pgdat8.orig/arch/powerpc/mm/mem.c	2006-03-17 13:48:31.665710185 +0900
+++ pgdat8/arch/powerpc/mm/mem.c	2006-03-17 13:52:47.538753925 +0900
@@ -114,6 +114,11 @@ void online_page(struct page *page)
 	num_physpages++;
 }
 
+int arch_nid_probe(u64 start)
+{
+	return hot_add_scn_to_nid(start);
+}
+
 int __meminit arch_add_memory(int nid, u64 start, u64 size)
 {
 	struct pglist_data *pgdata;
Index: pgdat8/include/linux/memory_hotplug.h
===================================================================
--- pgdat8.orig/include/linux/memory_hotplug.h	2006-03-17 13:48:31.626647685 +0900
+++ pgdat8/include/linux/memory_hotplug.h	2006-03-17 13:51:28.325864271 +0900
@@ -66,6 +66,15 @@ extern int online_pages(unsigned long, u
 /* reasonably generic interface to expand the physical pages in a zone  */
 extern int __add_pages(struct zone *zone, unsigned long start_pfn,
 	unsigned long nr_pages);
+#if defined(CONFIG_NUMA) && defined(CONFIG_ARCH_MEMORY_PROBE)
+extern int arch_nid_probe(u64 start);
+#else
+static inline int arch_nid_probe(u64 start)
+{
+	return 0;
+}
+#endif
+
 #else /* ! CONFIG_MEMORY_HOTPLUG */
 /*
  * Stub functions for when hotplug is off
Index: pgdat8/drivers/base/memory.c
===================================================================
--- pgdat8.orig/drivers/base/memory.c	2006-03-17 13:47:31.558289046 +0900
+++ pgdat8/drivers/base/memory.c	2006-03-17 13:51:28.326840833 +0900
@@ -310,7 +310,8 @@ memory_probe_store(struct class *class, 
 
 	phys_addr = simple_strtoull(buf, NULL, 0);
 
-	ret = add_memory(phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
+	ret = add_memory(arch_nid_probe(phys_addr),
+			 phys_addr, PAGES_PER_SECTION << PAGE_SHIFT);
 
 	if (ret)
 		count = ret;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
