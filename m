Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4D09E6B049F
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 03:23:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y62so133953653pfa.3
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:23:57 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id 3si10480915plz.629.2017.07.16.00.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 00:23:56 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id c24so15993604pfe.1
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 00:23:56 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH] mm/vmalloc: terminate searching since one node found
Date: Sun, 16 Jul 2017 15:23:47 +0800
Message-Id: <1500189827-2036-1-git-send-email-huangzhaoyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com:wq>

It is no need to find the very beginning of the area within
alloc_vmap_area, which can be done by judging each node during the process

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
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
