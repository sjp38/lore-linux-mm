Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 0A9246B006C
	for <linux-mm@kvack.org>; Mon,  1 Dec 2014 17:58:09 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id b13so15699293wgh.31
        for <linux-mm@kvack.org>; Mon, 01 Dec 2014 14:58:08 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id po7si32447844wjc.0.2014.12.01.14.58.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Dec 2014 14:58:08 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 2/3] mm: memory: remove ->vm_file check on shared writable vmas
Date: Mon,  1 Dec 2014 17:58:01 -0500
Message-Id: <1417474682-29326-2-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
References: <1417474682-29326-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

The only way a VMA can have shared and writable semantics is with a
backing file.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/memory.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 73220eb6e9e3..2a2e3648ed65 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2167,9 +2167,7 @@ reuse:
 				balance_dirty_pages_ratelimited(mapping);
 			}
 
-			/* file_update_time outside page_lock */
-			if (vma->vm_file)
-				file_update_time(vma->vm_file);
+			file_update_time(vma->vm_file);
 		}
 		put_page(dirty_page);
 		if (page_mkwrite) {
@@ -3025,8 +3023,7 @@ static int do_shared_fault(struct mm_struct *mm, struct vm_area_struct *vma,
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
