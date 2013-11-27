Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vb0-f46.google.com (mail-vb0-f46.google.com [209.85.212.46])
	by kanga.kvack.org (Postfix) with ESMTP id AA0796B0031
	for <linux-mm@kvack.org>; Tue, 26 Nov 2013 22:33:16 -0500 (EST)
Received: by mail-vb0-f46.google.com with SMTP id i12so4423687vbh.19
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:33:16 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id c1si20418114vcs.103.2013.11.26.19.33.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 26 Nov 2013 19:33:15 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id i72so4676369yha.39
        for <linux-mm@kvack.org>; Tue, 26 Nov 2013 19:33:15 -0800 (PST)
Date: Tue, 26 Nov 2013 19:33:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: memcg: do not declare OOM from __GFP_NOFAIL
 allocations
In-Reply-To: <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1311261931210.5973@chino.kir.corp.google.com>
References: <1385140676-5677-1-git-send-email-hannes@cmpxchg.org> <alpine.DEB.2.02.1311261658170.21003@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, 26 Nov 2013, David Rientjes wrote:

> On Fri, 22 Nov 2013, Johannes Weiner wrote:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 13b9d0f..cc4f9cb 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2677,6 +2677,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
> >  	if (unlikely(task_in_memcg_oom(current)))
> >  		goto bypass;
> >  
> > +	if (gfp_mask & __GFP_NOFAIL)
> > +		oom = false;
> > +
> >  	/*
> >  	 * We always charge the cgroup the mm_struct belongs to.
> >  	 * The mm_struct's mem_cgroup changes on task migration if the
> 
> Sorry, I don't understand this.  What happens in the following scenario:
> 
>  - memory.usage_in_bytes == memory.limit_in_bytes,
> 
>  - memcg reclaim fails to reclaim memory, and
> 
>  - all processes (perhaps only one) attached to the memcg are doing one of
>    the over dozen __GFP_NOFAIL allocations in the kernel?
> 
> How do we make forward progress if you cannot oom kill something?
> 

Ah, this is because of 3168ecbe1c04 ("mm: memcg: use proper memcg in limit 
bypass") which just bypasses all of these allocations and charges the root 
memcg.  So if allocations want to bypass memcg isolation they just have to 
be __GFP_NOFAIL?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
