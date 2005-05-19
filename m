Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j4JIlG8L029837
	for <linux-mm@kvack.org>; Thu, 19 May 2005 14:47:16 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j4JIlFW5106354
	for <linux-mm@kvack.org>; Thu, 19 May 2005 14:47:16 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j4JIlFA3002506
	for <linux-mm@kvack.org>; Thu, 19 May 2005 14:47:15 -0400
Subject: Re: page flags ?
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <20050519041116.1e3a6d29.akpm@osdl.org>
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518145644.717afc21.akpm@osdl.org>
	 <1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com>
	 <20050518162302.13a13356.akpm@osdl.org> <428C6FB9.4060602@shadowen.org>
	 <20050519041116.1e3a6d29.akpm@osdl.org>
Content-Type: multipart/mixed; boundary="=-oVFm9iO6Vst/xTl4onjF"
Message-Id: <1116527349.26913.1353.camel@dyn318077bld.beaverton.ibm.com>
Mime-Version: 1.0
Date: 19 May 2005 11:29:11 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

--=-oVFm9iO6Vst/xTl4onjF
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2005-05-19 at 04:11, Andrew Morton wrote:
> Andy Whitcroft <apw@shadowen.org> wrote:
> >
> >  > How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.
> > 
> >  The short answer is that on 32 bit architectures there are 24 bits
> >  allocated to general page flags, page-flags.h indicates that 21 are
> >  currently assigned so assuming it is accurate there are currently 3 bits
> >  free.
> 
> Yipes, I didn't realise we were that close.
> 
> We can reclaim PG_highmem, use page_zone(page)->highmem

Your wish is my command :)

I am worried about the overhead this might add to kmap/kunmap().

Thanks,
Badari



--=-oVFm9iO6Vst/xTl4onjF
Content-Disposition: attachment; filename=PG_highmem-remove.patch
Content-Type: text/plain; name=PG_highmem-remove.patch; charset=UTF-8
Content-Transfer-Encoding: 7bit

Patch to remove PG_highmem from page->flags.

Signed-off-by: Badari Pulavarty <pbadari@us.ibm.com>
 arch/frv/mm/init.c         |    1 -
 arch/i386/mm/init.c        |    1 -
 arch/mips/mm/init.c        |    1 -
 arch/ppc/mm/init.c         |    1 -
 arch/sparc/mm/init.c       |    1 -
 arch/um/kernel/mem.c       |    1 -
 fs/reiser4/page_cache.c    |    3 +--
 include/linux/page-flags.h |    4 ++--
 8 files changed, 3 insertions(+), 10 deletions(-)
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/frv/mm/init.c linux-2.6.12-rc4/arch/frv/mm/init.c
--- linux-2.6.12-rc4.org/arch/frv/mm/init.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/arch/frv/mm/init.c	2005-05-19 03:43:27.266433184 -0700
@@ -169,7 +169,6 @@ void __init mem_init(void)
 		struct page *page = &mem_map[pfn];
 
 		ClearPageReserved(page);
