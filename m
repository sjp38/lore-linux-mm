Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id C95D282BDA
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:10:42 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id ey11so471031pad.7
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 22:10:42 -0700 (PDT)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id z3si3282750pas.143.2014.10.23.22.10.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Oct 2014 22:10:41 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 24 Oct 2014 13:10:33 +0800
Subject: [PATCH RFC] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, 'Will Deacon' <Will.Deacon@arm.com>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>, "'akinobu.mita@gmail.com'" <akinobu.mita@gmail.com>

this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
so that we can use arm/arm64 rbit instruction to do bitrev operation
by hardware.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 arch/arm/Kconfig                |  1 +
 arch/arm/include/asm/bitrev.h   | 21 +++++++++++++++++++++
 arch/arm64/Kconfig              |  1 +
 arch/arm64/include/asm/bitrev.h | 21 +++++++++++++++++++++
 include/linux/bitrev.h          |  9 +++++++++
 lib/Kconfig                     |  8 ++++++++
 lib/bitrev.c                    |  2 ++
 7 files changed, 63 insertions(+)
 create mode 100644 arch/arm/include/asm/bitrev.h
 create mode 100644 arch/arm64/include/asm/bitrev.h

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 89c4b5c..426cbcc 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -16,6 +16,7 @@ config ARM
 	select DCACHE_WORD_ACCESS if HAVE_EFFICIENT_UNALIGNED_ACCESS
 	select GENERIC_ALLOCATOR
 	select GENERIC_ATOMIC64 if (CPU_V7M || CPU_V6 || !CPU_32v6K || !AEABI)
+	select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
 	select GENERIC_CLOCKEVENTS_BROADCAST if SMP
 	select GENERIC_IDLE_POLL_SETUP
 	select GENERIC_IRQ_PROBE
diff --git a/arch/arm/include/asm/bitrev.h b/arch/arm/include/asm/bitrev.h
new file mode 100644
index 0000000..0df5866
--- /dev/null
+++ b/arch/arm/include/asm/bitrev.h
@@ -0,0 +1,21 @@
+#ifndef __ASM_ARM_BITREV_H
+#define __ASM_ARM_BITREV_H
+
+static inline __attribute_const__ u32 __arch_bitrev32(u32 x)
+{
+	__asm__ ("rbit %0, %1" : "=3Dr" (x) : "r" (x));
+	return x;
+}
+
+static inline __attribute_const__ u16 __arch_bitrev16(u16 x)
+{
+	return __arch_bitrev32((u32)x) >> 16;
+}
+
+static inline __attribute_const__ u8 __arch_bitrev8(u8 x)
+{
+	return __arch_bitrev32((u32)x) >> 24;
+}
+
+#endif
+
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index ac9afde..a2566d7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -35,6 +35,7 @@ config ARM64
 	select HARDIRQS_SW_RESEND
 	select HAVE_ARCH_AUDITSYSCALL
 	select HAVE_ARCH_JUMP_LABEL
+	select HAVE_ARCH_BITREVERSE
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_BPF_JIT
diff --git a/arch/arm64/include/asm/bitrev.h b/arch/arm64/include/asm/bitre=
v.h
new file mode 100644
index 0000000..5d24c11
--- /dev/null
+++ b/arch/arm64/include/asm/bitrev.h
@@ -0,0 +1,21 @@
+#ifndef __ASM_ARM_BITREV_H
+#define __ASM_ARM_BITREV_H
+
+static inline __attribute_const__ u32 __arch_bitrev32(u32 x)
+{
+	__asm__ ("rbit %w0, %w1" : "=3Dr" (x) : "r" (x));
+	return x;
+}
+
+static inline __attribute_const__ u16 __arch_bitrev16(u16 x)
+{
+	return __arch_bitrev32((u32)x) >> 16;
+}
+
+static inline __attribute_const__ u8 __arch_bitrev8(u8 x)
+{
+	return __arch_bitrev32((u32)x) >> 24;
+}
+
+#endif
+
diff --git a/include/linux/bitrev.h b/include/linux/bitrev.h
index 7ffe03f..ef5b2bb 100644
--- a/include/linux/bitrev.h
+++ b/include/linux/bitrev.h
@@ -3,6 +3,14 @@
=20
 #include <linux/types.h>
=20
+#ifdef CONFIG_HAVE_ARCH_BITREVERSE
+#include <asm/bitrev.h>
+
+#define bitrev32 __arch_bitrev32
+#define bitrev16 __arch_bitrev16
+#define bitrev8 __arch_bitrev8
+
+#else
 extern u8 const byte_rev_table[256];
=20
 static inline u8 bitrev8(u8 byte)
@@ -13,4 +21,5 @@ static inline u8 bitrev8(u8 byte)
 extern u16 bitrev16(u16 in);
 extern u32 bitrev32(u32 in);
=20
+#endif /* CONFIG_HAVE_ARCH_BITREVERSE */
 #endif /* _LINUX_BITREV_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 54cf309..e0e0453 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -13,6 +13,14 @@ config RAID6_PQ
 config BITREVERSE
 	tristate
=20
+config HAVE_ARCH_BITREVERSE
+	boolean
+	default n
+	help
+	  This option provides an config for the architecture which have instruct=
ion
+	  can do bitreverse operation, we use the hardware instruction if the arc=
hitecture
+	  have this capability.
+
 config RATIONAL
 	boolean
=20
diff --git a/lib/bitrev.c b/lib/bitrev.c
index 3956203..93d637a 100644
--- a/lib/bitrev.c
+++ b/lib/bitrev.c
@@ -1,3 +1,4 @@
+#ifndef CONFIG_HAVE_ARCH_BITREVERSE
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/bitrev.h>
@@ -57,3 +58,4 @@ u32 bitrev32(u32 x)
 	return (bitrev16(x & 0xffff) << 16) | bitrev16(x >> 16);
 }
 EXPORT_SYMBOL(bitrev32);
+#endif /* CONFIG_HAVE_ARCH_BITREVERSE */
--=20
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
