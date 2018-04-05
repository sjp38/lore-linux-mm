Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A5B96B0003
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 09:55:38 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d14-v6so19173310plj.4
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 06:55:38 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p91-v6si5703497plb.705.2018.04.05.06.55.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 06:55:36 -0700 (PDT)
Date: Thu, 5 Apr 2018 14:54:57 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC] mm: memory.low heirarchical behavior
Message-ID: <20180405135450.GA5396@castle.DHCP.thefacebook.com>
References: <20180320223353.5673-1-guro@fb.com>
 <20180321182308.GA28232@cmpxchg.org>
 <20180321190801.GA22452@castle.DHCP.thefacebook.com>
 <20180404170700.GA2161@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180404170700.GA2161@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 04, 2018 at 01:07:00PM -0400, Johannes Weiner wrote:
> On Wed, Mar 21, 2018 at 07:08:06PM +0000, Roman Gushchin wrote:
> > > On Tue, Mar 20, 2018 at 10:33:53PM +0000, Roman Gushchin wrote:
> > > > This patch aims to address an issue in current memory.low semantics,
> > > > which makes it hard to use it in a hierarchy, where some leaf memory
> > > > cgroups are more valuable than others.
> > > > 
> > > > For example, there are memcgs A, A/B, A/C, A/D and A/E:
> > > > 
> > > >   A      A/memory.low = 2G, A/memory.current = 6G
> > > >  //\\
> > > > BC  DE   B/memory.low = 3G  B/memory.usage = 2G
> > > >          C/memory.low = 1G  C/memory.usage = 2G
> > > >          D/memory.low = 0   D/memory.usage = 2G
> > > > 	 E/memory.low = 10G E/memory.usage = 0
> > > > 
> > > > If we apply memory pressure, B, C and D are reclaimed at
> > > > the same pace while A's usage exceeds 2G.
> > > > This is obviously wrong, as B's usage is fully below B's memory.low,
> > > > and C has 1G of protection as well.
> > > > Also, A is pushed to the size, which is less than A's 2G memory.low,
> > > > which is also wrong.
> > > > 
> > > > A simple bash script (provided below) can be used to reproduce
> > > > the problem. Current results are:
> > > >   A:    1430097920
> > > >   A/B:  711929856
> > > >   A/C:  717426688
> > > >   A/D:  741376
> > > >   A/E:  0
> > > 
> > > Yes, this is a problem. And the behavior with your patch looks much
> > > preferable over the status quo.
> > > 
> > > > To address the issue a concept of effective memory.low is introduced.
> > > > Effective memory.low is always equal or less than original memory.low.
> > > > In a case, when there is no memory.low overcommittment (and also for
> > > > top-level cgroups), these two values are equal.
> > > > Otherwise it's a part of parent's effective memory.low, calculated as
> > > > a cgroup's memory.low usage divided by sum of sibling's memory.low
> > > > usages (under memory.low usage I mean the size of actually protected
> > > > memory: memory.current if memory.current < memory.low, 0 otherwise).
> > > 
> > > This hurts my brain.
> > > 
> > > Why is memory.current == memory.low (which should fully protect
> > > memory.current) a low usage of 0?
> > > 
> > > Why is memory.current > memory.low not a low usage of memory.low?
> > > 
> > > I.e. shouldn't this be low_usage = min(memory.current, memory.low)?
> > 
> > This is really the non-trivial part.
> > 
> > Let's look at an example:
> > memcg A   (memory.current = 4G, memory.low = 2G)
> > memcg A/B (memory.current = 2G, memory.low = 2G)
> > memcg A/C (memory.current = 2G, memory.low = 1G)
> > 
> > If we'll calculate effective memory.low using your definition
> > before any reclaim, we end up with the following:
> > A/B  2G * 2G / (2G + 1G) = 4/3G
> > A/C  2G * 1G / (2G + 1G) = 2/3G
> > 
> > Looks good, but both cgroups are below their effective limits.
> > When memory pressure is applied, both are reclaimed at the same pace.
> > While both B and C are getting smaller and smaller, their weights
> > and effective low limits are getting closer and closer, but
> > still below their usages. This ends up when both cgroups will
> > have size of 1G, which is obviously wrong.
> > 
> > Fundamentally the problem is that memory.low doesn't define
> > the reclaim speed, just yes or no. So, if there are children cgroups,
> > some of which are below their memory.low, and some above (as in the example),
> > it's crucially important to reclaim unprotected memory first.
> > 
> > This is exactly what my code does: as soon as memory.current is larger
> > than memory.low, we don't treat cgroup's memory as protected at all,
> > so it doesn't affect effective limits of sibling cgroups.
> 
> Okay, that explanation makes sense to me. Once you're in excess, your
> memory is generally unprotected wrt your siblings until you're reigned
> in again.
> 
> It should still be usage <= low rather than usage < low, right? Since
> you're protected up to and including what that number says.
> 
> > > > @@ -1726,6 +1756,7 @@ static void drain_stock(struct memcg_stock_pcp *stock)
> > > >  		page_counter_uncharge(&old->memory, stock->nr_pages);
> > > >  		if (do_memsw_account())
> > > >  			page_counter_uncharge(&old->memsw, stock->nr_pages);
> > > > +		memcg_update_low(old);
> > > >  		css_put_many(&old->css, stock->nr_pages);
> > > >  		stock->nr_pages = 0;
> > > 
> > > The function is called every time the page counter changes and walks
> > > up the hierarchy exactly the same. That is a good sign that the low
> > > usage tracking should really be part of the page counter code itself.
> > 
> > I thought about it, but the problem is that page counters are used for
> > accounting swap, kmem, tcpmem (for v1), where low limit calculations are
> > not applicable. I've no idea, how to add them nicely and without excessive
> > overhead.
> > Also, good news are that it's possible to avoid any tracking until
> > a user actually overcommits memory.low guarantees. I plan to implement
> > this optimization in a separate patch.
> 
> Hm, I'm not too worried about swap (not a sensitive path) or the other
> users (per-cpu batched). It just adds a branch. How about the below?
> 
> diff --git a/include/linux/page_counter.h b/include/linux/page_counter.h
> index c15ab80ad32d..95bdbca86751 100644
> --- a/include/linux/page_counter.h
> +++ b/include/linux/page_counter.h
> @@ -9,8 +9,13 @@
>  struct page_counter {
>  	atomic_long_t count;
>  	unsigned long limit;
> +	unsigned long protected;
>  	struct page_counter *parent;
>  
> +	/* Hierarchical, proportional protection */
> +	atomic_long_t protected_count;
> +	atomic_long_t children_protected_count;
> +

I followed your approach, but without introducing the new "protected" term.
It looks cute in the usage tracking part, but a bit weird in mem_cgroup_low(),
and it's not clear how to reuse it for memory.min. I think, we shouldn't
introduce a new term without strict necessity.

Also, I moved the low field from memcg to page_counter, what made
the code simpler and cleaner.

Does it look good to you?

Thanks!

--
