Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1C56B0007
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 08:22:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t133so817636wmt.6
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 05:22:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u14si183051edd.30.2018.04.06.05.22.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 05:22:14 -0700 (PDT)
Date: Fri, 6 Apr 2018 13:21:38 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH v3 3/4] mm: treat memory.low value inclusive
Message-ID: <20180406122132.GA7185@castle>
References: <20180405185921.4942-1-guro@fb.com>
 <20180405185921.4942-3-guro@fb.com>
 <20180405194526.GC27918@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180405194526.GC27918@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 05, 2018 at 03:45:26PM -0400, Johannes Weiner wrote:
> On Thu, Apr 05, 2018 at 07:59:20PM +0100, Roman Gushchin wrote:
> > If memcg's usage is equal to the memory.low value, avoid reclaiming
> > from this cgroup while there is a surplus of reclaimable memory.
> > 
> > This sounds more logical and also matches memory.high and memory.max
> > behavior: both are inclusive.
> 
> I was trying to figure out why we did it this way in the first place
> and found this patch:
> 
> commit 4e54dede38b45052a941bcf709f7d29f2e18174d
> Author: Michal Hocko <mhocko@suse.cz>
> Date:   Fri Feb 27 15:51:46 2015 -0800
> 
>     memcg: fix low limit calculation
>     
>     A memcg is considered low limited even when the current usage is equal to
>     the low limit.  This leads to interesting side effects e.g.
>     groups/hierarchies with no memory accounted are considered protected and
>     so the reclaim will emit MEMCG_LOW event when encountering them.
>     
>     Another and much bigger issue was reported by Joonsoo Kim.  He has hit a
>     NULL ptr dereference with the legacy cgroup API which even doesn't have
>     low limit exposed.  The limit is 0 by default but the initial check fails
>     for memcg with 0 consumption and parent_mem_cgroup() would return NULL if
>     use_hierarchy is 0 and so page_counter_read would try to dereference NULL.
>     
>     I suppose that the current implementation is just an overlook because the
>     documentation in Documentation/cgroups/unified-hierarchy.txt says:
>     
>       "The memory.low boundary on the other hand is a top-down allocated
>       reserve.  A cgroup enjoys reclaim protection when it and all its
>       ancestors are below their low boundaries"
>     
>     Fix the usage and the low limit comparision in mem_cgroup_low accordingly.
>     
> > @@ -5709,7 +5709,7 @@ bool mem_cgroup_low(struct mem_cgroup *root, struct mem_cgroup *memcg)
> >  	elow = min(elow, parent_elow * low_usage / siblings_low_usage);
> >  exit:
> >  	memcg->memory.elow = elow;
> > -	return usage < elow;
> > +	return usage <= elow;
> 
> So I think this needs to be usage && usage <= elow to not emit
> MEMCG_LOW events in case usage == elow == 0.

Perfect catch! Thanks, Johannes!

Updated version below.

--
