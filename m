Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6C86B0279
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 04:27:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 1so13430200pfi.14
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 01:27:20 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id p65si1246137pfl.366.2017.07.18.01.27.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 01:27:18 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id o88so1894725pfk.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 01:27:18 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH v3] mm/vmalloc: terminate searching since one node found
Date: Tue, 18 Jul 2017 16:27:04 +0800
Message-Id: <1500366424-5882-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It is no need to find the very beginning of the area within
alloc_vmap_area, which can be done by judging each node during the process

For current approach, the worst case is that the starting node which be found
for searching the 'vmap_area_list' is close to the 'vstart', while the final
available one is round to the tail(especially for the left branch).
This commit have the list searching start at the first available node, which
will save the time of walking the rb tree'(1)' and walking the list'(2)'.

      vmap_area_root
          /      \
     tmp_next     U
        /
      tmp
       /
     ...  (1)
      /
    first(current approach)

vmap_area_list->...->first->...->tmp->tmp_next
                            (2)

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/vmalloc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 34a1c3e..9a5c177 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -459,9 +459,18 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
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
+			                if (cached_hole_size >= size)
+						cached_hole_size = 0;
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
