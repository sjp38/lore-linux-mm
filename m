Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id C22E06B01BB
	for <linux-mm@kvack.org>; Fri, 28 May 2010 06:53:31 -0400 (EDT)
Received: from unknown (HELO localhost.localdomain) (zcncxNmDysja2tXBptWToZWJlF6Wp6IuYnI=@[200.157.204.20])
          (envelope-sender <cesarb@cesarb.net>)
          by smtp-03.mandic.com.br (qmail-ldap-1.03) with AES256-SHA encrypted SMTP
          for <linux-mm@kvack.org>; 28 May 2010 10:53:27 -0000
From: Cesar Eduardo Barros <cesarb@cesarb.net>
Subject: [PATCH] Make kunmap_atomic() harder to misuse
Date: Fri, 28 May 2010 07:53:13 -0300
Message-Id: <1275043993-26557-1-git-send-email-cesarb@cesarb.net>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, David Howells <dhowells@redhat.com>, Koichi Yasutake <yasutake.koichi@jp.panasonic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "David S. Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Arnd Bergmann <arnd@arndb.de>, Rusty Russell <rusty@rustcorp.com.au>, Cesar Eduardo Barros <cesarb@cesarb.net>
List-ID: <linux-mm.kvack.org>

kunmap_atomic() is currently at level -4 on Rusty's "Hard To Misuse"
list[1] ("Follow common convention and you'll get it wrong"), except in
some architectures when CONFIG_DEBUG_HIGHMEM is set[2][3].

kunmap() takes a pointer to a struct page; kunmap_atomic(), however,
takes takes a pointer to within the page itself. This seems to once in a
while trip people up (the convention they are following is the one from
kunmap()).

Make it much harder to misuse, by moving it to level 9 on Rusty's
list[4] ("The compiler/linker won't let you get it wrong"). This is done
by refusing to build if the pointer passed to it is convertible to a
struct page * but it is not a void * (verified by trying to convert it
to a pointer to a dummy struct).

The real kunmap_atomic() is renamed to kunmap_atomic_notypecheck()
(which is what you would call in case for some strange reason calling it
with a pointer to a struct page is not incorrect in your code).

Compile tested on x86-64.

[1] http://ozlabs.org/~rusty/index.cgi/tech/2008-04-01.html
[2] In these cases, it is at level 5, "Do it right or it will always
    break at runtime."
[3] At least mips and powerpc look very similar, and sparc also seems to
    share a common ancestor with both; there seems to be quite some
    degree of copy-and-paste coding here. The include/asm/highmem.h file
    for these three archs mention x86 CPUs at its top.
[4] http://ozlabs.org/~rusty/index.cgi/tech/2008-03-30.html
[5] As an aside, could someone tell me why mn10300 uses unsigned long as
    the first parameter of kunmap_atomic() instead of void *?

Cc: Russell King <linux@arm.linux.org.uk> (arch/arm)
Cc: Ralf Baechle <ralf@linux-mips.org> (arch/mips)
Cc: David Howells <dhowells@redhat.com> (arch/frv, arch/mn10300)
Cc: Koichi Yasutake <yasutake.koichi@jp.panasonic.com> (arch/mn10300)
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org> (arch/powerpc)
Cc: Paul Mackerras <paulus@samba.org> (arch/powerpc)
Cc: "David S. Miller" <davem@davemloft.net> (arch/sparc)
Cc: Thomas Gleixner <tglx@linutronix.de> (arch/x86)
Cc: Ingo Molnar <mingo@redhat.com> (arch/x86)
Cc: "H. Peter Anvin" <hpa@zytor.com> (arch/x86)
Cc: x86@kernel.org (arch/x86)
Cc: Arnd Bergmann <arnd@arndb.de> (include/asm-generic)
Cc: Rusty Russell <rusty@rustcorp.com.au> ("Hard To Misuse" list)
Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>
---
 arch/arm/include/asm/highmem.h     |    2 +-
 arch/arm/mm/highmem.c              |    4 ++--
 arch/frv/include/asm/highmem.h     |    2 +-
 arch/mips/include/asm/highmem.h    |    4 ++--
 arch/mips/mm/highmem.c             |    4 ++--
 arch/mn10300/include/asm/highmem.h |    2 +-
 arch/powerpc/include/asm/highmem.h |    2 +-
 arch/powerpc/mm/highmem.c          |    4 ++--
 arch/sparc/include/asm/highmem.h   |    2 +-
 arch/sparc/mm/highmem.c            |    4 ++--
 arch/x86/include/asm/highmem.h     |    2 +-
 arch/x86/mm/highmem_32.c           |    4 ++--
 include/linux/highmem.h            |   12 +++++++++++-
 13 files changed, 29 insertions(+), 19 deletions(-)

