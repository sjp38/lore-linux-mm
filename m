Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 60D796B02F5
	for <linux-mm@kvack.org>; Fri, 20 Aug 2010 05:45:52 -0400 (EDT)
Message-ID: <4C6E4ECD.1090607@linux.intel.com>
Date: Fri, 20 Aug 2010 17:45:49 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: [BUGFIX][PATCH 1/2] x86, mem: separate x86_64 vmalloc_sync_all()
 into separate functions
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Cc: "ak@linux.intel.com" <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

hello,

Resend these two patches for bug fixing:

The bug is that when memory hotplug-adding happens for a large enough area that a new PGD entry is
needed for the direct mapping, the PGDs of other processes would not get updated. This leads to some
CPUs oopsing when they have to access the unmapped areas, e.g. onlining CPUs on the new added node.

Thanks!

---
 From 04d9fc860db40f15ad629f8b341ff84b83a00a8d Mon Sep 17 00:00:00 2001
From: Haicheng Li <haicheng.li@linux.intel.com>
Date: Wed, 19 May 2010 17:42:14 +0800
Subject: [PATCH] x86, mem-hotplug: separate x86_64 vmalloc_sync_all() into separate functions

No behavior change here.

Move some of vmalloc_sync_all() code into a new function
sync_global_pgds() that will be useful for memory hotplug.

Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
CC: Andi Kleen <ak@linux.intel.com>
---
  arch/x86/include/asm/pgtable_64.h |    2 ++
  arch/x86/mm/fault.c               |   24 +-----------------------
  arch/x86/mm/init_64.c             |   30 ++++++++++++++++++++++++++++++
  3 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/arch/x86/include/asm/pgtable_64.h b/arch/x86/include/asm/pgtable_64.h
index 181be52..317026d 100644
--- a/arch/x86/include/asm/pgtable_64.h
+++ b/arch/x86/include/asm/pgtable_64.h
@@ -102,6 +102,8 @@ static inline void native_pgd_clear(pgd_t *pgd)
  	native_set_pgd(pgd, native_make_pgd(0));
  }

+extern void sync_global_pgds(unsigned long start, unsigned long end);
+
  /*
   * Conversion functions: convert a page and protection to a page entry,
   * and a page entry and page directory to the page they refer to.
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index f627779..7ae0897 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -326,29 +326,7 @@ out:

  void vmalloc_sync_all(void)
  {
-	unsigned long address;
-
-	for (address = VMALLOC_START & PGDIR_MASK; address <= VMALLOC_END;
-	     address += PGDIR_SIZE) {
-
-		const pgd_t *pgd_ref = pgd_offset_k(address);
-		unsigned long flags;
-		struct page *page;
-
-		if (pgd_none(*pgd_ref))
-			continue;
-
-		spin_lock_irqsave(&pgd_lock, flags);
-		list_for_each_entry(page, &pgd_list, lru) {
-			pgd_t *pgd;
-			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			if (pgd_none(*pgd))
-				set_pgd(pgd, *pgd_ref);
-			else
-				BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
-		}
-		spin_unlock_irqrestore(&pgd_lock, flags);
-	}
+	sync_global_pgds(VMALLOC_START & PGDIR_MASK, VMALLOC_END);
  }

  /*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index ee41bba..b0c3df0 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -98,6 +98,36 @@ static int __init nonx32_setup(char *str)
  __setup("noexec32=", nonx32_setup);

  /*
+ * When memory was added/removed make sure all the processes MM have
+ * suitable PGD entries in the local PGD level page.
+ */
+void sync_global_pgds(unsigned long start, unsigned long end)
+{
+	unsigned long address;
+
+	for (address = start; address <= end; address += PGDIR_SIZE) {
+		const pgd_t *pgd_ref = pgd_offset_k(address);
+		unsigned long flags;
+		struct page *page;
+
+		if (pgd_none(*pgd_ref))
+			continue;
+
+		spin_lock_irqsave(&pgd_lock, flags);
+		list_for_each_entry(page, &pgd_list, lru) {
+			pgd_t *pgd;
+			pgd = (pgd_t *)page_address(page) + pgd_index(address);
+			if (pgd_none(*pgd))
+				set_pgd(pgd, *pgd_ref);
+			else
+				BUG_ON(pgd_page_vaddr(*pgd)
+					 != pgd_page_vaddr(*pgd_ref));
+		}
+		spin_unlock_irqrestore(&pgd_lock, flags);
+	}
+}
+
+/*
   * NOTE: This function is marked __ref because it calls __init function
   * (alloc_bootmem_pages). It's safe to do it ONLY when after_bootmem == 0.
   */
-- 
1.5.6.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
