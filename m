Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DE5F56B742B
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:01:13 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p11-v6so8976093oih.17
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:01:13 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f192-v6si1598869oig.411.2018.09.05.09.01.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:01:11 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85Fuin2083536
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:01:10 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2maghme3j9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:01:08 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:01:01 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 24/29] memblock: replace free_bootmem_late with memblock_free_late
Date: Wed,  5 Sep 2018 18:59:39 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-25-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

The free_bootmem_late and memblock_free_late do exactly the same thing:
they iterate over a range and give pages to the page allocator.

Replace calls to free_bootmem_late with calls to memblock_free_late and
remove the bootmem variant.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/sparc/kernel/mdesc.c               |  3 ++-
 arch/x86/platform/efi/quirks.c          |  6 +++---
 drivers/firmware/efi/apple-properties.c |  2 +-
 include/linux/bootmem.h                 |  2 --
 mm/nobootmem.c                          | 24 ------------------------
 5 files changed, 6 insertions(+), 31 deletions(-)

diff --git a/arch/sparc/kernel/mdesc.c b/arch/sparc/kernel/mdesc.c
index 59131e7..a41526b 100644
--- a/arch/sparc/kernel/mdesc.c
+++ b/arch/sparc/kernel/mdesc.c
@@ -12,6 +12,7 @@
 #include <linux/mm.h>
 #include <linux/miscdevice.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/export.h>
 #include <linux/refcount.h>
 
@@ -190,7 +191,7 @@ static void __init mdesc_memblock_free(struct mdesc_handle *hp)
 
 	alloc_size = PAGE_ALIGN(hp->handle_size);
 	start = __pa(hp);
-	free_bootmem_late(start, alloc_size);
+	memblock_free_late(start, alloc_size);
 }
 
 static struct mdesc_mem_ops memblock_mdesc_ops = {
diff --git a/arch/x86/platform/efi/quirks.c b/arch/x86/platform/efi/quirks.c
index 844d31c..7b4854c 100644
--- a/arch/x86/platform/efi/quirks.c
+++ b/arch/x86/platform/efi/quirks.c
@@ -332,7 +332,7 @@ void __init efi_reserve_boot_services(void)
 
 		/*
 		 * Because the following memblock_reserve() is paired
-		 * with free_bootmem_late() for this region in
+		 * with memblock_free_late() for this region in
 		 * efi_free_boot_services(), we must be extremely
 		 * careful not to reserve, and subsequently free,
 		 * critical regions of memory (like the kernel image) or
@@ -363,7 +363,7 @@ void __init efi_reserve_boot_services(void)
 		 * doesn't make sense as far as the firmware is
 		 * concerned, but it does provide us with a way to tag
 		 * those regions that must not be paired with
-		 * free_bootmem_late().
+		 * memblock_free_late().
 		 */
 		md->attribute |= EFI_MEMORY_RUNTIME;
 	}
@@ -413,7 +413,7 @@ void __init efi_free_boot_services(void)
 			size -= rm_size;
 		}
 
-		free_bootmem_late(start, size);
+		memblock_free_late(start, size);
 	}
 
 	if (!num_entries)
diff --git a/drivers/firmware/efi/apple-properties.c b/drivers/firmware/efi/apple-properties.c
index 60a9571..2b675f7 100644
--- a/drivers/firmware/efi/apple-properties.c
+++ b/drivers/firmware/efi/apple-properties.c
@@ -235,7 +235,7 @@ static int __init map_properties(void)
 		 */
 		data->len = 0;
 		memunmap(data);
-		free_bootmem_late(pa_data + sizeof(*data), data_len);
+		memblock_free_late(pa_data + sizeof(*data), data_len);
 
 		return ret;
 	}
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 706cf8e..bcc7e2f 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -30,8 +30,6 @@ extern unsigned long free_all_bootmem(void);
 extern void reset_node_managed_pages(pg_data_t *pgdat);
 extern void reset_all_zones_managed_pages(void);
 
-extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
-
 /* We are using top down, so it is safe to use 0 here */
 #define BOOTMEM_LOW_LIMIT 0
 
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 85e1822..ee0f7fc 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -33,30 +33,6 @@ unsigned long min_low_pfn;
 unsigned long max_pfn;
 unsigned long long max_possible_pfn;
 
-/**
- * free_bootmem_late - free bootmem pages directly to page allocator
- * @addr: starting address of the range
- * @size: size of the range in bytes
- *
- * This is only useful when the bootmem allocator has already been torn
- * down, but we are still initializing the system.  Pages are given directly
- * to the page allocator, no bootmem metadata is updated because it is gone.
- */
-void __init free_bootmem_late(unsigned long addr, unsigned long size)
-{
-	unsigned long cursor, end;
-
-	kmemleak_free_part_phys(addr, size);
-
-	cursor = PFN_UP(addr);
-	end = PFN_DOWN(addr + size);
-
-	for (; cursor < end; cursor++) {
-		__free_pages_bootmem(pfn_to_page(cursor), cursor, 0);
-		totalram_pages++;
-	}
-}
-
 static void __init __free_pages_memory(unsigned long start, unsigned long end)
 {
 	int order;
-- 
2.7.4
