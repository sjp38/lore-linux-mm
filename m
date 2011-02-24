Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 656F48D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 00:39:53 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p1O5dnYh026954
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:39:49 -0800
Received: from gwb15 (gwb15.prod.google.com [10.200.2.15])
	by kpbe19.cbf.corp.google.com with ESMTP id p1O5dIvb032571
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:39:48 -0800
Received: by gwb15 with SMTP id 15so128099gwb.38
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:39:47 -0800 (PST)
Date: Wed, 23 Feb 2011 21:39:49 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix possible cause of a page_mapped BUG
Message-ID: <alpine.LSU.2.00.1102232136020.2239@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Robert Swiecki <robert@swiecki.net>, Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Robert Swiecki reported a BUG_ON(page_mapped) from a fuzzer, punching
a hole with madvise(,, MADV_REMOVE).  That path is under mutex, and
cannot be explained by lack of serialization in unmap_mapping_range().

Reviewing the code, I found one place where vm_truncate_count handling
should have been updated, when I switched at the last minute from one
way of managing the restart_addr to another: mremap move changes the
virtual addresses, so it ought to adjust the restart_addr.

But rather than exporting the notion of restart_addr from memory.c, or
converting to restart_pgoff throughout, simply reset vm_truncate_count
to 0 to force a rescan if mremap move races with preempted truncation.

We have no confirmation that this fixes Robert's BUG,
but it is a fix that's worth making anyway.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/mremap.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- 2.6.38-rc6/mm/mremap.c	2011-01-18 22:04:56.000000000 -0800
+++ linux/mm/mremap.c	2011-02-23 15:29:52.000000000 -0800
@@ -94,9 +94,7 @@ static void move_ptes(struct vm_area_str
 		 */
 		mapping = vma->vm_file->f_mapping;
 		spin_lock(&mapping->i_mmap_lock);
-		if (new_vma->vm_truncate_count &&
-		    new_vma->vm_truncate_count != vma->vm_truncate_count)
-			new_vma->vm_truncate_count = 0;
+		new_vma->vm_truncate_count = 0;
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
