Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5D76B0072
	for <linux-mm@kvack.org>; Tue, 16 Dec 2014 11:18:38 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id k14so1678582wgh.1
        for <linux-mm@kvack.org>; Tue, 16 Dec 2014 08:18:37 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t5si3563157wiz.88.2014.12.16.08.18.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Dec 2014 08:18:37 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memory: remove ->vm_file check on shared writable vmas
Date: Tue, 16 Dec 2014 11:18:10 -0500
Message-Id: <1418746691-326-3-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
References: <1418746691-326-1-git-send-email-hannes@cmpxchg.org>
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
index 4c06cdcd36cf..d5a303cf2901 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2155,9 +2155,7 @@ reuse:
 				balance_dirty_pages_ratelimited(mapping);
 			}
 
-			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
+			file_update_time(vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
@@ -3013,8 +3011,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
