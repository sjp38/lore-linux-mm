Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 35C7B6B0258
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:16:09 -0400 (EDT)
Received: by padfo6 with SMTP id fo6so2942925pad.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:16:09 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id p3si20261854pdf.71.2015.08.24.15.16.08
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:16:08 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 08/10] mm: make vmalloc.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:40 -0400
Message-ID: <1440454482-12250-9-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Roman Pen <r.peniaev@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>, Toshi Kani <toshi.kani@hp.com>, David Rientjes <rientjes@google.com>, Rob Jones <rob.jones@codethink.co.uk>, WANG Chao <chaowang@redhat.com>

The Kconfig currently controlling compilation of this code is CONFIG_MMU
which is per arch, but in all cases it is bool or def_bool meaning that
it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
code there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall might make more sense here.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Roman Pen <r.peniaev@gmail.com>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Rob Jones <rob.jones@codethink.co.uk>
Cc: WANG Chao <chaowang@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/vmalloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 2faaa2976447..a27e6b3d58f4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -10,7 +10,7 @@
 
 #include <linux/vmalloc.h>
 #include <linux/mm.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/highmem.h>
 #include <linux/sched.h>
 #include <linux/slab.h>
@@ -2686,7 +2686,7 @@ static int __init proc_vmalloc_init(void)
 	proc_create("vmallocinfo", S_IRUSR, NULL, &proc_vmalloc_operations);
 	return 0;
 }
-module_init(proc_vmalloc_init);
+device_initcall(proc_vmalloc_init);
 
 void get_vmalloc_info(struct vmalloc_info *vmi)
 {
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
