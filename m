Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B5A86B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 05:24:26 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e3so24223716pfc.4
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:24:26 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id u27si1348985pfg.100.2017.07.20.02.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 02:24:25 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id v190so2290600pgv.1
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 02:24:25 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH v4] mm/vmalloc: terminate searching since one node found
Date: Thu, 20 Jul 2017 17:24:16 +0800
Message-Id: <1500542656-23332-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

It is no need to find the very beginning of the area within
alloc_vmap_area, which can be done by judging each node during the process

free_vmap_cache miss:
      vmap_area_root
          /      \
     tmp_next     U
        /  (T1)
      tmp
       /
     ...   (T2)
      /
    first

vmap_area_list->first->......->tmp->tmp_next->...->vmap_area_list
                  |-----(T3)----|

Under the scenario of free_vmap_cache miss, total time consumption of finding
the suitable hole is T = T1 + T2 + T3, while the commit decrease it to T1.

In fact, 'vmalloc' always start from the fix address(VMALLOC_START),which will
 cause the 'first' to be close to the begining of the list(vmap_area_list) and
 make T3 to be big.

The commit will especially help for a large and almost full vmalloc area.
Whearas, it would NOT affect current quick approach such as free_vmap_cache, for
it just take effect when free_vmap_cache miss and will reestablish it laterly.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/vmalloc.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8698c1c..f58f445 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -471,9 +471,20 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 		while (n) {
 			struct vmap_area *tmp;
+			struct vmap_area *tmp_next;
 			tmp = rb_entry(n, struct vmap_area, rb_node);
+			tmp_next = list_next_entry(tmp, list);
 			if (tmp->va_end >= addr) {
 				first = tmp;
+				if (ALIGN(tmp->va_end, align) + size
+						< tmp_next->va_start) {
+					/*
+					 * free_vmap_cache miss now,don't
+					 * update cached_hole_size here,
+					 * as __free_vmap_area does
+					 */
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
