Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id D16C16B0044
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 09:30:18 -0400 (EDT)
Date: Mon, 6 Aug 2012 15:30:15 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V8 2/2] mm: memcg detect no memcgs above softlimit under
 zone reclaim
Message-ID: <20120806133015.GC6150@dhcp22.suse.cz>
References: <1343942664-13365-1-git-send-email-yinghan@google.com>
 <20120803140224.GC8434@dhcp22.suse.cz>
 <CALWz4iwJaUB9QuSgAoj_cbwY88SZ5er-W7ss7TJ1DFbf7wyevg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALWz4iwJaUB9QuSgAoj_cbwY88SZ5er-W7ss7TJ1DFbf7wyevg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hillf Danton <dhillf@gmail.com>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Fri 03-08-12 09:28:22, Ying Han wrote:
> On Fri, Aug 3, 2012 at 7:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Thu 02-08-12 14:24:24, Ying Han wrote:
[...]
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 88487b3..8622022 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
[...]
> >> @@ -1879,10 +1883,15 @@ static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >>                * we have to reclaim under softlimit instead of burning more
> >>                * cpu cycles.
> >>                */
> >> -             if (!global_reclaim(sc) || sc->priority < DEF_PRIORITY ||
> >> -                             mem_cgroup_over_soft_limit(memcg))
> >> +             if (ignore_softlimit || !global_reclaim(sc) ||
> >> +                             sc->priority < DEF_PRIORITY ||
> >> +                             mem_cgroup_over_soft_limit(memcg)) {
> >>                       shrink_lruvec(lruvec, sc);
> >>
> >> +                     if (!mem_cgroup_is_root(memcg))
> >> +                             over_softlimit = true;
> >> +             }
> >> +
> >
> > I think this is still not sufficient because you do not want to hammer
> > root in the ignore_softlimit case.
> 
> Are you worried about over-reclaiming from root cgroup while the rest
> of the cgroup are under softimit? 

yes

> Hmm.. That only affect the DEF_PRIORITY level, and not sure how bad it
> is.

Even if it was for DEF_PRIORITY it would mean that the root group is
second class citizen which is definitely not good.

> On the other hand, I wonder if it is necessary bad since the pages
> under root cgroup are mainly re-parented pages which only get chance
> to be reclaimed under global pressure.

Hmm, I do not think this is true in general and you shouldn't rely on
it.

> 
> --Ying
> 
> > --
> > Michal Hocko
> > SUSE Labs

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
