Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 7F11F6B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 12:08:21 -0500 (EST)
Received: by mail-wg0-f54.google.com with SMTP id z12so16119562wgg.13
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:08:21 -0800 (PST)
Received: from mail-wg0-x232.google.com (mail-wg0-x232.google.com. [2a00:1450:400c:c00::232])
        by mx.google.com with ESMTPS id n2si11518796wiy.31.2015.01.15.09.08.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 15 Jan 2015 09:08:20 -0800 (PST)
Received: by mail-wg0-f50.google.com with SMTP id a1so16136871wgh.9
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 09:08:20 -0800 (PST)
Date: Thu, 15 Jan 2015 18:08:17 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 2/2] mm: memcontrol: default hierarchy interface for
 memory
Message-ID: <20150115170817.GE7008@dhcp22.suse.cz>
References: <1420776904-8559-1-git-send-email-hannes@cmpxchg.org>
 <1420776904-8559-2-git-send-email-hannes@cmpxchg.org>
 <20150114153425.GF4706@dhcp22.suse.cz>
 <20150114171944.GB32040@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150114171944.GB32040@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 14-01-15 12:19:44, Johannes Weiner wrote:
> On Wed, Jan 14, 2015 at 04:34:25PM +0100, Michal Hocko wrote:
> > On Thu 08-01-15 23:15:04, Johannes Weiner wrote:
[...]
> > > @@ -2322,6 +2325,12 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> > >  			struct lruvec *lruvec;
> > >  			int swappiness;
> > >  
> > > +			if (mem_cgroup_low(root, memcg)) {
> > > +				if (!sc->may_thrash)
> > > +					continue;
> > > +				mem_cgroup_events(memcg, MEMCG_LOW, 1);
> > > +			}
> > > +
> > >  			lruvec = mem_cgroup_zone_lruvec(zone, memcg);
> > >  			swappiness = mem_cgroup_swappiness(memcg);
> > >  
> > > @@ -2343,8 +2352,7 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> > >  				mem_cgroup_iter_break(root, memcg);
> > >  				break;
> > >  			}
> > > -			memcg = mem_cgroup_iter(root, memcg, &reclaim);
> > > -		} while (memcg);
> > > +		} while ((memcg = mem_cgroup_iter(root, memcg, &reclaim)));
> > 
> > I had a similar code but then I could trigger quick priority drop downs
> > during parallel reclaim with multiple low limited groups. I've tried to
> > address that by retrying shrink_zone if it hasn't called shrink_lruvec
> > at all. Still not ideal because it can livelock theoretically, but I
> > haven't seen that in my testing.
> 
> Do you remember the circumstances and the exact configuration?

Well, I was testing heavy parallel memory intensive load (combination of
anon and file) in one memcg and many (hundreds of) idle memcgs to see
how much overhead memcg traversing would cost us. And I misconfigured by
setting idle memcgs low-limit to -1 instead of 0. There is nothing
running in them.
I've noticed that I can see more pages reclaimed than expected and also
higher runtime which turned out to be related to longer stalls during
reclaim rather than the cost of the memcg reclaim iterator.  Debugging
has shown that many direct reclaimers were racing over low-limited
groups and dropped to lower priorities. The race window was apparently
much much smaller than a noop shrink_lruvec run.

So in a sense this was a mis-configured system because I do not expect
so many low limited groups in real life but there was still something
reclaimable so the machine wasn't really over-committed. So this points
to an issue which might happen, albeit in a smaller scale, if there are
many groups, heavy reclaim and some reclaimers unlucky to race and see
only low-limited groups.
 
> I tested this with around 30 containerized kernel build jobs whose low
> boundaries pretty much added up to the available physical memory and
> never observed this.  That being said, thrashing is an emergency path
> and users should really watch the memory.events low counter.  After
> all, if global reclaim frequently has to ignore the reserve settings,
> what's the point of having them in the first place?

Sure, over-committed low limit is a misconfiguration. But this is not
what happened in my testing.

> So while I see that this might burn some cpu cycles when the system is
> misconfigured, and that we could definitely be smarter about this, I'm
> not convinced we have to rush a workaround before moving ahead with
> this patch, especially not one that is prone to livelock the system.

OK, then do not merge it to the original patch. If for nothing else then
for bisectability. I will post a patch separately. I still think we
should consider a way how to address it sooner or later because the
result would be non trivial to debug.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