-		set_bit(PG_highmem, &page->flags);
 		set_page_count(page, 1);
 		__free_page(page);
 		totalram_pages++;
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/i386/mm/init.c linux-2.6.12-rc4/arch/i386/mm/init.c
--- linux-2.6.12-rc4.org/arch/i386/mm/init.c	2005-05-17 02:27:11.350562312 -0700
+++ linux-2.6.12-rc4/arch/i386/mm/init.c	2005-05-19 03:43:43.178014256 -0700
@@ -269,7 +269,6 @@ void __init one_highpage_init(struct pag
 {
 	if (page_is_ram(pfn) && !(bad_ppro && page_kills_ppro(pfn))) {
 		ClearPageReserved(page);
-		set_bit(PG_highmem, &page->flags);
 		set_page_count(page, 1);
 		__free_page(page);
 		totalhigh_pages++;
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/mips/mm/init.c linux-2.6.12-rc4/arch/mips/mm/init.c
--- linux-2.6.12-rc4.org/arch/mips/mm/init.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/arch/mips/mm/init.c	2005-05-19 03:43:57.457843392 -0700
@@ -232,7 +232,6 @@ void __init mem_init(void)
 #ifdef CONFIG_LIMITED_DMA
 		set_page_address(page, lowmem_page_address(page));
 #endif
-		set_bit(PG_highmem, &page->flags);
 		set_page_count(page, 1);
 		__free_page(page);
 		totalhigh_pages++;
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/ppc/mm/init.c linux-2.6.12-rc4/arch/ppc/mm/init.c
--- linux-2.6.12-rc4.org/arch/ppc/mm/init.c	2005-05-17 02:27:11.400554712 -0700
+++ linux-2.6.12-rc4/arch/ppc/mm/init.c	2005-05-19 03:44:18.800598800 -0700
@@ -459,7 +459,6 @@ void __init mem_init(void)
 			struct page *page = mem_map + pfn;
 
 			ClearPageReserved(page);
-			set_bit(PG_highmem, &page->flags);
 			set_page_count(page, 1);
 			__free_page(page);
 			totalhigh_pages++;
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/sparc/mm/init.c linux-2.6.12-rc4/arch/sparc/mm/init.c
--- linux-2.6.12-rc4.org/arch/sparc/mm/init.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/arch/sparc/mm/init.c	2005-05-19 03:44:40.526295992 -0700
@@ -384,7 +384,6 @@ void map_high_region(unsigned long start
 		struct page *page = pfn_to_page(tmp);
 
 		ClearPageReserved(page);
-		set_bit(PG_highmem, &page->flags);
 		set_page_count(page, 1);
 		__free_page(page);
 		totalhigh_pages++;
diff -X dontdiff -Narup linux-2.6.12-rc4.org/arch/um/kernel/mem.c linux-2.6.12-rc4/arch/um/kernel/mem.c
--- linux-2.6.12-rc4.org/arch/um/kernel/mem.c	2005-05-06 22:20:31.000000000 -0700
+++ linux-2.6.12-rc4/arch/um/kernel/mem.c	2005-05-19 03:45:00.200305088 -0700
@@ -53,7 +53,6 @@ static void setup_highmem(unsigned long 
 	for(i = 0; i < highmem_len >> PAGE_SHIFT; i++){
 		page = &mem_map[highmem_pfn + i];
 		ClearPageReserved(page);
-		set_bit(PG_highmem, &page->flags);
 		set_page_count(page, 1);
 		__free_page(page);
 	}
diff -X dontdiff -Narup linux-2.6.12-rc4.org/fs/reiser4/page_cache.c linux-2.6.12-rc4/fs/reiser4/page_cache.c
--- linux-2.6.12-rc4.org/fs/reiser4/page_cache.c	2005-05-17 02:27:19.258360144 -0700
+++ linux-2.6.12-rc4/fs/reiser4/page_cache.c	2005-05-19 03:45:38.432492912 -0700
@@ -744,7 +744,7 @@ print_page(const char *prefix, struct pa
 	}
 	printk("%s: page index: %lu mapping: %p count: %i private: %lx\n",
 	       prefix, page->index, page->mapping, page_count(page), page->private);
-	printk("\tflags: %s%s%s%s %s%s%s %s%s%s %s%s%s\n",
+	printk("\tflags: %s%s%s%s %s%s%s %s%s %s%s%s\n",
 	       page_flag_name(page, PG_locked),
 	       page_flag_name(page, PG_error),
 	       page_flag_name(page, PG_referenced),
@@ -754,7 +754,6 @@ print_page(const char *prefix, struct pa
 	       page_flag_name(page, PG_lru),
 	       page_flag_name(page, PG_slab),
 
-	       page_flag_name(page, PG_highmem),
 	       page_flag_name(page, PG_checked),
 	       page_flag_name(page, PG_reserved),
 
diff -X dontdiff -Narup linux-2.6.12-rc4.org/include/linux/page-flags.h linux-2.6.12-rc4/include/linux/page-flags.h
--- linux-2.6.12-rc4.org/include/linux/page-flags.h	2005-05-17 02:27:20.248209664 -0700
+++ linux-2.6.12-rc4/include/linux/page-flags.h	2005-05-19 03:46:57.214516224 -0700
@@ -61,7 +61,7 @@
 #define PG_active		 6
 #define PG_slab			 7	/* slab debug (Suparna wants this) */
 
-#define PG_highmem		 8
+#define PG_highmem_removed	 8	/* Trying to kill this */
 #define PG_fs_misc		 9	/* Filesystem specific bit */
 #define PG_checked		 9	/* kill me in 2.5.<early>. */
 #define PG_arch_1		10
@@ -216,7 +216,7 @@ extern void __mod_page_state(unsigned of
 #define TestSetPageSlab(page)	test_and_set_bit(PG_slab, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
-#define PageHighMem(page)	test_bit(PG_highmem, &(page)->flags)
+#define PageHighMem(page)	is_highmem(page_zone(page))
 #else
 #define PageHighMem(page)	0 /* needed to optimize away at compile time */
 #endif

--=-oVFm9iO6Vst/xTl4onjF--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
