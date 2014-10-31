Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B74DB280022
	for <linux-mm@kvack.org>; Fri, 31 Oct 2014 01:40:30 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id eu11so7067217pac.9
        for <linux-mm@kvack.org>; Thu, 30 Oct 2014 22:40:30 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id fn9si8367892pdb.160.2014.10.30.22.40.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 30 Oct 2014 22:40:29 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Fri, 31 Oct 2014 13:40:20 +0800
Subject: [RFC V6 1/3] add CONFIG_HAVE_ARCH_BITREVERSE to support rbit
 instruction
Message-ID: <35FD53F367049845BC99AC72306C23D103E010D18272@CNBJMBX05.corpusers.net>
References: <1414392371.8884.2.camel@perches.com>
 <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
 <35FD53F367049845BC99AC72306C23D103E010D1825F@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18260@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18261@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18264@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18265@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18266@CNBJMBX05.corpusers.net>
 <20141030120127.GC32589@arm.com>
 <CAKv+Gu9g5Q6fjPUy+P8YxkeDrH+bdO4kKGnxTQZRFhQpgPxaPA@mail.gmail.com>
 <20141030135749.GE32589@arm.com>
In-Reply-To: <20141030135749.GE32589@arm.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Will Deacon' <will.deacon@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joe Perches <joe@perches.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
so that we can use some architecture's bitrev hardware instruction
to do bitrev operation.

Introduce __constant_bitrev* macro for constant bitrev operation.

Change __bitrev16() __bitrev32() to be inline function,
don't need export symbol for these tiny functions.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 include/linux/bitrev.h | 77 ++++++++++++++++++++++++++++++++++++++++++++++=
+---
 lib/Kconfig            |  9 ++++++
 lib/bitrev.c           | 17 ++---------
 3 files changed, 84 insertions(+), 19 deletions(-)

diff --git a/include/linux/bitrev.h b/include/linux/bitrev.h
index 7ffe03f..fb790b8 100644
--- a/include/linux/bitrev.h
+++ b/include/linux/bitrev.h
@@ -3,14 +3,83 @@
=20
 #include <linux/types.h>
=20
-extern u8 const byte_rev_table[256];
+#ifdef CONFIG_HAVE_ARCH_BITREVERSE
+#include <asm/bitrev.h>
+
+#define __bitrev32 __arch_bitrev32
+#define __bitrev16 __arch_bitrev16
+#define __bitrev8 __arch_bitrev8
=20
-static inline u8 bitrev8(u8 byte)
+#else
+extern u8 const byte_rev_table[256];
+static inline u8 __bitrev8(u8 byte)
 {
 	return byte_rev_table[byte];
 }
=20
-extern u16 bitrev16(u16 in);
-extern u32 bitrev32(u32 in);
+static inline u16 __bitrev16(u16 x)
+{
+	return (__bitrev8(x & 0xff) << 8) | __bitrev8(x >> 8);
+}
+
+static inline u32 __bitrev32(u32 x)
+{
+	return (__bitrev16(x & 0xffff) << 16) | __bitrev16(x >> 16);
+}
+
+#endif /* CONFIG_HAVE_ARCH_BITREVERSE */
+
+#define __constant_bitrev32(x)	\
+({					\
+	u32 __x =3D x;			\
+	__x =3D (__x >> 16) | (__x << 16);	\
+	__x =3D ((__x & (u32)0xFF00FF00UL) >> 8) | ((__x & (u32)0x00FF00FFUL) << =
8);	\
+	__x =3D ((__x & (u32)0xF0F0F0F0UL) >> 4) | ((__x & (u32)0x0F0F0F0FUL) << =
4);	\
+	__x =3D ((__x & (u32)0xCCCCCCCCUL) >> 2) | ((__x & (u32)0x33333333UL) << =
2);	\
+	__x =3D ((__x & (u32)0xAAAAAAAAUL) >> 1) | ((__x & (u32)0x55555555UL) << =
1);	\
+	__x;								\
+})
+
+#define __constant_bitrev16(x)	\
+({					\
+	u16 __x =3D x;			\
+	__x =3D (__x >> 8) | (__x << 8);	\
+	__x =3D ((__x & (u16)0xF0F0U) >> 4) | ((__x & (u16)0x0F0FU) << 4);	\
+	__x =3D ((__x & (u16)0xCCCCU) >> 2) | ((__x & (u16)0x3333U) << 2);	\
+	__x =3D ((__x & (u16)0xAAAAU) >> 1) | ((__x & (u16)0x5555U) << 1);	\
+	__x;								\
+})
+
+#define __constant_bitrev8(x)	\
+({					\
+	u8 __x =3D x;			\
+	__x =3D (__x >> 4) | (__x << 4);	\
+	__x =3D ((__x & (u8)0xCCU) >> 2) | ((__x & (u8)0x33U) << 2);	\
+	__x =3D ((__x & (u8)0xAAU) >> 1) | ((__x & (u8)0x55U) << 1);	\
+	__x;								\
+})
+
+#define bitrev32(x) \
+({			\
+	u32 __x =3D x;	\
+	__builtin_constant_p(__x) ?	\
+	__constant_bitrev32(__x) :			\
+	__bitrev32(__x);				\
+})
+
+#define bitrev16(x) \
+({			\
+	u16 __x =3D x;	\
+	__builtin_constant_p(__x) ?	\
+	__constant_bitrev16(__x) :			\
+	__bitrev16(__x);				\
+ })
=20
+#define bitrev8(x) \
+({			\
+	u8 __x =3D x;	\
+	__builtin_constant_p(__x) ?	\
+	__constant_bitrev8(__x) :			\
+	__bitrev8(__x)	;			\
+ })
 #endif /* _LINUX_BITREV_H */
diff --git a/lib/Kconfig b/lib/Kconfig
index 54cf309..cd177ca 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -13,6 +13,15 @@ config RAID6_PQ
 config BITREVERSE
 	tristate
=20
+config HAVE_ARCH_BITREVERSE
+	boolean
+	default n
+	depends on BITREVERSE
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
index 3956203..40ffda9 100644
--- a/lib/bitrev.c
+++ b/lib/bitrev.c
@@ -1,3 +1,4 @@
+#ifndef CONFIG_HAVE_ARCH_BITREVERSE
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/bitrev.h>
@@ -42,18 +43,4 @@ const u8 byte_rev_table[256] =3D {
 };
 EXPORT_SYMBOL_GPL(byte_rev_table);
=20
-u16 bitrev16(u16 x)
-{
-	return (bitrev8(x & 0xff) << 8) | bitrev8(x >> 8);
-}
-EXPORT_SYMBOL(bitrev16);
-
-/**
- * bitrev32 - reverse the order of bits in a u32 value
- * @x: value to be bit-reversed
- */
-u32 bitrev32(u32 x)
-{
-	return (bitrev16(x & 0xffff) << 16) | bitrev16(x >> 16);
-}
-EXPORT_SYMBOL(bitrev32);
+#endif /* CONFIG_HAVE_ARCH_BITREVERSE */
--=20
2.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
