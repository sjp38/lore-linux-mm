Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5AC3B6B0039
	for <linux-mm@kvack.org>; Thu,  9 May 2013 13:33:52 -0400 (EDT)
Date: Thu, 9 May 2013 18:33:48 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC PATCH 00/22] Per-cpu page allocator replacement prototype
Message-ID: <20130509173348.GI11497@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
 <518BC3BD.30005@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <518BC3BD.30005@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, May 09, 2013 at 08:41:49AM -0700, Dave Hansen wrote:
> On 05/08/2013 09:02 AM, Mel Gorman wrote:
> > So preliminary testing indicates the results are mixed bag. As long as
> > locks are not contended, it performs fine but parallel fault testing
> > hits into spinlock contention on the magazine locks. A greater problem
> > is that because CPUs share magazines it means that the struct pages are
> > frequently dirtied cache lines. If CPU A frees a page to a magazine and
> > CPU B immediately allocates it then the cache line for the page and the
> > magazine bounces and this costs. It's on the TODO list to research if the
> > available literature has anything useful to say that does not depend on
> > per-cpu lists and the associated problems with them.
> 
> If we don't want to bounce 'struct page' cache lines around, then we
> _need_ to make sure that things that don't share caches don't use the
> same magazine.  I'm not sure there's any other way.  But, that doesn't
> mean we have to _statically_ assign cores/thread to particular magazines.
> 

We could do something similar to sd_llc_id in kernel/sched/core.c to
match CPUs to magazines where the data is likely to be at least in the
last level cache.

> Say we had a percpu hint which points us to the last magazine we used.
> We always go to it first, and fall back to round-robin if our preferred
> one is contended.  That way, if we have a mixture tasks doing heavy and
> light allocations, the heavy allocators will tend to "own" a magazine,
> and the lighter ones would gravitate to sharing one.
> 

We might not need the percpu hint if the sd_llc_id style hint was good
enough.

> It might be taking things too far, but we could even raise the number of
> magazines only when we actually *see* contention on the existing set.
> 

I had considered a similar idea. I think it would be relatively easy to
grow the number of magazines or even allocate them on a per-process
basis but it was less clear how it would be shrunk again.

> >  24 files changed, 571 insertions(+), 788 deletions(-)
> 
> oooooooooooooooooohhhhhhhhhhhhh.
> 
> The only question is how much we'll have to bloat it as we try to
> optimize things. :)
> 

Indeed :/

> BTW, I really like the 'magazine' name.  It's not frequently used in
> this kind of context and it conjures up a nice mental image whether it
> be of stacks of periodicals or firearm ammunition clips.

I remember the term from the papers Christoph cited.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
