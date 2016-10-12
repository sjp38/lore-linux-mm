Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id BC5816B0069
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 04:24:40 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id g45so31664823qte.5
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 01:24:40 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id r32si3310039qtb.104.2016.10.12.01.24.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 12 Oct 2016 01:24:39 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RESEND RFC PATCH v2 1/1] mm/vmalloc.c: simplify /proc/vmallocinfo
 implementation
Message-ID: <57FDF2E5.1000201@zoho.com>
Date: Wed, 12 Oct 2016 16:23:01 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, rientjes@google.com, tj@kernel.org, mingo@kernel.org, iamjoonsoo.kim@lge.com, mgorman@techsingularity.net, mhocko@kernel.org, sfr@canb.auug.org.au
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com

From: zijun_hu <zijun_hu@htc.com>

many seq_file helpers exist for simplifying implementation of virtual files
especially, for /proc nodes. however, the helpers for iteration over
list_head are available but aren't adopted to implement /proc/vmallocinfo
currently.

simplify /proc/vmallocinfo implementation by existing seq_file helpers

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 Changes in v2:
  - the redundant type cast is removed as advised by rientjes@google.com
  - commit messages are updated

 mm/vmalloc.c | 27 +++++----------------------
 1 file changed, 5 insertions(+), 22 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index f2481cb4e6b2..e73948afac70 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2574,32 +2574,13 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
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
@@ -2634,9 +2615,11 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 
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
