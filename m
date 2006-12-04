Date: Mon, 04 Dec 2006 22:27:21 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: 2.6.19 randconfig build error
In-Reply-To: <20061130210952.8fda882a.randy.dunlap@oracle.com>
References: <20061130210952.8fda882a.randy.dunlap@oracle.com>
Message-Id: <20061204222314.F7AC.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> mm/built-in.o: In function `add_memory':
> (.text+0x24235): undefined reference to `arch_add_memory'
> drivers/built-in.o: In function `memory_block_change_state':
> memory.c:(.text+0x75a1d): undefined reference to `remove_memory'
> make: *** [.tmp_vmlinux1] Error 1


Hmmm. True cause was i386's memory hotplug code didn't support NUMA code.
This compile error is fixed by this patch. 

But, if CONFIG_ACPI is on, memory_add_physaddr_to_nid() will 
be cause of another compile error yet, because there is no definition
of it. I'll fix it later.

Thanks.

-------------

This patch is to fix compile error when CONFIG_NEED_MULTIPLE_NODES=y
and config MEMORY_HOTPLUG=y as followings.

mm/built-in.o: In function `add_memory':
(.text+0x24235): undefined reference to `arch_add_memory'
drivers/built-in.o: In function `memory_block_change_state':
memory.c:(.text+0x75a1d): undefined reference to `remove_memory'
make: *** [.tmp_vmlinux1] Error 1

This is for 2.6.19, and I tested no compile error of it.


Signed-off-by: Yasunori Goto <y-goto@jp.fujitsu.com>


---
 arch/i386/mm/init.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6.19/arch/i386/mm/init.c
===================================================================
--- linux-2.6.19.orig/arch/i386/mm/init.c	2006-12-04 20:06:32.000000000 +0900
+++ linux-2.6.19/arch/i386/mm/init.c	2006-12-04 21:09:49.000000000 +0900
@@ -681,10 +681,9 @@
  * memory to the highmem for now.
  */
 #ifdef CONFIG_MEMORY_HOTPLUG
-#ifndef CONFIG_NEED_MULTIPLE_NODES
 int arch_add_memory(int nid, u64 start, u64 size)
 {
-	struct pglist_data *pgdata = &contig_page_data;
+	struct pglist_data *pgdata = NODE_DATA(nid);
 	struct zone *zone = pgdata->node_zones + ZONE_HIGHMEM;
 	unsigned long start_pfn = start >> PAGE_SHIFT;
 	unsigned long nr_pages = size >> PAGE_SHIFT;
@@ -697,7 +696,6 @@
 	return -EINVAL;
 }
 #endif
-#endif
 
 kmem_cache_t *pgd_cache;
 kmem_cache_t *pmd_cache;

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