diff --git a/arch/arm/include/asm/highmem.h b/arch/arm/include/asm/highmem.h
index feb988a..5aff581 100644
--- a/arch/arm/include/asm/highmem.h
+++ b/arch/arm/include/asm/highmem.h
@@ -36,7 +36,7 @@ extern void kunmap_high_l1_vipt(struct page *page, pte_t saved_pte);
 extern void *kmap(struct page *page);
 extern void kunmap(struct page *page);
 extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic(void *kvaddr, enum km_type type);
+extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
 extern struct page *kmap_atomic_to_page(const void *ptr);
 #endif
diff --git a/arch/arm/mm/highmem.c b/arch/arm/mm/highmem.c
index 77b030f..128c2aa 100644
--- a/arch/arm/mm/highmem.c
+++ b/arch/arm/mm/highmem.c
@@ -73,7 +73,7 @@ void *kmap_atomic(struct page *page, enum km_type type)
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	unsigned int idx = type + KM_TYPE_NR * smp_processor_id();
@@ -94,7 +94,7 @@ void kunmap_atomic(void *kvaddr, enum km_type type)
 	}
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic);
+EXPORT_SYMBOL(kunmap_atomic_notypecheck);
 
 void *kmap_atomic_pfn(unsigned long pfn, enum km_type type)
 {
diff --git a/arch/frv/include/asm/highmem.h b/arch/frv/include/asm/highmem.h
index 68e4677..cb4c317 100644
--- a/arch/frv/include/asm/highmem.h
+++ b/arch/frv/include/asm/highmem.h
@@ -152,7 +152,7 @@ do {									\
 	asm volatile("tlbpr %0,gr0,#4,#1" : : "r"(vaddr) : "memory");	\
 } while(0)
 
-static inline void kunmap_atomic(void *kvaddr, enum km_type type)
+static inline void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 	switch (type) {
         case 0:		__kunmap_atomic_primary(0, 2);	break;
diff --git a/arch/mips/include/asm/highmem.h b/arch/mips/include/asm/highmem.h
index 25adfb0..75753ca 100644
--- a/arch/mips/include/asm/highmem.h
+++ b/arch/mips/include/asm/highmem.h
@@ -48,14 +48,14 @@ extern void kunmap_high(struct page *page);
 extern void *__kmap(struct page *page);
 extern void __kunmap(struct page *page);
 extern void *__kmap_atomic(struct page *page, enum km_type type);
-extern void __kunmap_atomic(void *kvaddr, enum km_type type);
+extern void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 extern void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
 extern struct page *__kmap_atomic_to_page(void *ptr);
 
 #define kmap			__kmap
 #define kunmap			__kunmap
 #define kmap_atomic		__kmap_atomic
-#define kunmap_atomic		__kunmap_atomic
+#define kunmap_atomic_notypecheck		__kunmap_atomic_notypecheck
 #define kmap_atomic_to_page	__kmap_atomic_to_page
 
 #define flush_cache_kmaps()	flush_cache_all()
diff --git a/arch/mips/mm/highmem.c b/arch/mips/mm/highmem.c
index 127d732..6a2b1bf 100644
--- a/arch/mips/mm/highmem.c
+++ b/arch/mips/mm/highmem.c
@@ -64,7 +64,7 @@ void *__kmap_atomic(struct page *page, enum km_type type)
 }
 EXPORT_SYMBOL(__kmap_atomic);
 
-void __kunmap_atomic(void *kvaddr, enum km_type type)
+void __kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 #ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
@@ -87,7 +87,7 @@ void __kunmap_atomic(void *kvaddr, enum km_type type)
 
 	pagefault_enable();
 }
