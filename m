Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A092B6B0047
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:12:48 -0500 (EST)
Date: Fri, 18 Dec 2009 15:12:09 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
Message-ID: <20091218141209.GF29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <alpine.DEB.2.00.0912171352330.4640@router.home>
 <4B2A8D83.30305@redhat.com>
 <4B2A98E6.5080406@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B2A98E6.5080406@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Mike Travis <travis@sgi.com>
Cc: Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 12:47:34PM -0800, Mike Travis wrote:
> On very large SMP systems with huge amounts of memory, the
> gains from huge pages will be significant.  And swapping
> will not be an issue.  I agree that the two should be
> split up and perhaps even make swapping an option?

I think swapoff -a will already give you what you want without any
need to change the code. Especially using echo madvise > enabled, the
only overhead you can complain about is the need of PG_compound_lock
in put_page called by O_DIRECT I/O completion handlers, everything
else will gain nothing by disabling swap or removing split_huge_page.

Thinking at swap full, let's add this too just in case swap gets full
and we split for no gain... If add_to_swap fails try_to_unmap isn't
called hence it'll never be splitted.

diff --git a/mm/swap_state.c b/mm/swap_state.c
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -152,14 +152,16 @@ int add_to_swap(struct page *page)
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageUptodate(page));
 
-	if (unlikely(PageCompound(page)))
-		if (unlikely(split_huge_page(page)))
-			return 0;
-
 	entry = get_swap_page();
 	if (!entry.val)
 		return 0;
 
+	if (unlikely(PageCompound(page)))
+		if (unlikely(split_huge_page(page))) {
+			swapcache_free(entry, NULL);
+			return 0;
+		}
+
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
 	 * completely exhaust the page allocator. __GFP_NOMEMALLOC

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
