Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id EE8B36B006C
	for <linux-mm@kvack.org>; Fri,  5 Dec 2014 17:11:49 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id tp5so1592881ieb.37
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 14:11:49 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bq4si49769291wjc.138.2014.12.05.06.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Dec 2014 06:52:54 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memory: remove ->vm_file check on shared writable vmas
Date: Fri,  5 Dec 2014 09:52:45 -0500
Message-Id: <1417791166-32226-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1417791166-32226-1-git-send-email-hannes@cmpxchg.org>
References: <1417791166-32226-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Shared anonymous mmaps are implemented with shmem files, so all VMAs
with shared writable semantics also have an underlying backing file.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Jan Kara <jack@suse.cz>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 72d998eb0438..5640a718ac58 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2168,9 +2168,7 @@ reuse:
 				balance_dirty_pages_ratelimited(mapping);
 			}
 
-			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
+			file_update_time(vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
@@ -3026,8 +3024,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		balance_dirty_pages_ratelimited(mapping);
 	}
 
-	/* file_update_time outside page_lock */
-	if (vma->vm_file && !vma->vm_ops->page_mkwrite)
+	if (!vma->vm_ops->page_mkwrite)
 		file_update_time(vma->vm_file);
 
 	return ret;
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
