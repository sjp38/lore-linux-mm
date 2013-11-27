Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f49.google.com (mail-bk0-f49.google.com [209.85.214.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7DC586B0031
	for <linux-mm@kvack.org>; Wed, 27 Nov 2013 11:39:21 -0500 (EST)
Received: by mail-bk0-f49.google.com with SMTP id my13so3301273bkb.22
        for <linux-mm@kvack.org>; Wed, 27 Nov 2013 08:39:20 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id cg7si12482104bkc.339.2013.11.27.08.39.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 27 Nov 2013 08:39:20 -0800 (PST)
Date: Wed, 27 Nov 2013 11:39:16 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
Message-ID: <20131127163916.GB3556@cmpxchg.org>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Nov 26, 2013 at 07:33:12PM -0800, David Rientjes wrote:
> On Tue, 26 Nov 2013, David Rientjes wrote:
> 
> > On Fri, 22 Nov 2013, Johannes Weiner wrote:
> > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 13b9d0f..cc4f9cb 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2677,6 +2677,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> > >  	if (unlikely(task_in_memcg_oom(current)))
> > >  		goto bypass;
> > >  
> > > +	if (gfp_mask & __GFP_NOFAIL)
> > > +		oom = false;
> > > +
> > >  	/*
> > >  	 * We always charge the cgroup the mm_struct belongs to.
> > >  	 * The mm_struct's mem_cgroup changes on task migration if the
> > 
> > Sorry, I don't understand this.  What happens in the following scenario:
> > 
> >  - memory.usage_in_bytes == memory.limit_in_bytes,
> > 
> >  - memcg reclaim fails to reclaim memory, and
> > 
> >  - all processes (perhaps only one) attached to the memcg are doing one of
> >    the over dozen __GFP_NOFAIL allocations in the kernel?
> > 
> > How do we make forward progress if you cannot oom kill something?

Bypass the limit.

> Ah, this is because of 3168ecbe1c04 ("mm: memcg: use proper memcg in limit 
> bypass") which just bypasses all of these allocations and charges the root 
> memcg.  So if allocations want to bypass memcg isolation they just have to 
> be __GFP_NOFAIL?

I don't think we have another option.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
