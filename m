Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 3E83F6B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:17:03 -0400 (EDT)
Date: Wed, 15 Sep 2010 19:16:57 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] fix rmap walk during fork
Message-ID: <20100915171657.GP5981@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

The below bug in fork lead to the rmap walk finding the parent huge-pmd twice
instead of just one, because the anon_vma_chain objects of the child vma still
point to the vma->vm_mm of the parent. The below patch fixes it by making the
rmap walk accurate during fork. It's not a big deal normally but it
worth being accurate considering the cost is the same.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -360,10 +360,10 @@ static int dup_mmap(struct mm_struct *mm
 		if (IS_ERR(pol))
 			goto fail_nomem_policy;
 		vma_set_policy(tmp, pol);
+		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
 		tmp->vm_flags &= ~VM_LOCKED;
-		tmp->vm_mm = mm;
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
