Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAH2bhJT398524
	for <linux-mm@kvack.org>; Tue, 16 Nov 2004 21:37:43 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAH2bd5S178134
	for <linux-mm@kvack.org>; Tue, 16 Nov 2004 19:37:42 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id iAH2bd2T000890
	for <linux-mm@kvack.org>; Tue, 16 Nov 2004 19:37:39 -0700
Subject: [RFC] fix for hot-add enabled SRAT/BIOS and numa KVA areas
From: keith <kmannth@us.ibm.com>
Content-Type: multipart/mixed; boundary="=-eYHrM9EVEbLj1pVTtUh5"
Message-Id: <1100659057.26335.125.camel@knk>
Mime-Version: 1.0
Date: Tue, 16 Nov 2004 18:37:37 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: external hotplug mem list <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Chris McDermott <lcm@us.ibm.com>
List-ID: <linux-mm.kvack.org>

--=-eYHrM9EVEbLj1pVTtUh5
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

  My numa hardware (IBM x445 summit based) supports hot-add memory. 
When this feature is enabled in the bios and booted as with CONFIG_NUMA
I get a memory range exposed by the SRAT/ACPI parsing.  This range
express the amount of memory the "could" be added to the system.  
  
  This chunk extends from the end of physical memory to the end of the
i386 address space.  If the following my physical memory is 0x2C0000. 

(From the boot messages)
Memory range 0x80000 to 0xC0000 (type 0x0) in proximity domain 0x01 enabled
Memory range 0x100000 to 0x2C0000 (type 0x0) in proximity domain 0x01 enabled
Memory range 0x2C0000 to 0x1000000 (type 0x0) in proximity domain 0x01 enabled and removable
  
  These memory ranges I believe to be valid according to what I know
about the SRAT and the ACPI 2.0c specs.  (I am not an ACPI expert please
correct me if I am wrong!)

  The numa KVA code used the node_start and node_end values (obtained
from the above memory ranges) to make it's lowmem reservations.  The
problem is that the lowmem area reserved is quite large.  It reserves
the entire a lmem_map large enough for 0x1000000 address space.  I don't
feel this is a great use of lowmem on my system :)

  Thankfully as we know the e820 shows what memory is really in the
system.  My simple fix it to find the max_pfn from the e820 earlier and
set the numa KVA areas accordingly. 
 
Don't trust the SRAT for this info only the e820.  

Thanks,
  Keith Mannthey 



--=-eYHrM9EVEbLj1pVTtUh5
Content-Disposition: attachment; filename=fix2.patch
Content-Type: text/x-patch; name=fix2.patch; charset=
Content-Transfer-Encoding: 7bit

diff -urN linux-2.6.9/arch/i386/mm/discontig.c linux-2.6.9-fix2/arch/i386/mm/discontig.c
--- linux-2.6.9/arch/i386/mm/discontig.c	2004-11-16 17:41:18.207154544 -0800
+++ linux-2.6.9-fix2/arch/i386/mm/discontig.c	2004-11-16 17:37:05.811524512 -0800
@@ -199,6 +199,15 @@
 	unsigned long size, reserve_pages = 0;
 
 	for (nid = 1; nid < numnodes; nid++) {
+		/*
+		* The acpi/srat node info can show hot-add memroy zones
+		* where memory could be added but not currently present.
+		*/
+		if (node_start_pfn[nid] > max_pfn)
+			continue;
+		if (node_end_pfn[nid] > max_pfn)
+			node_end_pfn[nid] = max_pfn;
+
 		/* calculate the size of the mem_map needed in bytes */
 		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
 			* sizeof(struct page) + sizeof(pg_data_t);
@@ -261,12 +270,12 @@
 		printk("\n");
 	}
 
+	find_max_pfn();
 	reserve_pages = calculate_numa_remap_pages();
 
 	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(init_pg_tables_end);
 
-	find_max_pfn();
 	system_max_low_pfn = max_low_pfn = find_max_low_pfn() - reserve_pages;
 	printk("reserve_pages = %ld find_max_low_pfn() ~ %ld\n",
 			reserve_pages, max_low_pfn + reserve_pages);

--=-eYHrM9EVEbLj1pVTtUh5--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
