Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 30EB26B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 18:01:14 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so3524978eek.29
        for <linux-mm@kvack.org>; Fri, 02 May 2014 15:01:13 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id y6si2835673eep.257.2014.05.02.15.01.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 02 May 2014 15:01:12 -0700 (PDT)
Date: Fri, 2 May 2014 18:00:56 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140502220056.GP23420@cmpxchg.org>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140502164930.GP3446@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, May 02, 2014 at 06:49:30PM +0200, Michal Hocko wrote:
> On Fri 02-05-14 11:58:05, Johannes Weiner wrote:
> > On Fri, May 02, 2014 at 11:36:28AM +0200, Michal Hocko wrote:
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
> > > 
> > > > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > > > index c1cd99a5074b..0f428158254e 100644
> > > > > --- a/mm/vmscan.c
> > > > > +++ b/mm/vmscan.c
> > > [...]
> > > > > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > > > > +{
> > > > > +	if (!__shrink_zone(zone, sc, true)) {
> > > > > +		/*
> > > > > +		 * First round of reclaim didn't find anything to reclaim
> > > > > +		 * because of low limit protection so try again and ignore
> > > > > +		 * the low limit this time.
> > > > > +		 */
> > > > > +		__shrink_zone(zone, sc, false);
> > > > > +	}
> > 
> > So I don't think this can work as it is, because we are not actually
> > changing priority levels yet. 
> 
> __shrink_zone returns with 0 only if the whole hierarchy is is under low
> limit. This means that they are over-committed and it doesn't make much
> sense to play with priority. Low limit reclaimability is independent on
> the priority.
> 
> > It will give up on the guarantees of bigger groups way before smaller
> > groups are even seriously looked at.
> 
> How would that happen? Those (smaller) groups would get reclaimed and we
> wouldn't fallback. Or am I missing your point?

Lol, I hadn't updated my brain to a394cb8ee632 ("memcg,vmscan: do not
break out targeted reclaim without reclaimed pages") yet...  Yes, you
are right.

> > > > I would actually prefer not having a second round here, and make the
> > > > low limit behave more like mlock memory.  If there is no reclaimable
> > > > memory, go OOM.
> > > 
> > > This was done in my previous attempt and I prefer OOM myself but it is
> > > also true that starting with a more relaxed limit and adding an
> > > option for hard guarantee later when we have a clear usecase is a better
> > > approach. Although I can see potential in go-oom-rather-than-reclaim
> > > configurations, usecases I am primarily interested in won't overcommit on
> > > low_limit.
> > > 
> > > That being said, I like the idea of having the hard guarantee but I also
> > > think it should be configurable. I can post those patches in this thread
> > > but I feel it is too early as nobody has explicitly asked for this yet.
> > 
> > As per above, this makes the semantics so much more fishy.  When
> > exactly do we stop honoring the guarantees in the process?
> 
> When the reclaimed hierarchy is bellow low_limit. In other words when we
> would go and OOM without fallback.
>
> > This is not even guarantees anymore, but rather another reclaim
> > prioritization scheme with best-effort semantics.  That went over
> > horribly with soft limits, and I don't want to repeat this.
> > 
> > Overcommitting on guarantees makes no sense, and you even agree you
> > are not interested in it.  We also agree that we can always add a knob
> > later on to change semantics when an actual usecase presents itself,
> > so why not start with the clear and simple semantics, and the simpler
> > implementation?
> 
> So you are really preferring an OOM instead? That was the original
> implementation posted at the end of last year and some people
> had concerns about it. This is the primary reason I came up with a
> weaker version which fallbacks rather than OOM.

I'll dig through the archives on this then, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
