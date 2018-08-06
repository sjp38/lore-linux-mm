Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D492D6B0272
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:53:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g11-v6so3890703edi.8
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 03:53:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w49-v6si1490311edm.138.2018.08.06.03.53.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 03:53:02 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w76An4Ah107994
	for <linux-mm@kvack.org>; Mon, 6 Aug 2018 06:53:00 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kpm971nb4-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 06 Aug 2018 06:52:59 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Mon, 6 Aug 2018 11:52:55 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH v2 3/3] sparc32: split ramdisk detection and reservation to a helper function
Date: Mon,  6 Aug 2018 13:52:35 +0300
In-Reply-To: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533552755-16679-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533552755-16679-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The detection and reservation of ramdisk memory were separated to allow
bootmem bitmap initialization after the ramdisk boundaries are detected.
Since the bootmem initialization is removed, the reservation of ramdisk
memory is done immediately after its boundaries are found.

Split the entire block into a separate helper function.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Suggested-by: Sam Ravnborg <sam@ravnborg.org>
---
 arch/sparc/mm/init_32.c | 56 +++++++++++++++++++++++++++----------------------
 1 file changed, 31 insertions(+), 25 deletions(-)

diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index e786fe0..92634d4 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -102,6 +102,36 @@ static unsigned long calc_max_low_pfn(void)
 	return tmp;
 }
 
+static void __init find_ramdisk(unsigned long end_of_phys_memory)
+{
+#ifdef CONFIG_BLK_DEV_INITRD
+	unsigned long size;
+
+	/* Now have to check initial ramdisk, so that it won't pass
+	 * the end of memory
+	 */
+	if (sparc_ramdisk_image) {
+		if (sparc_ramdisk_image >= (unsigned long)&_end - 2 * PAGE_SIZE)
+			sparc_ramdisk_image -= KERNBASE;
+		initrd_start = sparc_ramdisk_image + phys_base;
+		initrd_end = initrd_start + sparc_ramdisk_size;
+		if (initrd_end > end_of_phys_memory) {
+			printk(KERN_CRIT "initrd extends beyond end of memory "
+			       "(0x%016lx > 0x%016lx)\ndisabling initrd\n",
+			       initrd_end, end_of_phys_memory);
+			initrd_start = 0;
+		} else {
+			/* Reserve the initrd image area. */
+			size = initrd_end - initrd_start;
+			memblock_reserve(initrd_start, size);
+
+			initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
+			initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
+		}
+	}
+#endif
+}
+
 unsigned long __init bootmem_init(unsigned long *pages_avail)
 {
 	unsigned long start_pfn, bytes_avail, size;
@@ -160,32 +190,8 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 		    high_pages >> (20 - PAGE_SHIFT));
 	}
 
-#ifdef CONFIG_BLK_DEV_INITRD
-	/* Now have to check initial ramdisk, so that it won't pass
-	 * the end of memory
-	 */
-	if (sparc_ramdisk_image) {
-		if (sparc_ramdisk_image >= (unsigned long)&_end - 2 * PAGE_SIZE)
-			sparc_ramdisk_image -= KERNBASE;
-		initrd_start = sparc_ramdisk_image + phys_base;
-		initrd_end = initrd_start + sparc_ramdisk_size;
-		if (initrd_end > end_of_phys_memory) {
-			printk(KERN_CRIT "initrd extends beyond end of memory "
-		                 	 "(0x%016lx > 0x%016lx)\ndisabling initrd\n",
-			       initrd_end, end_of_phys_memory);
-			initrd_start = 0;
-		}
-	}
-
-	if (initrd_start) {
-		/* Reserve the initrd image area. */
-		size = initrd_end - initrd_start;
-		memblock_reserve(initrd_start, size);
+	find_ramdisk(end_of_phys_memory);
 
-		initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
-		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
-	}
-#endif
 	/* Reserve the kernel text/data/bss. */
 	size = (start_pfn << PAGE_SHIFT) - phys_base;
 	memblock_reserve(phys_base, size);
-- 
2.7.4
