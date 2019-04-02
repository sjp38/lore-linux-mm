Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A9CDC10F0B
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CE912075E
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 16:25:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U5AbBFUw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CE912075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B99F6B026C; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 46F246B026F; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 248EF6B0270; Tue,  2 Apr 2019 12:25:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 844446B026C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 12:25:46 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id p82so3456419ljp.6
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 09:25:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=z12A+kO9gwTTiZ99k3PAIIown66gIUgk3OLde3/+1J0=;
        b=NdQ3+U2oVQ8U00r7gDuG5tc755fcWh7+UjWodq4Ii7Fc9sJICn//Jg+FkBKz8jAMHR
         WefDiNQp6ClMh2IvIIL1cssVZz1NdWIn8mINU9R9DWm1om6sZt/decxLabmGXeiBaBG/
         oj5NXsXGI61nLzliev88VK13EAK6Su/QyNr68/Yq/LzHxwRUg6f3CmYq9Y4zIgxHyqkR
         T161gJig/igE/0mXXmJr4L9eIFoeV/8VsVCF+tEfvzPuUZ51Ba1zM8xGAMPFSppK8aDC
         6EFHf3Vb17QF1AP5ZAQYEDBnvIUYrRhzRiwhtpBSsYutSkkaPu7l2CGQSKvZe9OldZKn
         tVRw==
X-Gm-Message-State: APjAAAUPpLhf322KDvtRvBgrPPsYzGT3YeD5VNAcUcbBnwQ3Se4y4o8j
	s+czL7fLIuOw2gIdSVEEWJ7Jqv/wopXzYLFEav0pwQh6ApYMAwPnGfMa02GfxjSs9z+VRSHFFB2
	wQvT44mV1lu8NIUeKbwUAuhI1hpOg1Ggxl5XrV23qOkPNvhxYb2ot21c++bkEODRMyQ==
X-Received: by 2002:a2e:2d02:: with SMTP id t2mr10491842ljt.148.1554222345860;
        Tue, 02 Apr 2019 09:25:45 -0700 (PDT)
X-Received: by 2002:a2e:2d02:: with SMTP id t2mr10491678ljt.148.1554222342598;
        Tue, 02 Apr 2019 09:25:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554222342; cv=none;
        d=google.com; s=arc-20160816;
        b=zzZSK9EiuuddbG1n3aBkMGo0ALf8fXOa9ASAbgHy/MDKWwc57wAvwN1dFgqNN8fahK
         IX/fc+sr4N+lOy7+WqegjPYvVnmQ5WW2Abqroh7/QyF0SDiqYQTZiv0/GNJRsRrlohTh
         WbQcdn3FVd1TtHFdlEa+fSAsg2mJB8m2Gqjq5WkMbBrXBvCT7yS9TxXBELhnWiTl6mWT
         gyYYVKL6h1cDQcwzZ9kvLwo7SN1gWDGc1KEwRrnZiET3N+EublL/PzGQpQte4NXGmTvH
         v9J/8HzkLuUCXCZsNi6TCy3YrKibF9YAeFMjetXqP5PZh43I0IJQWd0dYW6OY6NXd9KZ
         7ejQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=z12A+kO9gwTTiZ99k3PAIIown66gIUgk3OLde3/+1J0=;
        b=DnDPVLqrNd+TygGDjz1qI7rKB1KzkwwDgFEiImjmhkWksyJggnst/WjbZxfEXR2WqP
         sfQmetVjO8uKnspcD+S9JWG4z9ZkpjRPKDHelvTspsdS2+vJXgw+uFVxIiezUhmsvRUK
         DdnIiNVXCaEopHXvn3n4Go/vAX5h0VENeXJWW24fqqnSkJIAP1uJDy47g2GIw6EU8jrz
         /JmXje2Xh+MDW4PCNlK0AajyRGQvdc07yNR9qeBoiCbE1xMq6y2+2Kziq3pul3GYdE2u
         /ekrun/mCL/a9wb1X8EohhHtkkfXTbKgBbBAg6plO3Yjq6KRnO+w0tUqxpDrQBSdGd7+
         OSAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U5AbBFUw;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u4sor3485209lfi.57.2019.04.02.09.25.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 09:25:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U5AbBFUw;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=z12A+kO9gwTTiZ99k3PAIIown66gIUgk3OLde3/+1J0=;
        b=U5AbBFUw59mUh6Hx0JD75g+y4jbmaD9OPbaqFw8YmYmNjhaDPmd17xXuV0XVYxakyU
         7U8PhcJ7LrejLEHwOe6V2MKs4TTGQMDLOQAu6yMcbJOe9tXrHZdlItpFM4gAsXpSj4Yk
         T+kYffJobKZcNK65uSEXAPcXK0Nb+QPaIA/LqaZTR5xwc2UPACYaKG7dWO7OZWnUxxfo
         JC1smOlBETroryveS/As8Zyfh7ZF2Afp/6dsht4KkYE6p2CvJcqSaFq3V4u9S8su4GrV
         J5s6KZ2xAm63N4RaPW9k7Wd9Sfpvfr4+r/1MPaUiwMS1dIOwMqRejZYDh6qV/LRPNXTK
         L8kg==
X-Google-Smtp-Source: APXvYqxOdC2AFMoy42ExqRzhAdQPxeEaqTNL0yYSZfoqrfZFW6hi8YADDPhvuIri5np9Fzh8AfZRcg==
X-Received: by 2002:ac2:5381:: with SMTP id g1mr36216502lfh.130.1554222341667;
        Tue, 02 Apr 2019 09:25:41 -0700 (PDT)
Received: from pc636.semobile.internal ([37.139.158.167])
        by smtp.gmail.com with ESMTPSA id 13sm2550377lfy.2.2019.04.02.09.25.40
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 09:25:41 -0700 (PDT)
From: "Uladzislau Rezki (Sony)" <urezki@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>,
	Thomas Garnier <thgarnie@google.com>,
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>,
	Steven Rostedt <rostedt@goodmis.org>,
	Joel Fernandes <joelaf@google.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@elte.hu>,
	Tejun Heo <tj@kernel.org>,
	"Uladzislau Rezki (Sony)" <urezki@gmail.com>
