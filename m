Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 2FFD86B004F
	for <linux-mm@kvack.org>; Tue, 24 Jan 2012 03:30:29 -0500 (EST)
Date: Tue, 24 Jan 2012 09:30:26 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcg: fix over reclaiming mem cgroup
Message-ID: <20120124083026.GB26289@tiehlicka.suse.cz>
References: <CAJd=RBAbFd=MFZZyCKN-Si-Zt=C6dKVUaG-C7s5VKoTWfY00nA@mail.gmail.com>
 <20120123130221.GA15113@tiehlicka.suse.cz>
 <CALWz4izWYb=_svn=UJ1C--pWXv59H2ahn6EJEnTpJv-dT6WGsw@mail.gmail.com>
 <CAKTCnzk1srmgyDzmSDzMsnbjmmt1ke91=kr0C4bECyxb1J6Rog@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKTCnzk1srmgyDzmSDzMsnbjmmt1ke91=kr0C4bECyxb1J6Rog@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Ying Han <yinghan@google.com>, Hillf Danton <dhillf@gmail.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Tue 24-01-12 09:18:21, Balbir Singh wrote:
> On Tue, Jan 24, 2012 at 12:44 AM, Ying Han <yinghan@google.com> wrote:
> > On Mon, Jan 23, 2012 at 5:02 AM, Michal Hocko <mhocko@suse.cz> wrote:
> >> On Sat 21-01-12 22:49:23, Hillf Danton wrote:
> >>> In soft limit reclaim, overreclaim occurs when pages are reclaimed from mem
> >>> group that is under its soft limit, or when more pages are reclaimd than the
> >>> exceeding amount, then performance of reclaimee goes down accordingly.
> >>
> >> First of all soft reclaim is more a help for the global memory pressure
> >> balancing rather than any guarantee about how much we reclaim for the
> >> group.
> >> We need to do more changes in order to make it a guarantee.
> >> For example you implementation will cause severe problems when all
> >> cgroups are soft unlimited (default conf.) or when nobody is above the
> >> limit but the total consumption triggers the global reclaim. Therefore
> >> nobody is in excess and you would skip all groups and only bang on the
> >> root memcg.
> >>
> 
> True, ideally soft reclaim should not turn on and allow global reclaim
> to occur in the scenario mentioned.
> 
> >> Ying Han has a patch which basically skips all cgroups which are under
> >> its limit until we reach a certain reclaim priority but even for this we
> >> need some additional changes - e.g. reverse the current default setting
> >> of the soft limit.
> >>
> 
> I'd be wary of that approach, because it might be harder to explain
> the working of soft limits,

This is an attempt to turn the soft reclaim into a "guarantee". Changing
the default value from unlimited to 0 basically says that everybody will
be considered under memory pressure unless the soft limit setting says
otherwise.
This btw. has been the case with the double (global and per-cgroup) LRUs
as well. It was just hidden.

> I'll look at the discussion thread mentioned earlier for the benefits
> of that approach.
> 
> >> Anyway, I like the nr_to_reclaim reduction idea because we have to do
> >> this in some way because the global reclaim starts with ULONG
> >> nr_to_scan.
> >
> > Agree with Michal where there are quite a lot changes we need to get
> > in for soft limit before any further optimization.
> >
> > Hillf, please refer to the patch from Johannes
> > https://lkml.org/lkml/2012/1/13/99 which got quite a lot recent
> > discussions. I am expecting to get that in before further soft limit
> > changes.
> 
> Balbir
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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
