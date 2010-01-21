Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 866016B006A
	for <linux-mm@kvack.org>; Thu, 21 Jan 2010 18:03:21 -0500 (EST)
Date: Fri, 22 Jan 2010 00:01:27 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22 of 30] pmd_trans_huge migrate bugcheck
Message-ID: <20100121230127.GI5598@random.random>
References: <patchbomb.1264054824@v2.random>
 <f5766ea214603fc6a64f.1264054846@v2.random>
 <alpine.DEB.2.00.1001211431300.13130@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1001211431300.13130@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 02:40:41PM -0600, Christoph Lameter wrote:
> On Thu, 21 Jan 2010, Andrea Arcangeli wrote:
> 
> > From: Andrea Arcangeli <aarcange@redhat.com>
> >
> > No pmd_trans_huge should ever materialize in migration ptes areas, because
> > try_to_unmap will split the hugepage before migration ptes are instantiated.
> 
> try_to_unmap? How do you isolate the hugepages from the LRU? If you do
> isolate the huge pages via a LRU and get a 2M page then the migration
> logic has to be modified to be aware that huge pages may split during try_to_unmap.

Good point, all we need to do is to add one split_huge_page before
isolate_lru_page, the one in try_to_unmap isn't enough. Effectively I
guess I can remove the one in try_to_unmap then and replace it with
BUG_ON(TransHugePage(page)).

Subject: pmd_trans_huge migrate

From: Andrea Arcangeli <aarcange@redhat.com>

No pmd_trans_huge should ever materialize in migration ptes areas, because
we split the hugepage before migration ptes are instantiated.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---

diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -99,6 +99,7 @@ static int remove_migration_pte(struct p
 		goto out;
 
 	pmd = pmd_offset(pud, addr);
+	VM_BUG_ON(pmd_trans_huge(*pmd));
 	if (!pmd_present(*pmd))
 		goto out;
 
@@ -833,6 +834,9 @@ static int do_move_page_to_node_array(st
 				!migrate_all)
 			goto put_and_set;
 
+		if (unlikely(PageTransHuge(page)))
+			if (unlikely(split_huge_page(page)))
+				goto put_and_set;
 		err = isolate_lru_page(page);
 		if (!err) {
 			list_add_tail(&page->lru, &pagelist);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
