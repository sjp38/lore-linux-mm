Received: by nf-out-0910.google.com with SMTP id c10so1890844nfd.6
        for <linux-mm@kvack.org>; Tue, 29 Jul 2008 00:53:36 -0700 (PDT)
Date: Tue, 29 Jul 2008 15:54:41 +0800
From: Dave Young <hidave.darkstar@gmail.com>
Subject: [PATCH V2] i386 : vmalloc size fix
Message-ID: <20080729075441.GA3075@darkstar>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, yhlu.kernel@gmail.com, x86@kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

v2 based on the ported version of ingo, changes:
remove unused VMALLOC_RESERVE macro in page_32.h

--
Booting kernel with vmalloc=[any size<=16m] will oops on my pc (i386/1G memory).

BUG_ON in arch/x86/mm/init_32.c triggered:
BUG_ON((unsigned long)high_memory > VMALLOC_START);

It's due to the vm area hole.

In include/asm-x86/pgtable_32.h:
#define VMALLOC_OFFSET	(8 * 1024 * 1024)
#define VMALLOC_START	(((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) \
			 & ~(VMALLOC_OFFSET - 1))

There's several related point:
1. MAXMEM :
 (-__PAGE_OFFSET - __VMALLOC_RESERVE).
The space after VMALLOC_END is included as well, I set it to
(VMALLOC_END - PAGE_OFFSET - __VMALLOC_RESERVE)

2. VMALLOC_OFFSET is not considered in __VMALLOC_RESERVE
fixed by adding VMALLOC_OFFSET to it.

3. VMALLOC_START :
 (((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) & ~(VMALLOC_OFFSET - 1))
So it's not always 8M, bigger than 8M possible.
I set it to ((unsigned long)high_memory + VMALLOC_OFFSET)

4. the VMALLOC_RESERVE is an unused macro, so remove it here.

Signed-off-by: Dave Young <hidave.darkstar@gmail.com>

arch/x86/mm/pgtable_32.c     |    3 ++-
include/asm-x86/page_32.h    |    3 ---
include/asm-x86/pgtable_32.h |    5 +++--
3 files changed, 5 insertions(+), 6 deletions(-)

Index: linux-2.6/arch/x86/mm/pgtable_32.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/pgtable_32.c	2008-07-29 14:43:02.000000000 +0800
+++ linux-2.6/arch/x86/mm/pgtable_32.c	2008-07-29 14:44:43.000000000 +0800
@@ -123,7 +123,8 @@
 	if (!arg)
 		return -EINVAL;
 
-	__VMALLOC_RESERVE = memparse(arg, &arg);
+	/* Add VMALLOC_OFFSET to the parsed value due to vm area guard hole*/
+	__VMALLOC_RESERVE = memparse(arg, &arg) + VMALLOC_OFFSET;
 	return 0;
 }
 early_param("vmalloc", parse_vmalloc);
Index: linux-2.6/include/asm-x86/page_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/page_32.h	2008-07-29 14:44:13.000000000 +0800
+++ linux-2.6/include/asm-x86/page_32.h	2008-07-29 14:45:15.000000000 +0800
@@ -89,9 +89,6 @@
 extern unsigned int __VMALLOC_RESERVE;
 extern int sysctl_legacy_va_layout;
 
-#define VMALLOC_RESERVE		((unsigned long)__VMALLOC_RESERVE)
-#define MAXMEM			(-__PAGE_OFFSET - __VMALLOC_RESERVE)
-
 extern void find_low_pfn_range(void);
 extern unsigned long init_memory_mapping(unsigned long start,
 					 unsigned long end);
Index: linux-2.6/include/asm-x86/pgtable_32.h
===================================================================
--- linux-2.6.orig/include/asm-x86/pgtable_32.h	2008-07-29 14:43:02.000000000 +0800
+++ linux-2.6/include/asm-x86/pgtable_32.h	2008-07-29 14:44:43.000000000 +0800
@@ -56,8 +56,7 @@
  * area for the same reason. ;)
  */
 #define VMALLOC_OFFSET	(8 * 1024 * 1024)
-#define VMALLOC_START	(((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) \
-			 & ~(VMALLOC_OFFSET - 1))
+#define VMALLOC_START	((unsigned long)high_memory + VMALLOC_OFFSET)
 #ifdef CONFIG_X86_PAE
 #define LAST_PKMAP 512
 #else
@@ -73,6 +72,8 @@
 # define VMALLOC_END	(FIXADDR_START - 2 * PAGE_SIZE)
 #endif
 
+#define MAXMEM	(VMALLOC_END - PAGE_OFFSET - __VMALLOC_RESERVE)
+
 /*
  * Define this if things work differently on an i386 and an i486:
  * it will (on an i486) warn about kernel memory accesses that are

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
