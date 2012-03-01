Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id EB35E6B00E7
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 06:41:57 -0500 (EST)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH 9/9] mm: Update file times from fault path only if .page_mkwrite is not set
Date: Thu,  1 Mar 2012 12:41:43 +0100
Message-Id: <1330602103-8851-10-git-send-email-jack@suse.cz>
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jan Kara <jack@suse.cz>

Filesystems wanting to properly support freezing need to have control
when file_update_time() is called. After pushing file_update_time()
to all relevant .page_mkwrite implementations we can just stop calling
file_update_time() when filesystem implements .page_mkwrite.

Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/memory.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index fa2f04e..1dfe9a1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2621,6 +2621,9 @@ reuse:
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
 			set_page_dirty_balance(dirty_page, page_mkwrite);
+			/* file_update_time outside page_lock */
+			if (vma->vm_file)
+				file_update_time(vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
@@ -2638,10 +2641,6 @@ reuse:
 			}
 		}
 
-		/* file_update_time outside page_lock */
-		if (vma->vm_file)
-			file_update_time(vma->vm_file);
-
 		return ret;
 	}
 
@@ -3310,12 +3309,13 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 
 	if (dirty_page) {
 		struct address_space *mapping = page->mapping;
+		int dirtied = 0;
 
 		if (set_page_dirty(dirty_page))
-			page_mkwrite = 1;
+			dirtied = 1;
 		unlock_page(dirty_page);
 		put_page(dirty_page);
-		if (page_mkwrite && mapping) {
+		if ((dirtied || page_mkwrite) && mapping) {
 			/*
 			 * Some device drivers do not set page.mapping but still
 			 * dirty their pages
@@ -3324,7 +3324,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		}
 
 		/* file_update_time outside page_lock */
-		if (vma->vm_file)
+		if (vma->vm_file && !page_mkwrite)
 			file_update_time(vma->vm_file);
 	} else {
 		unlock_page(vmf.page);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
