Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0FB6B0009
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:30 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id d186-v6so14213573iog.10
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s63-v6sor2846027ioi.261.2018.04.23.05.55.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:29 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 2/9] vmalloc: rename llist field in vmap_area
Date: Mon, 23 Apr 2018 16:54:51 +0400
Message-Id: <20180423125458.5338-3-igor.stoppa@huawei.com>
In-Reply-To: <20180423125458.5338-1-igor.stoppa@huawei.com>
References: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

The vmap_area structure has a field of type struct llist_node, named
purge_list and is used when performing lazy purge of the area.

Such field is left unused during the actual utilization of the
structure.

This patch renames the field to a more generic "area_list", to allow for
utilization outside of the purging phase.

Since the purging happens after the vmap_area is dismissed, its use is
mutually exclusive with any use performed while the area is allocated.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
---
 include/linux/vmalloc.h | 2 +-
 mm/vmalloc.c            | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 1e5d8c392f15..2d07dfef3cfd 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -47,7 +47,7 @@ struct vmap_area {
 	unsigned long flags;
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
-	struct llist_node purge_list;    /* "lazy purge" list */
+	struct llist_node area_list;    /* generic list of areas */
 	struct vm_struct *vm;
 	struct rcu_head rcu_head;
 };
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 61a1ca22b0f6..1bb2233bb262 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -682,7 +682,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	lockdep_assert_held(&vmap_purge_lock);
 
 	valist = llist_del_all(&vmap_purge_list);
-	llist_for_each_entry(va, valist, purge_list) {
+	llist_for_each_entry(va, valist, area_list) {
 		if (va->va_start < start)
 			start = va->va_start;
 		if (va->va_end > end)
@@ -696,7 +696,7 @@ static bool __purge_vmap_area_lazy(unsigned long start, unsigned long end)
 	flush_tlb_kernel_range(start, end);
 
 	spin_lock(&vmap_area_lock);
-	llist_for_each_entry_safe(va, n_va, valist, purge_list) {
+	llist_for_each_entry_safe(va, n_va, valist, area_list) {
 		int nr = (va->va_end - va->va_start) >> PAGE_SHIFT;
 
 		__free_vmap_area(va);
@@ -743,7 +743,7 @@ static void free_vmap_area_noflush(struct vmap_area *va)
 				    &vmap_lazy_nr);
 
 	/* After this point, we may free va at any time */
-	llist_add(&va->purge_list, &vmap_purge_list);
+	llist_add(&va->area_list, &vmap_purge_list);
 
 	if (unlikely(nr_lazy > lazy_max_pages()))
 		try_purge_vmap_area_lazy();
-- 
2.14.1
