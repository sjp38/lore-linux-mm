Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 267D06B01EF
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 11:47:25 -0400 (EDT)
Date: Wed, 21 Apr 2010 10:46:45 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of PageSwapCache
 pages
In-Reply-To: <20100421153421.GM30306@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1004211038020.4959@router.home>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie> <1271797276-31358-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1004210927550.4959@router.home> <20100421150037.GJ30306@csn.ul.ie> <alpine.DEB.2.00.1004211004360.4959@router.home>
 <20100421151417.GK30306@csn.ul.ie> <alpine.DEB.2.00.1004211027120.4959@router.home> <20100421153421.GM30306@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010, Mel Gorman wrote:

> > > 2. Is the BUG_ON check in
> > >    include/linux/swapops.h#migration_entry_to_page() now wrong? (I
> > >    think yes, but I'm not sure and I'm having trouble verifying it)
> >
> > The bug check ensures that migration entries only occur when the page
> > is locked. This patch changes that behavior. This is going too oops
> > therefore in unmap_and_move() when you try to remove the migration_ptes
> > from an unlocked page.
> >
>
> It's not unmap_and_move() that the problem is occurring on but during a
> page fault - presumably in do_swap_page but I'm not 100% certain.

remove_migration_pte() calls migration_entry_to_page(). So it must do that
only if the page is still locked.

You need to ensure that the page is not unlocked in move_to_new_page() if
the migration ptes are kept.

move_to_new_page() only unlocks the new page not the original page. So that is safe.

And it seems that the old page is also unlocked in unmap_and_move() only
after the migration_ptes have been removed? So we are fine after all...?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
