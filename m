Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E7E06B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 06:01:54 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w72so11265907pfa.7
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 03:01:54 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id w64si1302935pfk.356.2017.07.21.03.01.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 03:01:53 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id s4so5045198pgr.5
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 03:01:53 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Subject: [PATCH v1] mm/vmalloc: add a node corresponding to cached_hole_size
Date: Fri, 21 Jul 2017 18:01:41 +0800
Message-Id: <1500631301-17444-1-git-send-email-zhaoyang.huang@spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhaoyang.huang@spreadtrum.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Ingo Molnar <mingo@kernel.org>, zijun_hu <zijun_hu@htc.com>, Vlastimil Babka <vbabka@suse.cz>, Thomas Garnier <thgarnie@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@zoho.com

we just record the cached_hole_size now, which will be used when
the criteria meet both of 'free_vmap_cache == NULL' and 'size <
cached_hole_size'. However, under above scenario, the search will
start from the rb_root and then find the node which just in front
of the cached hole.

free_vmap_cache miss:
      vmap_area_root
          /      \
       _next     U
        /  (T1)
 cached_hole_node
       /
     ...   (T2)
      /
    first

vmap_area_list->first->......->cached_hole_node->cached_hole_node.list.next
                  |-------(T3)-------| | <<< cached_hole_size >>> |

vmap_area_list->......->cached_hole_node->cached_hole_node.list.next
                               | <<< cached_hole_size >>> |

The time cost to search the node now is T = T1 + T2 + T3.
The commit add a cached_hole_node here to record the one just in front of
the cached_hole_size, which can help to avoid walking the rb tree and
the list and make the T = 0;

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@spreadtrum.com>
---
 mm/vmalloc.c | 23 +++++++++++++++++++++--
 1 file changed, 21 insertions(+), 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 8698c1c..4e76e7f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -336,6 +336,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 
 /* The vmap cache globals are protected by vmap_area_lock */
 static struct rb_node *free_vmap_cache;
+static struct vmap_area *cached_hole_node;
 static unsigned long cached_hole_size;
 static unsigned long cached_vstart;
 static unsigned long cached_align;
@@ -444,6 +445,12 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 			size < cached_hole_size ||
 			vstart < cached_vstart ||
 			align < cached_align) {
+	/*if we have a cached node, just use it*/
+	if ((size < cached_hole_size) && cached_hole_node != NULL) {
+		addr = ALIGN(cached_hole_node->va_end, align);
+		cached_hole_node = NULL;
+		goto found;
+	}
 nocache:
 		cached_hole_size = 0;
 		free_vmap_cache = NULL;
@@ -487,8 +494,13 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 	/* from the starting point, walk areas until a suitable hole is found */
 	while (addr + size > first->va_start && addr + size <= vend) {
-		if (addr + cached_hole_size < first->va_start)
+		if (addr + cached_hole_size < first->va_start) {
 			cached_hole_size = first->va_start - addr;
+			/*record the node corresponding to the hole*/
+			cached_hole_node = (first->list.prev ==
+					    &vmap_area_list) ?
+					    NULL : list_prev_entry(first, list);
+		}
 		addr = ALIGN(first->va_end, align);
 		if (addr + size < addr)
 			goto overflow;
@@ -571,10 +583,17 @@ static void __free_vmap_area(struct vmap_area *va)
 			}
 		}
 	}
+	if (va == cached_hole_node) {
+		/*cached node is freed, the hole get bigger*/
+		if (cached_hole_node->list.prev != &vmap_area_list)
+			cached_hole_node = list_prev_entry(cached_hole_node,
+							   list);
+		else
+			cached_hole_node = NULL;
+	}
 	rb_erase(&va->rb_node, &vmap_area_root);
 	RB_CLEAR_NODE(&va->rb_node);
 	list_del_rcu(&va->list);
-
 	/*
 	 * Track the highest possible candidate for pcpu area
 	 * allocation.  Areas outside of vmalloc area can be returned
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
