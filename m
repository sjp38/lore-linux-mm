Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id C2FA56B005A
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 20:24:51 -0500 (EST)
Date: Mon, 12 Nov 2012 20:24:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] bootmem: fix wrong call parameter for free_bootmem()
Message-ID: <20121113012436.GG10092@cmpxchg.org>
References: <1352737915-30906-1-git-send-email-js1304@gmail.com>
 <1352737915-30906-4-git-send-email-js1304@gmail.com>
 <20121112152342.ce90052a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121112152342.ce90052a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>

On Mon, Nov 12, 2012 at 03:23:42PM -0800, Andrew Morton wrote:
> On Tue, 13 Nov 2012 01:31:55 +0900
> Joonsoo Kim <js1304@gmail.com> wrote:
> 
> > It is somehow strange that alloc_bootmem return virtual address
> > and free_bootmem require physical address.
> > Anyway, free_bootmem()'s first parameter should be physical address.
> > 
> > There are some call sites for free_bootmem() with virtual address.
> > So fix them.
> 
> Well gee, I wonder how that happened :(

free_bootmem() is the counterpart to reserve_bootmem() to configure
physical memory ranges.  Allocations are assumed to be permanent.

> How does this look?

Much better.  How about this in addition?

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 7b74452..b519cb2 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -49,7 +49,7 @@ extern unsigned long free_all_bootmem_node(pg_data_t *pgdat);
 extern unsigned long free_all_bootmem(void);
 
 extern void free_bootmem_node(pg_data_t *pgdat,
-			      unsigned long addr,
+			      unsigned long physaddr,
 			      unsigned long size);
 extern void free_bootmem(unsigned long physaddr, unsigned long size);
 extern void free_bootmem_late(unsigned long physaddr, unsigned long size);
diff --git a/mm/bootmem.c b/mm/bootmem.c
index 4c079ba..5135d84 100644
--- a/mm/bootmem.c
+++ b/mm/bootmem.c
@@ -147,7 +147,7 @@ unsigned long __init init_bootmem(unsigned long start, unsigned long pages)
 
 /*
  * free_bootmem_late - free bootmem pages directly to page allocator
- * @addr: starting physical address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * This is only useful when the bootmem allocator has already been torn
@@ -385,7 +385,7 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 
 /**
  * free_bootmem - mark a page range as usable
- * @addr: starting physical address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * Partial pages will be considered reserved and left as they are.
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 714d5d6..a532960 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -58,21 +58,21 @@ static void * __init __alloc_memory_core_early(int nid, u64 size, u64 align,
 
 /*
  * free_bootmem_late - free bootmem pages directly to page allocator
- * @addr: starting address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * This is only useful when the bootmem allocator has already been torn
  * down, but we are still initializing the system.  Pages are given directly
  * to the page allocator, no bootmem metadata is updated because it is gone.
  */
-void __init free_bootmem_late(unsigned long addr, unsigned long size)
+void __init free_bootmem_late(unsigned long physaddr, unsigned long size)
 {
 	unsigned long cursor, end;
 
-	kmemleak_free_part(__va(addr), size);
+	kmemleak_free_part(__va(physaddr), size);
 
-	cursor = PFN_UP(addr);
-	end = PFN_DOWN(addr + size);
+	cursor = PFN_UP(physaddr);
+	end = PFN_DOWN(physaddr + size);
 
 	for (; cursor < end; cursor++) {
 		__free_pages_bootmem(pfn_to_page(cursor), 0);
@@ -188,17 +188,17 @@ void __init free_bootmem_node(pg_data_t *pgdat, unsigned long physaddr,
 
 /**
  * free_bootmem - mark a page range as usable
- * @addr: starting address of the range
+ * @physaddr: starting physical address of the range
  * @size: size of the range in bytes
  *
  * Partial pages will be considered reserved and left as they are.
  *
  * The range must be contiguous but may span node boundaries.
  */
-void __init free_bootmem(unsigned long addr, unsigned long size)
+void __init free_bootmem(unsigned long physaddr, unsigned long size)
 {
-	kmemleak_free_part(__va(addr), size);
-	memblock_free(addr, size);
+	kmemleak_free_part(__va(physaddr), size);
+	memblock_free(physaddr, size);
 }
 
 static void * __init ___alloc_bootmem_nopanic(unsigned long size,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
