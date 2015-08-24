Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 1DF736B0258
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:16:02 -0400 (EDT)
Received: by qgj62 with SMTP id 62so95823073qgj.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:16:01 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id n83si12125055qki.56.2015.08.24.15.15.57
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:58 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 10/10] mm: make kasan.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:42 -0400
Message-ID: <1440454482-12250-11-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Andrey Konovalov <adech.fo@gmail.com>

The Makefile currently controlling compilation of this code is obj-y
meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
code there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall might make more sense here.

We don't replace module.h with init.h since the file already has that.

Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <adech.fo@gmail.com>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/kasan/kasan.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 7b28e9cdf1c7..19786018f172 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -22,7 +22,6 @@
 #include <linux/memblock.h>
 #include <linux/memory.h>
 #include <linux/mm.h>
-#include <linux/module.h>
 #include <linux/printk.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -532,6 +531,5 @@ static int __init kasan_memhotplug_init(void)
 
 	return 0;
 }
-
-module_init(kasan_memhotplug_init);
+device_initcall(kasan_memhotplug_init);
 #endif
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
