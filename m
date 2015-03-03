Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id CC8B66B006C
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:06 -0500 (EST)
Received: by iecar1 with SMTP id ar1so60443746iec.11
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:06 -0800 (PST)
Received: from g2t2354.austin.hp.com (g2t2354.austin.hp.com. [15.217.128.53])
        by mx.google.com with ESMTPS id h130si1981581ioh.98.2015.03.03.09.45.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:06 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 1/6] mm: Change __get_vm_area_node() to use fls_long()
Date: Tue,  3 Mar 2015 10:44:19 -0700
Message-Id: <1425404664-19675-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

__get_vm_area_node() takes unsigned long size, which is a 64-bit
value on a 64-bit kernel.  However, fls(size) simply ignores the
upper 32-bit.  Change to use fls_long() to handle the size properly.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/vmalloc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 35b25e1..fe1672d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -29,6 +29,7 @@
 #include <linux/atomic.h>
 #include <linux/compiler.h>
 #include <linux/llist.h>
+#include <linux/bitops.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlbflush.h>
@@ -1314,7 +1315,8 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 
 	BUG_ON(in_interrupt());
 	if (flags & VM_IOREMAP)
-		align = 1ul << clamp(fls(size), PAGE_SHIFT, IOREMAP_MAX_ORDER);
+		align = 1ul << clamp_t(int, fls_long(size),
+				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
