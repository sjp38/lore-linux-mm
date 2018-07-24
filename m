Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5609C6B0010
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:32 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id m197-v6so4111848oig.18
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 06:23:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e125-v6si7483836oif.165.2018.07.24.06.23.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 06:23:31 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w6ODIleN008490
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:30 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ke3r5uyb2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 09:23:30 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Tue, 24 Jul 2018 14:23:28 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 2/2] um: switch to NO_BOOTMEM
Date: Tue, 24 Jul 2018 16:23:14 +0300
In-Reply-To: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532438594-4530-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1532438594-4530-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>
Cc: Michal Hocko <mhocko@kernel.org>, linux-um@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Replace bootmem initialization with memblock_add and memblock_reserve calls
and explicit initialization of {min,max}_low_pfn.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/um/Kconfig.common   |  2 ++
 arch/um/kernel/physmem.c | 20 +++++++++-----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/arch/um/Kconfig.common b/arch/um/Kconfig.common
index 07f84c8..1487957 100644
--- a/arch/um/Kconfig.common
+++ b/arch/um/Kconfig.common
@@ -8,6 +8,8 @@ config UML
 	select HAVE_UID16
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_DEBUG_KMEMLEAK
+	select HAVE_MEMBLOCK
+	select NO_BOOTMEM
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/um/kernel/physmem.c b/arch/um/kernel/physmem.c
index 0eaec0e..296a91a 100644
--- a/arch/um/kernel/physmem.c
+++ b/arch/um/kernel/physmem.c
@@ -5,6 +5,7 @@
 
 #include <linux/module.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/mm.h>
 #include <linux/pfn.h>
 #include <asm/page.h>
@@ -80,23 +81,18 @@ void __init setup_physmem(unsigned long start, unsigned long reserve_end,
 			  unsigned long len, unsigned long long highmem)
 {
 	unsigned long reserve = reserve_end - start;
-	unsigned long pfn = PFN_UP(__pa(reserve_end));
-	unsigned long delta = (len - reserve) >> PAGE_SHIFT;
-	unsigned long offset, bootmap_size;
-	long map_size;
+	long map_size = len - reserve;
 	int err;
 
-	offset = reserve_end - start;
-	map_size = len - offset;
 	if(map_size <= 0) {
 		os_warn("Too few physical memory! Needed=%lu, given=%lu\n",
-			offset, len);
+			reserve, len);
 		exit(1);
 	}
 
 	physmem_fd = create_mem_file(len + highmem);
 
-	err = os_map_memory((void *) reserve_end, physmem_fd, offset,
+	err = os_map_memory((void *) reserve_end, physmem_fd, reserve,
 			    map_size, 1, 1, 1);
 	if (err < 0) {
 		os_warn("setup_physmem - mapping %ld bytes of memory at 0x%p "
@@ -113,9 +109,11 @@ void __init setup_physmem(unsigned long start, unsigned long reserve_end,
 	os_write_file(physmem_fd, __syscall_stub_start, PAGE_SIZE);
 	os_fsync_file(physmem_fd);
 
-	bootmap_size = init_bootmem(pfn, pfn + delta);
-	free_bootmem(__pa(reserve_end) + bootmap_size,
-		     len - bootmap_size - reserve);
+	memblock_add(__pa(start), len + highmem);
+	memblock_reserve(__pa(start), reserve);
+
+	min_low_pfn = PFN_UP(__pa(reserve_end));
+	max_low_pfn = min_low_pfn + (map_size >> PAGE_SHIFT);
 }
 
 int phys_mapping(unsigned long phys, unsigned long long *offset_out)
-- 
2.7.4
