Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D606E9000C2
	for <linux-mm@kvack.org>; Thu,  7 Jul 2011 16:12:56 -0400 (EDT)
Date: Thu, 7 Jul 2011 15:12:52 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <CAOJsxLFsX3Q84QAeyRt5dZOdRxb3TiABPrP-YrWc91+BmR8ZBg@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1107071511010.26083@router.home>
References: <alpine.DEB.2.00.1107071314320.21719@router.home> <1310064771.21902.55.camel@jaguar> <alpine.DEB.2.00.1107071402490.24248@router.home> <20110707.122151.314840355798805828.davem@davemloft.net>
 <CAOJsxLFsX3Q84QAeyRt5dZOdRxb3TiABPrP-YrWc91+BmR8ZBg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Miller <davem@davemloft.net>, marcin.slusarz@gmail.com, mpm@selenic.com, linux-kernel@vger.kernel.org, rientjes@google.com, linux-mm@kvack.org

On Thu, 7 Jul 2011, Pekka Enberg wrote:

> I applied the patch. I think a follow up patch that moves the function
> to lib/string.c with proper generic name would be in order. Thanks!

Well this is really straightforward. Hasnt seen much testing yet and
needs refinement but it would be like this:


---
 arch/x86/include/asm/string_32.h |    2 ++
 arch/x86/lib/string_32.c         |   17 +++++++++++++++++
 include/linux/string.h           |    3 +++
 lib/string.c                     |   25 +++++++++++++++++++++++++
 mm/slub.c                        |   13 ++++++-------
 5 files changed, 53 insertions(+), 7 deletions(-)

Index: linux-2.6/arch/x86/lib/string_32.c
===================================================================
--- linux-2.6.orig/arch/x86/lib/string_32.c	2011-07-07 15:03:46.000000000 -0500
+++ linux-2.6/arch/x86/lib/string_32.c	2011-07-07 15:03:56.000000000 -0500
@@ -214,6 +214,23 @@ void *memscan(void *addr, int c, size_t
 EXPORT_SYMBOL(memscan);
 #endif

+#ifdef __HAVE_ARCH_INV_MEMSCAN
+void *inv_memscan(void *addr, int c, size_t size)
+{
+	if (!size)
+		return addr;
+	asm volatile("repz; scasb\n\t"
+	    "jz 1f\n\t"
+	    "dec %%edi\n"
+	    "1:"
+	    : "=D" (addr), "=c" (size)
+	    : "0" (addr), "1" (size), "a" (c)
+	    : "memory");
+	return addr;
+}
+EXPORT_SYMBOL(memscan);
+#endif
+
 #ifdef __HAVE_ARCH_STRNLEN
 size_t strnlen(const char *s, size_t count)
 {
Index: linux-2.6/include/linux/string.h
===================================================================
--- linux-2.6.orig/include/linux/string.h	2011-07-07 15:03:46.000000000 -0500
+++ linux-2.6/include/linux/string.h	2011-07-07 15:03:56.000000000 -0500
@@ -108,6 +108,9 @@ extern void * memmove(void *,const void
 #ifndef __HAVE_ARCH_MEMSCAN
 extern void * memscan(void *,int,__kernel_size_t);
 #endif
+#ifndef __HAVE_ARCH_INV_MEMSCAN
+extern void * inv_memscan(void *,int,__kernel_size_t);
+#endif
 #ifndef __HAVE_ARCH_MEMCMP
 extern int memcmp(const void *,const void *,__kernel_size_t);
 #endif
Index: linux-2.6/lib/string.c
===================================================================
--- linux-2.6.orig/lib/string.c	2011-07-07 15:03:46.000000000 -0500
+++ linux-2.6/lib/string.c	2011-07-07 15:03:56.000000000 -0500
@@ -684,6 +684,31 @@ void *memscan(void *addr, int c, size_t
 EXPORT_SYMBOL(memscan);
 #endif

+#ifndef __HAVE_ARCH_INV_MEMSCAN
+/**
+ * memscan - Skip characters in an area of memory.
+ * @addr: The memory area
+ * @c: The byte to skip
+ * @size: The size of the area.
+ *
+ * returns the address of the first mismatch of @c, or 1 byte past
+ * the area if @c matches to the end
+ */
+void *inv_memscan(void *addr, int c, size_t size)
+{
+	unsigned char *p = addr;
+
+	while (size) {
+		if (*p != c)
+			return (void *)p;
+		p++;
+		size--;
+	}
+  	return (void *)p;
+}
+EXPORT_SYMBOL(inv_memscan);
+#endif
+
 #ifndef __HAVE_ARCH_STRSTR
 /**
  * strstr - Find the first substring in a %NUL terminated string
Index: linux-2.6/arch/x86/include/asm/string_32.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/string_32.h	2011-07-07 15:05:44.000000000 -0500
+++ linux-2.6/arch/x86/include/asm/string_32.h	2011-07-07 15:06:16.000000000 -0500
@@ -336,6 +336,8 @@ void *__constant_c_and_count_memset(void
  */
 #define __HAVE_ARCH_MEMSCAN
 extern void *memscan(void *addr, int c, size_t size);
+#define __HAVE_ARCH_INV_MEMSCAN
+extern void *inv_memscan(void *addr, int c, size_t size);

 #endif /* __KERNEL__ */

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-07-07 15:04:11.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-07-07 15:10:21.000000000 -0500
@@ -559,13 +559,12 @@ static void init_object(struct kmem_cach

 static u8 *check_bytes(u8 *start, unsigned int value, unsigned int bytes)
 {
-	while (bytes) {
-		if (*start != (u8)value)
-			return start;
-		start++;
-		bytes--;
-	}
-	return NULL;
+	u8 *p = inv_memscan(start, value, bytes);
+
+	if (p == start + bytes)
+		return NULL;
+
+	return p;
 }

 static void restore_bytes(struct kmem_cache *s, char *message, u8 data,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
