Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 686796B026D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 07:56:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w185-v6so1653016oig.19
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 04:56:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c134-v6si1048834oig.261.2018.08.02.04.56.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 04:56:21 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w72Bu0QD137890
	for <linux-mm@kvack.org>; Thu, 2 Aug 2018 07:56:20 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2kky4qe8j0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 02 Aug 2018 07:56:13 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Thu, 2 Aug 2018 12:54:07 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/2] sparc32: tidy up ramdisk memory reservation
Date: Thu,  2 Aug 2018 14:53:53 +0300
In-Reply-To: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1533210833-14748-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1533210833-14748-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "David S. Miller" <davem@davemloft.net>
Cc: Sam Ravnborg <sam@ravnborg.org>, Michal Hocko <mhocko@kernel.org>, sparclinux@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The detection and reservation of ramdisk memory were separated to allow
bootmem bitmap initialization after the ramdisk boundaries are detected.
Since the bootmem initialization is removed, the reservation of ramdisk
memory can be done immediately after its boundaries are found.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/sparc/mm/init_32.c | 24 ++++++++++--------------
 1 file changed, 10 insertions(+), 14 deletions(-)

diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 5117a5e..b5d8f90 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -161,6 +161,8 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 		    high_pages >> (20 - PAGE_SHIFT));
 	}
 
+	*pages_avail = (memblock_phys_mem_size() >> PAGE_SHIFT) - high_pages;
+
 #ifdef CONFIG_BLK_DEV_INITRD
 	/*
 	 * Now have to check initial ramdisk, so that it won't pass
@@ -176,23 +178,17 @@ unsigned long __init bootmem_init(unsigned long *pages_avail)
 		                 	 "(0x%016lx > 0x%016lx)\ndisabling initrd\n",
 			       initrd_end, end_of_phys_memory);
 			initrd_start = 0;
+		} else {
+			/* Reserve the initrd image area. */
+			size = initrd_end - initrd_start;
+			memblock_reserve(initrd_start, size);
+			*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
+
+			initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
+			initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
 		}
 	}
 #endif
-
-	*pages_avail = (memblock_phys_mem_size() >> PAGE_SHIFT) - high_pages;
-
-#ifdef CONFIG_BLK_DEV_INITRD
-	if (initrd_start) {
-		/* Reserve the initrd image area. */
-		size = initrd_end - initrd_start;
-		memblock_reserve(initrd_start, size);
-		*pages_avail -= PAGE_ALIGN(size) >> PAGE_SHIFT;
-
-		initrd_start = (initrd_start - phys_base) + PAGE_OFFSET;
-		initrd_end = (initrd_end - phys_base) + PAGE_OFFSET;
-	}
-#endif
 	/* Reserve the kernel text/data/bss. */
 	size = (start_pfn << PAGE_SHIFT) - phys_base;
 	memblock_reserve(phys_base, size);
-- 
2.7.4