-EXPORT_SYMBOL(__kunmap_atomic);
+EXPORT_SYMBOL(__kunmap_atomic_notypecheck);
 
 /*
  * This is the same as kmap_atomic() but can map memory that doesn't
diff --git a/arch/mn10300/include/asm/highmem.h b/arch/mn10300/include/asm/highmem.h
index 90f2abb..b0b187a 100644
--- a/arch/mn10300/include/asm/highmem.h
+++ b/arch/mn10300/include/asm/highmem.h
@@ -91,7 +91,7 @@ static inline unsigned long kmap_atomic(struct page *page, enum km_type type)
 	return vaddr;
 }
 
-static inline void kunmap_atomic(unsigned long vaddr, enum km_type type)
+static inline void kunmap_atomic_notypecheck(unsigned long vaddr, enum km_type type)
 {
 #if HIGHMEM_DEBUG
 	enum fixed_addresses idx = type + KM_TYPE_NR * smp_processor_id();
diff --git a/arch/powerpc/include/asm/highmem.h b/arch/powerpc/include/asm/highmem.h
index a74c4ee..d10d64a 100644
--- a/arch/powerpc/include/asm/highmem.h
+++ b/arch/powerpc/include/asm/highmem.h
@@ -62,7 +62,7 @@ extern void *kmap_high(struct page *page);
 extern void kunmap_high(struct page *page);
 extern void *kmap_atomic_prot(struct page *page, enum km_type type,
 			      pgprot_t prot);
-extern void kunmap_atomic(void *kvaddr, enum km_type type);
+extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 
 static inline void *kmap(struct page *page)
 {
diff --git a/arch/powerpc/mm/highmem.c b/arch/powerpc/mm/highmem.c
index c2186c7..857d417 100644
--- a/arch/powerpc/mm/highmem.c
+++ b/arch/powerpc/mm/highmem.c
@@ -52,7 +52,7 @@ void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot)
 }
 EXPORT_SYMBOL(kmap_atomic_prot);
 
-void kunmap_atomic(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 #ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
@@ -74,4 +74,4 @@ void kunmap_atomic(void *kvaddr, enum km_type type)
 #endif
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic);
+EXPORT_SYMBOL(kunmap_atomic_notypecheck);
diff --git a/arch/sparc/include/asm/highmem.h b/arch/sparc/include/asm/highmem.h
index 3de42e7..ec23b0a 100644
--- a/arch/sparc/include/asm/highmem.h
+++ b/arch/sparc/include/asm/highmem.h
@@ -71,7 +71,7 @@ static inline void kunmap(struct page *page)
 }
 
 extern void *kmap_atomic(struct page *page, enum km_type type);
-extern void kunmap_atomic(void *kvaddr, enum km_type type);
+extern void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 extern struct page *kmap_atomic_to_page(void *vaddr);
 
 #define flush_cache_kmaps()	flush_cache_all()
diff --git a/arch/sparc/mm/highmem.c b/arch/sparc/mm/highmem.c
index 7916feb..e139e9c 100644
--- a/arch/sparc/mm/highmem.c
+++ b/arch/sparc/mm/highmem.c
@@ -65,7 +65,7 @@ void *kmap_atomic(struct page *page, enum km_type type)
 }
 EXPORT_SYMBOL(kmap_atomic);
 
-void kunmap_atomic(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 #ifdef CONFIG_DEBUG_HIGHMEM
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
@@ -100,7 +100,7 @@ void kunmap_atomic(void *kvaddr, enum km_type type)
 
 	pagefault_enable();
 }
-EXPORT_SYMBOL(kunmap_atomic);
+EXPORT_SYMBOL(kunmap_atomic_notypecheck);
 
 /* We may be fed a pagetable here by ptep_to_xxx and others. */
 struct page *kmap_atomic_to_page(void *ptr)
