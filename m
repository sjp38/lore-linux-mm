Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B6026B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 11:00:38 -0500 (EST)
Date: Sat, 19 Dec 2009 16:59:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14 of 28] pte alloc trans splitting
Message-ID: <20091219155948.GA29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <fb0a9a34367c5c9bf2e4.1261076417@v2.random>
 <20091218190334.GF21194@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091218190334.GF21194@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 07:03:34PM +0000, Mel Gorman wrote:
> On Thu, Dec 17, 2009 at 07:00:17PM -0000, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > pte alloc routines must wait for split_huge_page if the pmd is not
> > present and not null (i.e. pmd_trans_splitting).
> 
> More stupid questions. When a large page is about to be split, you clear the
> present bit to cause faults and hold those accesses until the split completes?

That was previous version. New version doesn't clear the present bit
but sets its own reserved bit in the pmd. All we have to protect is
kernel code, not userland. We have to protect against anything that
will change the mapcount. The mapcount is the key here, as it is only
accounted in the head page and it has to be transferred to all tail
pages during the split. So during the split the mapcount can't
change. But that doesn't mean userland can't keep changing and reading
the page contents while we transfer the mapcount.

> Again, no doubt this is obvious later but a description in the leader of
> the basic approach to splitting huge pages wouldn't kill.

Yes sure good idea, I added a comment in the most crucial point... not
in the header.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -628,11 +628,28 @@ static void __split_huge_page_refcount(s
 		 */
 		smp_wmb();
 
+		/*
+		 * __split_huge_page_splitting() already set the
+		 * splitting bit in all pmd that could map this
+		 * hugepage, that will ensure no CPU can alter the
+		 * mapcount on the head page. The mapcount is only
+		 * accounted in the head page and it has to be
+		 * transferred to all tail pages in the below code. So
+		 * for this code to be safe, the split the mapcount
+		 * can't change. But that doesn't mean userland can't
+		 * keep changing and reading the page contents while
+		 * we transfer the mapcount, so the pmd splitting
+		 * status is achieved setting a reserved bit in the
+		 * pmd, not by clearing the present bit.
+		*/
 		BUG_ON(page_mapcount(page_tail));
 		page_tail->_mapcount = page->_mapcount;
+
 		BUG_ON(page_tail->mapping);
 		page_tail->mapping = page->mapping;
+
 		page_tail->index = ++head_index;
+
 		BUG_ON(!PageAnon(page_tail));
 		BUG_ON(!PageUptodate(page_tail));
 		BUG_ON(!PageDirty(page_tail));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
