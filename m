Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id C60086B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 14:14:53 -0400 (EDT)
Date: Tue, 17 Mar 2009 11:09:02 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain>
References: <1237007189.25062.91.camel@pasglop> <200903141620.45052.nickpiggin@yahoo.com.au> <20090316223612.4B2A.A69D9226@jp.fujitsu.com> <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random>
 <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random> <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Linus Torvalds wrote:
> 
> Do all the other get_user_pages() users do that, though?
> 
> [ Looks around - at least access_process_vm(), IB and the NFS direct code 
>   do. So we seem to be mostly ok, at least for the main users ]
> 
> Ok, no worries.

This problem is actually pretty easy to fix for anonymous pages: since the 
act of pinning (for writes) should have done all the COW stuff and made 
sure the page is not in the swap cache, we only need to avoid adding it 
back.

IOW, something like the following makes sense on all levels regardless 
(note: I didn't check if there is some off-by-one issue where we've raised 
the page count for other reasons when scanning it, so this is not meant to 
be a serious patch, just a "something along these lines" thing).

This does not obviate the need to mark pages dirty afterwards, though, 
since true shared mappings always cause that (and we cannot keep them 
dirty, since somebody may be doing fsync() on them or something like 
that).

But since the COW issue is only a matter of private pages, this handles 
that trivially.

			Linus

---
 mm/swap_state.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3ecea98..83137fe 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -140,6 +140,10 @@ int add_to_swap(struct page *page)
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageUptodate(page));
 
+	/* Refuse to add pinned pages to the swap cache */
+	if (page_count(page) > page_mapped(page))
+		return 0;
+
 	for (;;) {
 		entry = get_swap_page();
 		if (!entry.val)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
