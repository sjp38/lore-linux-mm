Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 727606B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 06:21:44 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so2842942eei.0
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 03:21:43 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id j47si18586013eeo.53.2013.12.11.03.21.43
        for <linux-mm@kvack.org>;
        Wed, 11 Dec 2013 03:21:43 -0800 (PST)
Date: Wed, 11 Dec 2013 11:21:37 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/18] mm: fix TLB flush race between migration, and
 change_protection_range
Message-ID: <20131211112137.GZ11295@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-12-git-send-email-mgorman@suse.de>
 <52A72463.9080108@redhat.com>
 <20131210171936.GM11295@suse.de>
 <20131210180208.GY4208@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20131210180208.GY4208@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Tue, Dec 10, 2013 at 10:02:08AM -0800, Paul E. McKenney wrote:
> > > Should this be smp_mb__after_unlock_lock(); ?
> > 
> > I think this is still ok. Minimally, it's missing the unlock/lock pair that
> > would cause smp_mb__after_unlock_lock() to be treated as a full barrier
> > on architectures that care. The CPU executing this code as already seen
> > the pmd_numa update if it's in the fault handler so it just needs to be
> > sure to not reorder the check with respect to the page copy.
> 
> You really do need a lock operation somewhere shortly before the
> smp_mb__after_unlock_lock().
> 

My badly phrased point was that there was no unlock/lock operation nearby
that needs to be ordered with respect to the tlb_flush_pending check. I
do not see a need for smp_mb__after_unlock_lock() here and just this
hunk is required.

> > index c122bb1..33e5519 100644
> > --- a/include/linux/mm_types.h
> > +++ b/include/linux/mm_types.h
> > @@ -482,7 +482,12 @@ static inline bool tlb_flush_pending(struct mm_struct *mm)
> >  static inline void set_tlb_flush_pending(struct mm_struct *mm)
> >  {
> >  	mm->tlb_flush_pending = true;
> > -	barrier();
> > +
> > +	/*
> > +	 * Guarantee that the tlb_flush_pending store does not leak into the
> > +	 * critical section updating the page tables
> > +	 */
> > +	smp_mb_before_spinlock();
> >  }
> >  /* Clearing is done after a TLB flush, which also provides a barrier. */
> >  static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> > 

A double check would be nice please.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
