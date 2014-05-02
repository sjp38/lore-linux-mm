Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 68AB36B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 10:15:21 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so3216469eek.4
        for <linux-mm@kvack.org>; Fri, 02 May 2014 07:15:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x46si1748347eea.239.2014.05.02.07.15.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 07:15:18 -0700 (PDT)
Date: Fri, 2 May 2014 16:15:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140502141515.GJ3446@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502120715.GI3446@dhcp22.suse.cz>
 <20140502130118.GK23420@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502130118.GK23420@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 02-05-14 09:01:18, Johannes Weiner wrote:
> On Fri, May 02, 2014 at 02:07:15PM +0200, Michal Hocko wrote:
> > On Fri 02-05-14 11:36:28, Michal Hocko wrote:
> > > On Wed 30-04-14 18:55:50, Johannes Weiner wrote:
> > > > On Mon, Apr 28, 2014 at 02:26:42PM +0200, Michal Hocko wrote:
> > > > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > > > index 19d620b3d69c..40e517630138 100644
> > > > > --- a/mm/memcontrol.c
> > > > > +++ b/mm/memcontrol.c
> > > > > @@ -2808,6 +2808,29 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> > > > >  	return mem_cgroup_from_id(id);
> > > > >  }
> > > > >  
> > > > > +/**
> > > > > + * mem_cgroup_reclaim_eligible - checks whether given memcg is eligible for the
> > > > > + * reclaim
> > > > > + * @memcg: target memcg for the reclaim
> > > > > + * @root: root of the reclaim hierarchy (null for the global reclaim)
> > > > > + *
> > > > > + * The given group is reclaimable if it is above its low limit and the same
> > > > > + * applies for all parents up the hierarchy until root (including).
> > > > > + */
> > > > > +bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> > > > > +		struct mem_cgroup *root)
> > > > 
> > > > Could you please rename this to something that is more descriptive in
> > > > the reclaim callsite?  How about mem_cgroup_within_low_limit()?
> > > 
> > > I have intentionally used somethig that is not low_limit specific. The
> > > generic reclaim code does't have to care about the reason why a memcg is
> > > not reclaimable. I agree that having follow_low_limit paramter explicit
> > > and mem_cgroup_reclaim_eligible not is messy. So something should be
> > > renamed. I would probably go with s@follow_low_limit@check_reclaim_eligible@
> > > but I do not have a strong preference.
> > 
> > What about this?
> 
> I really don't like it.
> 
> Yes, we should be hiding implementation details, but we should stop
> treating memcg like an alien in this code.  The VM code obviously
> doesn't have to know HOW the guarantees are exactly implemented, but
> it's a perfectly fine *concept* that can be known outside of memcg:
> 
> shrink_zone:
> for each memcg in system:
>   if mem_cgroup_within_guarantee(memcg):
>     continue
>   reclaim(memcg-zone)
> 
> is perfectly understandable and makes it easier to reason about the
> behavior of the reclaim code.  If I just see !mem_cgroup_eligible(), I
> don't know if this affects the scenario I'm thinking about at all.
> 
> It's obscuring useful information for absolutely no benefit.  If you
> burden the reclaim code with a callback, you better explain what you
> are doing.  You owe it to the reader.

OK fair enough, what about the following?
---
