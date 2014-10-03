Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id E19606B0069
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 14:01:24 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id f12so1175652qad.36
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 11:01:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c6si13440668qag.131.2014.10.03.11.01.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 11:01:24 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 10/17] mm: rmap preparation for remap_anon_pages
Date: Fri,  3 Oct 2014 19:08:00 +0200
Message-Id: <1412356087-16115-11-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

remap_anon_pages (unlike remap_file_pages) tries to be non intrusive
in the rmap code.

As far as the rmap code is concerned, rmap_anon_pages only alters the
page->mapping and page->index. It does it while holding the page
lock. However there are a few places that in presence of anon pages
are allowed to do rmap walks without the page lock (split_huge_page
and page_referenced_anon). Those places that are doing rmap walks
without taking the page lock first, must be updated to re-check that
the page->mapping didn't change after they obtained the anon_vma
lock. remap_anon_pages takes the anon_vma lock for writing before
altering the page->mapping, so if the page->mapping is still the same
after obtaining the anon_vma lock (without the page lock), the rmap
walks can go ahead safely (and remap_anon_pages will wait them to
complete before proceeding).

remap_anon_pages serializes against itself with the page lock.

All other places taking the anon_vma lock while holding the mmap_sem
for writing, don't need to check if the page->mapping has changed
after taking the anon_vma lock, regardless of the page lock, because
remap_anon_pages holds the mmap_sem for reading.

Overall this looks a fairly small change to the rmap code, notably
less intrusive than the nonlinear vmas created by remap_file_pages.

There's one constraint enforced to allow this simplification: the
source pages passed to remap_anon_pages must be mapped only in one
vma, but this is not a limitation when used to handle userland page
faults with MADV_USERFAULT. The source addresses passed to
remap_anon_pages should be set as VM_DONTCOPY with MADV_DONTFORK to
avoid any risk of the mapcount of the pages increasing, if fork runs
in parallel in another thread, before or while remap_anon_pages runs.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c | 24 ++++++++++++++++++++----
 mm/rmap.c        |  9 +++++++++
 2 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b402d60..4277ed7 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1921,6 +1921,7 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 {
 	struct anon_vma *anon_vma;
 	int ret = 1;
+	struct address_space *mapping;
 
 	BUG_ON(is_huge_zero_page(page));
 	BUG_ON(!PageAnon(page));
@@ -1932,10 +1933,24 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 	 * page_lock_anon_vma_read except the write lock is taken to serialise
 	 * against parallel split or collapse operations.
 	 */
-	anon_vma = page_get_anon_vma(page);
-	if (!anon_vma)
-		goto out;
-	anon_vma_lock_write(anon_vma);
+	for (;;) {
+		mapping = ACCESS_ONCE(page->mapping);
+		anon_vma = page_get_anon_vma(page);
+		if (!anon_vma)
+			goto out;
+		anon_vma_lock_write(anon_vma);
+		/*
+		 * We don't hold the page lock here so
+		 * remap_anon_pages_huge_pmd can change the anon_vma
+		 * from under us until we obtain the anon_vma
+		 * lock. Verify that we obtained the anon_vma lock
+		 * before remap_anon_pages did.
+		 */
+		if (likely(mapping == ACCESS_ONCE(page->mapping)))
+			break;
+		anon_vma_unlock_write(anon_vma);
+		put_anon_vma(anon_vma);
+	}
 
 	ret = 0;
 	if (!PageCompound(page))
@@ -2460,6 +2475,7 @@ static void collapse_huge_page(struct mm_struct *mm,
 	 * Prevent all access to pagetables with the exception of
 	 * gup_fast later hanlded by the ptep_clear_flush and the VM
 	 * handled by the anon_vma lock + PG_lock.
+	 * remap_anon_pages is prevented to race as well by the mmap_sem.
 	 */
 	down_write(&mm->mmap_sem);
 	if (unlikely(khugepaged_test_exit(mm)))
diff --git a/mm/rmap.c b/mm/rmap.c
index 3e8491c..6d875eb 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -450,6 +450,7 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	struct anon_vma *root_anon_vma;
 	unsigned long anon_mapping;
 
+repeat:
 	rcu_read_lock();
 	anon_mapping = (unsigned long) ACCESS_ONCE(page->mapping);
 	if ((anon_mapping & PAGE_MAPPING_FLAGS) != PAGE_MAPPING_ANON)
@@ -488,6 +489,14 @@ struct anon_vma *page_lock_anon_vma_read(struct page *page)
 	rcu_read_unlock();
 	anon_vma_lock_read(anon_vma);
 
+	/* check if remap_anon_pages changed the anon_vma */
+	if (unlikely((unsigned long) ACCESS_ONCE(page->mapping) != anon_mapping)) {
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
