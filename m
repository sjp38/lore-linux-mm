Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 20C066B0037
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:27 -0400 (EDT)
Received: by mail-pd0-f175.google.com with SMTP id v10so8898172pde.34
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:26 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id au10si45876068pbd.14.2014.07.09.04.36.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:25 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G0083K08NL860@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:23 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 02/21] init: main: initialize kasan's shadow
 area on boot
Date: Wed, 09 Jul 2014 15:29:56 +0400
Message-id: <1404905415-9046-3-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

This patch initializes shadow area after it was allocated by arch code.
All low memory marked as accessible except shadow area itself.
Later free_all_bootmem() will release pages to buddy allocator
and these pages will be marked as unaccessible, untill somebody
will allocate them.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 init/main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/init/main.c b/init/main.c
index bb1aed9..d06a636 100644
--- a/init/main.c
+++ b/init/main.c
@@ -78,6 +78,7 @@
 #include <linux/context_tracking.h>
 #include <linux/random.h>
 #include <linux/list.h>
+#include <linux/kasan.h>
 
 #include <asm/io.h>
 #include <asm/bugs.h>
@@ -549,7 +550,7 @@ asmlinkage __visible void __init start_kernel(void)
 			   set_init_arg);
 
 	jump_label_init();
-
+	kasan_init_shadow();
 	/*
 	 * These use large bootmem allocations and must precede
 	 * kmem_cache_init()
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
