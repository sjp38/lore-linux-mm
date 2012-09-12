Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 3873A6B00BB
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 06:55:40 -0400 (EDT)
Date: Wed, 12 Sep 2012 11:55:35 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch 2/2 v2]compaction: check lock contention first before
 taking lock
Message-ID: <20120912105535.GM11266@suse.de>
References: <20120910011850.GD3715@kernel.org>
 <20120911164330.4fffee4f.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120911164330.4fffee4f.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shli@kernel.org>, linux-mm@kvack.org, aarcange@redhat.com

On Tue, Sep 11, 2012 at 04:43:30PM -0700, Andrew Morton wrote:
> On Mon, 10 Sep 2012 09:18:50 +0800
> Shaohua Li <shli@kernel.org> wrote:
> 
> > isolate_migratepages_range will take zone->lru_lock first and check if the lock
> > is contented, if yes, it will release the lock. This isn't efficient. If the
> > lock is truly contented, a lock/unlock pair will increase the lock contention.
> > We'd better check if the lock is contended first. compact_trylock_irqsave
> > perfectly meets the requirement.
> > 
> > V2:
> > leave cond_resched() pointed out by Mel.
> > 
> > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > ---
> >  mm/compaction.c |    5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > Index: linux/mm/compaction.c
> > ===================================================================
> > --- linux.orig/mm/compaction.c	2012-09-10 08:49:40.377869710 +0800
> > +++ linux/mm/compaction.c	2012-09-10 08:53:10.295230575 +0800
> > @@ -295,8 +295,9 @@ isolate_migratepages_range(struct zone *
> >  
> >  	/* Time to isolate some pages for migration */
> >  	cond_resched();
> > -	spin_lock_irqsave(&zone->lru_lock, flags);
> > -	locked = true;
> > +	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
> > +	if (!locked)
> > +		return 0;
> >  	for (; low_pfn < end_pfn; low_pfn++) {
> >  		struct page *page;
> 
> Geeze that compact_checklock_irqsave stuff is naaaasty.
> 

The intention is to avoid THP allocations getting stuck in compaction.c
for ages due to spinlock contention. It's always better for those to
fail quickly. If compact_trylock_irqsave is improved it must still be
able to do this.

> What happens if a process has need_resched set?

On async compaction, it will abort compaction and it's up to the caller
	to retry with sync compaction if necessary. Whether compaction
	is called again comes down to this check in the page allocator.

        /*
         * If compaction is deferred for high-order allocations, it is because
         * sync compaction recently failed. In this is the case and the caller
         * requested a movable allocation that does not heavily disrupt the
         * system then fail the allocation instead of entering direct
         * reclaim.
         */
        if ((deferred_compaction || contended_compaction) &&
            (gfp_mask & (__GFP_MOVABLE|__GFP_REPEAT)) == __GFP_MOVABLE)
                goto nopage;

On sync compaction, it will call cond_resched() and continue compacting

> It cannot perform
> compaction? 

It can still use sync compaction.

> There is no relationship between the concepts "user
> pressed ^C" and "this device driver or subsystem wants a high-order
> allocation".
> 

hmm, I see your point. The fatal signal check is "hidden" but this was to
preseve the existing behaviour prior to commit [c67fe375: mm: compaction:
Abort async compaction if locks are contended or taking too long]. The
fatal_signal_check could be deleted from compact_trylock_irqsave() but
then it should be checked in the isolate_migratepages_range() at the
very least. How about this?

---8<---
mm: compaction: Move fatal signal check out of compact_checklock_irqsave

Commit [c67fe3752: mm: compaction: Abort async compaction if locks are
contended or taking too long] addressed a lock contention problem in
compaction by introducing compact_checklock_irqsave() that effecively
aborting async compaction in the event of compaction.

To preserve existing behaviour it also moved a fatal_signal_pending() check
into compact_checklock_irqsave() but that is very misleading.  It "hides"
the check within a locking function but has nothing to do with locking as
such. It just happens to work in a desirable fashion.

This patch moves the fatal_signal_pending() check to
isolate_migratepages_range() where it belongs. Arguably the same check
should also happen when isolating pages for freeing but it's overkill.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0fbc6b7..364e12f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -76,8 +76,6 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 		}
 
 		cond_resched();
-		if (fatal_signal_pending(current))
-			return false;
 	}
 
 	if (!locked)
@@ -364,7 +362,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		/* Check if it is ok to still hold the lock */
 		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
 								locked, cc);
-		if (!locked)
+		if (!locked || fatal_signal_pending(current))
 			break;
 
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
