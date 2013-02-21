Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 6CDEB6B0002
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 16:18:10 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so4330033dak.0
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 13:18:09 -0800 (PST)
Date: Thu, 21 Feb 2013 13:18:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] memory-hotplug: implement register_page_bootmem_info_section
 of sparse-vmemmap fix fix fix fix fix
In-Reply-To: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.02.1302211314100.25402@chino.kir.corp.google.com>
References: <1358495676-4488-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lin Feng <linfeng@cn.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wen Congyang <wency@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>

Fixes

mm/memory_hotplug.c:133:13: warning: 'register_page_bootmem_info_section' defined but not used [-Wunused-function]

by defining the function only in configurations where it is used.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/memory_hotplug.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -129,6 +129,7 @@ void __ref put_page_bootmem(struct page *page)
 
 }
 
+#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 #ifndef CONFIG_SPARSEMEM_VMEMMAP
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
@@ -163,7 +164,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
 
 }
-#else
+#else /* CONFIG_SPARSEMEM_VMEMMAP */
 static void register_page_bootmem_info_section(unsigned long start_pfn)
 {
 	unsigned long *usemap, mapsize, section_nr, i;
@@ -188,9 +189,8 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
 	for (i = 0; i < mapsize; i++, page++)
 		get_page_bootmem(section_nr, page, MIX_SECTION_INFO);
 }
-#endif
+#endif /* !CONFIG_SPARSEMEM_VMEMMAP */
 
-#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 void register_page_bootmem_info_node(struct pglist_data *pgdat)
 {
 	unsigned long i, pfn, end_pfn, nr_pages;
@@ -232,7 +232,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 			register_page_bootmem_info_section(pfn);
 	}
 }
-#endif
+#endif /* CONFIG_HAVE_BOOTMEM_INFO_NODE */
 
 static void grow_zone_span(struct zone *zone, unsigned long start_pfn,
 			   unsigned long end_pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
