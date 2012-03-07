Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 4ADF16B004A
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 06:01:05 -0500 (EST)
Date: Wed, 7 Mar 2012 11:01:00 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v2
Message-ID: <20120307110100.GB17697@suse.de>
References: <20120306132735.GA2855@suse.de>
 <20120306122657.8e5b128d.akpm@linux-foundation.org>
 <20120306224201.GA17697@suse.de>
 <20120306145451.8eff82a6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120306145451.8eff82a6.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Mar 06, 2012 at 02:54:51PM -0800, Andrew Morton wrote:
> > > > -static inline void put_mems_allowed(void)
> > > > +/*
> > > > + * If this returns false, the operation that took place after get_mems_allowed
> > > > + * may have failed. It is up to the caller to retry the operation if
> > > > + * appropriate
> > > > + */
> > > > +static inline bool put_mems_allowed(unsigned int seq)
> > > >  {
> > > > -	/*
> > > > -	 * ensure that reading mems_allowed and mempolicy before reducing
> > > > -	 * mems_allowed_change_disable.
> > > > -	 *
> > > > -	 * the write-side task will know that the read-side task is still
> > > > -	 * reading mems_allowed or mempolicy, don't clears old bits in the
> > > > -	 * nodemask.
> > > > -	 */
> > > > -	smp_mb();
> > > > -	--ACCESS_ONCE(current->mems_allowed_change_disable);
> > > > +	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
> > > >  }
> > > >  
> > > >  static inline void set_mems_allowed(nodemask_t nodemask)
> > > 
> > > How come set_mems_allowed() still uses task_lock()?
> > >
> > 
> > Consistency.
> > 
> > The task_lock is taken by kernel/cpuset.c when updating
> > mems_allowed so it is taken here. That said, it is unnecessary to take
> > as the two places where set_mems_allowed is used are not going to be
> > racing. In the unlikely event that set_mems_allowed() gets another user,
> > there is no harm is leaving the task_lock as it is. It's not in a hot
> > path of any description.
> 
> But shouldn't set_mems_allowed() bump mems_allowed_seq?

Yes, it should. It's not necessary with the existing callers but the
"consistency" argument applies. Fixed now.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
