Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id C56B56B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 14:35:19 -0400 (EDT)
Received: from /spool/local
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Thu, 25 Jul 2013 04:32:17 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 525912BB0051
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:35:15 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6OIJf954391294
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:19:41 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6OIZETR028852
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 04:35:14 +1000
Message-ID: <51F01E5F.80307@linux.vnet.ibm.com>
Date: Wed, 24 Jul 2013 13:35:11 -0500
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 1/8] register bootmem pages for powerpc when sparse vmemmap
 is not defined
References: <51F01E06.6090800@linux.vnet.ibm.com>
In-Reply-To: <51F01E06.6090800@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linuxppc-dev@lists.ozlabs.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, isimatu.yasuaki@jp.fujitsu.com

Previous commit 46723bfa540... introduced a new config option
HAVE_BOOTMEM_INFO_NODE that ended up breaking memory hot-remove for powerpc
when sparse vmemmap is not defined.

This patch defines HAVE_BOOTMEM_INFO_NODE for powerpc and adds the call to
register_page_bootmem_info_node. Without this patch we get a BUG_ON for memory
hot remove in put_page_bootmem().

This also adds a stub for register_page_bootmem_memmap to allow powerpc to
build with sparse vmemmap defined.

Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
---

---
 arch/powerpc/mm/init_64.c |    6 ++++++
 arch/powerpc/mm/mem.c     |    9 +++++++++
 mm/Kconfig                |    2 +-
 3 files changed, 16 insertions(+), 1 deletion(-)

Index: linux/arch/powerpc/mm/init_64.c
===================================================================
--- linux.orig/arch/powerpc/mm/init_64.c
+++ linux/arch/powerpc/mm/init_64.c
@@ -300,5 +300,11 @@ void vmemmap_free(unsigned long start, u
 {
 }
 
+void register_page_bootmem_memmap(unsigned long section_nr,
+				  struct page *start_page, unsigned long size)
+{
+	WARN_ONCE(1, KERN_INFO
+		  "Sparse Vmemmap not fully supported for bootmem info nodes\n");
+}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
Index: linux/arch/powerpc/mm/mem.c
===================================================================
--- linux.orig/arch/powerpc/mm/mem.c
+++ linux/arch/powerpc/mm/mem.c
@@ -297,12 +297,21 @@ void __init paging_init(void)
 }
 #endif /* ! CONFIG_NEED_MULTIPLE_NODES */
 
+static void __init register_page_bootmem_info(void)
+{
+	int i;
+
+	for_each_online_node(i)
+		register_page_bootmem_info_node(NODE_DATA(i));
+}
+
 void __init mem_init(void)
 {
 #ifdef CONFIG_SWIOTLB
 	swiotlb_init(0);
 #endif
 
+	register_page_bootmem_info();
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 	set_max_mapnr(max_pfn);
 	free_all_bootmem();
Index: linux/mm/Kconfig
===================================================================
--- linux.orig/mm/Kconfig
+++ linux/mm/Kconfig
@@ -183,7 +183,7 @@ config MEMORY_HOTPLUG_SPARSE
 config MEMORY_HOTREMOVE
 	bool "Allow for memory hot remove"
 	select MEMORY_ISOLATION
-	select HAVE_BOOTMEM_INFO_NODE if X86_64
+	select HAVE_BOOTMEM_INFO_NODE if (X86_64 || PPC64)
 	depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
 	depends on MIGRATION
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
