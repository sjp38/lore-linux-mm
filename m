Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C1C406B0201
	for <linux-mm@kvack.org>; Tue, 11 May 2010 12:29:41 -0400 (EDT)
Date: Tue, 11 May 2010 18:29:09 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100511162909.GI10631@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
 <alpine.DEB.2.00.1005012055010.2663@router.home>
 <20100504094522.GA20979@csn.ul.ie>
 <alpine.DEB.2.00.1005101239400.13652@router.home>
 <20100510175654.GL26611@csn.ul.ie>
 <alpine.DEB.2.00.1005110857350.1500@router.home>
 <20100511151142.GS26611@csn.ul.ie>
 <alpine.DEB.2.00.1005111055070.1500@router.home>
 <20100511161516.GU26611@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100511161516.GU26611@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 11, 2010 at 05:15:16PM +0100, Mel Gorman wrote:
> On Tue, May 11, 2010 at 10:56:00AM -0500, Christoph Lameter wrote:
> > On Tue, 11 May 2010, Mel Gorman wrote:
> > 
> > > Or just identify the temporary stack from the migration side instead of
> > > adding to the cost of exec?
> > 
> > Adding one off checks to a generic mechanism isnt really clean
> > programming. Using the provided means of disabling a generic mechanism is.
> > 
> 
> Andrea's solution is likely lighter than yours as it is one kmalloc and
> an insertion into the VM as opposed to a page table walk with reference
> counting. Better yet, it exists as a patch that has been tested and it
> fits in with the generic mechanism by guaranteeing that rmap_walk finds
> all the migration PTEs during the second walk.
> 
> The problem remains the same - that class of solution increases the cost of
> a common operation (exec) to keep a much less operation (migration) happy.

page table walk adding reference counting is still a one off check,
the generic rmap_walk mechanism won't care about the reference
counting, still only migrate checks the page count... so it doesn't
move the needle in clean programming terms.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
