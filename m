Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 402426B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 07:45:43 -0400 (EDT)
Date: Thu, 16 Jun 2011 13:45:39 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 4/8] memcg: rework soft limit reclaim
Message-ID: <20110616114538.GF9840@tiehlicka.suse.cz>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <1306909519-7286-5-git-send-email-hannes@cmpxchg.org>
 <BANLkTim5TSWpBfeF2dugGZwQmNC-Cf+GCNctraq8FtziJxsd2g@mail.gmail.com>
 <BANLkTimuRks4+h=Kjt2Lzc-s-XsAHCH9vg@mail.gmail.com>
 <20110609150026.GD3994@tiehlicka.suse.cz>
 <20110610073638.GA15403@tiehlicka.suse.cz>
 <BANLkTikUmzF6kgJ6WUQGK0M=uzPH6Ac09koCnQwi8vMbxu40WQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTikUmzF6kgJ6WUQGK0M=uzPH6Ac09koCnQwi8vMbxu40WQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed 15-06-11 15:57:59, Ying Han wrote:
> On Fri, Jun 10, 2011 at 12:36 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 09-06-11 17:00:26, Michal Hocko wrote:
> >> On Thu 02-06-11 22:25:29, Ying Han wrote:
> >> > On Thu, Jun 2, 2011 at 2:55 PM, Ying Han <yinghan@google.com> wrote:
> >> > > On Tue, May 31, 2011 at 11:25 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> >> > >> Currently, soft limit reclaim is entered from kswapd, where it selects
> >> [...]
> >> > >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > >> index c7d4b44..0163840 100644
> >> > >> --- a/mm/vmscan.c
> >> > >> +++ b/mm/vmscan.c
> >> > >> @@ -1988,9 +1988,13 @@ static void shrink_zone(int priority, struct zone *zone,
> >> > >>                unsigned long reclaimed = sc->nr_reclaimed;
> >> > >>                unsigned long scanned = sc->nr_scanned;
> >> > >>                unsigned long nr_reclaimed;
> >> > >> +               int epriority = priority;
> >> > >> +
> >> > >> +               if (mem_cgroup_soft_limit_exceeded(root, mem))
> >> > >> +                       epriority -= 1;
> >> > >
> >> > > Here we grant the ability to shrink from all the memcgs, but only
> >> > > higher the priority for those exceed the soft_limit. That is a design
> >> > > change
> >> > > for the "soft_limit" which giving a hint to which memcgs to reclaim
> >> > > from first under global memory pressure.
> >> >
> >> >
> >> > Basically, we shouldn't reclaim from a memcg under its soft_limit
> >> > unless we have trouble reclaim pages from others.
> >>
> >> Agreed.
> >>
> >> > Something like the following makes better sense:
> >> >
> >> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> > index bdc2fd3..b82ba8c 100644
> >> > --- a/mm/vmscan.c
> >> > +++ b/mm/vmscan.c
> >> > @@ -1989,6 +1989,8 @@ restart:
> >> >         throttle_vm_writeout(sc->gfp_mask);
> >> >  }
> >> >
> >> > +#define MEMCG_SOFTLIMIT_RECLAIM_PRIORITY       2
> >> > +
> >> >  static void shrink_zone(int priority, struct zone *zone,
> >> >                                 struct scan_control *sc)
> >> >  {
> >> > @@ -2001,13 +2003,13 @@ static void shrink_zone(int priority, struct zone *zone,
> >> >                 unsigned long reclaimed = sc->nr_reclaimed;
> >> >                 unsigned long scanned = sc->nr_scanned;
> >> >                 unsigned long nr_reclaimed;
> >> > -               int epriority = priority;
> >> >
> >> > -               if (mem_cgroup_soft_limit_exceeded(root, mem))
> >> > -                       epriority -= 1;
> >> > +               if (!mem_cgroup_soft_limit_exceeded(root, mem) &&
> >> > +                               priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
> >> > +                       continue;
> >>
> >> yes, this makes sense but I am not sure about the right(tm) value of the
> >> MEMCG_SOFTLIMIT_RECLAIM_PRIORITY. 2 sounds too low.
> >
> > There is also another problem. I have just realized that this code path
> > is shared with the cgroup direct reclaim. We shouldn't care about soft
> > limit in such a situation. It would be just a wasting of cycles. So we
> > have to:
> >
> > if (current_is_kswapd() &&
> >        !mem_cgroup_soft_limit_exceeded(root, mem) &&
> >        priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
> >        continue;
> 
> Agreed.
> 
> >
> > Maybe the condition would have to be more complex for per-cgroup
> > background reclaim, though.
> 
> That would be the same logic for per-memcg direct reclaim. In general,
> we don't consider soft_limit
> unless the global memory pressure. So the condition could be something like:
> 
> > if (   global_reclaim(sc) &&
> >        !mem_cgroup_soft_limit_exceeded(root, mem) &&
> >        priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
> >        continue;
> 
> make sense?

Yes seems to be more consistent.

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
