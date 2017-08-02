Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B89276B0612
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 16:39:08 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id p48so26376649qtf.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 13:39:08 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l60si12182026qtd.478.2017.08.02.13.39.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 13:39:07 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [v4 01/15] x86/mm: reserve only exiting low pages
Date: Wed,  2 Aug 2017 16:38:10 -0400
Message-Id: <1501706304-869240-2-git-send-email-pasha.tatashin@oracle.com>
In-Reply-To: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
References: <1501706304-869240-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org

Struct pages are initialized by going through __init_single_page(). Since
the existing physical memory in memblock is represented in memblock.memory
list, struct page for every page from this list goes through
__init_single_page().

The second memblock list: memblock.reserved, manages the allocated memory.
The memory that won't be available to kernel allocator. So, every page from
this list goes through reserve_bootmem_region(), where certain struct page
fields are set, the assumption being that the struct pages have been
initialized beforehand.

In trim_low_memory_range() we unconditionally reserve memoryfrom PFN 0, but
memblock.memory might start at a later PFN. For example, in QEMU,
e820__memblock_setup() can use PFN 1 as the first PFN in memblock.memory,
so PFN 0 is not on memblock.memory (and hence isn't initialized via
__init_single_page) but is on memblock.reserved (and hence we set fields in
the uninitialized struct page).

Currently, the struct page memory is always zeroed during allocation,
which prevents this problem from being detected. But, if some asserts
provided by CONFIG_DEBUG_VM_PGFLAGS are tighten, this problem may become
visible in existing kernels.

In this patchset we will stop zeroing struct page memory during allocation.
Therefore, this bug must be fixed in order to avoid random assert failures
caused by CONFIG_DEBUG_VM_PGFLAGS triggers.

The fix is to reserve memory from the first existing PFN.

Signed-off-by: Pavel Tatashin <pasha.tatashin@oracle.com>
Reviewed-by: Steven Sistare <steven.sistare@oracle.com>
Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Reviewed-by: Bob Picco <bob.picco@oracle.com>
---
 arch/x86/kernel/setup.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 3486d0498800..489cdc141bcb 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -790,7 +790,10 @@ early_param("reservelow", parse_reservelow);
 
 static void __init trim_low_memory_range(void)
 {
-	memblock_reserve(0, ALIGN(reserve_low, PAGE_SIZE));
+	unsigned long min_pfn = find_min_pfn_with_active_regions();
+	phys_addr_t base = min_pfn << PAGE_SHIFT;
+
+	memblock_reserve(base, ALIGN(reserve_low, PAGE_SIZE));
 }
 	
 /*
-- 
2.13.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
