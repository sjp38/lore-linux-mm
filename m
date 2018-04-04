Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 14F656B0289
	for <linux-mm@kvack.org>; Wed,  4 Apr 2018 15:19:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id d12so9817939qki.17
        for <linux-mm@kvack.org>; Wed, 04 Apr 2018 12:19:38 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id x123si6343858qke.473.2018.04.04.12.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Apr 2018 12:19:31 -0700 (PDT)
From: jglisse@redhat.com
Subject: [RFC PATCH 73/79] mm: pass down struct address_space to set_page_dirty()
Date: Wed,  4 Apr 2018 15:18:25 -0400
Message-Id: <20180404191831.5378-36-jglisse@redhat.com>
In-Reply-To: <20180404191831.5378-1-jglisse@redhat.com>
References: <20180404191831.5378-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Tejun Heo <tj@kernel.org>, Jan Kara <jack@suse.cz>, Josef Bacik <jbacik@fb.com>, Mel Gorman <mgorman@techsingularity.net>

From: JA(C)rA'me Glisse <jglisse@redhat.com>

Pass down struct address_space to set_page_dirty() everywhere it is
already available.

<---------------------------------------------------------------------
@exists@
expression E;
identifier F, M;
@@
F(..., struct address_space * M, ...) {
...
-set_page_dirty(NULL, E)
+set_page_dirty(M, E)
...
}

@exists@
expression E;
identifier M;
@@
struct address_space * M;
...
-set_page_dirty(NULL, E)
+set_page_dirty(M, E)

@exists@
expression E;
identifier F, I;
@@
F(..., struct inode * I, ...) {
...
-set_page_dirty(NULL, E)
+set_page_dirty(I->i_mapping, E)
...
}

@exists@
expression E;
identifier I;
@@
struct inode * I;
...
-set_page_dirty(NULL, E)
+set_page_dirty(I->i_mapping, E)
--------------------------------------------------------------------->

Signed-off-by: JA(C)rA'me Glisse <jglisse@redhat.com>
CC: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux-fsdevel@vger.kernel.org
Cc: Tejun Heo <tj@kernel.org>
Cc: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <jbacik@fb.com>
Cc: Mel Gorman <mgorman@techsingularity.net>
---
 mm/filemap.c        |  2 +-
 mm/khugepaged.c     |  2 +-
 mm/memory.c         |  2 +-
 mm/page-writeback.c |  4 ++--
 mm/page_io.c        |  4 ++--
 mm/shmem.c          | 18 +++++++++---------
 mm/truncate.c       |  2 +-
 7 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c1ee7431bc4d..a15c29350a6a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2717,7 +2717,7 @@ int filemap_page_mkwrite(struct vm_fault *vmf)
 	 * progress, we are guaranteed that writeback during freezing will
 	 * see the dirty page and writeprotect it again.
 	 */
-	set_page_dirty(NULL, page);
+	set_page_dirty(inode->i_mapping, page);
 	wait_for_stable_page(page);
 out:
 	sb_end_pagefault(inode->i_sb);
