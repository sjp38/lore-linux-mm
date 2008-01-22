From: Anton Salikhmetov <salikhmetov@gmail.com>
Subject: [PATCH -v8 2/4] Update ctime and mtime for memory-mapped files
Date: Wed, 23 Jan 2008 02:21:18 +0300
Message-Id: <12010440822957-git-send-email-salikhmetov@gmail.com>
In-Reply-To: <12010440803930-git-send-email-salikhmetov@gmail.com>
References: <12010440803930-git-send-email-salikhmetov@gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, a.p.zijlstra@chello.nl, akpm@linux-foundation.org, protasnb@gmail.com, miklos@szeredi.hu, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Update ctime and mtime for memory-mapped files at a write access on
a present, read-only PTE, as well as at a write on a non-present PTE.

Signed-off-by: Anton Salikhmetov <salikhmetov@gmail.com>
---
 mm/memory.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 6dd1cd8..4b0144b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1670,6 +1670,9 @@ gotten:
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
+
 		/*
 		 * Yes, Virginia, this is actually required to prevent a race
 		 * with clear_page_dirty_for_io() from clearing the page dirty
@@ -2343,6 +2346,9 @@ out_unlocked:
 	if (anon)
 		page_cache_release(vmf.page);
 	else if (dirty_page) {
+		if (vma->vm_file)
+			file_update_time(vma->vm_file);
+
 		set_page_dirty_balance(dirty_page, page_mkwrite);
 		put_page(dirty_page);
 	}
-- 
1.4.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
