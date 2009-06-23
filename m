Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6FD186B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:51:17 -0400 (EDT)
Date: Tue, 23 Jun 2009 13:52:49 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] mm: don't rely on flags coincidence
In-Reply-To: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0906231349250.19552@sister.anvils>
References: <alpine.LFD.2.01.0906211331480.3240@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Indeed FOLL_WRITE matches FAULT_FLAG_WRITE, matches GUP_FLAGS_WRITE,
and it's tempting to devise a set of Grand Unified Paging flags;
but not today.  So until then, let's rely upon the compiler to spot
the coincidence, "rather than have that subtle dependency and a
comment for it" - as you remarked in another context yesterday.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/memory.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- 2.6.30-git20/mm/memory.c	2009-06-23 11:06:25.000000000 +0100
+++ linux/mm/memory.c	2009-06-23 13:07:57.000000000 +0100
@@ -1311,8 +1311,10 @@ int __get_user_pages(struct task_struct
 			while (!(page = follow_page(vma, start, foll_flags))) {
 				int ret;
 
-				/* FOLL_WRITE matches FAULT_FLAG_WRITE! */
-				ret = handle_mm_fault(mm, vma, start, foll_flags & FOLL_WRITE);
+				ret = handle_mm_fault(mm, vma, start,
+					(foll_flags & FOLL_WRITE) ?
+					FAULT_FLAG_WRITE : 0);
+
 				if (ret & VM_FAULT_ERROR) {
 					if (ret & VM_FAULT_OOM)
 						return i ? i : -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
