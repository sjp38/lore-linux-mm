Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6A8C78E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 19:36:53 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id q207so14271461iod.18
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 16:36:53 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 71sor4872782itw.15.2019.01.11.16.36.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 Jan 2019 16:36:52 -0800 (PST)
From: Blake Caldwell <blake.caldwell@colorado.edu>
Subject: [PATCH 1/4] userfaultfd: UFFDIO_REMAP: rmap preparation
Date: Sat, 12 Jan 2019 00:36:26 +0000
Message-Id: <97a56d8c0d61846bdfa9fa0f8449238781bd5178.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
In-Reply-To: <cover.1547251023.git.blake.caldwell@colorado.edu>
References: <cover.1547251023.git.blake.caldwell@colorado.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: blake.caldwell@colorado.edu
Cc: rppt@linux.vnet.ibm.com, xemul@virtuozzo.com, akpm@linux-foundation.org, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

From: Andrea Arcangeli <aarcange@redhat.com>

As far as the rmap code is concerned, UFFDIO_REMAP only alters the
page->mapping and page->index. It does it while holding the page
lock. However page_referenced() is doing rmap walks without taking the
page lock first, so page_lock_anon_vma_read must be updated to
re-check that the page->mapping didn't change after we obtained the
anon_vma read lock.

UFFDIO_REMAP takes the anon_vma lock for writing before altering the
page->mapping, so if the page->mapping is still the same after
obtaining the anon_vma read lock (without the page lock), the rmap
walks can go ahead safely (and UFFDIO_REMAP will wait the rmap walk to
complete before proceeding).

UFFDIO_REMAP serializes against itself with the page lock.

All other places taking the anon_vma lock while holding the mmap_sem
for writing, don't need to check if the page->mapping has changed
after taking the anon_vma lock, regardless of the page lock, because
UFFDIO_REMAP holds the mmap_sem for reading.

There's one constraint enforced to allow this simplification: the
source pages passed to UFFDIO_REMAP must be mapped only in one vma,
but this constraint is an acceptable tradeoff for UFFDIO_REMAP
users.

The source addresses passed to UFFDIO_REMAP should be set as
VM_DONTCOPY with MADV_DONTFORK to avoid any risk of the mapcount of
the pages increasing if some thread of the process forks() before
UFFDIO_REMAP run.

Acked-by: Pavel Emelyanov <xemul@virtuozzo.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/rmap.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/mm/rmap.c b/mm/rmap.c
index 0454ecc2..d8f228d 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -510,6 +510,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	struct anon_vma *root_anon_vma;
 	unsigned long anon_mapping;
 
+repeat:
 	rcu_read_lock();
 	anon_mapping = (unsigned long)READ_ONCE(page->mapping);
 	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
@@ -548,6 +549,18 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	rcu_read_unlock();
 	anon_vma_lock_read(anon_vma);
 
+	/*
+	 * Check if UFFDIO_REMAP changed the anon_vma. This is needed
+	 * because we don't assume the page was locked.
+	 */
+	if (unlikely((unsigned long) READ_ONCE(page->mapping) !=
+		     anon_mapping)) {
+		anon_vma_unlock_read(anon_vma);
+		put_anon_vma(anon_vma);
+		anon_vma = NULL;
+		goto repeat;
+	}
+
 	if (atomic_dec_and_test(&anon_vma->refcount)) {
 		/*
 		 * Oops, we held the last refcount, release the lock
-- 
1.8.3.1
