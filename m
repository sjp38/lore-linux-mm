Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id B78846B0259
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 11:26:23 -0500 (EST)
Received: by oige206 with SMTP id e206so29345956oig.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 08:26:23 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id g15si997128oem.99.2015.12.09.08.26.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 08:26:20 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 2/2] x86/mm/pat: Change free_memtype() to free shrinking range
Date: Wed,  9 Dec 2015 09:26:08 -0700
Message-Id: <1449678368-31793-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
References: <1449678368-31793-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, Borislav Petkov <bp@suse.de>

mremap() to shrink the map size of a VM_PFNMAP range causes
the following error message, and leaves the pfn range allocated.

 x86/PAT: test:3493 freeing invalid memtype [mem 0x483200000-0x4863fffff]

rbt_memtype_erase(), called from free_memtype() with spin_lock
held, only accepts to free a whole memtype node in memtype_rbroot.
Change rbt_memtype_erase() to accept a request that shrinks the
size of a memtype node for mremap().

memtype_rb_exact_match() is renamed to memtype_rb_match(),
which now performs exact match or shrink match per match_type.
Since the memtype_rbroot tree allows overlapping ranges,
rbt_memtype_erase() checks exact match first to ensure the case
of freeing a whole node, which is the normal case.  For the
shrink case, rbt_memtype_erase() proceeds in two steps, 1) remove
the node, and then 2) insert the updated node.  This allows proper
update of augmented values, subtree_max_end, in the tree.

Reference: https://lkml.org/lkml/2015/10/28/865
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
---
 arch/x86/mm/pat.c        |    2 +-
 arch/x86/mm/pat_rbtree.c |   46 +++++++++++++++++++++++++++++++++++++---------
 2 files changed, 38 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f3e391e..f277efd 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -586,7 +586,7 @@ int free_memtype(u64 start, u64 end)
 	entry = rbt_memtype_erase(start, end);
 	spin_unlock(&memtype_lock);
 
-	if (!entry) {
+	if (IS_ERR(entry)) {
 		pr_info("x86/PAT: %s:%d freeing invalid memtype [mem %#010Lx-%#010Lx]\n",
 			current->comm, current->pid, start, end - 1);
 		return -EINVAL;
diff --git a/arch/x86/mm/pat_rbtree.c b/arch/x86/mm/pat_rbtree.c
index 6393108..d6faef8 100644
--- a/arch/x86/mm/pat_rbtree.c
+++ b/arch/x86/mm/pat_rbtree.c
@@ -98,8 +98,13 @@ static struct memtype *memtype_rb_lowest_match(struct rb_root *root,
 	return last_lower; /* Returns NULL if there is no overlap */
 }
 
-static struct memtype *memtype_rb_exact_match(struct rb_root *root,
-				u64 start, u64 end)
+enum {
+	MEMTYPE_EXACT_MATCH  = 0,
+	MEMTYPE_SHRINK_MATCH = 1
+};
+
+static struct memtype *memtype_rb_match(struct rb_root *root,
+				u64 start, u64 end, int match_type)
 {
 	struct memtype *match;
 
@@ -107,7 +112,12 @@ static struct memtype *memtype_rb_exact_match(struct rb_root *root,
 	while (match != NULL && match->start < end) {
 		struct rb_node *node;
 
-		if (match->start == start && match->end == end)
+		if ((match_type == MEMTYPE_EXACT_MATCH) &&
+		    (match->start == start) && (match->end == end))
+			return match;
+
+		if ((match_type == MEMTYPE_SHRINK_MATCH) &&
+		    (match->start < start) && (match->end == end))
 			return match;
 
 		node = rb_next(&match->rb);
@@ -117,7 +127,7 @@ static struct memtype *memtype_rb_exact_match(struct rb_root *root,
 			match = NULL;
 	}
 
-	return NULL; /* Returns NULL if there is no exact match */
+	return NULL; /* Returns NULL if there is no match */
 }
 
 static int memtype_rb_check_conflict(struct rb_root *root,
@@ -210,12 +220,30 @@ struct memtype *rbt_memtype_erase(u64 start, u64 end)
 {
 	struct memtype *data;
 
-	data = memtype_rb_exact_match(&memtype_rbroot, start, end);
-	if (!data)
-		goto out;
+	/* Exact match takes precedence over shrink match */
+	data = memtype_rb_match(&memtype_rbroot, start, end,
+				MEMTYPE_EXACT_MATCH);
+	if (!data) {
+		data = memtype_rb_match(&memtype_rbroot, start, end,
+					MEMTYPE_SHRINK_MATCH);
+		if (!data)
+			return ERR_PTR(-EINVAL);
+	}
+
+	if (data->start == start) {
+		/* Exact match: erase this node */
+		rb_erase_augmented(&data->rb, &memtype_rbroot,
+					&memtype_rb_augment_cb);
+	} else {
+		/* Shrink match: update the end value of this node */
+		rb_erase_augmented(&data->rb, &memtype_rbroot,
+					&memtype_rb_augment_cb);
+		data->end = start;
+		data->subtree_max_end = data->end;
+		memtype_rb_insert(&memtype_rbroot, data);
+		return NULL;
+	}
 
-	rb_erase_augmented(&data->rb, &memtype_rbroot, &memtype_rb_augment_cb);
-out:
 	return data;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
