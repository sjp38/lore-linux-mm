Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 548B36B0082
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 04:35:32 -0400 (EDT)
Date: Thu, 9 Jun 2011 10:35:03 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 0/8] mm: memcg naturalization -rc2
Message-ID: <20110609083503.GC11603@cmpxchg.org>
References: <1306909519-7286-1-git-send-email-hannes@cmpxchg.org>
 <BANLkTikgqSsg5+49295h7kdZ=sQpZLs4kw@mail.gmail.com>
 <BANLkTi=sYtLGk2_VQLejEU2rQ0JBgg_ZmQ@mail.gmail.com>
 <20110602075028.GB20630@cmpxchg.org>
 <BANLkTi=AZG4LKUdeODB0uP=_CVBRnGs_Nw@mail.gmail.com>
 <20110602175142.GH28684@cmpxchg.org>
 <BANLkTi=9083abfiKdZ5_oXyA+dZqaXJfZg@mail.gmail.com>
 <20110608153211.GB27827@cmpxchg.org>
 <BANLkTincHpoay1JtpjG0RY9CCvfepRohTXUH6KKULYJ9jbdo+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <BANLkTincHpoay1JtpjG0RY9CCvfepRohTXUH6KKULYJ9jbdo+A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 08, 2011 at 08:52:03PM -0700, Ying Han wrote:
> On Wed, Jun 8, 2011 at 8:32 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Jun 07, 2011 at 08:53:21PM -0700, Ying Han wrote:
> >> 2. The way we treat the per-memcg soft_limit is changed in this patch.
> >> The same comment I made on the following patch where we shouldn't
> >> change the definition of user API (soft_limit_in_bytes in this case).
> >> So I attached the patch to fix that where we should only go to the
> >> ones under their soft_limit above certain reclaim priority. Please
> >> consider.
> >
> > Here is your proposal from the other mail:
> >
> > : Basically, we shouldn't reclaim from a memcg under its soft_limit
> > : unless we have trouble reclaim pages from others. Something like the
> > : following makes better sense:
> > :
> > : diff --git a/mm/vmscan.c b/mm/vmscan.c
> > : index bdc2fd3..b82ba8c 100644
> > : --- a/mm/vmscan.c
> > : +++ b/mm/vmscan.c
> > : @@ -1989,6 +1989,8 @@ restart:
> > :         throttle_vm_writeout(sc->gfp_mask);
> > :  }
> > :
> > : +#define MEMCG_SOFTLIMIT_RECLAIM_PRIORITY       2
> > : +
> > :  static void shrink_zone(int priority, struct zone *zone,
> > :                                 struct scan_control *sc)
> > :  {
> > : @@ -2001,13 +2003,13 @@ static void shrink_zone(int priority, struct zone *zone,
> > :                 unsigned long reclaimed = sc->nr_reclaimed;
> > :                 unsigned long scanned = sc->nr_scanned;
> > :                 unsigned long nr_reclaimed;
> > : -               int epriority = priority;
> > :
> > : -               if (mem_cgroup_soft_limit_exceeded(root, mem))
> > : -                       epriority -= 1;
> > : +               if (!mem_cgroup_soft_limit_exceeded(root, mem) &&
> > : +                               priority > MEMCG_SOFTLIMIT_RECLAIM_PRIORITY)
> > : +                       continue;
> >
> > I am not sure if you are serious or playing devil's advocate here,
> > because it exacerbates the problem you are concerned about in 1. by
> > orders of magnitude.
> 
> No, the two are different issues. The first one is a performance
> concern of detailed implementation, while the second one is a design
> concern.

Got ya.

> > I guess it would make much more sense to evaluate if reclaiming from
> > memcgs while there are others exceeding their soft limit is even a
> > problem.  Otherwise this discussion is pretty pointless.
> 
> AFAIK it is a problem since it changes the spec of kernel API
> memory.soft_limit_in_bytes. That value is set per-memcg which all the
> pages allocated above that are best effort and targeted to reclaim
> prior to others.

That's not really true.  Quoting the documentation:

    When the system detects memory contention or low memory, control groups
    are pushed back to their soft limits. If the soft limit of each control
    group is very high, they are pushed back as much as possible to make
    sure that one control group does not starve the others of memory.

I am language lawyering here, but I don't think it says it won't touch
other memcgs at all while there are memcgs exceeding their soft limit.

It would be a lie about the current code in the first place, which
does soft limit reclaim and then regular reclaim, no matter the
outcome of the soft limit reclaim cycle.  It will go for the soft
limit first, but after an allocation under pressure the VM is likely
to have reclaimed from other memcgs as well.

I saw your patch to fix that and break out of reclaim if soft limit
reclaim did enough.  But this fix is not much newer than my changes.

The second part of this is:

    Please note that soft limits is a best effort feature, it comes with
    no guarantees, but it does its best to make sure that when memory is
    heavily contended for, memory is allocated based on the soft limit
    hints/setup. Currently soft limit based reclaim is setup such that
    it gets invoked from balance_pgdat (kswapd).

It's not the pages-over-soft-limit that are best effort.  It says that
it tries its best to take soft limits into account while reclaiming.

My code does that, so I don't think we are breaking any promises
currently made in the documentation.

But much more important than keeping documentation promises is not to
break actual users.  So if you are yourself a user of soft limits,
test the new code pretty please and complain if it breaks your setup!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
