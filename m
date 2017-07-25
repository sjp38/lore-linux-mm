Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id A196E6B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:44:26 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so26903035wrz.10
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 05:44:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e6si16105642wrc.122.2017.07.25.05.44.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Jul 2017 05:44:25 -0700 (PDT)
Date: Tue, 25 Jul 2017 14:44:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, memcg: reset low limit during memcg offlining
Message-ID: <20170725124419.GG26723@dhcp22.suse.cz>
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
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 25-07-17 13:31:13, Roman Gushchin wrote:
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

Well, originally I wanted to suggest the same but then I asked the very
same question and couldn't answer it myself. memcg_offline_kmem feels
much more generic.

> As I understand, css_reset() callback is intended to _completely_ disable all
> limits, as if there were no cgroup at all. And it's main purpose to be called
> when controllers are detached from the hierarhy.

yes, that is my understanding as well.
 
> Offlining is different: some limits make perfect sence after offlining
> (e.g. we want to limit the writeback speed), and other might be tweaked
> (e.g. we can set soft limit to prioritize reclaiming of abandoned cgroups).

and the writeback path was exactly the one that triggered my
suspicious...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
