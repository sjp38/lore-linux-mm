Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 261056B0137
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 04:19:59 -0400 (EDT)
Date: Thu, 13 Sep 2012 09:19:54 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/2 v2]compaction: check lock contention first before
 taking lock
Message-ID: <20120913081954.GQ11266@suse.de>
References: <20120910011850.GD3715@kernel.org>
 <20120911164330.4fffee4f.akpm@linux-foundation.org>
 <20120912105535.GM11266@suse.de>
 <20120912145902.96c26c25.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120912145902.96c26c25.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, aarcange@redhat.com

On Wed, Sep 12, 2012 at 02:59:02PM -0700, Andrew Morton wrote:
> On Wed, 12 Sep 2012 11:55:35 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > On Tue, Sep 11, 2012 at 04:43:30PM -0700, Andrew Morton wrote:
> > > On Mon, 10 Sep 2012 09:18:50 +0800
> > > Shaohua Li <shli@kernel.org> wrote:
> > > 
> > > > isolate_migratepages_range will take zone->lru_lock first and check if the lock
> > > > is contented, if yes, it will release the lock. This isn't efficient. If the
> > > > lock is truly contented, a lock/unlock pair will increase the lock contention.
> > > > We'd better check if the lock is contended first. compact_trylock_irqsave
> > > > perfectly meets the requirement.
> > > > 
> > > > V2:
> > > > leave cond_resched() pointed out by Mel.
> > > > 
> > > > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > > > ---
> > > >  mm/compaction.c |    5 +++--
> > > >  1 file changed, 3 insertions(+), 2 deletions(-)
> > > > 
> > > > Index: linux/mm/compaction.c
> > > > ===================================================================
> > > > --- linux.orig/mm/compaction.c	2012-09-10 08:49:40.377869710 +0800
> > > > +++ linux/mm/compaction.c	2012-09-10 08:53:10.295230575 +0800
> > > > @@ -295,8 +295,9 @@ isolate_migratepages_range(struct zone *
> > > >  
> > > >  	/* Time to isolate some pages for migration */
> > > >  	cond_resched();
> > > > -	spin_lock_irqsave(&zone->lru_lock, flags);
> > > > -	locked = true;
> > > > +	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
> > > > +	if (!locked)
> > > > +		return 0;
> > > >  	for (; low_pfn < end_pfn; low_pfn++) {
> > > >  		struct page *page;
> > > 
> > > Geeze that compact_checklock_irqsave stuff is naaaasty.
> > > 
> > 
> > The intention is to avoid THP allocations getting stuck in compaction.c
> > for ages due to spinlock contention. It's always better for those to
> > fail quickly. If compact_trylock_irqsave is improved it must still be
> > able to do this.
> 
> So there's an implicit two-level prioritization here.  But between what
> and what?
> 

Between two processes trying high-order allocations at the same time. In
practice it is expected to be two processes trying to allocate a THP.

> It all sounds a bit hack/bandaidy?
> 

It is but excessive time spent in compaction.c offsets any advantage
of using THP. The ideal would be that the zone lock or lru_lock could be
fine-grained but I have not designed something suitable. Splitting lru_lock
would be particularly problematic.

> > > There is no relationship between the concepts "user
> > > pressed ^C" and "this device driver or subsystem wants a high-order
> > > allocation".
> > > 
> > 
> > hmm, I see your point. The fatal signal check is "hidden" but this was to
> > preseve the existing behaviour prior to commit [c67fe375: mm: compaction:
> > Abort async compaction if locks are contended or taking too long]. The
> > fatal_signal_check could be deleted from compact_trylock_irqsave() but
> > then it should be checked in the isolate_migratepages_range() at the
> > very least. How about this?
> 
> hm, well, actually, I chose ^C as an example of something which might
> set need_resched().  How about `There is no relationship between the
> concepts "this process exceeded its timeslice" and "this device driver
> or subsystem wants a high-order allocation"'.
> 

A device driver or subsystem that wants a high-order allocation will not
(or at least are very unlikely) to have specified __GFP_MOVABLE. These
will retry with sync compaction and wait for the lock to be acquired.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
