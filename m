Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id i9SHvvNX264900
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 13:57:57 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id i9SHvvQU446492
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:57:57 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id i9SHvu6e028988
	for <linux-mm@kvack.org>; Thu, 28 Oct 2004 11:57:56 -0600
Message-ID: <41813323.4090208@us.ibm.com>
Date: Thu, 28 Oct 2004 10:57:55 -0700
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [2/7] 060 refactor setup_memory i386
References: <E1CNBE0-0006bV-ML@ladymac.shadowen.org> <41811566.2070200@us.ibm.com> <4181168B.3060209@shadowen.org>
In-Reply-To: <4181168B.3060209@shadowen.org>
Content-Type: multipart/mixed;
 boundary="------------000801080308050901070409"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000801080308050901070409
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There's no reason not to just move setup_bootmem_allocator() above the
first call to it, except for code churn.  This saves a predeclaration.

--------------000801080308050901070409
Content-Type: text/plain;
 name="2_7_060_refactor_setup_memory_i386-cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="2_7_060_refactor_setup_memory_i386-cleanup.patch"



---

 sparsemem-dave/arch/i386/kernel/setup.c |   59 +++++++++++++++-----------------
 1 files changed, 29 insertions(+), 30 deletions(-)

diff -puN arch/i386/kernel/setup.c~2_7_060_refactor_setup_memory_i386-cleanup arch/i386/kernel/setup.c
--- sparsemem/arch/i386/kernel/setup.c~2_7_060_refactor_setup_memory_i386-cleanup	2004-10-28 10:23:29.000000000 -0700
+++ sparsemem-dave/arch/i386/kernel/setup.c	2004-10-28 10:24:27.000000000 -0700
@@ -1014,36 +1014,6 @@ static void __init reserve_ebda_region(v
 		reserve_bootmem(addr, PAGE_SIZE);	
 }
 
-#ifndef CONFIG_DISCONTIGMEM
-void __init setup_bootmem_allocator(void);
-static unsigned long __init setup_memory(void)
-{
-	/*
-	 * partially used pages are not usable - thus
-	 * we are rounding upwards:
-	 */
-	min_low_pfn = PFN_UP(init_pg_tables_end);
-
-	find_max_pfn();
-
-	max_low_pfn = find_max_low_pfn();
-
-#ifdef CONFIG_HIGHMEM
-	highstart_pfn = highend_pfn = max_pfn;
-	if (max_pfn > max_low_pfn) {
-		highstart_pfn = max_low_pfn;
-	}
-	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
-		pages_to_mb(highend_pfn - highstart_pfn));
-#endif
-	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
-			pages_to_mb(max_low_pfn));
-
-	setup_bootmem_allocator();
-	return max_low_pfn;
-}
-#endif /* !CONFIG_DISCONTIGMEM */
-
 void __init setup_bootmem_allocator(void)
 {
 	unsigned long bootmap_size;
@@ -1119,6 +1089,35 @@ void __init setup_bootmem_allocator(void
 #endif
 }
 
+#ifndef CONFIG_DISCONTIGMEM
+static unsigned long __init setup_memory(void)
+{
+	/*
+	 * partially used pages are not usable - thus
+	 * we are rounding upwards:
+	 */
+	min_low_pfn = PFN_UP(init_pg_tables_end);
+
+	find_max_pfn();
+
+	max_low_pfn = find_max_low_pfn();
+
+#ifdef CONFIG_HIGHMEM
+	highstart_pfn = highend_pfn = max_pfn;
+	if (max_pfn > max_low_pfn) {
+		highstart_pfn = max_low_pfn;
+	}
+	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
+		pages_to_mb(highend_pfn - highstart_pfn));
+#endif
+	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
+			pages_to_mb(max_low_pfn));
+
+	setup_bootmem_allocator();
+	return max_low_pfn;
+}
+#endif /* !CONFIG_DISCONTIGMEM */
+
 /*
  * Request address space for all standard RAM and ROM resources
  * and also for regions reported as reserved by the e820.
_

--------------000801080308050901070409--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
