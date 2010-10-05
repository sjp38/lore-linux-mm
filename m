Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id D8D116B007B
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 03:53:58 -0400 (EDT)
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id o957ruLU014266
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:56 -0700
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by kpbe11.cbf.corp.google.com with ESMTP id o957rtai002880
	for <linux-mm@kvack.org>; Tue, 5 Oct 2010 00:53:55 -0700
Received: by pvg2 with SMTP id 2so1539080pvg.19
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 00:53:55 -0700 (PDT)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/3] filemap_fault: unique path for locking page
Date: Tue,  5 Oct 2010 00:53:33 -0700
Message-Id: <1286265215-9025-2-git-send-email-walken@google.com>
In-Reply-To: <1286265215-9025-1-git-send-email-walken@google.com>
References: <1286265215-9025-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Ying Han <yinghan@google.com>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

This change introduces a single location where filemap_fault() locks
the desired page. There used to be two such places, depending if the
initial find_get_page() was successful or not.

Signed-off-by: Michel Lespinasse <walken@google.com>
---
 mm/filemap.c |   20 +++++++++++---------
 1 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 3d4df44..8ed709a 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1539,25 +1539,27 @@ int filemap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 		 * waiting for the lock.
 		 */
 		do_async_mmap_readahead(vma, ra, file, page, offset);
-		lock_page(page);
-
-		/* Did it get truncated? */
-		if (unlikely(page->mapping != mapping)) {
-			unlock_page(page);
-			put_page(page);
-			goto no_cached_page;
-		}
 	} else {
 		/* No page in the page cache at all */
 		do_sync_mmap_readahead(vma, ra, file, offset);
 		count_vm_event(PGMAJFAULT);
 		ret = VM_FAULT_MAJOR;
 retry_find:
-		page = find_lock_page(mapping, offset);
+		page = find_get_page(mapping, offset);
 		if (!page)
 			goto no_cached_page;
 	}
 
+	lock_page(page);
+
+	/* Did it get truncated? */
+	if (unlikely(page->mapping != mapping)) {
+		unlock_page(page);
+		put_page(page);
+		goto retry_find;
+	}
+	VM_BUG_ON(page->index != offset);
+
 	/*
 	 * We have a locked page in the page cache, now we need to check
 	 * that it's up-to-date. If not, it is going to be due to an error.
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