Subject: [RESEND PATCH 1/3] mm/vmap: keep track of free blocks for vmap allocation
Date: Tue,  2 Apr 2019 18:25:29 +0200
Message-Id: <20190402162531.10888-2-urezki@gmail.com>
X-Mailer: git-send-email 2.11.0
In-Reply-To: <20190402162531.10888-1-urezki@gmail.com>
References: <20190402162531.10888-1-urezki@gmail.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently an allocation of the new vmap area is done over busy
list iteration(complexity O(n)) until a suitable hole is found
between two busy areas. Therefore each new allocation causes
the list being grown. Due to over fragmented list and different
permissive parameters an allocation can take a long time. For
example on embedded devices it is milliseconds.

This patch organizes the KVA memory layout into free areas of the
1-ULONG_MAX range. It uses an augment red-black tree that keeps
blocks sorted by their offsets in pair with linked list keeping
the free space in order of increasing addresses.

Each vmap_area object contains the "subtree_max_size" that reflects
a maximum available free block in its left or right sub-tree. Thus,
that allows to take a decision and traversal toward the block that
will fit and will have the lowest start address, i.e. sequential
allocation.

Allocation: to allocate a new block a search is done over the
tree until a suitable lowest(left most) block is large enough
to encompass: the requested size, alignment and vstart point.
If the block is bigger than requested size - it is split.

De-allocation: when a busy vmap area is freed it can either be
merged or inserted to the tree. Red-black tree allows efficiently
find a spot whereas a linked list provides a constant-time access
to previous and next blocks to check if merging can be done. In case
of merging of de-allocated memory chunk a large coalesced area is
created.

