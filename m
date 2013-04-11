Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B6DB36B0005
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 14:56:36 -0400 (EDT)
Date: Thu, 11 Apr 2013 14:56:32 -0400
From: Dave Jones <davej@redhat.com>
Subject: print out hardware name & modules list when we encounter bad page
 tables.
Message-ID: <20130411185632.GA7569@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Given we have been seeing a lot of reports of page table corruption
for a while now, perhaps if we print out the hardware name, and list
of modules loaded, we might see some patterns emerging.

Signed-off-by: Dave Jones <davej@redhat.com>

diff -durpN '--exclude-from=/home/davej/.exclude' /home/davej/src/kernel/git-trees/linux/include/asm-generic/bug.h linux-dj/include/asm-generic/bug.h
--- linux/include/asm-generic/bug.h	2013-01-04 18:57:12.604282214 -0500
+++ linux-dj/include/asm-generic/bug.h	2013-02-28 20:04:37.649304147 -0500
@@ -55,6 +55,8 @@ struct bug_entry {
 #define BUG_ON(condition) do { if (unlikely(condition)) BUG(); } while(0)
 #endif
 
+void print_hardware_dmi_name(void);
+
 /*
  * WARN(), WARN_ON(), WARN_ON_ONCE, and so on can be used to report
  * significant issues that need prompt attention if they should ever
diff -durpN '--exclude-from=/home/davej/.exclude' /home/davej/src/kernel/git-trees/linux/kernel/panic.c linux-dj/kernel/panic.c
--- linux/kernel/panic.c	2013-02-26 14:41:18.544116674 -0500
+++ linux-dj/kernel/panic.c	2013-02-28 20:04:37.666304115 -0500
@@ -397,16 +397,22 @@ struct slowpath_args {
 	va_list args;
 };
 
-static void warn_slowpath_common(const char *file, int line, void *caller,
-				 unsigned taint, struct slowpath_args *args)
+void print_hardware_dmi_name(void)
 {
 	const char *board;
 
-	printk(KERN_WARNING "------------[ cut here ]------------\n");
-	printk(KERN_WARNING "WARNING: at %s:%d %pS()\n", file, line, caller);
 	board = dmi_get_system_info(DMI_PRODUCT_NAME);
 	if (board)
 		printk(KERN_WARNING "Hardware name: %s\n", board);
+}
+
+static void warn_slowpath_common(const char *file, int line, void *caller,
+				 unsigned taint, struct slowpath_args *args)
+{
+	printk(KERN_WARNING "------------[ cut here ]------------\n");
+	printk(KERN_WARNING "WARNING: at %s:%d %pS()\n", file, line, caller);
+
+	print_hardware_dmi_name();
 
 	if (args)
 		vprintk(args->fmt, args->args);
diff -durpN '--exclude-from=/home/davej/.exclude' /home/davej/src/kernel/git-trees/linux/mm/memory.c linux-dj/mm/memory.c
--- linux/mm/memory.c	2013-02-26 14:41:18.591116577 -0500
+++ linux-dj/mm/memory.c	2013-02-28 20:04:37.678304092 -0500
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/module.h>
 #include <linux/migrate.h>
 #include <linux/string.h>
 
@@ -705,6 +706,9 @@ static void print_bad_pte(struct vm_area
 		"BUG: Bad page map in process %s  pte:%08llx pmd:%08llx\n",
 		current->comm,
 		(long long)pte_val(pte), (long long)pmd_val(*pmd));
+	print_hardware_dmi_name();
+	print_modules();
+
 	if (page)
 		dump_page(page);
 	printk(KERN_ALERT
--- linux-dj/mm/page_alloc.c~	2013-04-11 11:47:12.536675503 -0400
+++ linux-dj/mm/page_alloc.c	2013-04-11 11:47:16.416667806 -0400
@@ -321,6 +321,7 @@ static void bad_page(struct page *page)
 		current->comm, page_to_pfn(page));
 	dump_page(page);
 
+	print_hardware_dmi_name();
 	print_modules();
 	dump_stack();
 out:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
