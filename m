Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id AB2226B0008
	for <linux-mm@kvack.org>; Fri,  1 Feb 2013 01:10:20 -0500 (EST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch] mm: mlock: document scary-looking stack expansion mlock chain
Date: Fri,  1 Feb 2013 01:10:13 -0500
Message-Id: <1359699013-7160-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The fact that mlock calls get_user_pages, and get_user_pages might
call mlock when expanding a stack looks like a potential recursion.

However, mlock makes sure the requested range is already contained
within a vma, so no stack expansion will actually happen from mlock.

Should this ever change: the stack expansion mlocks only the newly
expanded range and so will not result in recursive expansion.

Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/mlock.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/mm/mlock.c b/mm/mlock.c
index b1647fb..78c4924 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -185,6 +185,10 @@ long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	if (vma->vm_flags & (VM_READ | VM_WRITE | VM_EXEC))
 		gup_flags |= FOLL_FORCE;
 
+	/*
+	 * We made sure addr is within a VMA, so the following will
+	 * not result in a stack expansion that recurses back here.
+	 */
 	return __get_user_pages(current, mm, addr, nr_pages, gup_flags,
 				NULL, NULL, nonblocking);
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
