Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id D9DFE6B0036
	for <linux-mm@kvack.org>; Thu, 25 Sep 2014 09:43:58 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id z2so9475644wiv.2
        for <linux-mm@kvack.org>; Thu, 25 Sep 2014 06:43:58 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id r8si10613174wif.54.2014.09.25.06.43.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Sep 2014 06:43:56 -0700 (PDT)
Date: Thu, 25 Sep 2014 09:43:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcontrol: do not iterate uninitialized memcgs
Message-ID: <20140925134342.GB22508@cmpxchg.org>
References: <1411612278-4707-1-git-send-email-hannes@cmpxchg.org>
 <20140925025758.GA6903@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140925025758.GA6903@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 24, 2014 at 10:57:58PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Wed, Sep 24, 2014 at 10:31:18PM -0400, Johannes Weiner wrote:
> ..
> > not meet the ordering requirements for memcg, and so we still may see
> > partially initialized memcgs from the iterators.
> 
> It's mainly the other way around - a fully initialized css may not
> show up in an iteration, but given that there's no memory ordering or
> synchronization around the flag, anything can happen.

Oh sure, I'm just more worried about leaking invalid memcgs rather
than temporarily skipping over a fully initialized one.  But I updated
the changelog to mention both possibilities.

> > +		if (next_css == &root->css ||
> > +		    css_tryget_online(next_css)) {
> > +			struct mem_cgroup *memcg;
> > +
> > +			memcg = mem_cgroup_from_css(next_css);
> > +			if (memcg->initialized) {
> > +				/*
> > +				 * Make sure the caller's accesses to
> > +				 * the memcg members are issued after
> > +				 * we see this flag set.
> 
> I usually prefer if the comment points to the exact location that the
> matching memory barriers live.  Sometimes it's difficult to locate the
> partner barrier even w/ the functional explanation.

That makes sense, updated.

> > +				 */
> > +				smp_rmb();
> > +				return memcg;
> 
> In an unlikely event this rmb becomes an issue, a self-pointing
> pointer which is set/read using smp_store_release() and
> smp_load_acquire() respectively can do with plain barrier() on the
> reader side on archs which don't need data dependency barrier
> (basically everything except alpha).  Not sure whether that'd be more
> or less readable than this tho.

So as far as I understand memory-barriers.txt we do not even need a
data dependency here to use store_release and load_acquire:

mem_cgroup_css_online():
<initialize memcg>
smp_store_release(&memcg->initialized, 1);

mem_cgroup_iter():
<look up maybe-initialized memcg>
if (smp_load_acquire(&memcg->initialized))
  return memcg;

So while I doubt that the smp_rmb() will become a problem in this
path, it would be neat to annotate the state flag around which we
synchronize like this, rather than have an anonymous barrier.

Peter, would you know if this is correct, or whether these primitives
actually do require a data dependency?

Thanks!

Updated patch:

---
