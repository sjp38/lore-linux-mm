Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id CD9606B0035
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 13:02:14 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id wn1so5672120obc.19
        for <linux-mm@kvack.org>; Tue, 10 Dec 2013 10:02:14 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id rj3si11098237oeb.29.2013.12.10.10.02.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 10 Dec 2013 10:02:13 -0800 (PST)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 10 Dec 2013 11:02:12 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 47CFA1FF001B
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:01:47 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp07028.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rBAG02429765360
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 17:00:02 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rBAI5BpG016931
	for <linux-mm@kvack.org>; Tue, 10 Dec 2013 11:05:11 -0700
Date: Tue, 10 Dec 2013 10:02:08 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 11/18] mm: fix TLB flush race between migration, and
 change_protection_range
Message-ID: <20131210180208.GY4208@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
 <1386572952-1191-12-git-send-email-mgorman@suse.de>
 <52A72463.9080108@redhat.com>
 <20131210171936.GM11295@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131210171936.GM11295@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Tue, Dec 10, 2013 at 05:19:36PM +0000, Mel Gorman wrote:
> On Tue, Dec 10, 2013 at 09:25:39AM -0500, Rik van Riel wrote:
> > On 12/09/2013 02:09 AM, Mel Gorman wrote:
> > 
> > After reading the locking thread that Paul McKenney started,
> > I wonder if I got the barriers wrong in these functions...
> 
> If Documentation/memory-barriers.txt could not be used to frighten small
> children before, it certainly can now.

Depends on the children.  Some might find it quite attractive, sort of
like running while carrying a knife.

> > > +#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
> > > +/*
> > > + * Memory barriers to keep this state in sync are graciously provided by
> > > + * the page table locks, outside of which no page table modifications happen.
> > > + * The barriers below prevent the compiler from re-ordering the instructions
> > > + * around the memory barriers that are already present in the code.
> > > + */
> > > +static inline bool tlb_flush_pending(struct mm_struct *mm)
> > > +{
> > > +	barrier();
> > 
> > Should this be smp_mb__after_unlock_lock(); ?
> 
> I think this is still ok. Minimally, it's missing the unlock/lock pair that
> would cause smp_mb__after_unlock_lock() to be treated as a full barrier
> on architectures that care. The CPU executing this code as already seen
> the pmd_numa update if it's in the fault handler so it just needs to be
> sure to not reorder the check with respect to the page copy.

You really do need a lock operation somewhere shortly before the
smp_mb__after_unlock_lock().

> > > +	return mm->tlb_flush_pending;
> > > +}
> > > +static inline void set_tlb_flush_pending(struct mm_struct *mm)
> > > +{
> > > +	mm->tlb_flush_pending = true;
> > > +	barrier();
> > > +}
> 
> That now needs an smp_mb_before_spinlock to guarantee that the store
> mm->tlb_flush_pending does not leak into the section updating the page
> tables and get re-ordered. The result would pair with tlb_flush_pending
> to guarantee that a pagetable update that starts in parallel will be
> visible to flush the TLB before the cop

That would be required even if UNLOCK+LOCK continued being a full barrier.
A lock acquisition by itself never was guaranteed to be a full barrier.

							Thanx, Paul

> > > +/* Clearing is done after a TLB flush, which also provides a barrier. */
> > > +static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> > > +{
> > > +	barrier();
> > > +	mm->tlb_flush_pending = false;
> > > +}
> > 
> 
> This should be ok. Stores updating page tables complete before the ptl
> unlock in addition to the TLB flush itself being a barrier that
> guarantees the this update takes place afterwards.
> 
> Peter/Paul?
> 
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index c122bb1..33e5519 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -482,7 +482,12 @@ static inline bool tlb_flush_pending(struct mm_struct *mm)
>  static inline void set_tlb_flush_pending(struct mm_struct *mm)
>  {
>  	mm->tlb_flush_pending = true;
> -	barrier();
> +
> +	/*
> +	 * Guarantee that the tlb_flush_pending store does not leak into the
> +	 * critical section updating the page tables
> +	 */
> +	smp_mb_before_spinlock();
>  }
>  /* Clearing is done after a TLB flush, which also provides a barrier. */
>  static inline void clear_tlb_flush_pending(struct mm_struct *mm)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
