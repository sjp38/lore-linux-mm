Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5448E6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:50:04 -0400 (EDT)
Date: Mon, 16 Mar 2009 17:44:25 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090316223612.4B2A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, KOSAKI Motohiro wrote:
> 
> if we only need concern to O_DIRECT, below patch is enough.

.. together with something like this, to handle the other direction. This 
should take care of the case of an O_DIRECT write() call using a page that 
was duplicated by an _earlier_ fork(), and then got split up by a COW in
the wrong direction (ie having data from the child show up in the write).

Untested. But fairly trivial, after all. We simply do the same old 
"reuse_swap_page()" count, but we only break the COW if the page count 
afterwards is 1 (reuse_swap_page will have removed it from the swap cache 
if it returns success).

Does this (together with Kosaki's patch) pass the tests that Andrea had?

		Linus

---
 mm/memory.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index baa999e..2bd5fb0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1928,7 +1928,13 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			}
 			page_cache_release(old_page);
 		}
-		reuse = reuse_swap_page(old_page);
+		/*
+		 * If we can re-use the swap page _and_ the end
+		 * result has only one user (the mapping), then
+		 * we reuse the whole page
+		 */
+		if (reuse_swap_page(old_page))
+			reuse = page_count(old_page) == 1;
 		unlock_page(old_page);
 	} else if (unlikely((vma->vm_flags & (VM_WRITE|VM_SHARED)) ==
 					(VM_WRITE|VM_SHARED))) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
