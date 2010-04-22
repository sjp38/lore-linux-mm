Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 77A606B01E3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 05:50:26 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3M9oJvF024468
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 18:50:20 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B26AE45DE56
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 18:50:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E6A045DE51
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 18:50:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FA0E1DB805D
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 18:50:19 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 063CE1DB803F
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 18:50:19 +0900 (JST)
Date: Thu, 22 Apr 2010 18:46:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100422184621.0aaaeb5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100422092819.GR30306@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	<1271797276-31358-5-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.2.00.1004210927550.4959@router.home>
	<20100421150037.GJ30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211004360.4959@router.home>
	<20100421151417.GK30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211027120.4959@router.home>
	<20100421153421.GM30306@csn.ul.ie>
	<alpine.DEB.2.00.1004211038020.4959@router.home>
	<20100422092819.GR30306@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <cl@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Apr 2010 10:28:20 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> On Wed, Apr 21, 2010 at 10:46:45AM -0500, Christoph Lameter wrote:
> > On Wed, 21 Apr 2010, Mel Gorman wrote:
> > 
> > > > > 2. Is the BUG_ON check in
> > > > >    include/linux/swapops.h#migration_entry_to_page() now wrong? (I
> > > > >    think yes, but I'm not sure and I'm having trouble verifying it)
> > > >
> > > > The bug check ensures that migration entries only occur when the page
> > > > is locked. This patch changes that behavior. This is going too oops
> > > > therefore in unmap_and_move() when you try to remove the migration_ptes
> > > > from an unlocked page.
> > > >
> > >
> > > It's not unmap_and_move() that the problem is occurring on but during a
> > > page fault - presumably in do_swap_page but I'm not 100% certain.
> > 
> > remove_migration_pte() calls migration_entry_to_page(). So it must do that
> > only if the page is still locked.
> > 
> 
> Correct, but the other call path is
> 
> do_swap_page
>   -> migration_entry_wait
>     -> migration_entry_to_page
> 
> with migration_entry_wait expecting the page to be locked. There is a dangling
> migration PTEs coming from somewhere. I thought it was from unmapped swapcache
> first, but that cannot be the case. There is a race somewhere.
> 
> > You need to ensure that the page is not unlocked in move_to_new_page() if
> > the migration ptes are kept.
> > 
> > move_to_new_page() only unlocks the new page not the original page. So that is safe.
> > 
> > And it seems that the old page is also unlocked in unmap_and_move() only
> > after the migration_ptes have been removed? So we are fine after all...?
> > 
> 
> You'd think but migration PTEs are being left behind in some circumstance. I
> thought it was due to this series, but it's unlikely. It's more a case that
> compaction heavily exercises migration.
> 
> We can clean up the old migration PTEs though when they are encountered
> like in the following patch for example? I'll continue investigating why
> this dangling migration pte exists as closing that race would be a
> better fix.
> 
> ==== CUT HERE ====
> mm,migration: Remove dangling migration ptes pointing to unlocked pages
> 
> Due to some yet-to-be-identified race, it is possible for migration PTEs
> to be left behind, When later paged-in, a BUG is triggered that assumes
> that all migration PTEs are point to a page currently being migrated and
> so must be locked.
> 
> Rather than calling BUG, this patch notes the existance of dangling migration
> PTEs in migration_entry_wait() and cleans them up.
> 

I use similar patch for debugging. In my patch, this when this function founds
dangling migration entry, return error code and do_swap_page() returns
VM_FAULT_SIGBUS.


Hmm..in my test, the case was.

Before try_to_unmap:
	mapcount=1, SwapCache, remap_swapcache=1
After remap
	mapcount=0, SwapCache, rc=0.

So, I think there may be some race in rmap_walk() and vma handling or
anon_vma handling. migration_entry isn't found by rmap_walk.

Hmm..it seems this kind patch will be required for debug.

-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
