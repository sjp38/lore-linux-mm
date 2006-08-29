Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k7TKJbmC004718
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7TKJbYG260548
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7TKJbeL007153
	for <linux-mm@kvack.org>; Tue, 29 Aug 2006 16:19:37 -0400
Subject: [RFC][PATCH 02/10] conditionally define generic get_order() (ARCH_HAS_GET_ORDER)
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 29 Aug 2006 13:19:35 -0700
References: <20060829201934.47E63D1F@localhost.localdomain>
In-Reply-To: <20060829201934.47E63D1F@localhost.localdomain>
Message-Id: <20060829201935.9954D4F2@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-ia64@vger.kernel.org, rdunlap@xenotime.net, lethal@linux-sh.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch makes asm-generic/page.h safe to include in lots of code.  This
prepares it for the introduction shortly of the generic PAGE_SIZE code.

There was some discussion that ARCH_HAS_FOO is a disgusting mechanism and
should be wiped off the face of the earth.  It was argued that these things
introduce unnecessary complexity, reduce greppability, and obscure the
conditions under which FOO was defined.  I agree with *ALL* of this.  I
think this patch is different. ;)

This is very greppable.  If you grep and see foo() showing up in
asm-generic/foo.h, it is *obvious* that it is a generic version.  If you
see another version in asm-i386/foo.h, it is also obvious that i386 has
(or can) override the generic one.

As for obscuring the conditions under which it is defined, you do this when
you are either missing a symbol, or have duplicate symbols.  So, you want to
know:

1. *IS* the generic one being defined?
2. When is this generic defined (and how do I turn it off)?
3. How to I get the damn thing defined (if the symbol is missing)?

With Kconfig, this is all easy, especially for arch-specific stuff.

If you requiring that the non-generic symbol be defined first:

	http://article.gmane.org/gmane.linux.kernel/422942/match=very+complex+xyzzy+don+t+want

it gets awfully messy because you end up having to fix up all of the
architectures' headers that define the thing to get rid of any circular
dependencies.

So, is _this_ patch disgusting?

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 threadalloc-dave/include/asm-generic/page.h |    4 +++-
 threadalloc-dave/mm/Kconfig                 |    4 ++++
 2 files changed, 7 insertions(+), 1 deletion(-)

diff -puN include/asm-generic/page.h~generic-get_order include/asm-generic/page.h
--- threadalloc/include/asm-generic/page.h~generic-get_order	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/include/asm-generic/page.h	2006-08-29 13:14:50.000000000 -0700
@@ -6,6 +6,7 @@
 
 #include <linux/compiler.h>
 
+#ifndef CONFIG_ARCH_HAVE_GET_ORDER
 /* Pure 2^n version of get_order */
 static __inline__ __attribute_const__ int get_order(unsigned long size)
 {
@@ -20,7 +21,8 @@ static __inline__ __attribute_const__ in
 	return order;
 }
 
-#endif	/* __ASSEMBLY__ */
+#endif	/* CONFIG_ARCH_HAVE_GET_ORDER */
+#endif /*  __ASSEMBLY__ */
 #endif	/* __KERNEL__ */
 
 #endif	/* _ASM_GENERIC_PAGE_H */
diff -puN mm/Kconfig~generic-get_order mm/Kconfig
--- threadalloc/mm/Kconfig~generic-get_order	2006-08-29 13:14:49.000000000 -0700
+++ threadalloc-dave/mm/Kconfig	2006-08-29 13:14:50.000000000 -0700
@@ -1,3 +1,7 @@
+config ARCH_HAVE_GET_ORDER
+	def_bool y
+	depends on IA64 || PPC32 || XTENSA
+
 config SELECT_MEMORY_MODEL
 	def_bool y
 	depends on EXPERIMENTAL || ARCH_SELECT_MEMORY_MODEL
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
