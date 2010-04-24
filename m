Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A46AE6B0224
	for <linux-mm@kvack.org>; Sat, 24 Apr 2010 06:52:49 -0400 (EDT)
Date: Sat, 24 Apr 2010 11:52:27 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
	PageSwapCache  pages
Message-ID: <20100424105226.GF14351@csn.ul.ie>
References: <x2l28c262361004220313q76752366l929a8959cd6d6862@mail.gmail.com> <20100422193106.9ffad4ec.kamezawa.hiroyu@jp.fujitsu.com> <20100422195153.d91c1c9e.kamezawa.hiroyu@jp.fujitsu.com> <1271946226.2100.211.camel@barrios-desktop> <1271947206.2100.216.camel@barrios-desktop> <20100422154443.GD30306@csn.ul.ie> <20100423183135.GT32034@random.random> <20100423192311.GC14351@csn.ul.ie> <20100423193948.GU32034@random.random> <20100423213549.GV32034@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100423213549.GV32034@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 23, 2010 at 11:35:49PM +0200, Andrea Arcangeli wrote:
> On Fri, Apr 23, 2010 at 09:39:48PM +0200, Andrea Arcangeli wrote:
> > On Fri, Apr 23, 2010 at 08:23:12PM +0100, Mel Gorman wrote:
> > > On Fri, Apr 23, 2010 at 08:31:35PM +0200, Andrea Arcangeli wrote:
> > > > Hi Mel,
> > > > 
> > > > On Thu, Apr 22, 2010 at 04:44:43PM +0100, Mel Gorman wrote:
> > > > > heh, I thought of a similar approach at the same time as you but missed
> > > > > this mail until later. However, with this approach I suspect there is a
> > > > > possibility that two walkers of the same anon_vma list could livelock if
> > > > > two locks on the list are held at the same time. Am still thinking of
> > > > > how it could be resolved without introducing new locking.
> > > > 
> > > > Trying to understand this issue and I've some questions. This
> > > > vma_adjust and lock inversion troubles with the anon-vma lock in
> > > > rmap_walk are a new issue introduced by the recent anon-vma changes,
> > > > right?
> > > > 
> > > 
> > > In a manner of speaking. There was no locking going on but prior to the
> > > anon_vma changes, there would have been only one anon_vma lock and the
> > > fix would be easier - just take the lock on anon_vma->lock while the
> > > VMAs are being updated.
> > 
> > So it was very much a bug before too and we could miss to find some
> > pte mapping the page if vm_start was adjusted?
> 
> Well I looked deeper into it myself as I wanted to have this bit (and
> other bits) sorted out in aa.git, and definitely this is a bug
> introduced by the newest anon-vma changes in 2.6.34-rc so aa.git
> cannot be affected as it's using the 2.6.33 anon-vma (and prev) code.
> 

I think you're right. This is a new bug introduced by the anon_vma changes. On
the plus side, it means we don't have to worry about -stable.

> vma_adjust already takes the anon_vma->lock and of course I also
> further verified that trying to apply your snippet to vma_adjust
> results in immediately deadlock as the very same lock is already taken
> in my tree as it's the same anon-vma (simpler).

Yes, I expected that. Previously, there was only one anon_vma so if you
double-take the lock, bad things happen.

> So aa.git will be
> immune from these bugs for now.
> 

It should be. I expect that's why you have never seen the bugon in
swapops.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
