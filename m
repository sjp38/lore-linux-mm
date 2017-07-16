Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 64C286B049F
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 03:28:35 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id u5so139350699pgq.14
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:28:35 -0700 (PDT)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id m15si10536420pgr.14.2017.07.16.00.28.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 00:28:34 -0700 (PDT)
Received: by mail-pg0-x243.google.com with SMTP id v190so1906010pgv.1
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:28:34 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH] mm/vmalloc: terminate searching since one node found
Date: Sun, 16 Jul 2017 15:28:27 +0800
Message-Id: <1500190107-2192-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is no need to find the very beginning of the area within
alloc_vmap_area, which can be done by judging each node during the process

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
---
 mm/vmalloc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e..f833e07 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -459,9 +459,16 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 		while (n) {
 			struct vmap_area *tmp;
+			struct vmap_area *tmp_next;
 			tmp = rb_entry(n, struct vmap_area, rb_node);
+			tmp_next = list_next_entry(tmp, list);
 			if (tmp->va_end >= addr) {
 				first = tmp;
+				if (ALIGN(tmp->va_end, align) + size
+						< tmp_next->va_start) {
+					addr = ALIGN(tmp->va_end, align);
+					goto found;
+				}
 				if (tmp->va_start <= addr)
 					break;
 				n = n->rb_left;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
