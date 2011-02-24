Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDC68D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 00:32:02 -0500 (EST)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p1O5W07W020662
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:32:00 -0800
Received: from gwb15 (gwb15.prod.google.com [10.200.2.15])
	by wpaz17.hot.corp.google.com with ESMTP id p1O5Vx5L009471
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:31:59 -0800
Received: by gwb15 with SMTP id 15so166538gwb.10
        for <linux-mm@kvack.org>; Wed, 23 Feb 2011 21:31:59 -0800 (PST)
Date: Wed, 23 Feb 2011 21:31:50 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: remove worrying dead code from find_get_pages()
Message-ID: <alpine.LSU.2.00.1102232127590.2239@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@kernel.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Wu Fengguang <fengguang.wu@intel.com>, Salman Qazi <sqazi@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The radix_tree_deref_retry() case in find_get_pages() has a strange
little excrescence, not seen in the other gang lookups: it looks like
the start of an abandoned attempt to guarantee forward progress in a
case that cannot arise.

ret should always be 0 here: if it isn't, then going back to restart
will leak references to pages already gotten.  There used to be a
comment saying nr_found is necessarily 1 here: that's not quite true,
but the radix_tree_deref_retry() case is peculiar to the entry at index
0, when we race with it being moved out of the radix_tree root or back.

Remove the worrisome two lines, add a brief comment here and in
find_get_pages_contig() and find_get_pages_tag(), and a WARN_ON
in find_get_pages() should it ever be seen elsewhere than at 0.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/filemap.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

--- 2.6.38-rc6/mm/filemap.c	2011-01-18 22:04:56.000000000 -0800
+++ linux/mm/filemap.c	2011-02-23 15:45:47.000000000 -0800
@@ -782,9 +782,13 @@ repeat:
 		page = radix_tree_deref_slot((void **)pages[i]);
 		if (unlikely(!page))
 			continue;
+
+		/*
+		 * This can only trigger when the entry at index 0 moves out
+		 * of or back to the root: none yet gotten, safe to restart.
+		 */
 		if (radix_tree_deref_retry(page)) {
-			if (ret)
-				start = pages[ret-1]->index;
+			WARN_ON(start | i);
 			goto restart;
 		}
 
@@ -834,6 +838,11 @@ repeat:
 		page = radix_tree_deref_slot((void **)pages[i]);
 		if (unlikely(!page))
 			continue;
+
+		/*
+		 * This can only trigger when the entry at index 0 moves out
+		 * of or back to the root: none yet gotten, safe to restart.
+		 */
 		if (radix_tree_deref_retry(page))
 			goto restart;
 
@@ -894,6 +903,11 @@ repeat:
 		page = radix_tree_deref_slot((void **)pages[i]);
 		if (unlikely(!page))
 			continue;
+
+		/*
+		 * This can only trigger when the entry at index 0 moves out
+		 * of or back to the root: none yet gotten, safe to restart.
+		 */
 		if (radix_tree_deref_retry(page))
 			goto restart;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
