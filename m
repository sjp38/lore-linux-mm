Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Wed, 9 Jan 2019 23:18:38 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] mm: shuffle GFP_* flags
Message-ID: <20190109201838.GA9140@avx2>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

GFP_KERNEL is one of the most used constant but on archs like arm
with fixed length instruction some constants are more equal than
the others. Constants with tightly packed bits can be injected directly
into instruction stream:

	   0:   e3a00d33        mov     r0, #3264       ; 0xcc0

Others require multiple instructions or even loading out of instruction
stream:

	   0:   e3a000c0        mov     r0, #192        ; 0xc0
	   4:   e3400060        movt    r0, #96		; 0x60

Shuffle GFP_* flags so that GFP_KERNEL/GFP_ATOMIC + __GFP_ZERO bits are
close to each other.

Savings on arm configs are ~0.1%.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/gfp.h |   30 +++++++++++++++---------------
 1 file changed, 15 insertions(+), 15 deletions(-)

--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -24,21 +24,21 @@ struct vm_area_struct;
 #define ___GFP_HIGH		0x20u
 #define ___GFP_IO		0x40u
 #define ___GFP_FS		0x80u
-#define ___GFP_WRITE		0x100u
-#define ___GFP_NOWARN		0x200u
-#define ___GFP_RETRY_MAYFAIL	0x400u
-#define ___GFP_NOFAIL		0x800u
-#define ___GFP_NORETRY		0x1000u
-#define ___GFP_MEMALLOC		0x2000u
-#define ___GFP_COMP		0x4000u
-#define ___GFP_ZERO		0x8000u
-#define ___GFP_NOMEMALLOC	0x10000u
-#define ___GFP_HARDWALL		0x20000u
-#define ___GFP_THISNODE		0x40000u
-#define ___GFP_ATOMIC		0x80000u
-#define ___GFP_ACCOUNT		0x100000u
-#define ___GFP_DIRECT_RECLAIM	0x200000u
-#define ___GFP_KSWAPD_RECLAIM	0x400000u
+#define ___GFP_ZERO		0x100u
+#define ___GFP_ATOMIC		0x200u
+#define ___GFP_DIRECT_RECLAIM	0x400u
+#define ___GFP_KSWAPD_RECLAIM	0x800u
+#define ___GFP_WRITE		0x1000u
+#define ___GFP_NOWARN		0x2000u
+#define ___GFP_RETRY_MAYFAIL	0x4000u
+#define ___GFP_NOFAIL		0x8000u
+#define ___GFP_NORETRY		0x10000u
+#define ___GFP_MEMALLOC		0x20000u
+#define ___GFP_COMP		0x40000u
+#define ___GFP_NOMEMALLOC	0x80000u
+#define ___GFP_HARDWALL		0x100000u
+#define ___GFP_THISNODE		0x200000u
+#define ___GFP_ACCOUNT		0x400000u
 #ifdef CONFIG_LOCKDEP
 #define ___GFP_NOLOCKDEP	0x800000u
 #else
