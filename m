Message-ID: <41D99C3A.5090400@sgi.com>
Date: Mon, 03 Jan 2005 13:25:46 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: migration cache, updated
Content-Type: multipart/mixed;
 boundary="------------000705090500000100060804"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcello Tosatti <marcelo.tosatti@cyclades.com>, Hirokazu Takahashi <taka@valinux.co.jp>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------000705090500000100060804
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Marcello and Takahashi-san,

In working with your migration cache patch, I found out that
if CONFIG_MIGRATE_MEMORY is not set, then the kernel with your patch
applied (on top of my "split out" version of the memory migration
code from the hotplug patch) doesn't link.  (It still expects
migration_space, etc to be defined as externals, and these aren't
defined if CONFIG_MIGRATE_MEMORY is not set.)

Now I realize your patch is probably not "final" (there are a couple
of FIXME's still in there....), but I found the attached patch
useful as it lets my patched kernel compile with or without
CONFIG_MEMORY_MIGRATE set.

I hope you find this useful and will incorporate it into your
migration cache patch.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------

--------------000705090500000100060804
Content-Type: text/plain;
 name="migration_cache_update_fix_link.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="migration_cache_update_fix_link.patch"

Fix the migration cache patch so that it will link even if
CONFIG_MEMORY_MIGRATE is not set.

Signed-off-by:Ray Bryant <raybry@sgi.com>

Index: linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mm.h
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/include/linux/mm.h	2004-12-29 09:30:00.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/include/linux/mm.h	2004-12-29 09:33:46.000000000 -0800
@@ -279,6 +279,7 @@ struct page {
 #include <linux/swap.h>
 #include <linux/swapops.h> 
 
+#ifdef CONFIG_MEMORY_MIGRATE
 static inline int PageMigration(struct page *page)
 {
         swp_entry_t entry;
@@ -293,7 +294,9 @@ static inline int PageMigration(struct p
 
         return 1;
 }
-
+#else
+#define PageMigration(p)  0
+#endif /* CONFIG_MEMORY_MIGRATE */
 
 /*
  * Methods to modify the page usage count.
@@ -506,9 +509,13 @@ static inline struct address_space *page
 {
 	struct address_space *mapping = page->mapping;
 
+#ifdef CONFIG_MEMORY_MIGRATE
 	if (unlikely(PageMigration(page)))
 		mapping = &migration_space;
 	else if (unlikely(PageSwapCache(page)))
+#else
+ 	if (unlikely(PageSwapCache(page)))
+#endif
 		mapping = &swapper_space;
 	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
 		mapping = NULL;
Index: linux-2.6.10-rc2-mm4-page-migration-only/include/linux/swapops.h
===================================================================
--- linux-2.6.10-rc2-mm4-page-migration-only.orig/include/linux/swapops.h	2004-12-29 09:30:00.000000000 -0800
+++ linux-2.6.10-rc2-mm4-page-migration-only/include/linux/swapops.h	2004-12-29 09:36:30.000000000 -0800
@@ -70,6 +70,7 @@ static inline pte_t swp_entry_to_pte(swp
 	return __swp_entry_to_pte(arch_entry);
 }
 
+#ifdef CONFIG_MEMORY_MIGRATE
 static inline int pte_is_migration(pte_t pte)
 {
 	unsigned long swp_type;
@@ -81,6 +82,9 @@ static inline int pte_is_migration(pte_t
 
 	return swp_type == MIGRATION_TYPE;
 }
+#else
+#define pte_is_migration(x) 0
+#endif /* CONFIG_MEMORY_MIGRATE */
 
 static inline pte_t migration_entry_to_pte(swp_entry_t entry)
 {

--------------000705090500000100060804--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
