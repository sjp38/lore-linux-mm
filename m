Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UFN555027800
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:23:05 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UFQC8P549568
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 09:26:12 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8UFPXBC015068
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 09:25:33 -0600
Subject: [PATCH 1/2] memhotplug testing: hack for flat systems
From: Dave Hansen <haveblue@us.ibm.com>
Date: Fri, 30 Sep 2005 08:25:31 -0700
Message-Id: <20050930152531.3FDB46D3@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: magnus@valinux.co.jp
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Before this patch, the sparse code is only hooked into the NUMA
subarchitectures on i386.  This patch makes sure that normal,
contiguous systems get their memory put into sparsemem correctly.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 arch/i386/mach-default/setup.c           |    0 
 memhotplug-dave/arch/i386/kernel/setup.c |    8 ++++++++
 2 files changed, 8 insertions(+)

diff -puN arch/i386/kernel/setup.c~C1-memory_present-for-contig-systems arch/i386/kernel/setup.c
--- memhotplug/arch/i386/kernel/setup.c~C1-memory_present-for-contig-systems	2005-09-29 12:33:19.000000000 -0700
+++ memhotplug-dave/arch/i386/kernel/setup.c	2005-09-29 12:33:19.000000000 -0700
@@ -978,6 +978,12 @@ efi_find_max_pfn(unsigned long start, un
 	return 0;
 }
 
+static int __init
+efi_memory_present_wrapper(unsigned long start, unsigned long end, void *arg)
+{
+	memory_present(0, start, end);
+	return 0;
+}
 
 /*
  * Find the highest page frame number we have available
@@ -989,6 +995,7 @@ void __init find_max_pfn(void)
 	max_pfn = 0;
 	if (efi_enabled) {
 		efi_memmap_walk(efi_find_max_pfn, &max_pfn);
+		efi_memmap_walk(efi_memory_present_wrapper, NULL);
 		return;
 	}
 
@@ -1003,6 +1010,7 @@ void __init find_max_pfn(void)
 			continue;
 		if (end > max_pfn)
 			max_pfn = end;
+		memory_present(0, start, end);
 	}
 }
 
diff -puN mm/Kconfig~C1-memory_present-for-contig-systems mm/Kconfig
diff -puN mm/page_alloc.c~C1-memory_present-for-contig-systems mm/page_alloc.c
diff -L build_zonelists_fix -puN /dev/null /dev/null
diff -puN arch/i386/mm/init.c~C1-memory_present-for-contig-systems arch/i386/mm/init.c
diff -puN arch/i386/mach-default/setup.c~C1-memory_present-for-contig-systems arch/i386/mach-default/setup.c
diff -L arch/i386/mm/setup.c -puN /dev/null /dev/null
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
