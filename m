Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F199A6B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 03:23:22 -0500 (EST)
Message-Id: <4D00A03F0200007800026DEB@vpn.id2.novell.com>
Date: Thu, 09 Dec 2010 08:24:15 +0000
From: "Jan Beulich" <JBeulich@novell.com>
Subject: [PATCH] clean up and adjust kmap-types.h
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: mingo@elte.hu, tglx@linutronix.de, linux-arch@vger.kernel.org, hpa@zytor.com
List-ID: <linux-mm.kvack.org>

Several of the types aren't being used at all anymore - those can be
deleted altogether. Others are used only by single components that can
be assumed to be enabled everywhere, so those are made dependent upon
CONFIG_* settings. Since this somewhat conflicts with the sequential
gap markers used under __WITH_KM_FENCE, and since this can be
simplified anyway, fold the enumerator definitions with the (modified
accordingly) KMAP_D() macro always.

The whole point of the reduction is that, at least on ix86, the number
of kmap types can (depending on configuration) affect the amount of
low memory, and thus unused types should be avoided if possible.

Signed-off-by: Jan Beulich <jbeulich@novell.com>

---
 arch/arm/include/asm/kmap_types.h     |    6 ---
 arch/powerpc/include/asm/kmap_types.h |   11 -------
 arch/tile/include/asm/kmap_types.h    |    5 ---
 include/asm-generic/kmap_types.h      |   53 ++++++++++++++++-------------=
-----
 4 files changed, 26 insertions(+), 49 deletions(-)

--- 2.6.37-rc5/arch/arm/include/asm/kmap_types.h
+++ 2.6.37-rc5-kmap-types/arch/arm/include/asm/kmap_types.h
@@ -24,10 +24,4 @@ enum km_type {
 	KM_TYPE_NR
 };
=20
-#ifdef CONFIG_DEBUG_HIGHMEM
-#define KM_NMI		(-1)
-#define KM_NMI_PTE	(-1)
-#define KM_IRQ_PTE	(-1)
-#endif
-
 #endif
--- 2.6.37-rc5/arch/powerpc/include/asm/kmap_types.h
+++ 2.6.37-rc5-kmap-types/arch/powerpc/include/asm/kmap_types.h
@@ -30,16 +30,5 @@ enum km_type {
 	KM_TYPE_NR
 };
=20
-/*
- * This is a temporary build fix that (so they say on lkml....) should no =
longer
- * be required after 2.6.33, because of changes planned to the kmap code.
- * Let's try to remove this cruft then.
- */
-#ifdef CONFIG_DEBUG_HIGHMEM
-#define KM_NMI		(-1)
-#define KM_NMI_PTE	(-1)
-#define KM_IRQ_PTE	(-1)
-#endif
-
 #endif	/* __KERNEL__ */
 #endif	/* _ASM_POWERPC_KMAP_TYPES_H */
--- 2.6.37-rc5/arch/tile/include/asm/kmap_types.h
+++ 2.6.37-rc5-kmap-types/arch/tile/include/asm/kmap_types.h
@@ -45,12 +45,7 @@ enum {
 	KM_IRQ1,
 	KM_SOFTIRQ0,
 	KM_SOFTIRQ1,
-	KM_SYNC_ICACHE,
-	KM_SYNC_DCACHE,
 	KM_UML_USERCOPY,
-	KM_IRQ_PTE,
-	KM_NMI,
-	KM_NMI_PTE,
 	KM_KDB
 };
=20
--- 2.6.37-rc5/include/asm-generic/kmap_types.h
+++ 2.6.37-rc5-kmap-types/include/asm-generic/kmap_types.h
@@ -2,37 +2,36 @@
 #define _ASM_GENERIC_KMAP_TYPES_H
=20
 #ifdef __WITH_KM_FENCE
-# define KMAP_D(n) __KM_FENCE_##n ,
+# define KMAP_D(n) __KM_FENCE_##n, KM_##n
 #else
-# define KMAP_D(n)
+# define KMAP_D(n) KM_##n
 #endif
=20
 enum km_type {
-KMAP_D(0)	KM_BOUNCE_READ,
-KMAP_D(1)	KM_SKB_SUNRPC_DATA,
-KMAP_D(2)	KM_SKB_DATA_SOFTIRQ,
-KMAP_D(3)	KM_USER0,
-KMAP_D(4)	KM_USER1,
-KMAP_D(5)	KM_BIO_SRC_IRQ,
-KMAP_D(6)	KM_BIO_DST_IRQ,
-KMAP_D(7)	KM_PTE0,
-KMAP_D(8)	KM_PTE1,
-KMAP_D(9)	KM_IRQ0,
-KMAP_D(10)	KM_IRQ1,
-KMAP_D(11)	KM_SOFTIRQ0,
-KMAP_D(12)	KM_SOFTIRQ1,
-KMAP_D(13)	KM_SYNC_ICACHE,
-KMAP_D(14)	KM_SYNC_DCACHE,
-/* UML specific, for copy_*_user - used in do_op_one_page */
-KMAP_D(15)	KM_UML_USERCOPY,
-KMAP_D(16)	KM_IRQ_PTE,
-KMAP_D(17)	KM_NMI,
-KMAP_D(18)	KM_NMI_PTE,
-KMAP_D(19)	KM_KDB,
-/*
- * Remember to update debug_kmap_atomic() when adding new kmap types!
- */
-KMAP_D(20)	KM_TYPE_NR
+	KMAP_D(BOUNCE_READ),
+#if defined(CONFIG_SUNRPC) || defined(CONFIG_SUNRPC_MODULE)
+	KMAP_D(SKB_SUNRPC_DATA),
+#endif
+	KMAP_D(SKB_DATA_SOFTIRQ),
+	KMAP_D(USER0),
+	KMAP_D(USER1),
+	KMAP_D(BIO_SRC_IRQ),
+	KMAP_D(BIO_DST_IRQ),
+#if defined(CONFIG_X86) && defined(CONFIG_CRASH_DUMP)
+	KMAP_D(PTE0),
+#endif
+	KMAP_D(IRQ0),
+	KMAP_D(IRQ1),
+	KMAP_D(SOFTIRQ0),
+	KMAP_D(SOFTIRQ1),
+#ifdef CONFIG_UML /* for copy_*_user - used in do_op_one_page */
+	KMAP_D(UML_USERCOPY),
+#endif
+#ifdef CONFIG_KGDB_KDB
+	KMAP_D(KDB),
+#endif
+
+	KMAP_D(TYPE_NR)
 };
=20
 #undef KMAP_D



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
