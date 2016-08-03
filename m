Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2337D6B0253
	for <linux-mm@kvack.org>; Wed,  3 Aug 2016 07:09:45 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so122893647wme.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 04:09:45 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id o198si26153657wmd.84.2016.08.03.04.09.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 04:09:43 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id o80so35727309wme.0
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 04:09:43 -0700 (PDT)
Date: Wed, 3 Aug 2016 13:09:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/3] mm: memcontrol: fix swap counter leak on swapout
 from offline cgroup
Message-ID: <20160803110941.GA19196@dhcp22.suse.cz>
References: <c911b6a1bacfd2bcb8ddf7314db26d0eee0f0b70.1470149524.git.vdavydov@virtuozzo.com>
 <20160802160025.GB28900@dhcp22.suse.cz>
 <20160803095049.GG13263@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160803095049.GG13263@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 03-08-16 12:50:49, Vladimir Davydov wrote:
> On Tue, Aug 02, 2016 at 06:00:26PM +0200, Michal Hocko wrote:
> > On Tue 02-08-16 18:00:48, Vladimir Davydov wrote:
> ...
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 3be791afd372..4ae12effe347 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -4036,6 +4036,24 @@ static void mem_cgroup_id_get(struct mem_cgroup *memcg)
> > >  	atomic_inc(&memcg->id.ref);
> > >  }
> > >  
> > > +static struct mem_cgroup *mem_cgroup_id_get_active(struct mem_cgroup *memcg)
> > > +{
> > > +	while (!atomic_inc_not_zero(&memcg->id.ref)) {
> > > +		/*
> > > +		 * The root cgroup cannot be destroyed, so it's refcount must
> > > +		 * always be >= 1.
> > > +		 */
> > > +		if (memcg == root_mem_cgroup) {
> > > +			VM_BUG_ON(1);
> > > +			break;
> > > +		}
> > 
> > why not simply VM_BUG_ON(memcg == root_mem_cgroup)?
> 
> Because with DEBUG_VM disabled we could wind up looping forever here if
> the refcount of the root_mem_cgroup got screwed up. On production
> kernels, it's better to break the loop and carry on closing eyes on
> diverging counters rather than getting a lockup.

Wouldn't this just paper over a real bug? Anyway I will not insist but
making the code more complex just to pretend we can handle a situation
gracefully doesn't sound right to me.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