Complexity: ~O(log(N))

Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
---
 include/linux/vmalloc.h |    6 +-
 mm/vmalloc.c            | 1004 +++++++++++++++++++++++++++++++++++------------
 2 files changed, 762 insertions(+), 248 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 398e9c95cd61..ad483378fdd1 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -45,12 +45,16 @@ struct vm_struct {
 struct vmap_area {
 	unsigned long va_start;
 	unsigned long va_end;
+
+	/*
+	 * Largest available free size in subtree.
+	 */
+	unsigned long subtree_max_size;
 	unsigned long flags;
 	struct rb_node rb_node;         /* address sorted rbtree */
 	struct list_head list;          /* address sorted list */
 	struct llist_node purge_list;    /* "lazy purge" list */
 	struct vm_struct *vm;
-	struct rcu_head rcu_head;
 };
 
 /*
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 755b02983d8d..3adbad3fb6c1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -31,6 +31,7 @@
 #include <linux/compiler.h>
 #include <linux/llist.h>
 #include <linux/bitops.h>
+#include <linux/rbtree_augmented.h>
 
 #include <linux/uaccess.h>
 #include <asm/tlbflush.h>
@@ -320,9 +321,7 @@ unsigned long vmalloc_to_pfn(const void *vmalloc_addr)
 }
 EXPORT_SYMBOL(vmalloc_to_pfn);
 
-
 /*** Global kva allocator ***/
-
 #define VM_LAZY_FREE	0x02
 #define VM_VM_AREA	0x04
 
@@ -331,14 +330,76 @@ static DEFINE_SPINLOCK(vmap_area_lock);
 LIST_HEAD(vmap_area_list);
 static LLIST_HEAD(vmap_purge_list);
 static struct rb_root vmap_area_root = RB_ROOT;
+static bool vmap_initialized __read_mostly;
+
+/*
+ * This kmem_cache is used for vmap_area objects. Instead of
+ * allocating from slab we reuse an object from this cache to
+ * make things faster. Especially in "no edge" splitting of
+ * free block.
+ */
+static struct kmem_cache *vmap_area_cachep;
+
+/*
+ * This linked list is used in pair with free_vmap_area_root.
+ * It gives O(1) access to prev/next to perform fast coalescing.
+ */
+static LIST_HEAD(free_vmap_area_list);
+
+/*
+ * This augment red-black tree represents the free vmap space.
+ * All vmap_area objects in this tree are sorted by va->va_start
+ * address. It is used for allocation and merging when a vmap
+ * object is released.
+ *
+ * Each vmap_area node contains a maximum available free block
+ * of its sub-tree, right or left. Therefore it is possible to
+ * find a lowest match of free area.
+ */
+static struct rb_root free_vmap_area_root = RB_ROOT;
 
-/* The vmap cache globals are protected by vmap_area_lock */
-static struct rb_node *free_vmap_cache;
-static unsigned long cached_hole_size;
-static unsigned long cached_vstart;
-static unsigned long cached_align;
+static __always_inline unsigned long
+__va_size(struct vmap_area *va)
+{
+	return (va->va_end - va->va_start);
+}
+
+static __always_inline unsigned long
+get_subtree_max_size(struct rb_node *node)
+{
+	struct vmap_area *va;
 
-static unsigned long vmap_area_pcpu_hole;
+	va = rb_entry_safe(node, struct vmap_area, rb_node);
+	return va ? va->subtree_max_size : 0;
+}
+
+/*
+ * Gets called when remove the node and rotate.
+ */
+static __always_inline unsigned long
+compute_subtree_max_size(struct vmap_area *va)
+{
+	unsigned long max_size = __va_size(va);
+	unsigned long child_max_size;
+
+	child_max_size = get_subtree_max_size(va->rb_node.rb_right);
+	if (child_max_size > max_size)
+		max_size = child_max_size;
+
+	child_max_size = get_subtree_max_size(va->rb_node.rb_left);
+	if (child_max_size > max_size)
+		max_size = child_max_size;
+
+	return max_size;
+}
+
+RB_DECLARE_CALLBACKS(static, free_vmap_area_rb_augment_cb,
+	struct vmap_area, rb_node, unsigned long, subtree_max_size,
+	compute_subtree_max_size)
+
+static void purge_vmap_area_lazy(void);
+static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
+static unsigned long lazy_max_pages(void);
 
 static struct vmap_area *__find_vmap_area(unsigned long addr)
 {
@@ -359,41 +420,520 @@ static struct vmap_area *__find_vmap_area(unsigned long addr)
 	return NULL;
 }
 
-static void __insert_vmap_area(struct vmap_area *va)
-{
-	struct rb_node **p = &vmap_area_root.rb_node;
-	struct rb_node *parent = NULL;
-	struct rb_node *tmp;
+/*
+ * This function returns back addresses of parent node
+ * and its left or right link for further processing.
+ */
+static __always_inline struct rb_node **
+__find_va_links(struct vmap_area *va,
+	struct rb_root *root, struct rb_node *from,
+	struct rb_node **parent)
+{
+	struct vmap_area *tmp_va;
+	struct rb_node **link;
+
+	if (root) {
+		link = &root->rb_node;
+		if (unlikely(!*link)) {
+			*parent = NULL;
+			return link;
+		}
+	} else {
+		link = &from;
+	}
 
-	while (*p) {
-		struct vmap_area *tmp_va;
+	/*
+	 * Go to the bottom of the tree.
+	 */
+	do {
+		tmp_va = rb_entry(*link, struct vmap_area, rb_node);
 
-		parent = *p;
-		tmp_va = rb_entry(parent, struct vmap_area, rb_node);
-		if (va->va_start < tmp_va->va_end)
-			p = &(*p)->rb_left;
-		else if (va->va_end > tmp_va->va_start)
-			p = &(*p)->rb_right;
+		/*
+		 * During the traversal we also do some sanity check.
+		 * Trigger the BUG() if there are sides(left/right)
+		 * or full overlaps.
+		 */
+		if (va->va_start < tmp_va->va_end &&
+				va->va_end <= tmp_va->va_start)
+			link = &(*link)->rb_left;
+		else if (va->va_end > tmp_va->va_start &&
+				va->va_start >= tmp_va->va_end)
+			link = &(*link)->rb_right;
 		else
 			BUG();
+	} while (*link);
+
+	*parent = &tmp_va->rb_node;
+	return link;
+}
+
+static __always_inline struct list_head *
+__get_va_next_sibling(struct rb_node *parent, struct rb_node **link)
+{
+	struct list_head *list;
+
+	if (likely(parent)) {
+		list = &rb_entry(parent, struct vmap_area, rb_node)->list;
+		return (&parent->rb_right == link ? list->next:list);
 	}
 
-	rb_link_node(&va->rb_node, parent, p);
-	rb_insert_color(&va->rb_node, &vmap_area_root);
+	/*
+	 * The red-black tree where we try to find VA neighbors
+	 * before merging or inserting is empty, i.e. it means
+	 * there is no free vmap space. Normally it does not
+	 * happen but we handle this case anyway.
+	 */
+	return NULL;
+}
+
+static __always_inline void
+__link_va(struct vmap_area *va, struct rb_root *root,
+	struct rb_node *parent, struct rb_node **link, struct list_head *head)
+{
+	/*
+	 * VA is still not in the list, but we can
+	 * identify its future previous list_head node.
+	 */
+	if (likely(parent)) {
+		head = &rb_entry(parent, struct vmap_area, rb_node)->list;
+		if (&parent->rb_right != link)
+			head = head->prev;
+	}
 
-	/* address-sort this list */
-	tmp = rb_prev(&va->rb_node);
-	if (tmp) {
-		struct vmap_area *prev;
-		prev = rb_entry(tmp, struct vmap_area, rb_node);
-		list_add_rcu(&va->list, &prev->list);
-	} else
-		list_add_rcu(&va->list, &vmap_area_list);
+	/* Insert to the rb-tree */
+	rb_link_node(&va->rb_node, parent, link);
+	if (root == &free_vmap_area_root) {
+		/*
+		 * Some explanation here. Just perform simple insertion
+		 * to the tree. We do not set va->subtree_max_size to
+		 * its current size before calling rb_insert_augmented().
+		 * It is because of we populate the tree from the bottom
+		 * to parent levels when the node _is_ in the tree.
+		 *
+		 * Therefore we set subtree_max_size to zero after insertion,
+		 * to let __augment_tree_propagate_from() puts everything to
+		 * the correct order later on.
+		 */
+		rb_insert_augmented(&va->rb_node,
+			root, &free_vmap_area_rb_augment_cb);
+		va->subtree_max_size = 0;
+	} else {
+		rb_insert_color(&va->rb_node, root);
+	}
+
+	/* Address-sort this list */
+	list_add(&va->list, head);
 }
 
-static void purge_vmap_area_lazy(void);
+static __always_inline void
+__unlink_va(struct vmap_area *va, struct rb_root *root)
+{
+	/*
+	 * During merging a VA node can be empty, therefore
+	 * not linked with the tree nor list. Just check it.
+	 */
+	if (!RB_EMPTY_NODE(&va->rb_node)) {
+		if (root == &free_vmap_area_root)
+			rb_erase_augmented(&va->rb_node,
+				root, &free_vmap_area_rb_augment_cb);
+		else
+			rb_erase(&va->rb_node, root);
 
-static BLOCKING_NOTIFIER_HEAD(vmap_notify_list);
+		list_del(&va->list);
+		RB_CLEAR_NODE(&va->rb_node);
+	}
+}
+
+/*
+ * This function populates subtree_max_size from bottom to upper
+ * levels starting from VA point. The propagation must be done
+ * when VA size is modified by changing its va_start/va_end. Or
+ * in case of newly inserting of VA to the tree.
+ *
+ * It means that __augment_tree_propagate_from() must be called:
+ * - After VA has been inserted to the tree(free path);
+ * - After VA has been shrunk(allocation path);
+ * - After VA has been increased(merging path).
+ *
+ * Please note that, it does not mean that upper parent nodes
+ * and their subtree_max_size are recalculated all the time up
+ * to the root node.
+ *
+ *       4--8
+ *        /\
+ *       /  \
+ *      /    \
+ *    2--2  8--8
+ *
+ * For example if we modify the node 4, shrinking it to 2, then
+ * no any modification is required. If we shrink the node 2 to 1
+ * its subtree_max_size is updated only, and set to 1. If we shrink
+ * the node 8 to 6, then its subtree_max_size is set to 6 and parent
+ * node becomes 4--6.
+ */
+static __always_inline void
+__augment_tree_propagate_from(struct vmap_area *va)
+{
+	struct rb_node *node = &va->rb_node;
+	unsigned long new_va_sub_max_size;
+
+	while (node) {
+		va = rb_entry(node, struct vmap_area, rb_node);
+		new_va_sub_max_size = compute_subtree_max_size(va);
+
+		/*
+		 * If the newly calculated maximum available size of the
+		 * subtree is equal to the current one, then it means that
+		 * the tree is propagated correctly. So we have to stop at
+		 * this point to save cycles.
+		 */
+		if (va->subtree_max_size == new_va_sub_max_size)
+			break;
+
+		va->subtree_max_size = new_va_sub_max_size;
+		node = rb_parent(&va->rb_node);
+	}
+}
+
+static void
+__insert_vmap_area(struct vmap_area *va,
+	struct rb_root *root, struct list_head *head)
+{
+	struct rb_node **link;
+	struct rb_node *parent;
+
+	link = __find_va_links(va, root, NULL, &parent);
+	__link_va(va, root, parent, link, head);
+}
+
+static void
+__insert_vmap_area_augment(struct vmap_area *va,
+	struct rb_node *from, struct rb_root *root,
+	struct list_head *head)
+{
+	struct rb_node **link;
+	struct rb_node *parent;
+
+	if (from)
+		link = __find_va_links(va, NULL, from, &parent);
+	else
+		link = __find_va_links(va, root, NULL, &parent);
+
+	__link_va(va, root, parent, link, head);
+	__augment_tree_propagate_from(va);
+}
+
+/*
+ * Merge de-allocated chunk of VA memory with previous
+ * and next free blocks. If coalesce is not done a new
+ * free area is inserted. If VA has been merged, it is
+ * freed.
+ */
+static __always_inline void
+__merge_or_add_vmap_area(struct vmap_area *va,
+	struct rb_root *root, struct list_head *head)
+{
+	struct vmap_area *sibling;
+	struct list_head *next;
+	struct rb_node **link;
+	struct rb_node *parent;
+	bool merged = false;
+
+	/*
+	 * Find a place in the tree where VA potentially will be
+	 * inserted, unless it is merged with its sibling/siblings.
+	 */
+	link = __find_va_links(va, root, NULL, &parent);
+
+	/*
+	 * Get next node of VA to check if merging can be done.
+	 */
+	next = __get_va_next_sibling(parent, link);
+	if (unlikely(next == NULL))
+		goto insert;
+
+	/*
+	 * start            end
+	 * |                |
+	 * |<------VA------>|<-----Next----->|
+	 *                  |                |
+	 *                  start            end
+	 */
+	if (next != head) {
+		sibling = list_entry(next, struct vmap_area, list);
+		if (sibling->va_start == va->va_end) {
+			sibling->va_start = va->va_start;
+
+			/* Check and update the tree if needed. */
+			__augment_tree_propagate_from(sibling);
+
+			/* Remove this VA, it has been merged. */
+			__unlink_va(va, root);
+
+			/* Free vmap_area object. */
+			kmem_cache_free(vmap_area_cachep, va);
+
+			/* Point to the new merged area. */
+			va = sibling;
+			merged = true;
+		}
+	}
+
+	/*
+	 * start            end
+	 * |                |
+	 * |<-----Prev----->|<------VA------>|
+	 *                  |                |
+	 *                  start            end
+	 */
+	if (next->prev != head) {
+		sibling = list_entry(next->prev, struct vmap_area, list);
+		if (sibling->va_end == va->va_start) {
+			sibling->va_end = va->va_end;
+
+			/* Check and update the tree if needed. */
+			__augment_tree_propagate_from(sibling);
+
+			/* Remove this VA, it has been merged. */
+			__unlink_va(va, root);
+
+			/* Free vmap_area object. */
+			kmem_cache_free(vmap_area_cachep, va);
+
+			return;
+		}
+	}
+
+insert:
+	if (!merged) {
+		__link_va(va, root, parent, link, head);
+		__augment_tree_propagate_from(va);
+	}
+}
+
+static __always_inline bool
+is_within_this_va(struct vmap_area *va, unsigned long size,
+	unsigned long align, unsigned long vstart)
+{
+	unsigned long nva_start_addr;
+
+	if (va->va_start > vstart)
+		nva_start_addr = ALIGN(va->va_start, align);
+	else
+		nva_start_addr = ALIGN(vstart, align);
+
+	/* Can be overflowed due to big size or alignment. */
+	if (nva_start_addr + size < nva_start_addr ||
+			nva_start_addr < vstart)
+		return false;
+
+	return (nva_start_addr + size <= va->va_end);
+}
+
+/*
+ * Find the first free block(lowest start address) in the tree,
+ * that will accomplish the request corresponding to passing
+ * parameters.
+ */
+static __always_inline struct vmap_area *
+__find_vmap_lowest_match(unsigned long size,
+	unsigned long align, unsigned long vstart)
+{
+	struct vmap_area *va;
+	struct rb_node *node;
+	unsigned long length;
+
+	/* Start from the root. */
+	node = free_vmap_area_root.rb_node;
+
+	/* Adjust the search size for alignment overhead. */
+	length = size + align - 1;
+
+	while (node) {
+		va = rb_entry(node, struct vmap_area, rb_node);
+
+		if (get_subtree_max_size(node->rb_left) >= length &&
+				vstart < va->va_start) {
+			node = node->rb_left;
+		} else {
+			if (is_within_this_va(va, size, align, vstart))
+				return va;
+
+			/*
+			 * Does not make sense to go deeper towards the right
+			 * sub-tree if it does not have a free block that is
+			 * equal or bigger to the requested search length.
+			 */
+			if (get_subtree_max_size(node->rb_right) >= length) {
+				node = node->rb_right;
+				continue;
+			}
+
+			/*
+			 * OK. We roll back and find the fist right sub-tree,
+			 * that will satisfy the search criteria. It can happen
+			 * only once due to "vstart" restriction.
+			 */
+			while ((node = rb_parent(node))) {
+				va = rb_entry(node, struct vmap_area, rb_node);
+				if (is_within_this_va(va, size, align, vstart))
+					return va;
+
+				if (get_subtree_max_size(node->rb_right) >= length &&
+						vstart <= va->va_start) {
+					node = node->rb_right;
+					break;
+				}
+			}
+		}
+	}
+
+	return NULL;
+}
+
+enum alloc_fit_type {
+	NOTHING_FIT = 0,
+	FL_FIT_TYPE = 1,	/* full fit */
+	LE_FIT_TYPE = 2,	/* left edge fit */
+	RE_FIT_TYPE = 3,	/* right edge fit */
+	NE_FIT_TYPE = 4		/* no edge fit */
+};
+
+static __always_inline u8
+__classify_va_fit_type(struct vmap_area *va,
+	unsigned long nva_start_addr, unsigned long size)
+{
+	u8 fit_type;
+
+	/* Check if it is within VA. */
+	if (nva_start_addr < va->va_start ||
+			nva_start_addr + size > va->va_end)
+		return NOTHING_FIT;
+
+	/* Now classify. */
+	if (va->va_start == nva_start_addr) {
+		if (va->va_end == nva_start_addr + size)
+			fit_type = FL_FIT_TYPE;
+		else
+			fit_type = LE_FIT_TYPE;
+	} else if (va->va_end == nva_start_addr + size) {
+		fit_type = RE_FIT_TYPE;
+	} else {
+		fit_type = NE_FIT_TYPE;
+	}
+
+	return fit_type;
+}
+
+static __always_inline int
+__adjust_va_to_fit_type(struct vmap_area *va,
+	unsigned long nva_start_addr, unsigned long size, u8 fit_type)
+{
+	struct vmap_area *lva;
+
+	if (fit_type == FL_FIT_TYPE) {
+		/*
+		 * No need to split VA, it fully fits.
+		 *
+		 * |               |
+		 * V      NVA      V
+		 * |---------------|
+		 */
+		__unlink_va(va, &free_vmap_area_root);
+		kmem_cache_free(vmap_area_cachep, va);
+	} else if (fit_type == LE_FIT_TYPE) {
+		/*
+		 * Split left edge of fit VA.
+		 *
+		 * |       |
+		 * V  NVA  V   R
+		 * |-------|-------|
+		 */
+		va->va_start += size;
+	} else if (fit_type == RE_FIT_TYPE) {
+		/*
+		 * Split right edge of fit VA.
+		 *
+		 *         |       |
+		 *     L   V  NVA  V
+		 * |-------|-------|
+		 */
+		va->va_end = nva_start_addr;
+	} else if (fit_type == NE_FIT_TYPE) {
+		/*
+		 * Split no edge of fit VA.
+		 *
+		 *     |       |
+		 *   L V  NVA  V R
+		 * |---|-------|---|
+		 */
+		lva = kmem_cache_alloc(vmap_area_cachep, GFP_NOWAIT);
+		if (unlikely(!lva))
+			return -1;
+
+		/*
+		 * Build the remainder.
+		 */
+		lva->va_start = va->va_start;
+		lva->va_end = nva_start_addr;
+
+		/*
+		 * Shrink this VA to remaining size.
+		 */
+		va->va_start = nva_start_addr + size;
+	} else {
+		return -1;
+	}
+
+	if (fit_type != FL_FIT_TYPE) {
+		__augment_tree_propagate_from(va);
+
+		if (fit_type == NE_FIT_TYPE)
+			__insert_vmap_area_augment(lva, &va->rb_node,
+				&free_vmap_area_root, &free_vmap_area_list);
+	}
+
+	return 0;
+}
+
+/*
+ * Returns a start address of the newly allocated area, if success.
+ * Otherwise a vend is returned that indicates failure.
+ */
+static __always_inline unsigned long
+__alloc_vmap_area(unsigned long size, unsigned long align,
+	unsigned long vstart, unsigned long vend, int node)
+{
+	unsigned long nva_start_addr;
+	struct vmap_area *va;
+	u8 fit_type;
+	int ret;
+
+	va = __find_vmap_lowest_match(size, align, vstart);
+	if (unlikely(!va))
+		return vend;
+
+	if (va->va_start > vstart)
+		nva_start_addr = ALIGN(va->va_start, align);
+	else
+		nva_start_addr = ALIGN(vstart, align);
+
+	/* Check the "vend" restriction. */
+	if (nva_start_addr + size > vend)
+		return vend;
+
+	/* Classify what we have found. */
+	fit_type = __classify_va_fit_type(va, nva_start_addr, size);
+	if (WARN_ON_ONCE(fit_type == NOTHING_FIT))
+		return vend;
+
+	/* Update the free vmap_area. */
+	ret = __adjust_va_to_fit_type(va, nva_start_addr, size, fit_type);
+	if (ret)
+		return vend;
+
+	return nva_start_addr;
+}
 
 /*
  * Allocate a region of KVA of the specified size and alignment, within the
@@ -405,18 +945,19 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 				int node, gfp_t gfp_mask)
 {
 	struct vmap_area *va;
-	struct rb_node *n;
 	unsigned long addr;
 	int purged = 0;
-	struct vmap_area *first;
 
 	BUG_ON(!size);
 	BUG_ON(offset_in_page(size));
 	BUG_ON(!is_power_of_2(align));
 
+	if (unlikely(!vmap_initialized))
+		return ERR_PTR(-EBUSY);
+
 	might_sleep();
 
-	va = kmalloc_node(sizeof(struct vmap_area),
+	va = kmem_cache_alloc_node(vmap_area_cachep,
 			gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!va))
 		return ERR_PTR(-ENOMEM);
@@ -429,87 +970,20 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 
 retry:
 	spin_lock(&vmap_area_lock);
-	/*
-	 * Invalidate cache if we have more permissive parameters.
-	 * cached_hole_size notes the largest hole noticed _below_
-	 * the vmap_area cached in free_vmap_cache: if size fits
-	 * into that hole, we want to scan from vstart to reuse
-	 * the hole instead of allocating above free_vmap_cache.
-	 * Note that __free_vmap_area may update free_vmap_cache
-	 * without updating cached_hole_size or cached_align.
-	 */
-	if (!free_vmap_cache ||
-			size < cached_hole_size ||
-			vstart < cached_vstart ||
-			align < cached_align) {
-nocache:
-		cached_hole_size = 0;
-		free_vmap_cache = NULL;
-	}
-	/* record if we encounter less permissive parameters */
-	cached_vstart = vstart;
-	cached_align = align;
-
-	/* find starting point for our search */
-	if (free_vmap_cache) {
-		first = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
-		addr = ALIGN(first->va_end, align);
-		if (addr < vstart)
-			goto nocache;
-		if (addr + size < addr)
-			goto overflow;
-
-	} else {
-		addr = ALIGN(vstart, align);
-		if (addr + size < addr)
-			goto overflow;
 
-		n = vmap_area_root.rb_node;
-		first = NULL;
-
-		while (n) {
-			struct vmap_area *tmp;
-			tmp = rb_entry(n, struct vmap_area, rb_node);
-			if (tmp->va_end >= addr) {
-				first = tmp;
-				if (tmp->va_start <= addr)
-					break;
-				n = n->rb_left;
-			} else
-				n = n->rb_right;
-		}
-
-		if (!first)
-			goto found;
-	}
-
-	/* from the starting point, walk areas until a suitable hole is found */
-	while (addr + size > first->va_start && addr + size <= vend) {
-		if (addr + cached_hole_size < first->va_start)
-			cached_hole_size = first->va_start - addr;
-		addr = ALIGN(first->va_end, align);
-		if (addr + size < addr)
-			goto overflow;
-
-		if (list_is_last(&first->list, &vmap_area_list))
-			goto found;
-
-		first = list_next_entry(first, list);
-	}
-
-found:
 	/*
-	 * Check also calculated address against the vstart,
-	 * because it can be 0 because of big align request.
+	 * If an allocation fails, the "vend" address is
+	 * returned. Therefore trigger the overflow path.
 	 */
-	if (addr + size > vend || addr < vstart)
+	addr = __alloc_vmap_area(size, align, vstart, vend, node);
+	if (unlikely(addr == vend))
 		goto overflow;
 
 	va->va_start = addr;
 	va->va_end = addr + size;
 	va->flags = 0;
-	__insert_vmap_area(va);
-	free_vmap_cache = &va->rb_node;
+	__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+
 	spin_unlock(&vmap_area_lock);
 
 	BUG_ON(!IS_ALIGNED(va->va_start, align));
@@ -538,7 +1012,8 @@ static struct vmap_area *alloc_vmap_area(unsigned long size,
 	if (!(gfp_mask & __GFP_NOWARN) && printk_ratelimit())
 		pr_warn("vmap allocation for size %lu failed: use vmalloc=<size> to increase size\n",
 			size);
-	kfree(va);
+
+	kmem_cache_free(vmap_area_cachep, va);
 	return ERR_PTR(-EBUSY);
 }
 
@@ -558,35 +1033,16 @@ static void __free_vmap_area(struct vmap_area *va)
 {
 	BUG_ON(RB_EMPTY_NODE(&va->rb_node));
 
-	if (free_vmap_cache) {
-		if (va->va_end < cached_vstart) {
-			free_vmap_cache = NULL;
-		} else {
-			struct vmap_area *cache;
-			cache = rb_entry(free_vmap_cache, struct vmap_area, rb_node);
-			if (va->va_start <= cache->va_start) {
-				free_vmap_cache = rb_prev(&va->rb_node);
-				/*
-				 * We don't try to update cached_hole_size or
-				 * cached_align, but it won't go very wrong.
-				 */
-			}
-		}
-	}
-	rb_erase(&va->rb_node, &vmap_area_root);
-	RB_CLEAR_NODE(&va->rb_node);
-	list_del_rcu(&va->list);
-
 	/*
-	 * Track the highest possible candidate for pcpu area
-	 * allocation.  Areas outside of vmalloc area can be returned
-	 * here too, consider only end addresses which fall inside
-	 * vmalloc area proper.
+	 * Remove from the busy tree/list.
 	 */
-	if (va->va_end > VMALLOC_START && va->va_end <= VMALLOC_END)
-		vmap_area_pcpu_hole = max(vmap_area_pcpu_hole, va->va_end);
+	__unlink_va(va, &vmap_area_root);
 
-	kfree_rcu(va, rcu_head);
+	/*
+	 * Merge VA with its neighbors, otherwise just add it.
+	 */
+	__merge_or_add_vmap_area(va,
+		&free_vmap_area_root, &free_vmap_area_list);
 }
 
 /*
@@ -793,8 +1249,6 @@ static struct vmap_area *find_vmap_area(unsigned long addr)
 
 #define VMAP_BLOCK_SIZE		(VMAP_BBMAP_BITS * PAGE_SIZE)
 
-static bool vmap_initialized __read_mostly = false;
-
 struct vmap_block_queue {
 	spinlock_t lock;
 	struct list_head free;
@@ -1248,12 +1702,52 @@ void __init vm_area_register_early(struct vm_struct *vm, size_t align)
 	vm_area_add_early(vm);
 }
 
+static void vmap_init_free_space(void)
+{
+	unsigned long vmap_start = 1;
+	const unsigned long vmap_end = ULONG_MAX;
+	struct vmap_area *busy, *free;
+
+	/*
+	 *     B     F     B     B     B     F
+	 * -|-----|.....|-----|-----|-----|.....|-
+	 *  |           The KVA space           |
+	 *  |<--------------------------------->|
+	 */
+	list_for_each_entry(busy, &vmap_area_list, list) {
+		if (busy->va_start - vmap_start > 0) {
+			free = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
+			free->va_start = vmap_start;
+			free->va_end = busy->va_start;
+
+			__insert_vmap_area_augment(free, NULL,
+				&free_vmap_area_root, &free_vmap_area_list);
+		}
+
+		vmap_start = busy->va_end;
+	}
+
+	if (vmap_end - vmap_start > 0) {
+		free = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
+		free->va_start = vmap_start;
+		free->va_end = vmap_end;
+
+		__insert_vmap_area_augment(free, NULL,
+			&free_vmap_area_root, &free_vmap_area_list);
+	}
+}
+
 void __init vmalloc_init(void)
 {
 	struct vmap_area *va;
 	struct vm_struct *tmp;
 	int i;
 
+	/*
+	 * Create the cache for vmap_area objects.
+	 */
+	vmap_area_cachep = KMEM_CACHE(vmap_area, SLAB_PANIC);
+
 	for_each_possible_cpu(i) {
 		struct vmap_block_queue *vbq;
 		struct vfree_deferred *p;
@@ -1268,16 +1762,18 @@ void __init vmalloc_init(void)
 
 	/* Import existing vmlist entries. */
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
-		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
+		va = kmem_cache_zalloc(vmap_area_cachep, GFP_NOWAIT);
 		va->flags = VM_VM_AREA;
 		va->va_start = (unsigned long)tmp->addr;
 		va->va_end = va->va_start + tmp->size;
 		va->vm = tmp;
-		__insert_vmap_area(va);
+		__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
 	}
 
-	vmap_area_pcpu_hole = VMALLOC_END;
-
+	/*
+	 * Now we can initialize a free vmap space.
+	 */
+	vmap_init_free_space();
 	vmap_initialized = true;
 }
 
@@ -2385,81 +2881,66 @@ static struct vmap_area *node_to_va(struct rb_node *n)
 }
 
 /**
- * pvm_find_next_prev - find the next and prev vmap_area surrounding @end
- * @end: target address
- * @pnext: out arg for the next vmap_area
- * @pprev: out arg for the previous vmap_area
+ * pvm_find_va_enclose_addr - find the vmap_area @addr belongs to
+ * @addr: target address
  *
- * Returns: %true if either or both of next and prev are found,
- *	    %false if no vmap_area exists
- *
- * Find vmap_areas end addresses of which enclose @end.  ie. if not
- * NULL, *pnext->va_end > @end and *pprev->va_end <= @end.
+ * Returns: vmap_area if it is found. If there is no such area
+ *   the first highest(reverse order) vmap_area is returned
+ *   i.e. va->va_start < addr && va->va_end < addr or NULL
+ *   if there are no any areas before @addr.
  */
-static bool pvm_find_next_prev(unsigned long end,
-			       struct vmap_area **pnext,
-			       struct vmap_area **pprev)
+static struct vmap_area *
+pvm_find_va_enclose_addr(unsigned long addr)
 {
-	struct rb_node *n = vmap_area_root.rb_node;
-	struct vmap_area *va = NULL;
+	struct vmap_area *va, *tmp;
+	struct rb_node *n;
+
+	n = free_vmap_area_root.rb_node;
+	va = NULL;
 
 	while (n) {
-		va = rb_entry(n, struct vmap_area, rb_node);
-		if (end < va->va_end)
-			n = n->rb_left;
-		else if (end > va->va_end)
+		tmp = rb_entry(n, struct vmap_area, rb_node);
+		if (tmp->va_start <= addr) {
+			va = tmp;
+			if (tmp->va_end >= addr)
+				break;
+
 			n = n->rb_right;
-		else
-			break;
+		} else {
+			n = n->rb_left;
+		}
 	}
 
-	if (!va)
-		return false;
-
-	if (va->va_end > end) {
-		*pnext = va;
-		*pprev = node_to_va(rb_prev(&(*pnext)->rb_node));
-	} else {
-		*pprev = va;
-		*pnext = node_to_va(rb_next(&(*pprev)->rb_node));
-	}
-	return true;
+	return va;
 }
 
 /**
- * pvm_determine_end - find the highest aligned address between two vmap_areas
- * @pnext: in/out arg for the next vmap_area
- * @pprev: in/out arg for the previous vmap_area
- * @align: alignment
- *
- * Returns: determined end address
+ * pvm_determine_end_from_reverse - find the highest aligned address
+ * of free block below VMALLOC_END
+ * @va:
+ *   in - the VA we start the search(reverse order);
+ *   out - the VA with the highest aligned end address.
  *
- * Find the highest aligned address between *@pnext and *@pprev below
- * VMALLOC_END.  *@pnext and *@pprev are adjusted so that the aligned
- * down address is between the end addresses of the two vmap_areas.
- *
- * Please note that the address returned by this function may fall
- * inside *@pnext vmap_area.  The caller is responsible for checking
- * that.
+ * Returns: determined end address within vmap_area
  */
-static unsigned long pvm_determine_end(struct vmap_area **pnext,
-				       struct vmap_area **pprev,
-				       unsigned long align)
+static unsigned long
+pvm_determine_end_from_reverse(struct vmap_area **va, unsigned long align)
 {
-	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
+	unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
 	unsigned long addr;
 
-	if (*pnext)
-		addr = min((*pnext)->va_start & ~(align - 1), vmalloc_end);
-	else
-		addr = vmalloc_end;
+	if (unlikely(!(*va)))
+		goto leave;
 
-	while (*pprev && (*pprev)->va_end > addr) {
-		*pnext = *pprev;
-		*pprev = node_to_va(rb_prev(&(*pnext)->rb_node));
+	list_for_each_entry_from_reverse((*va),
+			&free_vmap_area_list, list) {
+		addr = min((*va)->va_end & ~(align - 1), vmalloc_end);
+		if ((*va)->va_start < addr)
+			return addr;
 	}
 
-	return addr;
+leave:
+	return 0;
 }
 
 /**
@@ -2479,12 +2960,12 @@ static unsigned long pvm_determine_end(struct vmap_area **pnext,
  * to gigabytes.  To avoid interacting with regular vmallocs, these
  * areas are allocated from top.
  *
- * Despite its complicated look, this allocator is rather simple.  It
- * does everything top-down and scans areas from the end looking for
- * matching slot.  While scanning, if any of the areas overlaps with
- * existing vmap_area, the base address is pulled down to fit the
- * area.  Scanning is repeated till all the areas fit and then all
- * necessary data structures are inserted and the result is returned.
+ * Despite its complicated look, this allocator is rather simple. It
+ * does everything top-down and scans free blocks from the end looking
+ * for matching base. While scanning, if any of the areas do not fit the
+ * base address is pulled down to fit the area. Scanning is repeated till
+ * all the areas fit and then all necessary data structures are inserted
+ * and the result is returned.
  */
 struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 				     const size_t *sizes, int nr_vms,
@@ -2492,11 +2973,12 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 {
 	const unsigned long vmalloc_start = ALIGN(VMALLOC_START, align);
 	const unsigned long vmalloc_end = VMALLOC_END & ~(align - 1);
-	struct vmap_area **vas, *prev, *next;
+	struct vmap_area **vas, *va;
 	struct vm_struct **vms;
 	int area, area2, last_area, term_area;
-	unsigned long base, start, end, last_end;
+	unsigned long base, start, size, end, last_end;
 	bool purged = false;
+	u8 fit_type;
 
 	/* verify parameters and allocate data structures */
 	BUG_ON(offset_in_page(align) || !is_power_of_2(align));
@@ -2532,7 +3014,7 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		goto err_free2;
 
 	for (area = 0; area < nr_vms; area++) {
-		vas[area] = kzalloc(sizeof(struct vmap_area), GFP_KERNEL);
+		vas[area] = kmem_cache_zalloc(vmap_area_cachep, GFP_KERNEL);
 		vms[area] = kzalloc(sizeof(struct vm_struct), GFP_KERNEL);
 		if (!vas[area] || !vms[area])
 			goto err_free;
@@ -2545,49 +3027,29 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	start = offsets[area];
 	end = start + sizes[area];
 
-	if (!pvm_find_next_prev(vmap_area_pcpu_hole, &next, &prev)) {
-		base = vmalloc_end - last_end;
-		goto found;
-	}
-	base = pvm_determine_end(&next, &prev, align) - end;
+	va = pvm_find_va_enclose_addr(vmalloc_end);
+	base = pvm_determine_end_from_reverse(&va, align) - end;
 
 	while (true) {
-		BUG_ON(next && next->va_end <= base + end);
-		BUG_ON(prev && prev->va_end > base + end);
-
 		/*
 		 * base might have underflowed, add last_end before
 		 * comparing.
 		 */
-		if (base + last_end < vmalloc_start + last_end) {
-			spin_unlock(&vmap_area_lock);
-			if (!purged) {
-				purge_vmap_area_lazy();
-				purged = true;
-				goto retry;
-			}
-			goto err_free;
-		}
+		if (base + last_end < vmalloc_start + last_end)
+			goto overflow;
 
 		/*
-		 * If next overlaps, move base downwards so that it's
-		 * right below next and then recheck.
+		 * Fitting base has not been found.
 		 */
-		if (next && next->va_start < base + end) {
-			base = pvm_determine_end(&next, &prev, align) - end;
-			term_area = area;
-			continue;
-		}
+		if (va == NULL)
+			goto overflow;
 
 		/*
-		 * If prev overlaps, shift down next and prev and move
-		 * base so that it's right below new next and then
-		 * recheck.
+		 * If this VA does not fit, move base downwards and recheck.
 		 */
-		if (prev && prev->va_end > base + start)  {
-			next = prev;
-			prev = node_to_va(rb_prev(&next->rb_node));
-			base = pvm_determine_end(&next, &prev, align) - end;
+		if (base + start < va->va_start || base + end > va->va_end) {
+			va = node_to_va(rb_prev(&va->rb_node));
+			base = pvm_determine_end_from_reverse(&va, align) - end;
 			term_area = area;
 			continue;
 		}
@@ -2599,21 +3061,40 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 		area = (area + nr_vms - 1) % nr_vms;
 		if (area == term_area)
 			break;
+
 		start = offsets[area];
 		end = start + sizes[area];
-		pvm_find_next_prev(base + end, &next, &prev);
+		va = pvm_find_va_enclose_addr(base + end);
 	}
-found:
+
 	/* we've found a fitting base, insert all va's */
 	for (area = 0; area < nr_vms; area++) {
-		struct vmap_area *va = vas[area];
+		int ret;
 
-		va->va_start = base + offsets[area];
-		va->va_end = va->va_start + sizes[area];
-		__insert_vmap_area(va);
-	}
+		start = base + offsets[area];
+		size = sizes[area];
 
-	vmap_area_pcpu_hole = base + offsets[last_area];
+		va = pvm_find_va_enclose_addr(start);
+		if (WARN_ON_ONCE(va == NULL))
+			/* It is a BUG(), but trigger recovery instead. */
+			goto recovery;
+
+		fit_type = __classify_va_fit_type(va, start, size);
+		if (WARN_ON_ONCE(fit_type == NOTHING_FIT))
+			/* It is a BUG(), but trigger recovery instead. */
+			goto recovery;
+
+		ret = __adjust_va_to_fit_type(va, start, size, fit_type);
+		if (unlikely(ret))
+			goto recovery;
+
+		/* Allocated area. */
+		va = vas[area];
+		va->va_start = start;
+		va->va_end = start + size;
+
+		__insert_vmap_area(va, &vmap_area_root, &vmap_area_list);
+	}
 
 	spin_unlock(&vmap_area_lock);
 
@@ -2625,9 +3106,38 @@ struct vm_struct **pcpu_get_vm_areas(const unsigned long *offsets,
 	kfree(vas);
 	return vms;
 
+recovery:
+	/* Remove previously inserted areas. */
+	while (area--) {
+		__free_vmap_area(vas[area]);
+		vas[area] = NULL;
+	}
+
+overflow:
+	spin_unlock(&vmap_area_lock);
+	if (!purged) {
+		purge_vmap_area_lazy();
+		purged = true;
+
+		/* Before "retry", check if we recover. */
+		for (area = 0; area < nr_vms; area++) {
+			if (vas[area])
+				continue;
+
+			vas[area] = kmem_cache_zalloc(
+				vmap_area_cachep, GFP_KERNEL);
+			if (!vas[area])
+				goto err_free;
+		}
+
+		goto retry;
+	}
+
 err_free:
 	for (area = 0; area < nr_vms; area++) {
-		kfree(vas[area]);
+		if (vas[area])
+			kmem_cache_free(vmap_area_cachep, vas[area]);
+
 		kfree(vms[area]);
 	}
 err_free2:
-- 
2.11.0

