Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 61ED86B0005
	for <linux-mm@kvack.org>; Thu, 17 Mar 2016 07:59:50 -0400 (EDT)
Received: by mail-wm0-f41.google.com with SMTP id l68so223191454wml.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:59:50 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ku4si9434048wjc.49.2016.03.17.04.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Mar 2016 04:59:49 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id x188so6275654wmg.0
        for <linux-mm@kvack.org>; Thu, 17 Mar 2016 04:59:48 -0700 (PDT)
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: [PATCH 1/2] mm/vmap: Add a notifier for when we run out of vmap address space
Date: Thu, 17 Mar 2016 11:59:41 +0000
Message-Id: <1458215982-13405-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Roman Pen <r.peniaev@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

vmaps are temporary kernel mappings that may be of long duration.
Reusing a vmap on an object is preferrable for a driver as the cost of
setting up the vmap can otherwise dominate the operation on the object.
However, the vmap address space is rather limited on 32bit systems and
so we add a notification for vmap pressure in order for the driver to
release any cached vmappings.

The interface is styled after the oom-notifier where the callees are
passed a pointer to an unsigned long counter for them to indicate if they
have freed any space.

Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Roman Pen <r.peniaev@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 include/linux/vmalloc.h |  4 ++++
 mm/vmalloc.c            | 22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index d1f1d338af20..edd676b8e112 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -187,4 +187,8 @@ pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 #define VMALLOC_TOTAL 0UL
 #endif
 
+struct notitifer_block;
+int register_vmap_purge_notifier(struct notifier_block *nb);
+int unregister_vmap_purge_notifier(struct notifier_block *nb);
+
 #endif /* _LINUX_VMALLOC_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fb42a5bffe47..fd2ca94c2732 100644
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
@@ -356,6 +359,7 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	struct vmap_area *va;
 	struct rb_node *n;
 	unsigned long addr;
+	unsigned long freed;
 	int purged = 0;
 	struct vmap_area *first;
 
@@ -468,6 +472,12 @@ overflow:
 		purged = 1;
 		goto retry;
 	}
+	freed = 0;
+	blocking_notifier_call_chain(&vmap_notify_list, 0, &freed);
+	if (freed > 0) {
+		purged = 0;
+		goto retry;
+	}
 	if (printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: "
 			"use vmalloc=<size> to increase size.\n", size);
@@ -475,6 +485,18 @@ overflow:
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
