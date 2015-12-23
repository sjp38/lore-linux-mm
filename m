Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f175.google.com (mail-io0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id 01FE382F64
	for <linux-mm@kvack.org>; Tue, 22 Dec 2015 19:54:50 -0500 (EST)
Received: by mail-io0-f175.google.com with SMTP id 186so205565086iow.0
        for <linux-mm@kvack.org>; Tue, 22 Dec 2015 16:54:49 -0800 (PST)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id x4si36956606igl.23.2015.12.22.16.54.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Dec 2015 16:54:49 -0800 (PST)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH v2 2/2] x86/mm/pat: Change free_memtype() to support shrinking case
Date: Tue, 22 Dec 2015 17:54:24 -0700
Message-Id: <1450832064-10093-3-git-send-email-toshi.kani@hpe.com>
In-Reply-To: <1450832064-10093-1-git-send-email-toshi.kani@hpe.com>
References: <1450832064-10093-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, bp@alien8.de
Cc: stsp@list.ru, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Borislav Petkov <bp@suse.de>, Toshi Kani <toshi.kani@hpe.com>

Using mremap() to shrink the map size of a VM_PFNMAP range causes
the following error message, and leaves the pfn range allocated.

 x86/PAT: test:3493 freeing invalid memtype [mem 0x483200000-0x4863fffff]

This is because rbt_memtype_erase(), called from free_memtype()
with spin_lock held, only supports to free a whole memtype node in
memtype_rbroot.  Therefore, this patch changes rbt_memtype_erase()
to support a request that shrinks the size of a memtype node for
mremap().

memtype_rb_exact_match() is renamed to memtype_rb_match(), and
is enhanced to support EXACT_MATCH and END_MATH in @match_type.
Since the memtype_rbroot tree allows overlapping ranges,
rbt_memtype_erase() checks with EXACT_MATCH first, i.e. free
a whole node for the munmap case.  If no such entry is found,
it then checks with END_MATCH, i.e. shrink the size of a node
from the end for the mremap case.

On the mremap case, rbt_memtype_erase() proceeds in two steps,
1) remove the node, and then 2) insert the updated node.  This
allows proper update of augmented values, subtree_max_end, in
the tree.

Link: http://lkml.kernel.org/r/<1446072663.20657.150.camel@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Borislav Petkov <bp@suse.de>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
---
 arch/x86/mm/pat.c        |    2 +-
 arch/x86/mm/pat_rbtree.c |   52 ++++++++++++++++++++++++++++++++++++++--------
 2 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 1aca073..031782e 100644
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
index 6393108..2f77022 100644
--- a/arch/x86/mm/pat_rbtree.c
+++ b/arch/x86/mm/pat_rbtree.c
@@ -98,8 +98,13 @@ static struct memtype *memtype_rb_lowest_match(struct rb_root *root,
 	return last_lower; /* Returns NULL if there is no overlap */
 }
 
-static struct memtype *memtype_rb_exact_match(struct rb_root *root,
-				u64 start, u64 end)
+enum {
+	MEMTYPE_EXACT_MATCH	= 0,
+	MEMTYPE_END_MATCH	= 1
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
+		if ((match_type == MEMTYPE_END_MATCH) &&
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
@@ -210,12 +220,36 @@ struct memtype *rbt_memtype_erase(u64 start, u64 end)
 {
 	struct memtype *data;
 
-	data = memtype_rb_exact_match(&memtype_rbroot, start, end);
-	if (!data)
-		goto out;
+	/*
+	 * Since the memtype_rbroot tree allows overlapping ranges,
+	 * rbt_memtype_erase() checks with EXACT_MATCH first, i.e. free
+	 * a whole node for the munmap case.  If no such entry is found,
+	 * it then checks with END_MATCH, i.e. shrink the size of a node
+	 * from the end for the mremap case.
+	 */
+	data = memtype_rb_match(&memtype_rbroot, start, end,
+				MEMTYPE_EXACT_MATCH);
+	if (!data) {
+		data = memtype_rb_match(&memtype_rbroot, start, end,
+					MEMTYPE_END_MATCH);
+		if (!data)
+			return ERR_PTR(-EINVAL);
+	}
+
+	if (data->start == start) {
+		/* munmap: erase this node */
+		rb_erase_augmented(&data->rb, &memtype_rbroot,
+					&memtype_rb_augment_cb);
+	} else {
+		/* mremap: update the end value of this node */
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
