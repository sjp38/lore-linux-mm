Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 29E0A8E007A
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 06:57:07 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id v27-v6so1624420ljv.1
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 03:57:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c13sor1923695lfi.10.2019.01.24.03.57.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 03:57:05 -0800 (PST)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [PATCH v1 2/2] mm: add priority threshold to __purge_vmap_area_lazy()
Date: Thu, 24 Jan 2019 12:56:48 +0100
Message-Id: <20190124115648.9433-3-urezki@gmail.com>
In-Reply-To: <20190124115648.9433-1-urezki@gmail.com>
References: <20190124115648.9433-1-urezki@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: LKML <linux-kernel@vger.kernel.org>, Thomas Garnier <thgarnie@google.com>, Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Tejun Heo <tj@kernel.org>, "Uladzislau Rezki (Sony)" <urezki@gmail.com>

commit 763b218ddfaf ("mm: add preempt points into
__purge_vmap_area_lazy()")

introduced some preempt points, one of those is making an
allocation more prioritized over lazy free of vmap areas.

Prioritizing an allocation over freeing does not work well
all the time, i.e. it should be rather a compromise.

1) Number of lazy pages directly influence on busy list length
thus on operations like: allocation, lookup, unmap, remove, etc.

2) Under heavy stress of vmalloc subsystem i run into a situation
when memory usage gets increased hitting out_of_memory -> panic
state due to completely blocking of logic that frees vmap areas
in the __purge_vmap_area_lazy() function.

Establish a threshold passing which the freeing is prioritized
back over allocation creating a balance between each other.

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 mm/vmalloc.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fb4fb5fcee74..abe83f885069 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -661,23 +661,27 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
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
+	/*
+	 * TODO: to calculate a flush range without looping.
+	 * The list can be up to lazy_max_pages() elements.
+	 */
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
@@ -685,7 +689,9 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 
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
