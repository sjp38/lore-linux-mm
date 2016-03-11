Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2596B007E
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 10:53:04 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id fe3so85538522pab.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:53:04 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id h7si6121390pat.9.2016.03.11.07.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Mar 2016 07:53:02 -0800 (PST)
Date: Fri, 11 Mar 2016 18:52:53 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: [PATCH] mm: memcontrol: zap
 task_struct->memcg_oom_{gfp_mask,order}
Message-ID: <20160311155252.GR1946@esperanza>
References: <1457691167-22756-1-git-send-email-vdavydov@virtuozzo.com>
 <20160311115450.GH27701@dhcp22.suse.cz>
 <20160311123900.GM1946@esperanza>
 <20160311125104.GM27701@dhcp22.suse.cz>
 <20160311134533.GN1946@esperanza>
 <20160311143031.GS27701@dhcp22.suse.cz>
 <20160311150224.GQ1946@esperanza>
 <20160311154704.GW27701@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20160311154704.GW27701@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Mar 11, 2016 at 04:47:04PM +0100, Michal Hocko wrote:
> On Fri 11-03-16 18:02:24, Vladimir Davydov wrote:
> > On Fri, Mar 11, 2016 at 03:30:31PM +0100, Michal Hocko wrote:
> [...]
> > > Not really. GFP_KERNEL would allow to invoke some shrinkers which are
> > > GFP_NOFS incopatible.
> > 
> > Can't a GFP_NOFS allocation happen when there is no shrinkable objects
> > to drop so that there's no real difference between GFP_KERNEL and
> > GFP_NOFS?
> 
> Yes it can and we do not handle that case even in the global case.
>  
> [...]
> > > > We could ratelimit these messages. Slab charge failures are already
> > > > reported to dmesg (see ___slab_alloc -> slab_out_of_memory) and nobody's
> > > > complained so far. Are there any non-slab GFP_NOFS allocations charged
> > > > to memcg?
> > > 
> > > I believe there might be some coming from FS via add_to_page_cache_lru.
> > > Especially when their mapping gfp_mask clears __GFP_FS. I haven't
> > > checked the code deeper but some of those might be called from the page
> > > fault path and trigger memcg OOM. I would have to look closer.
> > 
> > If you think this warning is really a must have, and you don't like to
> > warn about every charge failure, may be we could just print info about
> > allocation that triggered OOM right in mem_cgroup_oom, like the code
> > below does? I think it would be more-or-less equivalent to what we have
> > now except it wouldn't require storing gfp_mask on task_struct.
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index a217b1374c32..d8e130d14f5d 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1604,6 +1604,8 @@ static void mem_cgroup_oom(struct mem_cgroup *memcg, gfp_t mask, int order)
> >  	 */
> >  	css_get(&memcg->css);
> >  	current->memcg_in_oom = memcg;
> > +
> > +	pr_warn("Process ... triggered OOM in memcg ... gfp ...\n");
> 
> Hmm, that could lead to intermixed oom reports and matching the failure
> to the particular report would be slighltly harder. But I guess it would
> be acceptable if it can help to shrink the task_struct in the end. There
> are people (google at least) who rely on the oom reports so I would
> asked them if they are OK with that. I do not see any obvious issues
> with this.

OK, I'll send v2 then.

Thanks a lot for your feedback.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
