Date: Wed, 18 May 2005 08:23:07 -0700
From: Matt Tolentino <metolent@snoqualmie.dp.intel.com>
Message-Id: <200505181523.j4IFN7rs026902@snoqualmie.dp.intel.com>
Subject: [patch 1/4] remove direct ref to contig_page_data for x86-64
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de, akpm@osdl.org
Cc: apw@shadowen.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch pulls out all remaining direct references to 
contig_page_data from arch/x86-64, thus saving an ifdef
in one case.  

Signed-off-by: Matt Tolentino <matthew.e.tolentino@intel.com>
Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 arch/x86_64/kernel/aperture.c |    4 ----
 arch/x86_64/kernel/setup.c    |    2 +-
 2 files changed, 1 insertion(+), 5 deletions(-)

diff -urNp linux-2.6.12-rc4-mm2/arch/x86_64/kernel/aperture.c linux-2.6.12-rc4-mm2-m/arch/x86_64/kernel/aperture.c
--- linux-2.6.12-rc4-mm2/arch/x86_64/kernel/aperture.c	2005-05-07 01:20:31.000000000 -0400
+++ linux-2.6.12-rc4-mm2-m/arch/x86_64/kernel/aperture.c	2005-05-16 13:13:52.000000000 -0400
@@ -42,11 +42,7 @@ static struct resource aper_res = {
 
 static u32 __init allocate_aperture(void) 
 {
-#ifdef CONFIG_DISCONTIGMEM
 	pg_data_t *nd0 = NODE_DATA(0);
-#else
-	pg_data_t *nd0 = &contig_page_data;
-#endif	
 	u32 aper_size;
 	void *p; 
 
diff -urNp linux-2.6.12-rc4-mm2/arch/x86_64/kernel/setup.c linux-2.6.12-rc4-mm2-m/arch/x86_64/kernel/setup.c
--- linux-2.6.12-rc4-mm2/arch/x86_64/kernel/setup.c	2005-05-16 13:17:18.000000000 -0400
+++ linux-2.6.12-rc4-mm2-m/arch/x86_64/kernel/setup.c	2005-05-16 13:13:52.000000000 -0400
@@ -408,7 +408,7 @@ static void __init contig_initmem_init(v
         if (bootmap == -1L) 
                 panic("Cannot find bootmem map of size %ld\n",bootmap_size);
         bootmap_size = init_bootmem(bootmap >> PAGE_SHIFT, end_pfn);
-        e820_bootmem_free(&contig_page_data, 0, end_pfn << PAGE_SHIFT); 
+        e820_bootmem_free(NODE_DATA(0), 0, end_pfn << PAGE_SHIFT);
         reserve_bootmem(bootmap, bootmap_size);
 } 
 #endif
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
