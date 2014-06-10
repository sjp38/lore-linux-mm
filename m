Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4C2866B0120
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:41:46 -0400 (EDT)
Received: by mail-ig0-f176.google.com with SMTP id a13so5781992igq.3
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:41:46 -0700 (PDT)
Received: from mail-ie0-x22f.google.com (mail-ie0-x22f.google.com [2607:f8b0:4001:c03::22f])
        by mx.google.com with ESMTPS id qm8si45566662igb.10.2014.06.10.16.41.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 16:41:45 -0700 (PDT)
Received: by mail-ie0-f175.google.com with SMTP id tp5so6296515ieb.34
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 16:41:45 -0700 (PDT)
Date: Tue, 10 Jun 2014 16:41:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/10] mm, compaction: periodically drop lock and restore
 IRQs in scanners
In-Reply-To: <5396B08A.6090900@suse.cz>
Message-ID: <alpine.DEB.2.02.1406101640510.32203@chino.kir.corp.google.com>
References: <1402305982-6928-1-git-send-email-vbabka@suse.cz> <1402305982-6928-3-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406091656340.17705@chino.kir.corp.google.com> <5396B08A.6090900@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On Tue, 10 Jun 2014, Vlastimil Babka wrote:

> On 06/10/2014 01:58 AM, David Rientjes wrote:
> > On Mon, 9 Jun 2014, Vlastimil Babka wrote:
> > 
> > > diff --git a/mm/compaction.c b/mm/compaction.c
> > > index d37f4a8..e1a4283 100644
> > > --- a/mm/compaction.c
> > > +++ b/mm/compaction.c
> > > @@ -185,54 +185,77 @@ static void update_pageblock_skip(struct
> > > compact_control *cc,
> > >   }
> > >   #endif /* CONFIG_COMPACTION */
> > > 
> > > -enum compact_contended should_release_lock(spinlock_t *lock)
> > > +/*
> > > + * Compaction requires the taking of some coarse locks that are
> > > potentially
> > > + * very heavily contended. For async compaction, back out if the lock
> > > cannot
> > > + * be taken immediately. For sync compaction, spin on the lock if needed.
> > > + *
> > > + * Returns true if the lock is held
> > > + * Returns false if the lock is not held and compaction should abort
> > > + */
> > > +static bool compact_trylock_irqsave(spinlock_t *lock,
> > > +			unsigned long *flags, struct compact_control *cc)
> > >   {
> > > -	if (need_resched())
> > > -		return COMPACT_CONTENDED_SCHED;
> > > -	else if (spin_is_contended(lock))
> > > -		return COMPACT_CONTENDED_LOCK;
> > > -	else
> > > -		return COMPACT_CONTENDED_NONE;
> > > +	if (cc->mode == MIGRATE_ASYNC) {
> > > +		if (!spin_trylock_irqsave(lock, *flags)) {
> > > +			cc->contended = COMPACT_CONTENDED_LOCK;
> > > +			return false;
> > > +		}
> > > +	} else {
> > > +		spin_lock_irqsave(lock, *flags);
> > > +	}
> > > +
> > > +	return true;
> > >   }
> > > 
> > >   /*
> > >    * Compaction requires the taking of some coarse locks that are
> > > potentially
> > > - * very heavily contended. Check if the process needs to be scheduled or
> > > - * if the lock is contended. For async compaction, back out in the event
> > > - * if contention is severe. For sync compaction, schedule.
> > > + * very heavily contended. The lock should be periodically unlocked to
> > > avoid
> > > + * having disabled IRQs for a long time, even when there is nobody
> > > waiting on
> > > + * the lock. It might also be that allowing the IRQs will result in
> > > + * need_resched() becoming true. If scheduling is needed, or somebody
> > > else
> > > + * has taken the lock, async compaction aborts. Sync compaction
> > > schedules.
> > > + * Either compaction type will also abort if a fatal signal is pending.
> > > + * In either case if the lock was locked, it is dropped and not regained.
> > >    *
> > > - * Returns true if the lock is held.
> > > - * Returns false if the lock is released and compaction should abort
> > > + * Returns true if compaction should abort due to fatal signal pending,
> > > or
> > > + *		async compaction due to lock contention or need to schedule
> > > + * Returns false when compaction can continue (sync compaction might have
> > > + *		scheduled)
> > >    */
> > > -static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long
> > > *flags,
> > > -				      bool locked, struct compact_control *cc)
> > > +static bool compact_unlock_should_abort(spinlock_t *lock,
> > > +		unsigned long flags, bool *locked, struct compact_control *cc)
> > >   {
> > > -	enum compact_contended contended = should_release_lock(lock);
> > > +	if (*locked) {
> > > +		spin_unlock_irqrestore(lock, flags);
> > > +		*locked = false;
> > > +	}
> > > 
> > > -	if (contended) {
> > > -		if (locked) {
> > > -			spin_unlock_irqrestore(lock, *flags);
> > > -			locked = false;
> > > -		}
> > > +	if (fatal_signal_pending(current)) {
> > > +		cc->contended = COMPACT_CONTENDED_SCHED;
> > > +		return true;
> > > +	}
> > > 
> > > -		/* async aborts if taking too long or contended */
> > > -		if (cc->mode == MIGRATE_ASYNC) {
> > > -			cc->contended = contended;
> > > -			return false;
> > > +	if (cc->mode == MIGRATE_ASYNC) {
> > > +		if (need_resched()) {
> > > +			cc->contended = COMPACT_CONTENDED_SCHED;
> > > +			return true;
> > >   		}
> > > -
> > > +		if (spin_is_locked(lock)) {
> > > +			cc->contended = COMPACT_CONTENDED_LOCK;
> > > +			return true;
> > > +		}
> > 
> > Any reason to abort here?  If we need to do compact_trylock_irqsave() on
> > this lock again then we'll abort when we come to that point, but it seems
> > pointless to abort early if the lock isn't actually needed anymore or it
> > is dropped before trying to acquire it again.
> 
> spin_is_locked() true means somebody was most probably waiting for us to
> unlock so maybe we should back off. But I'm not sure if that check can
> actually succeed so early after unlock.
> 

The fact remains, however, is that we may never actually need to grab that 
specific lock again and this would cause us to terminate prematurely.  I 
think the preemptive spin_is_locked() test should be removed here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
