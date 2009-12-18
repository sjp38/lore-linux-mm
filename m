Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6BF4B6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 09:28:17 -0500 (EST)
Date: Fri, 18 Dec 2009 15:27:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 01 of 28] compound_lock
Message-ID: <20091218142721.GI29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <7418f21427a000ad1665.1261076404@v2.random>
 <alpine.DEB.2.00.0912171346180.4640@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912171346180.4640@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 17, 2009 at 01:46:50PM -0600, Christoph Lameter wrote:
> On Thu, 17 Dec 2009, Andrea Arcangeli wrote:
> 
> >  	if (unlikely(PageTail(page)))
> > diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> > --- a/include/linux/page-flags.h
> > +++ b/include/linux/page-flags.h
> > @@ -108,6 +108,7 @@ enum pageflags {
> >  #ifdef CONFIG_MEMORY_FAILURE
> >  	PG_hwpoison,		/* hardware poisoned page. Don't touch */
> >  #endif
> > +	PG_compound_lock,
> >  	__NR_PAGEFLAGS,
> 
> Eats up a rare page bit.
> 
> #ifdef CONFIG_TRANSP_HUGE?

It can't go under #ifdef unless I also put under #ifdef the whole
refcounting changes on the compound pages of patch 2/28. Let me know
if this is what you're asking: it would be very feasible to not have
the PG_compound_lock logic in the compound get_page/put_page when
CONFIG_TRANSPARENT_HUGEPAGE=n. I just thought it's not worth it
because the only slowdown introduced in get_page/put_page by 2/28 for
hugetlbfs happens on O_DIRECT completion handlers. The reason
hugetlbfs can implement a backwards compatible get_page/put_page
without the need of PG_compound_lock and without the need of
refcounting how many pins there are on each tail page, is that the
hugepage managed by hugetlbfs can't be splitted and swapped out. So I
can optimize away that PG_compound_lock with
CONFIG_TRANSPARENT_HUGEPAGE=n if you want.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
