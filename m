Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id E24456B0038
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:45:55 -0500 (EST)
Received: by mail-ob0-f177.google.com with SMTP id wp18so27653720obc.8
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:45:55 -0800 (PST)
Received: from g4t3426.houston.hp.com (g4t3426.houston.hp.com. [15.201.208.54])
        by mx.google.com with ESMTPS id l9si6609006oia.66.2015.02.09.14.45.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:45:55 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 1/7] mm: Change __get_vm_area_node() to use fls_long()
Date: Mon,  9 Feb 2015 15:45:29 -0700
Message-Id: <1423521935-17454-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

__get_vm_area_node() takes unsigned long size, which is a 64-bit
value on a 64-bit kernel.  However, fls(size) simply ignores the
upper 32-bit.  Change to use fls_long() to handle the size properly.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 mm/vmalloc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 39c3388..40ea214 100644
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
