Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id D9CBA6B0031
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 13:11:52 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mz12so1678963bkb.30
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 10:11:52 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id xw1si4461623bkb.278.2014.01.10.10.11.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 10:11:51 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 3/9] mm: shmem: save one radix tree lookup when truncating swapped pages
Date: Fri, 10 Jan 2014 13:10:37 -0500
Message-Id: <1389377443-11755-4-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Page cache radix tree slots are usually stabilized by the page lock,
but shmem's swap cookies have no such thing.  Because the overall
truncation loop is lockless, the swap entry is currently confirmed by
a tree lookup and then deleted by another tree lookup under the same
tree lock region.

Use radix_tree_delete_item() instead, which does the verification and
deletion with only one lookup.  This also allows removing the
delete-only special case from shmem_radix_tree_replace().

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Minchan Kim <minchan@kernel.org>
---
 mm/shmem.c | 25 ++++++++++++-------------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8297623fcaed..7c67249d6f28 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -242,19 +242,17 @@ static int shmem_radix_tree_replace(struct address_space *mapping,
 			pgoff_t index, void *expected, void *replacement)
 {
 	void **pslot;
-	void *item = NULL;
+	void *item;
 
 	VM_BUG_ON(!expected);
+	VM_BUG_ON(!replacement);
 	pslot = radix_tree_lookup_slot(&mapping->page_tree, index);
-	if (pslot)
-		item = radix_tree_deref_slot_protected(pslot,
-							&mapping->tree_lock);
+	if (!pslot)
+		return -ENOENT;
+	item = radix_tree_deref_slot_protected(pslot, &mapping->tree_lock);
 	if (item != expected)
 		return -ENOENT;
-	if (replacement)
-		radix_tree_replace_slot(pslot, replacement);
-	else
-		radix_tree_delete(&mapping->page_tree, index);
+	radix_tree_replace_slot(pslot, replacement);
 	return 0;
 }
 
@@ -386,14 +384,15 @@ export:
 static int shmem_free_swap(struct address_space *mapping,
 			   pgoff_t index, void *radswap)
 {
-	int error;
+	void *old;
 
 	spin_lock_irq(&mapping->tree_lock);
-	error = shmem_radix_tree_replace(mapping, index, radswap, NULL);
+	old = radix_tree_delete_item(&mapping->page_tree, index, radswap);
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!error)
-		free_swap_and_cache(radix_to_swp_entry(radswap));
-	return error;
+	if (old != radswap)
+		return -ENOENT;
+	free_swap_and_cache(radix_to_swp_entry(radswap));
+	return 0;
 }
 
 /*
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
