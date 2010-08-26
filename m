Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C2AD36B01F0
	for <linux-mm@kvack.org>; Thu, 26 Aug 2010 02:13:03 -0400 (EDT)
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o7Q6D1NM005691
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:13:01 -0700
Received: from pwi8 (pwi8.prod.google.com [10.241.219.8])
	by kpbe18.cbf.corp.google.com with ESMTP id o7Q6CxID028082
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:13:00 -0700
Received: by pwi8 with SMTP id 8so691343pwi.13
        for <linux-mm@kvack.org>; Wed, 25 Aug 2010 23:12:59 -0700 (PDT)
Date: Wed, 25 Aug 2010 23:12:54 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix hang on anon_vma->root->lock
Message-ID: <alpine.LSU.2.00.1008252305540.19107@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

After several hours, kbuild tests hang with anon_vma_prepare() spinning on
a newly allocated anon_vma's lock - on a box with CONFIG_TREE_PREEMPT_RCU=y
(which makes this very much more likely, but it could happen without).

The ever-subtle page_lock_anon_vma() now needs a further twist: since
anon_vma_prepare() and anon_vma_fork() are liable to change the ->root
of a reused anon_vma structure at any moment, page_lock_anon_vma()
needs to check page_mapped() again before succeeding, otherwise
page_unlock_anon_vma() might address a different root->lock.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/rmap.c |   19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

--- 2.6.36-rc2/mm/rmap.c	2010-08-16 00:18:01.000000000 -0700
+++ linux/mm/rmap.c	2010-08-24 03:22:17.000000000 -0700
@@ -316,7 +316,7 @@ void __init anon_vma_init(void)
  */
 struct anon_vma *page_lock_anon_vma(struct page *page)
 {
-	struct anon_vma *anon_vma;
+	struct anon_vma *anon_vma, *root_anon_vma;
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
@@ -327,8 +327,21 @@ struct anon_vma *page_lock_anon_vma(stru
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	anon_vma_lock(anon_vma);
-	return anon_vma;
+	root_anon_vma = ACCESS_ONCE(anon_vma->root);
+	spin_lock(&root_anon_vma->lock);
+
+	/*
+	 * If this page is still mapped, then its anon_vma cannot have been
+	 * freed.  But if it has been unmapped, we have no security against
+	 * the anon_vma structure being freed and reused (for another anon_vma:
+	 * SLAB_DESTROY_BY_RCU guarantees that - so the spin_lock above cannot
+	 * corrupt): with anon_vma_prepare() or anon_vma_fork() redirecting
+	 * anon_vma->root before page_unlock_anon_vma() is called to unlock.
+	 */
+	if (page_mapped(page))
+		return anon_vma;
+
+	spin_unlock(&root_anon_vma->lock);
 out:
 	rcu_read_unlock();
 	return NULL;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
