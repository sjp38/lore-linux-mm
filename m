Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 944566B0254
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 18:15:48 -0400 (EDT)
Received: by pdbmi9 with SMTP id mi9so58090168pdb.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 15:15:48 -0700 (PDT)
Received: from mail1.windriver.com (mail1.windriver.com. [147.11.146.13])
        by mx.google.com with ESMTPS id fu2si29555709pbb.257.2015.08.24.15.15.47
        for <linux-mm@kvack.org>
        (version=TLSv1.1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 24 Aug 2015 15:15:47 -0700 (PDT)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 02/10] mm: make slab_common.c explicitly non-modular
Date: Mon, 24 Aug 2015 18:14:34 -0400
Message-ID: <1440454482-12250-3-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
References: <1440454482-12250-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

The Makefile currently controlling compilation of this code is obj-y
meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modularity so that when reading the
code there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.  However
one could argue that subsys_initcall() might make more sense here.

Cc: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5ce4faeb16fb..a27aff8d7cdc 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -10,7 +10,7 @@
 #include <linux/interrupt.h>
 #include <linux/memory.h>
 #include <linux/compiler.h>
-#include <linux/module.h>
+#include <linux/init.h>
 #include <linux/cpu.h>
 #include <linux/uaccess.h>
 #include <linux/seq_file.h>
@@ -1113,7 +1113,7 @@ static int __init slab_proc_init(void)
 						&proc_slabinfo_operations);
 	return 0;
 }
-module_init(slab_proc_init);
+device_initcall(slab_proc_init);
 #endif /* CONFIG_SLABINFO */
 
 static __always_inline void *__do_krealloc(const void *p, size_t new_size,
-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
