Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 552686B007E
	for <linux-mm@kvack.org>; Fri,  2 Mar 2012 12:43:54 -0500 (EST)
Date: Fri, 2 Mar 2012 17:43:49 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Remove memory barrier damage from the page
 allocator
Message-ID: <20120302174349.GB3481@suse.de>
References: <20120302112358.GA3481@suse.de>
 <alpine.DEB.2.00.1203021018130.15125@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203021018130.15125@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 02, 2012 at 10:19:55AM -0600, Christoph Lameter wrote:
> On Fri, 2 Mar 2012, Mel Gorman wrote:
> 
> > diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
> > index e9eaec5..ba6d217 100644
> > --- a/include/linux/cpuset.h
> > +++ b/include/linux/cpuset.h
> > @@ -92,38 +92,25 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
> >   * reading current mems_allowed and mempolicy in the fastpath must protected
> >   * by get_mems_allowed()
> >   */
> > -static inline void get_mems_allowed(void)
> > +static inline unsigned long get_mems_allowed(void)
> >  {
> > -	current->mems_allowed_change_disable++;
> > -
> > -	/*
> > -	 * ensure that reading mems_allowed and mempolicy happens after the
> > -	 * update of ->mems_allowed_change_disable.
> > -	 *
> > -	 * the write-side task finds ->mems_allowed_change_disable is not 0,
> > -	 * and knows the read-side task is reading mems_allowed or mempolicy,
> > -	 * so it will clear old bits lazily.
> > -	 */
> > -	smp_mb();
> > +	return atomic_read(&current->mems_allowed_seq);
> >  }
> >
> > -static inline void put_mems_allowed(void)
> > +/*
> > + * If this returns false, the operation that took place after get_mems_allowed
> > + * may have failed. It is up to the caller to retry the operation if
> > + * appropriate
> > + */
> > +static inline bool put_mems_allowed(unsigned long seq)
> >  {
> > -	/*
> > -	 * ensure that reading mems_allowed and mempolicy before reducing
> > -	 * mems_allowed_change_disable.
> > -	 *
> > -	 * the write-side task will know that the read-side task is still
> > -	 * reading mems_allowed or mempolicy, don't clears old bits in the
> > -	 * nodemask.
> > -	 */
> > -	smp_mb();
> > -	--ACCESS_ONCE(current->mems_allowed_change_disable);
> > +	return seq == atomic_read(&current->mems_allowed_seq);
> >  }
> 
> Use seqlock instead of the counter? Seems that you are recoding much of
> what a seqlock does. A seqlock also allows you to have a writer that sort
> of blocks the reades if necessary.
> 

I considered using a seqlock but it isn't cheap. The read side is heavy
with the possibility that it starts spinning and incurs a read barrier
(looking at read_seqbegin()) here. The retry block incurs another read
barrier so basically it would not be no better than what is there currently
(which at a 4% performance hit, sucks)

In the case of seqlocks, a reader will backoff if a writer is in progress
but the page allocator doesn't need that which is why I felt it was ok
to special case.  Instead, it will try allocate a page while the update
is in progress and only take special action if the allocation will fail.
Allocation failure is an unusual situation that can trigger application
exit or an OOM so it's ok to treat it as a slow path. A normal seqlock
would retry unconditionally and potentially have to handle the case
where it needs to free the page before retrying which is pointless.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
