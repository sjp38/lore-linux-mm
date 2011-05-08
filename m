Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0456B0022
	for <linux-mm@kvack.org>; Sun,  8 May 2011 15:45:00 -0400 (EDT)
Received: from wpaz17.hot.corp.google.com (wpaz17.hot.corp.google.com [172.24.198.81])
	by smtp-out.google.com with ESMTP id p48JiwVD001596
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:44:58 -0700
Received: from pzk6 (pzk6.prod.google.com [10.243.19.134])
	by wpaz17.hot.corp.google.com with ESMTP id p48Jivxt009647
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:44:57 -0700
Received: by pzk6 with SMTP id 6so726599pzk.12
        for <linux-mm@kvack.org>; Sun, 08 May 2011 12:44:56 -0700 (PDT)
Date: Sun, 8 May 2011 12:45:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 3/3] tmpfs: fix spurious ENOSPC when racing with unswap
In-Reply-To: <alpine.LSU.2.00.1105081238010.15963@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105081243260.15963@sister.anvils>
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils> <4DC4D9A6.9070103@parallels.com>
 <alpine.LSU.2.00.1105071621330.3668@sister.anvils> <4DC691D0.6050104@parallels.com> <alpine.LSU.2.00.1105081238010.15963@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Testing the shmem_swaplist replacements for igrab() revealed another bug:
writes to /dev/loop0 on a tmpfs file which fills its filesystem were
sometimes failing with "Buffer I/O error"s.

These came from ENOSPC failures of shmem_getpage(), when racing with
swapoff: the same could happen when racing with another shmem_getpage(),
pulling the page in from swap in between our find_lock_page() and our
taking the info->lock (though not in the single-threaded loop case).

This is unacceptable, and surprising that I've not noticed it before:
it dates back many years, but (presumably) was made a lot easier to
reproduce in 2.6.36, which sited a page preallocation in the race window.

Fix it by rechecking the page cache before settling on an ENOSPC error.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: stable@kernel.org
---

 mm/shmem.c |   32 ++++++++++++++++++++++----------
 1 file changed, 22 insertions(+), 10 deletions(-)

--- tmpfs2/mm/shmem.c	2011-05-07 17:39:00.656959448 -0700
+++ tmpfs3/mm/shmem.c	2011-05-07 17:40:00.665256101 -0700
@@ -1407,20 +1407,14 @@ repeat:
 		if (sbinfo->max_blocks) {
 			if (percpu_counter_compare(&sbinfo->used_blocks,
 						sbinfo->max_blocks) >= 0 ||
-			    shmem_acct_block(info->flags)) {
-				spin_unlock(&info->lock);
-				error = -ENOSPC;
-				goto failed;
-			}
+			    shmem_acct_block(info->flags))
+				goto nospace;
 			percpu_counter_inc(&sbinfo->used_blocks);
 			spin_lock(&inode->i_lock);
 			inode->i_blocks += BLOCKS_PER_PAGE;
 			spin_unlock(&inode->i_lock);
-		} else if (shmem_acct_block(info->flags)) {
-			spin_unlock(&info->lock);
-			error = -ENOSPC;
-			goto failed;
-		}
+		} else if (shmem_acct_block(info->flags))
+			goto nospace;
 
 		if (!filepage) {
 			int ret;
@@ -1500,6 +1494,24 @@ done:
 	error = 0;
 	goto out;
 
+nospace:
+	/*
+	 * Perhaps the page was brought in from swap between find_lock_page
+	 * and taking info->lock?  We allow for that at add_to_page_cache_lru,
+	 * but must also avoid reporting a spurious ENOSPC while working on a
+	 * full tmpfs.  (When filepage has been passed in to shmem_getpage, it
+	 * is already in page cache, which prevents this race from occurring.)
+	 */
+	if (!filepage) {
+		struct page *page = find_get_page(mapping, idx);
+		if (page) {
+			spin_unlock(&info->lock);
+			page_cache_release(page);
+			goto repeat;
+		}
+	}
+	spin_unlock(&info->lock);
+	error = -ENOSPC;
 failed:
 	if (*pagep != filepage) {
 		unlock_page(filepage);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
