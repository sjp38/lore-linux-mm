Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 17B8E6B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 04:30:22 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id s12so10666452lfs.8
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:30:22 -0700 (PDT)
Received: from mail-lf0-x241.google.com (mail-lf0-x241.google.com. [2a00:1450:4010:c07::241])
        by mx.google.com with ESMTPS id g89si5839716lfh.245.2017.07.26.01.30.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 01:30:20 -0700 (PDT)
Received: by mail-lf0-x241.google.com with SMTP id d80so4576820lfg.1
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 01:30:20 -0700 (PDT)
Date: Wed, 26 Jul 2017 11:30:17 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] mm, memcg: reset low limit during memcg offlining
Message-ID: <20170726083017.3yzeucmi7lcj46qd@esperanza>
References: <20170725114047.4073-1-guro@fb.com>
 <20170725120537.o4kgzjhcjcjmopzc@esperanza>
 <20170725123113.GB12635@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725123113.GB12635@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Jul 25, 2017 at 01:31:13PM +0100, Roman Gushchin wrote:
> On Tue, Jul 25, 2017 at 03:05:37PM +0300, Vladimir Davydov wrote:
> > On Tue, Jul 25, 2017 at 12:40:47PM +0100, Roman Gushchin wrote:
> > > A removed memory cgroup with a defined low limit and some belonging
> > > pagecache has very low chances to be freed.
> > > 
> > > If a cgroup has been removed, there is likely no memory pressure inside
> > > the cgroup, and the pagecache is protected from the external pressure
> > > by the defined low limit. The cgroup will be freed only after
> > > the reclaim of all belonging pages. And it will not happen until
> > > there are any reclaimable memory in the system. That means,
> > > there is a good chance, that a cold pagecache will reside
> > > in the memory for an undefined amount of time, wasting
> > > system resources.
> > > 
> > > Fix this issue by zeroing memcg->low during memcg offlining.
> > > 
> > > Signed-off-by: Roman Gushchin <guro@fb.com>
> > > Cc: Tejun Heo <tj@kernel.org>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Michal Hocko <mhocko@kernel.org>
> > > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > > Cc: kernel-team@fb.com
> > > Cc: cgroups@vger.kernel.org
> > > Cc: linux-mm@kvack.org
> > > Cc: linux-kernel@vger.kernel.org
> > > ---
> > >  mm/memcontrol.c | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index aed11b2d0251..2aa204b8f9fd 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -4300,6 +4300,8 @@ static void mem_cgroup_css_offline(struct cgroup_subsys_state *css)
> > >  	}
> > >  	spin_unlock(&memcg->event_list_lock);
> > >  
> > > +	memcg->low = 0;
> > > +
> > >  	memcg_offline_kmem(memcg);
> > >  	wb_memcg_offline(memcg);
> > >  
> > 
> > We already have that - see mem_cgroup_css_reset().
> 
> Hm, I see...
> 
> But are you sure, that calling mem_cgroup_css_reset() from offlining path
> is always a good idea?
> 
> As I understand, css_reset() callback is intended to _completely_ disable all
> limits, as if there were no cgroup at all.

But that's exactly what cgroup offline is: deletion of a cgroup as if it
never existed. The fact that we leave the zombie dangling until all
pages charged to the cgroup are gone is an implementation detail. IIRC
we would "reparent" those charges and delete the mem_cgroup right away
if it were not inherently racy.

> And it's main purpose to be called
> when controllers are detached from the hierarhy.
> 
> Offlining is different: some limits make perfect sence after offlining
> (e.g. we want to limit the writeback speed), and other might be tweaked
> (e.g. we can set soft limit to prioritize reclaiming of abandoned cgroups).

The user can't tweak limits of an offline cgroup, because the cgroup
directory no longer exist. So IMHO resetting all limits is reasonable.
If you want to keep the cgroup limits effective, you shouldn't have
deleted it in the first place, I suppose.

You might also want to check out this:

  http://www.spinics.net/lists/linux-mm/msg102995.html

> 
> So, I'd prefer to move this code to the offlining callback,
> and not to call css_reset.
> 
> But, anyway, thanks for pointing at the mem_cgroup_css_reset().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
