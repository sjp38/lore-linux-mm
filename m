Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id F18496B02A4
	for <linux-mm@kvack.org>; Tue, 10 Aug 2010 21:52:12 -0400 (EDT)
Date: Wed, 11 Aug 2010 07:23:45 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/8] hugetlb, rmap: add reverse mapping for hugepage
Message-ID: <20100810232344.GA7001@localhost>
References: <1275006562-18946-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1275006562-18946-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20100528144824.GD9774@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100528144824.GD9774@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 28, 2010 at 03:48:24PM +0100, Mel Gorman wrote:
> On Fri, May 28, 2010 at 09:29:16AM +0900, Naoya Horiguchi wrote:
> > This patch adds reverse mapping feature for hugepage by introducing
> > mapcount for shared/private-mapped hugepage and anon_vma for
> > private-mapped hugepage.
> > 
> > While hugepage is not currently swappable, reverse mapping can be useful
> > for memory error handler.
> > 
> > Without this patch, memory error handler cannot identify processes
> > using the bad hugepage nor unmap it from them. That is:
> > - for shared hugepage:
> >   we can collect processes using a hugepage through pagecache,
> >   but can not unmap the hugepage because of the lack of mapcount.
> > - for privately mapped hugepage:
> >   we can neither collect processes nor unmap the hugepage.
> > This patch solves these problems.
> > 
> > This patch include the bug fix given by commit 23be7468e8, so reverts it.
> > 
> > Dependency:
> >   "hugetlb: move definition of is_vm_hugetlb_page() to hugepage_inline.h"
> > 
> > ChangeLog since May 24.
> > - create hugetlb_inline.h and move is_vm_hugetlb_index() in it.
> > - move functions setting up anon_vma for hugepage into mm/rmap.c.
> > 
> > ChangeLog since May 13.
> > - rebased to 2.6.34
> > - fix logic error (in case that private mapping and shared mapping coexist)
> > - move is_vm_hugetlb_page() into include/linux/mm.h to use this function
> >   from linear_page_index()
> > - define and use linear_hugepage_index() instead of compound_order()
> > - use page_move_anon_rmap() in hugetlb_cow()
> > - copy exclusive switch of __set_page_anon_rmap() into hugepage counterpart.
> > - revert commit 24be7468 completely
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: Andi Kleen <andi@firstfloor.org>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Wu Fengguang <fengguang.wu@intel.com>
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Cc: Larry Woodman <lwoodman@redhat.com>
> > Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> 
> Ok, I could find no other problems with the hugetlb side of things in the
> first two patches. I haven't looked at the hwpoison parts but I'm assuming
> Andi has looked at those already. Thanks
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>

The hwpoison part looks good. We actually start by adding ugly code in
memory-failure.c to special handle huge pages, then decided that
hugetlb rmap is the way to go :)

Acked-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
