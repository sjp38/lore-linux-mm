Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFF76B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 04:17:11 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id 127so48908169wmu.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 01:17:11 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id v130si15247928wmb.44.2016.03.29.01.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Mar 2016 01:17:10 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id 20so2948119wmh.3
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 01:17:09 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH v3] mm/vmap: Add a notifier for when we run out of vmap address space
Date: Tue, 29 Mar 2016 09:16:57 +0100
Message-Id: <1459239417-25024-1-git-send-email-chris@chris-wilson.co.uk>
In-Reply-To: <20160328161549.c77046847a8ae791cb436aff@linux-foundation.org>
References: <20160328161549.c77046847a8ae791cb436aff@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Peniaev <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

vmaps are temporary kernel mappings that may be of long duration.
Reusing a vmap on an object is preferrable for a driver as the cost of
setting up the vmap can otherwise dominate the operation on the object.
However, the vmap address space is rather limited on 32bit systems and
so we add a notification for vmap pressure in order for the driver to
release any cached vmappings.

The interface is styled after the oom-notifier where the callees are
passed a pointer to an unsigned long counter for them to indicate if they
have freed any space.

v2: Guard the blocking notifier call with gfpflags_allow_blocking()
v3: Correct typo in forward declaration and move to head of file

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Peniaev <r.peniaev@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
Acked-by: Andrew Morton <akpm@linux-foundation.org> # for inclusion via DRM
---
Thanks Andrew, may I trouble someone for a Reviewed-by?
---
 include/linux/vmalloc.h |  4 ++++
 mm/vmalloc.c            | 27 +++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index d1f1d338af20..8b51df3ab334 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -8,6 +8,7 @@
 #include <linux/rbtree.h>
 
 struct vm_area_struct;		/* vma defining user mapping in mm_types.h */
+struct notifier_block;		/* in notifier.h */
 
 /* bits in flags of vmalloc's vm_struct below */
 #define VM_IOREMAP		0x00000001	/* ioremap() and friends */
@@ -187,4 +188,7 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 #define VMALLOC_TOTAL 0UL
 #endif
 
+int register_vmap_purge_notifier(struct notifier_block *nb);
+int unregister_vmap_purge_notifier(struct notifier_block *nb);
+
 #endif /* _LINUX_VMALLOC_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fb42a5bffe47..12d27ac303ae 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -21,6 +21,7 @@
 #include <linux/debugobjects.h>
 #include <linux/kallsyms.h>
 #include <linux/list.h>
+#include <linux/notifier.h>
 #include <linux/rbtree.h>
 #include <linux/radix-tree.h>
 #include <linux/rcupdate.h>
@@ -344,6 +345,8 @@ static void __insert_vmap_area(struct vmap_area *va)
 
 static void purge_vmap_area_lazy(void);
 
+static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
+
 /*
  * Allocate a region of KVA of the specified size and alignment, within the
  * vstart and vend.
@@ -363,6 +366,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	BUG_ON(offset_in_page(size));
 	BUG_ON(!is_power_of_2(align));
 
+	might_sleep_if(gfpflags_allow_blocking(gfp_mask));
+
 	va = kmalloc_node(sizeof(struct vmap_area),
 			gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!va))
@@ -468,6 +473,16 @@ overflow:
 		purged = 1;
 		goto retry;
 	}
+
+	if (gfpflags_allow_blocking(gfp_mask)) {
+		unsigned long freed = 0;
+		blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);
+		if (freed > 0) {
+			purged = 0;
+			goto retry;
+		}
+	}
+
 	if (printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: "
 			"use vmalloc=<size> to increase size.\n", size);
@@ -475,6 +490,18 @@ overflow:
 	return ERR_PTR(-EBUSY);
 }
 
+int register_vmap_purge_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_register(&vmap_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(register_vmap_purge_notifier);
+
+int unregister_vmap_purge_notifier(struct notifier_block *nb)
+{
+	return blocking_notifier_chain_unregister(&vmap_notify_list, nb);
+}
+EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier);
+
 static void __free_vmap_area(struct vmap_area *va)
 {
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