diff --git a/mm/khugepaged.c b/mm/khugepaged.c
index ccd5da4e855f..b9a968172fb9 100644
--- a/mm/khugepaged.c
+++ b/mm/khugepaged.c
@@ -1513,7 +1513,7 @@ static void collapse_shmem(struct mm_struct *mm,
 		retract_page_tables(mapping, start);
 
 		/* Everything is ready, let's unfreeze the new_page */
-		set_page_dirty(NULL, new_page);
+		set_page_dirty(mapping, new_page);
 		SetPageUptodate(new_page);
 		page_ref_unfreeze(new_page, HPAGE_PMD_NR);
 		mem_cgroup_commit_charge(new_page, memcg, false, true);
diff --git a/mm/memory.c b/mm/memory.c
index 20443ebf9c42..fbd80bb7a50a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2400,7 +2400,7 @@ static void fault_dirty_shared_page(struct vm_area_struct *vma,
 	bool dirtied;
 	bool page_mkwrite = vma->vm_ops && vma->vm_ops->page_mkwrite;
 
-	dirtied = set_page_dirty(NULL, page);
+	dirtied = set_page_dirty(mapping, page);
 	VM_BUG_ON_PAGE(PageAnon(page), page);
 	/*
 	 * Take a local copy of the address_space - page.mapping may be zeroed
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index eaa6c23ba752..59dc9a12efc7 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -2599,7 +2599,7 @@ int set_page_dirty_lock(struct address_space *_mapping, struct page *page)
 	int ret;
 
 	lock_page(page);
-	ret = set_page_dirty(NULL, page);
+	ret = set_page_dirty(_mapping, page);
 	unlock_page(page);
 	return ret;
 }
@@ -2693,7 +2693,7 @@ int clear_page_dirty_for_io(struct page *page)
 		 * threads doing their things.
 		 */
 		if (page_mkclean(page))
-			set_page_dirty(NULL, page);
+			set_page_dirty(mapping, page);
 		/*
 		 * We carefully synchronise fault handlers against
 		 * installing a dirty pte and marking the page dirty
diff --git a/mm/page_io.c b/mm/page_io.c
index 5afc8b8a6b97..fd3133cd50d4 100644
--- a/mm/page_io.c
+++ b/mm/page_io.c
@@ -329,7 +329,7 @@ int __swap_writepage(struct address_space *mapping, struct page *page,
 			 * the normal direct-to-bio case as it could
 			 * be temporary.
 			 */
-			set_page_dirty(NULL, page);
+			set_page_dirty(mapping, page);
 			ClearPageReclaim(page);
 			pr_err_ratelimited("Write error on dio swapfile (%llu)\n",
 					   page_file_offset(page));
@@ -348,7 +348,7 @@ int __swap_writepage(struct address_space *mapping, struct page *page,
 	ret = 0;
 	bio = get_swap_bio(GFP_NOIO, page, end_write_func);
 	if (bio == NULL) {
-		set_page_dirty(NULL, page);
+		set_page_dirty(mapping, page);
 		unlock_page(page);
 		ret = -ENOMEM;
 		goto out;
diff --git a/mm/shmem.c b/mm/shmem.c
index cb09fea4a9ce..eae03f684869 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -874,7 +874,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 				partial_end = 0;
 			}
 			zero_user_segment(page, partial_start, top);
-			set_page_dirty(NULL, page);
+			set_page_dirty(mapping, page);
 			unlock_page(page);
 			put_page(page);
 		}
@@ -884,7 +884,7 @@ static void shmem_undo_range(struct inode *inode, loff_t lstart, loff_t lend,
 		shmem_getpage(inode, end, &page, SGP_READ);
 		if (page) {
 			zero_user_segment(page, 0, partial_end);
-			set_page_dirty(NULL, page);
+			set_page_dirty(mapping, page);
 			unlock_page(page);
 			put_page(page);
 		}
@@ -1189,7 +1189,7 @@ static int shmem_unuse_inode(struct shmem_inode_info *info,
 		 * only does trylock page: if we raced, best clean up here.
 		 */
 		delete_from_swap_cache(*pagep);
-		set_page_dirty(NULL, *pagep);
+		set_page_dirty(mapping, *pagep);
 		if (!error) {
 			spin_lock_irq(&info->lock);
 			info->swapped--;
@@ -1364,7 +1364,7 @@ static int shmem_writepage(struct address_space *_mapping, struct page *page,
 free_swap:
 	put_swap_page(page, swap);
 redirty:
-	set_page_dirty(NULL, page);
+	set_page_dirty(_mapping, page);
 	if (wbc->for_reclaim)
 		return AOP_WRITEPAGE_ACTIVATE;	/* Return with page locked */
 	unlock_page(page);
@@ -1738,7 +1738,7 @@ static int shmem_getpage_gfp(struct inode *inode, pgoff_t index,
 			mark_page_accessed(page);
 
 		delete_from_swap_cache(page);
-		set_page_dirty(NULL, page);
+		set_page_dirty(mapping, page);
 		swap_free(swap);
 
 	} else {
@@ -2416,7 +2416,7 @@ shmem_write_end(struct file *file, struct address_space *mapping,
 		}
 		SetPageUptodate(head);
 	}
-	set_page_dirty(NULL, page);
+	set_page_dirty(mapping, page);
 	unlock_page(page);
 	put_page(page);
 
@@ -2469,7 +2469,7 @@ static ssize_t shmem_file_read_iter(struct kiocb *iocb, struct iov_iter *to)
 		}
 		if (page) {
 			if (sgp == SGP_CACHE)
-				set_page_dirty(NULL, page);
+				set_page_dirty(mapping, page);
 			unlock_page(page);
 		}
 
@@ -2970,7 +2970,7 @@ static long shmem_fallocate(struct file *file, int mode, loff_t offset,
 		 * than free the pages we are allocating (and SGP_CACHE pages
 		 * might still be clean: we now need to mark those dirty too).
 		 */
-		set_page_dirty(NULL, page);
+		set_page_dirty(inode->i_mapping, page);
 		unlock_page(page);
 		put_page(page);
 		cond_resched();
@@ -3271,7 +3271,7 @@ static int shmem_symlink(struct inode *dir, struct dentry *dentry, const char *s
 		inode->i_op = &shmem_symlink_inode_operations;
 		memcpy(page_address(page), symname, len);
 		SetPageUptodate(page);
-		set_page_dirty(NULL, page);
+		set_page_dirty(dir->i_mapping, page);
 		unlock_page(page);
 		put_page(page);
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index 78d907008367..f4f018f35552 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -874,7 +874,7 @@ void pagecache_isize_extended(struct inode *inode, loff_t from, loff_t to)
 	 * is needed.
 	 */
 	if (page_mkclean(page))
-		set_page_dirty(NULL, page);
+		set_page_dirty(inode->i_mapping, page);
 	unlock_page(page);
 	put_page(page);
 }
-- 
2.14.3
