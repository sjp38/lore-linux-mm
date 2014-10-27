Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 289CB900014
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 12:47:43 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so5775179pab.6
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 09:47:42 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ye5si10874838pbc.141.2014.10.27.09.47.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 27 Oct 2014 09:47:40 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NE400JJZ446JVA0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Oct 2014 16:50:30 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v5 02/12] kasan: Add support for upcoming GCC 5.0 asan ABI
 changes
Date: Mon, 27 Oct 2014 19:46:49 +0300
Message-id: <1414428419-17860-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1414428419-17860-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, Vegard Nossum <vegard.nossum@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Dave Jones <davej@redhat.com>, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

GCC 5.0 will have some changes in asan ABI.
New function (__asan_load*_noabort()/__asan_store*_noabort)
will be introduced.
By default, for -fsanitize=kernel-address GCC 5.0 will
generate __asan_load*_noabort() functions instead of __asan_load*()

Details in this thread: https://gcc.gnu.org/ml/gcc-patches/2014-10/msg02510.html

We still need __asan_load*() for GCC 4.9.2, so this patch just adds aliases.

Note: Patch for GCC hasn't been upstreamed yet.
I'm adding this patch in advance, to avoid breaking KASan
in future GCC update.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/kasan/kasan.c | 38 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 8ce738e..11fa3f8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -334,3 +334,41 @@ EXPORT_SYMBOL(__asan_storeN);
 /* to shut up compiler complaints */
 void __asan_handle_no_return(void) {}
 EXPORT_SYMBOL(__asan_handle_no_return);
+
+
+/* GCC 5.0 has different function names by default */
+void __asan_load1_noabort(unsigned long) __attribute__((alias("__asan_load1")));
+EXPORT_SYMBOL(__asan_load1_noabort);
+
+void __asan_load2_noabort(unsigned long) __attribute__((alias("__asan_load2")));
+EXPORT_SYMBOL(__asan_load2_noabort);
+
+void __asan_load4_noabort(unsigned long) __attribute__((alias("__asan_load4")));
+EXPORT_SYMBOL(__asan_load4_noabort);
+
+void __asan_load8_noabort(unsigned long) __attribute__((alias("__asan_load8")));
+EXPORT_SYMBOL(__asan_load8_noabort);
+
+void __asan_load16_noabort(unsigned long) __attribute__((alias("__asan_load16")));
+EXPORT_SYMBOL(__asan_load16_noabort);
+
+void __asan_loadN_noabort(unsigned long) __attribute__((alias("__asan_loadN")));
+EXPORT_SYMBOL(__asan_loadN_noabort);
+
+void __asan_store1_noabort(unsigned long) __attribute__((alias("__asan_store1")));
+EXPORT_SYMBOL(__asan_store1_noabort);
+
+void __asan_store2_noabort(unsigned long) __attribute__((alias("__asan_store2")));
+EXPORT_SYMBOL(__asan_store2_noabort);
+
+void __asan_store4_noabort(unsigned long) __attribute__((alias("__asan_store4")));
+EXPORT_SYMBOL(__asan_store4_noabort);
+
+void __asan_store8_noabort(unsigned long) __attribute__((alias("__asan_store8")));
+EXPORT_SYMBOL(__asan_store8_noabort);
+
+void __asan_store16_noabort(unsigned long) __attribute__((alias("__asan_store16")));
+EXPORT_SYMBOL(__asan_store16_noabort);
+
+void __asan_storeN_noabort(unsigned long) __attribute__((alias("__asan_storeN")));
+EXPORT_SYMBOL(__asan_storeN_noabort);
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
