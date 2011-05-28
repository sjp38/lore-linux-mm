Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id F3B5F6B0012
	for <linux-mm@kvack.org>; Sat, 28 May 2011 16:14:21 -0400 (EDT)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id p4SKEKKR030117
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:14:20 -0700
Received: from pzk2 (pzk2.prod.google.com [10.243.19.130])
	by wpaz9.hot.corp.google.com with ESMTP id p4SKEGWa017360
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 28 May 2011 13:14:19 -0700
Received: by pzk2 with SMTP id 2so1212850pzk.9
        for <linux-mm@kvack.org>; Sat, 28 May 2011 13:14:16 -0700 (PDT)
Date: Sat, 28 May 2011 13:14:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix race between truncate and writepage
Message-ID: <alpine.LSU.2.00.1105281311150.13319@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

While running fsx on tmpfs with a memhog then swapoff, swapoff was hanging
(interruptibly), repeatedly failing to locate the owner of a 0xff entry in
the swap_map.

Although shmem_writepage() does abandon when it sees incoming page index
is beyond eof, there was still a window in which shmem_truncate_range()
could come in between writepage's dropping lock and updating swap_map,
find the half-completed swap_map entry, and in trying to free it,
leave it in a state that swap_shmem_alloc() could not correct.

Arguably a bug in __swap_duplicate()'s and swap_entry_free()'s handling
of the different cases, but easiest to fix by moving swap_shmem_alloc()
under cover of the lock.

More interesting than the bug: it's been there since 2.6.33, why could
I not see it with earlier kernels?  The mmotm of two weeks ago seems to
have some magic for generating races, this is just one of three I found.

With yesterday's git I first saw this in mainline, bisected in search of
that magic, but the easy reproducibility evaporated.  Oh well, fix the bug.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---
 mm/shmem.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux.orig/mm/shmem.c	2011-05-27 19:05:27.000000000 -0700
+++ linux/mm/shmem.c	2011-05-27 19:45:44.194813695 -0700
@@ -1114,8 +1114,8 @@ static int shmem_writepage(struct page *
 		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
-		spin_unlock(&info->lock);
 		swap_shmem_alloc(swap);
+		spin_unlock(&info->lock);
 		BUG_ON(page_mapped(page));
 		swap_writepage(page, wbc);
 		return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
