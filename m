Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8992228027B
	for <linux-mm@kvack.org>; Tue, 27 Sep 2016 10:08:45 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id cg13so26897832pac.1
        for <linux-mm@kvack.org>; Tue, 27 Sep 2016 07:08:45 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r15si2905404pfb.215.2016.09.27.07.08.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 27 Sep 2016 07:08:44 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH v2 1/1] mm/vmalloc.c: simplify /proc/vmallocinfo
 implementation
Message-ID: <57EA7D53.3000608@zoho.com>
Date: Tue, 27 Sep 2016 22:08:19 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, npiggin@gmail.com, mhocko@kernel.org

From: zijun_hu <zijun_hu@htc.com>

simplify /proc/vmallocinfo implementation via existing seq_file
helpers for list_head

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 Changes in v2:
  - more detailed commit message is provided
  - the redundant type cast for list_entry() is removed as advised
    by rientjes@google.com

 mm/vmalloc.c | 27 +++++----------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cc6ecd60cc0e..8b80931654b7 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2576,32 +2576,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 static void *s_start(struct seq_file *m, loff_t *pos)
 	__acquires(&vmap_area_lock)
 {
-	loff_t n = *pos;
-	struct vmap_area *va;
-
 	spin_lock(&vmap_area_lock);
-	va = list_first_entry(&vmap_area_list, typeof(*va), list);
-	while (n > 0 && &va->list != &vmap_area_list) {
-		n--;
-		va = list_next_entry(va, list);
-	}
-	if (!n && &va->list != &vmap_area_list)
-		return va;
-
-	return NULL;
-
+	return seq_list_start(&vmap_area_list, *pos);
 }
 
 static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 {
-	struct vmap_area *va = p, *next;
-
-	++*pos;
-	next = list_next_entry(va, list);
-	if (&next->list != &vmap_area_list)
-		return next;
-
-	return NULL;
+	return seq_list_next(p, &vmap_area_list, pos);
 }
 
 static void s_stop(struct seq_file *m, void *p)
@@ -2636,9 +2617,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 
 static int s_show(struct seq_file *m, void *p)
 {
-	struct vmap_area *va = p;
+	struct vmap_area *va;
 	struct vm_struct *v;
 
+	va = list_entry(p, struct vmap_area, list);
+
 	/*
 	 * s_show can encounter race with remove_vm_area, !VM_VM_AREA on
 	 * behalf of vmap area is being tear down or vm_map_ram allocation.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
