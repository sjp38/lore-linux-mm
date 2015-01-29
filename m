Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 32E18900019
	for <linux-mm@kvack.org>; Thu, 29 Jan 2015 10:13:01 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id ey11so40158631pad.7
        for <linux-mm@kvack.org>; Thu, 29 Jan 2015 07:13:00 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id hn2si10282623pdb.76.2015.01.29.07.12.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 29 Jan 2015 07:12:50 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NIY00K1U2G16M10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 29 Jan 2015 15:16:49 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v10 15/17] kernel: add support for .init_array.* constructors
Date: Thu, 29 Jan 2015 18:11:59 +0300
Message-id: <1422544321-24232-16-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
 <1422544321-24232-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org, Arnd Bergmann <arnd@arndb.de>, "open list:GENERIC INCLUDE/A..." <linux-arch@vger.kernel.org>

KASan uses constructors for initializing redzones for global
variables. Actually KASan doesn't need priorities for constructors,
so they were removed from GCC 5.0, but GCC 4.9.2 still generates
constructors with priorities.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/asm-generic/vmlinux.lds.h | 1 +
 scripts/module-common.lds         | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index bee5d68..ac78910 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -478,6 +478,7 @@
 #define KERNEL_CTORS()	. = ALIGN(8);			   \
 			VMLINUX_SYMBOL(__ctors_start) = .; \
 			*(.ctors)			   \
+			*(SORT(.init_array.*))		   \
 			*(.init_array)			   \
 			VMLINUX_SYMBOL(__ctors_end) = .;
 #else
diff --git a/scripts/module-common.lds b/scripts/module-common.lds
index 0865b3e..01c5849 100644
--- a/scripts/module-common.lds
+++ b/scripts/module-common.lds
@@ -16,4 +16,7 @@ SECTIONS {
 	__kcrctab_unused	: { *(SORT(___kcrctab_unused+*)) }
 	__kcrctab_unused_gpl	: { *(SORT(___kcrctab_unused_gpl+*)) }
 	__kcrctab_gpl_future	: { *(SORT(___kcrctab_gpl_future+*)) }
+
+	. = ALIGN(8);
+	.init_array		: { *(SORT(.init_array.*)) *(.init_array) }
 }
-- 
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
