Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1E26B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 16:57:47 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z50so5018180qtj.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 13:57:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id s62sor10590598qkh.163.2017.10.03.13.57.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 03 Oct 2017 13:57:46 -0700 (PDT)
Date: Tue, 3 Oct 2017 16:57:44 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH] mm/percpu.c: use smarter memory allocation for struct
 pcpu_alloc_info
Message-ID: <nycvar.YSQ.7.76.1710031638450.5407@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

This can be much smaller than a page on very small memory systems. 
Always rounding up the size to a page is wasteful in that case, and 
required alignment is smaller than the memblock default. Let's round 
things up to a page size only when the actual size is >= page size, and 
then it makes sense to page-align for a nicer allocation pattern.

Signed-off-by: Nicolas Pitre <nico@linaro.org>

diff --git a/mm/percpu.c b/mm/percpu.c
index 434844415d..fe37f85cc2 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1410,13 +1410,17 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 	struct pcpu_alloc_info *ai;
 	size_t base_size, ai_size;
 	void *ptr;
-	int unit;
+	int unit, align;
 
-	base_size = ALIGN(sizeof(*ai) + nr_groups * sizeof(ai->groups[0]),
-			  __alignof__(ai->groups[0].cpu_map[0]));
+	align = __alignof__(ai->groups[0].cpu_map[0]);
+	base_size = ALIGN(sizeof(*ai) + nr_groups * sizeof(ai->groups[0]), align);
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
+	if (ai_size >= PAGE_SIZE) {
+		ai_size = PFN_ALIGN(ai_size);
+		align = PAGE_SIZE;
+	}
 
-	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), 0);
+	ptr = memblock_virt_alloc_nopanic(ai_size, align);
 	if (!ptr)
 		return NULL;
 	ai = ptr;
@@ -1428,7 +1432,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 		ai->groups[0].cpu_map[unit] = NR_CPUS;
 
 	ai->nr_groups = nr_groups;
-	ai->__ai_size = PFN_ALIGN(ai_size);
+	ai->__ai_size = ai_size;
 
 	return ai;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
