Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22CAD6B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 08:07:19 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id c13so3101030eek.38
        for <linux-mm@kvack.org>; Fri, 02 May 2014 05:07:18 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si1457317eew.96.2014.05.02.05.07.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 05:07:17 -0700 (PDT)
Date: Fri, 2 May 2014 14:07:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140502120715.GI3446@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502093628.GC3446@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 02-05-14 11:36:28, Michal Hocko wrote:
> On Wed 30-04-14 18:55:50, Johannes Weiner wrote:
> > On Mon, Apr 28, 2014 at 02:26:42PM +0200, Michal Hocko wrote:
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 19d620b3d69c..40e517630138 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -2808,6 +2808,29 @@ static struct mem_cgroup *mem_cgroup_lookup(unsigned short id)
> > >  	return mem_cgroup_from_id(id);
> > >  }
> > >  
> > > +/**
> > > + * mem_cgroup_reclaim_eligible - checks whether given memcg is eligible for the
> > > + * reclaim
> > > + * @memcg: target memcg for the reclaim
> > > + * @root: root of the reclaim hierarchy (null for the global reclaim)
> > > + *
> > > + * The given group is reclaimable if it is above its low limit and the same
> > > + * applies for all parents up the hierarchy until root (including).
> > > + */
> > > +bool mem_cgroup_reclaim_eligible(struct mem_cgroup *memcg,
> > > +		struct mem_cgroup *root)
> > 
> > Could you please rename this to something that is more descriptive in
> > the reclaim callsite?  How about mem_cgroup_within_low_limit()?
> 
> I have intentionally used somethig that is not low_limit specific. The
> generic reclaim code does't have to care about the reason why a memcg is
> not reclaimable. I agree that having follow_low_limit paramter explicit
> and mem_cgroup_reclaim_eligible not is messy. So something should be
> renamed. I would probably go with s@follow_low_limit@check_reclaim_eligible@
> but I do not have a strong preference.

What about this?
---
