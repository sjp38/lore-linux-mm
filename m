Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 79FF76B0038
	for <linux-mm@kvack.org>; Mon,  8 Sep 2014 19:38:33 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so2210518pdb.14
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 16:38:33 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id d9si616614pdm.56.2014.09.08.16.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Sep 2014 16:38:32 -0700 (PDT)
Received: by mail-pa0-f42.google.com with SMTP id lj1so2867092pab.15
        for <linux-mm@kvack.org>; Mon, 08 Sep 2014 16:38:32 -0700 (PDT)
From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH v2 3/3] x86: use __memblock_alloc_base() and memblock_alloc_base()
Date: Tue,  9 Sep 2014 08:38:04 +0900
Message-Id: <1410219484-8038-3-git-send-email-akinobu.mita@gmail.com>
In-Reply-To: <1410219484-8038-1-git-send-email-akinobu.mita@gmail.com>
References: <1410219484-8038-1-git-send-email-akinobu.mita@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Akinobu Mita <akinobu.mita@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-mm@kvack.org

__memblock_alloc_base() is equivalent to memblock_find_in_range() with
the range starting from 0 and subsequent memblock_reserve() call.
memblock_alloc_base() is similar to __memblock_alloc_base(), but it
calls panic if the allocation fails.  Convert to use these functions
where possible.

This is mainly a cleanup.  Also, memblock_alloc_base() and its variants
call kmemleak_alloc() for allocated memory block with min_count of 0, so
that it is never reported as leaks.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: linux-mm@kvack.org
---
* v2: split from membloc_alloc_range() conversions, and avoid unexpected
  panic on allocation failure.

 arch/x86/kernel/setup.c      | 9 ++-------
 arch/x86/mm/numa.c           | 4 +---
 arch/x86/mm/numa_emulation.c | 5 ++---
 arch/x86/realmode/init.c     | 5 +----
 4 files changed, 6 insertions(+), 17 deletions(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 7d32406..d3b1da5 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -327,16 +327,11 @@ static void __init relocate_initrd(void)
 	char *p, *q;
 
 	/* We need to move the initrd down into directly mapped mem */
-	relocated_ramdisk = memblock_find_in_range(0, PFN_PHYS(max_pfn_mapped),
-						   area_size, PAGE_SIZE);
-
-	if (!relocated_ramdisk)
-		panic("Cannot find place for new RAMDISK of size %lld\n",
-		      ramdisk_size);
+	relocated_ramdisk = memblock_alloc_base(area_size, PAGE_SIZE,
+						PFN_PHYS(max_pfn_mapped));
 
 	/* Note: this includes all the mem currently occupied by
 	   the initrd, we rely on that fact to keep the data intact. */
-	memblock_reserve(relocated_ramdisk, area_size);
 	initrd_start = relocated_ramdisk + PAGE_OFFSET;
 	initrd_end   = initrd_start + ramdisk_size;
 	printk(KERN_INFO "Allocated new RAMDISK: [mem %#010llx-%#010llx]\n",
diff --git a/arch/x86/mm/numa.c b/arch/x86/mm/numa.c
index a32b706..5deaa9b 100644
--- a/arch/x86/mm/numa.c
+++ b/arch/x86/mm/numa.c
@@ -375,15 +375,13 @@ static int __init numa_alloc_distance(void)
 	cnt++;
 	size = cnt * cnt * sizeof(numa_distance[0]);
 
-	phys = memblock_find_in_range(0, PFN_PHYS(max_pfn_mapped),
-				      size, PAGE_SIZE);
+	phys = __memblock_alloc_base(size, PAGE_SIZE, PFN_PHYS(max_pfn_mapped));
 	if (!phys) {
 		pr_warning("NUMA: Warning: can't allocate distance table!\n");
 		/* don't retry until explicitly reset */
 		numa_distance = (void *)1LU;
 		return -ENOMEM;
 	}
-	memblock_reserve(phys, size);
 
 	numa_distance = __va(phys);
 	numa_distance_cnt = cnt;
diff --git a/arch/x86/mm/numa_emulation.c b/arch/x86/mm/numa_emulation.c
index a8f90ce..4dc3405 100644
--- a/arch/x86/mm/numa_emulation.c
+++ b/arch/x86/mm/numa_emulation.c
@@ -357,13 +357,12 @@ void __init numa_emulation(struct numa_meminfo *numa_meminfo, int numa_dist_cnt)
 	if (numa_dist_cnt) {
 		u64 phys;
 
-		phys = memblock_find_in_range(0, PFN_PHYS(max_pfn_mapped),
-					      phys_size, PAGE_SIZE);
+		phys = __memblock_alloc_base(phys_size, PAGE_SIZE,
+					     PFN_PHYS(max_pfn_mapped));
 		if (!phys) {
 			pr_warning("NUMA: Warning: can't allocate copy of distance table, disabling emulation\n");
 			goto no_emu;
 		}
-		memblock_reserve(phys, phys_size);
 		phys_dist = __va(phys);
 
 		for (i = 0; i < numa_dist_cnt; i++)
diff --git a/arch/x86/realmode/init.c b/arch/x86/realmode/init.c
index bad628a..c6c212a 100644
--- a/arch/x86/realmode/init.c
+++ b/arch/x86/realmode/init.c
@@ -15,12 +15,9 @@ void __init reserve_real_mode(void)
 	size_t size = PAGE_ALIGN(real_mode_blob_end - real_mode_blob);
 
 	/* Has to be under 1M so we can execute real-mode AP code. */
-	mem = memblock_find_in_range(0, 1<<20, size, PAGE_SIZE);
-	if (!mem)
-		panic("Cannot allocate trampoline\n");
+	mem = memblock_alloc_base(size, PAGE_SIZE, 1 << 20);
 
 	base = __va(mem);
-	memblock_reserve(mem, size);
 	real_mode_header = (struct real_mode_header *) base;
 	printk(KERN_DEBUG "Base memory trampoline at [%p] %llx size %zu\n",
 	       base, (unsigned long long)mem, size);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
