Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id F14016B0008
	for <linux-mm@kvack.org>; Fri, 19 Oct 2018 13:35:55 -0400 (EDT)
Received: by mail-lf1-f72.google.com with SMTP id m3-v6so795123lfh.14
        for <linux-mm@kvack.org>; Fri, 19 Oct 2018 10:35:55 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n24-v6sor7822936lfe.33.2018.10.19.10.35.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Oct 2018 10:35:53 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RFC PATCH 2/2] mm: add priority threshold to __purge_vmap_area_lazy()
Date: Fri, 19 Oct 2018 19:35:38 +0200
Message-Id: <20181019173538.590-3-urezki@gmail.com>
In-Reply-To: <20181019173538.590-1-urezki@gmail.com>
References: <20181019173538.590-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

commit 763b218ddfaf ("mm: add preempt points into
__purge_vmap_area_lazy()")

introduced some preempt points, one of those is making
an allocation more prioritized.

Prioritizing an allocation over freeing does not work
well all the time, i.e. it should be rather a compromise.

1) Number of lazy pages directly influence on busy list
length thus on operations like: allocation, lookup, unmap,
remove, etc.

2) Under heavy simultaneous allocations/releases there may
be a situation when memory usage grows too fast hitting
out_of_memory -> panic.

Establish a threshold passing which the freeing path is
prioritized over allocation creating a balance between both.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index a7f257540a05..bbafcff6632b 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1124,23 +1124,23 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	struct llist_node *valist;
 	struct vmap_area *va;
 	struct vmap_area *n_va;
-	bool do_free = false;
+	int resched_threshold;
 
 	lockdep_assert_held(&vmap_purge_lock);
 
 	valist = llist_del_all(&vmap_purge_list);
+	if (unlikely(valist == NULL))
+		return false;
+
 	llist_for_each_entry(va, valist, purge_list) {
 		if (va->va_start < start)
 			start = va->va_start;
 		if (va->va_end > end)
 			end = va->va_end;
-		do_free = true;
 	}
 
-	if (!do_free)
-		return false;
-
 	flush_tlb_kernel_range(start, end);
+	resched_threshold = (int) lazy_max_pages() << 1;
 
 	spin_lock(&vmap_area_lock);
 	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
@@ -1148,7 +1148,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 
 		__free_vmap_area(va);
 		atomic_sub(nr, &vmap_lazy_nr);
-		cond_resched_lock(&vmap_area_lock);
+
+		if (atomic_read(&vmap_lazy_nr) < resched_threshold)
+			cond_resched_lock(&vmap_area_lock);
 	}
 	spin_unlock(&vmap_area_lock);
 	return true;
-- 
2.11.0
