Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 66CC36B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 10:10:25 -0500 (EST)
Date: Sat, 19 Dec 2009 16:09:16 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
Message-ID: <20091219150916.GW29790@random.random>
References: <patchbomb.1261076403@v2.random>
 <alpine.DEB.2.00.0912171352330.4640@router.home>
 <4B2A8D83.30305@redhat.com>
 <alpine.DEB.2.00.0912171402550.4640@router.home>
 <20091218140530.GE29790@random.random>
 <alpine.DEB.2.00.0912181229580.26947@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912181229580.26947@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Dec 18, 2009 at 12:33:36PM -0600, Christoph Lameter wrote:
> On Fri, 18 Dec 2009, Andrea Arcangeli wrote:
> 
> > On Thu, Dec 17, 2009 at 02:09:47PM -0600, Christoph Lameter wrote:
> > > Can we do this step by step? This splitting thing and its
> > > associated overhead causes me concerns.
> >
> > The split_huge_page* functionality whole point is exactly to do things
> > step by step. Removing it would mean doing it all at once.
> 
> The split huge page thing involved introducing new refcounting and locking
> features into the VM. Not a first step thing. And certainly difficult to
> verify if it is correct.

I can explain how it works no problem. I already did with Marcelo who
also audited my change to put_page.

> > This is like the big kernel lock when SMP initially was
> > introduced. Surely kernel would have been a little faster if the big
> > kernel lock was never introduced but over time the split_huge_page can
> > be removed just like the big kernel lock has been removed. Then the
> > PG_compound_lock can go away too.
> 
> That is a pretty strange comparison. Split huge page is like introducing
> the split pte lock after removing the bkl. You first want to solve the
> simpler issues (anon huge) and then see if there is a way to avoid
> introducing new locking methods.

I can't get your comparison... The reasoning behind my comparison is
very simple: we can't put spinlocks everywhere and pretend the kernel
to become threaded as a whole overnight. But we can put a BKL
(split_huge_page) that takes care of all not-yet-threaded (hugepage
aware) code paths that can't be converted overnight (swap, and all the
rest of mm/*.c) while we start threading file-by-file. First the
scheduler (malloc/free) and then the rest... Removing split_huge_page
if needed is simple.

> > scalable. In the future mmu notifier users that calls gup will stop
> > using FOLL_GET and in turn they will stop calling put_page, so
> > eliminating any need to take the PG_compound_lock in all KVM fast paths.
> 
> Maybe do that first then and never introduce the lock in the first place?

It's not feasible as I documented in previous emails. Removing
FOLL_GET surely would remove the need of all refcounting changes in
put_page for tail pages, and it would remove the need of
PG_compound_lock, but this only works for gup users that are
registered into mmu notifier! O_DIRECT will never be able to use mmu
notifier because it does DMA and we can't interrupt DMA in the middle
from the mmu notifier invalidate handler.

To say it in another way the only way to remove the PG_compound_lock
used by put_page _only_ when called on PageTail pages, is to force
anybody calling gup to be registered into mmu notifier and supporting
interrupting any access to the physical page returned by gup before
returning from mmu_notifier_invalidate*.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
