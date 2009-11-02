Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BF6396B007E
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 11:50:39 -0500 (EST)
Date: Mon, 2 Nov 2009 16:50:33 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] mm: remove incorrect swap_count() from try_to_unuse()
Message-ID: <Pine.LNX.4.64.0911021646020.23159@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bo Liu <bo-liu@hotmail.com>, Bob Liu <yjfpb04@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Bo Liu <bo-liu@hotmail.com>

In try_to_unuse(), swcount is a local copy of *swap_map, including the
SWAP_HAS_CACHE bit; but a wrong comparison against swap_count(*swap_map),
which masks off the SWAP_HAS_CACHE bit, succeeded where it should fail.

That had the effect of resetting the mm from which to start searching
for the next swap page, to an irrelevant mm instead of to an mm in which
this swap page had been found: which may increase search time by ~20%.
But we're used to swapoff being slow, so never noticed the slowdown.

Remove that one spurious use of swap_count(): Bo Liu thought it merely
redundant, Hugh rewrote the description since it was measurably wrong.

Signed-off-by: Bo Liu <bo-liu@hotmail.com>
Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: stable@kernel.org
---

 mm/swapfile.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- 2.6.32-rc5/mm/swapfile.c	2009-10-05 04:20:31.000000000 +0100
+++ linux/mm/swapfile.c	2009-10-28 19:31:43.000000000 +0000
@@ -1151,8 +1151,7 @@ static int try_to_unuse(unsigned int typ
 				} else
 					retval = unuse_mm(mm, entry, page);
 
-				if (set_start_mm &&
-				    swap_count(*swap_map) < swcount) {
+				if (set_start_mm && *swap_map < swcount) {
 					mmput(new_start_mm);
 					atomic_inc(&mm->mm_users);
 					new_start_mm = mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
