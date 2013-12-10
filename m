Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f46.google.com (mail-bk0-f46.google.com [209.85.214.46])
	by kanga.kvack.org (Postfix) with ESMTP id 599C36B0036
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 12:19:49 -0500 (EST)
Received: by mail-bk0-f46.google.com with SMTP id u15so2069316bkz.19
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 09:19:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id r9si15236397eeo.107.2013.12.10.09.19.39
        for <linux-mm@kvack.org>;
        Tue, 10 Dec 2013 09:19:40 -0800 (PST)
Date: Tue, 10 Dec 2013 17:19:36 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/18] mm: fix TLB flush race between migration, and
 change_protection_range
Message-ID: <20131210171936.GM11295@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-12-git-send-email-mgorman@suse.de>
 <52A72463.9080108@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <52A72463.9080108@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>

On Tue, Dec 10, 2013 at 09:25:39AM -0500, Rik van Riel wrote:
> On 12/09/2013 02:09 AM, Mel Gorman wrote:
> 
> After reading the locking thread that Paul McKenney started,
> I wonder if I got the barriers wrong in these functions...
> 

If Documentation/memory-barriers.txt could not be used to frighten small
children before, it certainly can now.

> > +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> > +/*
> > + * Memory barriers to keep this state in sync are graciously provided by
> > + * the page table locks, outside of which no page table modifications happen.
> > + * The barriers below prevent the compiler from re-ordering the instructions
> > + * around the memory barriers that are already present in the code.
> > + */
> > +static inline bool tlb_flush_pending(struct mm_struct *mm)
> > +{
> > +	barrier();
> 
> Should this be smp_mb__after_unlock_lock(); ?
> 

I think this is still ok. Minimally, it's missing the unlock/lock pair that
would cause smp_mb__after_unlock_lock() to be treated as a full barrier
on architectures that care. The CPU executing this code as already seen
the pmd_numa update if it's in the fault handler so it just needs to be
sure to not reorder the check with respect to the page copy.

> > +	return mm->tlb_flush_pending;
> > +}
> > +static inline void set_tlb_flush_pending(struct mm_struct *mm)
> > +{
> > +	mm->tlb_flush_pending = true;
> > +	barrier();
> > +}

That now needs an smp_mb_before_spinlock to guarantee that the store
mm->tlb_flush_pending does not leak into the section updating the page
tables and get re-ordered. The result would pair with tlb_flush_pending
to guarantee that a pagetable update that starts in parallel will be
visible to flush the TLB before the cop

> > +/* Clearing is done after a TLB flush, which also provides a barrier. */
> > +static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> > +{
> > +	barrier();
> > +	mm->tlb_flush_pending = false;
> > +}
> 

This should be ok. Stores updating page tables complete before the ptl
unlock in addition to the TLB flush itself being a barrier that
guarantees the this update takes place afterwards.

Peter/Paul?

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index c122bb1..33e5519 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -482,7 +482,12 @@ static inline bool tlb_flush_pending(struct mm_struct *mm)
 static inline void set_tlb_flush_pending(struct mm_struct *mm)
 {
 	mm->tlb_flush_pending = true;
-	barrier();
+
+	/*
+	 * Guarantee that the tlb_flush_pending store does not leak into the
+	 * critical section updating the page tables
+	 */
+	smp_mb_before_spinlock();
 }
 /* Clearing is done after a TLB flush, which also provides a barrier. */
 static inline void clear_tlb_flush_pending(struct mm_struct *mm)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