diff --git a/arch/x86/include/asm/highmem.h b/arch/x86/include/asm/highmem.h
index a726650..8caac76 100644
--- a/arch/x86/include/asm/highmem.h
+++ b/arch/x86/include/asm/highmem.h
@@ -61,7 +61,7 @@ void *kmap(struct page *page);
 void kunmap(struct page *page);
 void *kmap_atomic_prot(struct page *page, enum km_type type, pgprot_t prot);
 void *kmap_atomic(struct page *page, enum km_type type);
-void kunmap_atomic(void *kvaddr, enum km_type type);
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type);
 void *kmap_atomic_pfn(unsigned long pfn, enum km_type type);
 void *kmap_atomic_prot_pfn(unsigned long pfn, enum km_type type, pgprot_t prot);
 struct page *kmap_atomic_to_page(void *ptr);
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 63a6ba6..5e8fa12 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -53,7 +53,7 @@ void *kmap_atomic(struct page *page, enum km_type type)
 	return kmap_atomic_prot(page, type, kmap_prot);
 }
 
-void kunmap_atomic(void *kvaddr, enum km_type type)
+void kunmap_atomic_notypecheck(void *kvaddr, enum km_type type)
 {
 	unsigned long vaddr = (unsigned long) kvaddr & PAGE_MASK;
 	enum fixed_addresses idx = type + KM_TYPE_NR*smp_processor_id();
@@ -102,7 +102,7 @@ struct page *kmap_atomic_to_page(void *ptr)
 EXPORT_SYMBOL(kmap);
 EXPORT_SYMBOL(kunmap);
 EXPORT_SYMBOL(kmap_atomic);
-EXPORT_SYMBOL(kunmap_atomic);
+EXPORT_SYMBOL(kunmap_atomic_notypecheck);
 EXPORT_SYMBOL(kmap_atomic_prot);
 EXPORT_SYMBOL(kmap_atomic_to_page);
 
diff --git a/include/linux/highmem.h b/include/linux/highmem.h
index caafd05..9dc728c 100644
--- a/include/linux/highmem.h
+++ b/include/linux/highmem.h
@@ -2,6 +2,7 @@
 #define _LINUX_HIGHMEM_H
 
 #include <linux/fs.h>
+#include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/uaccess.h>
 
@@ -72,7 +73,7 @@ static inline void *kmap_atomic(struct page *page, enum km_type idx)
 }
 #define kmap_atomic_prot(page, idx, prot)	kmap_atomic(page, idx)
 
-#define kunmap_atomic(addr, idx)	do { pagefault_enable(); } while (0)
+#define kunmap_atomic_notypecheck(addr, idx)	do { pagefault_enable(); } while (0)
 #define kmap_atomic_pfn(pfn, idx)	kmap_atomic(pfn_to_page(pfn), (idx))
 #define kmap_atomic_to_page(ptr)	virt_to_page(ptr)
 
@@ -81,6 +82,15 @@ static inline void *kmap_atomic(struct page *page, enum km_type idx)
 
 #endif /* CONFIG_HIGHMEM */
 
+/* Prevent people trying to call kunmap_atomic() as if it were kunmap() */
+struct __kunmap_atomic_dummy {};
+#define kunmap_atomic(addr, idx) do { \
+		BUILD_BUG_ON( \
+			__builtin_types_compatible_p(typeof(addr), struct page *) && \
+			!__builtin_types_compatible_p(typeof(addr), struct __kunmap_atomic_dummy *)); \
+		kunmap_atomic_notypecheck((addr), (idx)); \
+	} while (0)
+
 /* when CONFIG_HIGHMEM is not set these will be plain clear/copy_page */
 #ifndef clear_user_highpage
 static inline void clear_user_highpage(struct page *page, unsigned long vaddr)
-- 
1.6.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
