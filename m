Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2ED6B0355
	for <linux-mm@kvack.org>; Sun, 28 Oct 2018 22:17:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id l15-v6so1624089pff.5
        for <linux-mm@kvack.org>; Sun, 28 Oct 2018 19:17:02 -0700 (PDT)
Received: from mailgw02.mediatek.com ([210.61.82.184])
        by mx.google.com with ESMTPS id k9-v6si18462628pgc.79.2018.10.28.19.17.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Oct 2018 19:17:00 -0700 (PDT)
From: <miles.chen@mediatek.com>
Subject: [PATCHv2] mm/page_owner: use kvmalloc instead of kmalloc
Date: Mon, 29 Oct 2018 10:16:43 +0800
Message-ID: <1540779403-27622-1-git-send-email-miles.chen@mediatek.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthias Brugger <matthias.bgg@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org, Joe Perches <joe@perches.com>, Michal Hocko <mhocko@kernel.org>, Matthew Wilcox <willy@infradead.org>, Miles Chen <miles.chen@mediatek.com>

From: Miles Chen <miles.chen@mediatek.com>

The kbuf used by page owner is allocated by kmalloc(), which means it
can use only normal memory and there might be a "out of memory"
issue when we're out of normal memory.

Use kvmalloc() so we can also allocate kbuf from
normal/hihghmem on 32bit kernel.

Clamp the kbuf size to PAGE_SIZE.

Change since v1:
  - use kvmalloc()
  - clamp buffer size to PAGE_SIZE

Signed-off-by: Miles Chen <miles.chen@mediatek.com>
Cc: Joe Perches <joe@perches.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@kernel.org>
---
 mm/page_owner.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index d80adfe..a064cd0 100644
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
@@ -351,7 +350,8 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 		.skip = 0
 	};
 
-	kbuf = kmalloc(count, GFP_KERNEL);
+	count = count > PAGE_SIZE ? PAGE_SIZE : count;
+	kbuf = kvmalloc(count, GFP_KERNEL);
 	if (!kbuf)
 		return -ENOMEM;
 
@@ -397,11 +397,11 @@ void pagetypeinfo_showmixedcount_print(struct seq_file *m,
 	if (copy_to_user(buf, kbuf, ret))
 		ret = -EFAULT;
 
-	kfree(kbuf);
+	kvfree(kbuf);
 	return ret;
 
 err:
-	kfree(kbuf);
+	kvfree(kbuf);
 	return -ENOMEM;
 }
 
-- 
1.9.1
