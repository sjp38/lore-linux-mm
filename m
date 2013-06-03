Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C3F2D6B0038
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:39:40 -0400 (EDT)
Received: by mail-pb0-f50.google.com with SMTP id wy17so5859147pbc.9
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 08:39:40 -0700 (PDT)
Message-ID: <51ACB8B6.60603@gmail.com>
Date: Mon, 03 Jun 2013 23:39:34 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm, vmalloc: Use clamp to simplify code
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/vmalloc.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index d365724..2d7eb81 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1337,16 +1337,8 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 	struct vm_struct *area;
 
 	BUG_ON(in_interrupt());
-	if (flags & VM_IOREMAP) {
-		int bit = fls(size);
-
-		if (bit > IOREMAP_MAX_ORDER)
-			bit = IOREMAP_MAX_ORDER;
-		else if (bit < PAGE_SHIFT)
-			bit = PAGE_SHIFT;
-
-		align = 1ul << bit;
-	}
+	if (flags & VM_IOREMAP)
+		align = 1ul << clamp(fls(size), PAGE_SHIFT, IOREMAP_MAX_ORDER);
 
 	size = PAGE_ALIGN(size);
 	if (unlikely(!size))
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
