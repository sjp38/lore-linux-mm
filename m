Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 822AA6B025E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 00:27:10 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t204so76357530ywt.2
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 21:27:10 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id 37si26622103qtu.94.2016.09.20.21.27.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 20 Sep 2016 21:27:09 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 2/5] mm/vmalloc.c: simplify /proc/vmallocinfo implementation
Message-ID: <57E20BE0.6040104@zoho.com>
Date: Wed, 21 Sep 2016 12:26:08 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, tj@kernel.org, mingo@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net

From: zijun_hu <zijun_hu@htc.com>

simplify /proc/vmallocinfo implementation via seq_file helpers
for list_head

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 mm/vmalloc.c | 27 +++++----------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index cc6ecd6..a125ae8 100644
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
 
+	va = list_entry((struct list_head *)p, struct vmap_area, list);
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
