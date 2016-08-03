Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 331D66B0005
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 08:00:31 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so113013673lfw.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 05:00:31 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id hu9si7641062wjb.5.2016.08.03.05.00.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 05:00:29 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id i5so35980081wmg.2
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 05:00:29 -0700 (PDT)
Date: Wed, 3 Aug 2016 14:00:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803120027.GA1490@dhcp22.suse.cz>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160803095049.GG13263@esperanza>
 <20160803110941.GA19196@dhcp22.suse.cz>
 <20160803114639.GI13263@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160803114639.GI13263@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-08-16 14:46:40, Vladimir Davydov wrote:
> On Wed, Aug 03, 2016 at 01:09:42PM +0200, Michal Hocko wrote:
> > On Wed 03-08-16 12:50:49, Vladimir Davydov wrote:
> > > On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> > > > On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> > > ...
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index 3be791afd372..4ae12effe347 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
> > > > >  	atomic_inc(&memcg->id.ref);
> > > > >  }
> > > > >  
> > > > > +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> > > > > +{
> > > > > +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> > > > > +		/*
> > > > > +		 * The root cgroup cannot be destroyed, so it's refcount must
> > > > > +		 * always be >= 1.
> > > > > +		 */
> > > > > +		if (memcg == root_mem_cgroup) {
> > > > > +			VM_BUG_ON(1);
> > > > > +			break;
> > > > > +		}
> > > > 
> > > > why not simply VM_BUG_ON(memcg == root_mem_cgroup)?
> > > 
> > > Because with DEBUG_VM disabled we could wind up looping forever here if
> > > the refcount of the root_mem_cgroup got screwed up. On production
> > > kernels, it's better to break the loop and carry on closing eyes on
> > > diverging counters rather than getting a lockup.
> > 
> > Wouldn't this just paper over a real bug? Anyway I will not insist but
> > making the code more complex just to pretend we can handle a situation
> > gracefully doesn't sound right to me.
> 
> But we can handle this IMO. AFAICS diverging id refcount will typically
> result in leaking swap charges, which aren't even a real resource.

Fair enough.

> At
> worst, we can leak an offline mem_cgroup, which is also not critical
> enough to crash the production system.

Agreed.

> I see your concern of papering over a bug though. What about adding a
> warning there?

WARN_ON_ONCE sounds better...
 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 1c0aa59fd333..8c8e68becee9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4044,7 +4044,7 @@ static struct mem_cgroup *mem_cgroup_id_get_online(struct mem_cgroup *memcg)
>  		 * The root cgroup cannot be destroyed, so it's refcount must
>  		 * always be >= 1.
>  		 */
> -		if (memcg == root_mem_cgroup) {
> +		if (WARN_ON_ONCE(memcg == root_mem_cgroup)) {
>  			VM_BUG_ON(1);
>  			break;
>  		}
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
