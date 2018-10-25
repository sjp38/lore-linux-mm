Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id F3AF46B02B3
	for <linux-mm@kvack.org>; Thu, 25 Oct 2018 14:34:51 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id v10-v6so6331637pgs.15
        for <linux-mm@kvack.org>; Thu, 25 Oct 2018 11:34:51 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id w11-v6si9112637pgf.587.2018.10.25.11.34.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Oct 2018 11:34:50 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCH] mm/page_owner: use vmalloc instead of kmalloc
Date: Fri, 26 Oct 2018 02:34:41 +0800
Message-ID: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Brugger <matthias.bgg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

The kbuf used by page owner is allocated by kmalloc(),
which means it can use only normal memory and there might
be a "out of memory" issue when we're out of normal memory.

Use vmalloc() so we can also allocate kbuf from highmem
on 32bit kernel.

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
---
 mm/page_owner.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index d80adfe702d3..7e6962adaa79 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -1,7 +1,6 @@
 // SPDX-License-Identifier: GPL-2.0
 #include <linux/debugfs.h>
 #include <linux/mm.h>
-#include <linux/slab.h>
 #include <linux/uaccess.h>
 #include <linux/bootmem.h>
 #include <linux/stacktrace.h>
@@ -10,6 +9,7 @@
 #include <linux/migrate.h>
 #include <linux/stackdepot.h>
 #include <linux/seq_file.h>
+#include <linux/vmalloc.h>
 
 #include "internal.h"
 
@@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 		.skip = 0
 	};
 
-	kbuf = kmalloc(count, GFP_KERNEL);
+	kbuf = vmalloc(count);
 	if (!kbuf)
 		return -ENOMEM;
 
@@ -397,11 +397,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
 	if (copy_to_user(buf, kbuf, ret))
 		ret = -EFAULT;
 
-	kfree(kbuf);
+	vfree(kbuf);
 	return ret;
 
 err:
-	kfree(kbuf);
+	vfree(kbuf);
 	return -ENOMEM;
 }
 
-- 
2.18.0
