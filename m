Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id E3E418E0001
	for <linux-mm@kvack.org>; Wed, 19 Dec 2018 12:38:01 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id x82so8002642ita.9
        for <linux-mm@kvack.org>; Wed, 19 Dec 2018 09:38:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f191sor9516662itc.25.2018.12.19.09.38.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Dec 2018 09:38:00 -0800 (PST)
From: Roman Gushchin <guroan@gmail.com>
Subject: [PATCH 1/3] mm: refactor __vunmap() to avoid duplicated call to find_vm_area()
Date: Wed, 19 Dec 2018 09:37:49 -0800
Message-Id: <20181219173751.28056-2-guro@fb.com>
In-Reply-To: <20181219173751.28056-1-guro@fb.com>
References: <20181219173751.28056-1-guro@fb.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Roman Gushchin <guro@fb.com>

__vunmap() calls find_vm_area() twice without an obvious reason:
first directly to get the area pointer, second indirectly by calling
remove_vm_area(), which is again searching for the area.

To remove this redundancy, let's split remove_vm_area() into
__remove_vm_area(struct vmap_area *), which performs the actual area
removal, and remove_vm_area(const void *addr) wrapper, which can
be used everywhere, where it has been used before.

On my test setup, I've got up to 12% speed up on vfree()'ing 1000000
of 4-pages vmalloc blocks.

Signed-off-by: Roman Gushchin <guro@fb.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
---
 mm/vmalloc.c | 47 +++++++++++++++++++++++++++--------------------
 1 file changed, 27 insertions(+), 20 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 871e41c55e23..7660e3ef4133 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -1462,6 +1462,24 @@ struct vm_struct *find_vm_area(const void *addr)
 	return NULL;
 }
 
+static struct vm_struct *__remove_vm_area(struct vmap_area *va)
+{
+	struct vm_struct *vm = va->vm;
+
+	might_sleep();
+
+	spin_lock(&vmap_area_lock);
+	va->vm = NULL;
+	va->flags &= ~VM_VM_AREA;
+	va->flags |= VM_LAZY_FREE;
+	spin_unlock(&vmap_area_lock);
+
+	kasan_free_shadow(vm);
+	free_unmap_vmap_area(va);
+
+	return vm;
+}
+
 /**
  *	remove_vm_area  -  find and remove a continuous kernel virtual area
  *	@addr:		base address
@@ -1472,31 +1490,20 @@ struct vm_struct *find_vm_area(const void *addr)
  */
 struct vm_struct *remove_vm_area(const void *addr)
 {
+	struct vm_struct *vm = NULL;
 	struct vmap_area *va;
 
-	might_sleep();
-
 	va = find_vmap_area((unsigned long)addr);
-	if (va && va->flags & VM_VM_AREA) {
-		struct vm_struct *vm = va->vm;
-
-		spin_lock(&vmap_area_lock);
-		va->vm = NULL;
-		va->flags &= ~VM_VM_AREA;
-		va->flags |= VM_LAZY_FREE;
-		spin_unlock(&vmap_area_lock);
-
-		kasan_free_shadow(vm);
-		free_unmap_vmap_area(va);
+	if (va && va->flags & VM_VM_AREA)
+		vm = __remove_vm_area(va);
 
-		return vm;
-	}
-	return NULL;
+	return vm;
 }
 
 static void __vunmap(const void *addr, int deallocate_pages)
 {
 	struct vm_struct *area;
+	struct vmap_area *va;
 
 	if (!addr)
 		return;
@@ -1505,17 +1512,18 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			addr))
 		return;
 
-	area = find_vmap_area((unsigned long)addr)->vm;
-	if (unlikely(!area)) {
+	va = find_vmap_area((unsigned long)addr);
+	if (unlikely(!va || !va->vm)) {
 		WARN(1, KERN_ERR "Trying to vfree() nonexistent vm area (%p)\n",
 				addr);
 		return;
 	}
 
+	area = va->vm;
 	debug_check_no_locks_freed(area->addr, get_vm_area_size(area));
 	debug_check_no_obj_freed(area->addr, get_vm_area_size(area));
 
-	remove_vm_area(addr);
+	__remove_vm_area(va);
 	if (deallocate_pages) {
 		int i;
 
@@ -1530,7 +1538,6 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	}
 
 	kfree(area);
-	return;
 }
 
 static inline void __vfree_deferred(const void *addr)
-- 
2.19.2
