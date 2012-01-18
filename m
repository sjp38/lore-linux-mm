Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id 4BD3A6B005A
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 10:13:17 -0500 (EST)
Date: Wed, 18 Jan 2012 16:13:13 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcg: remove checking reclaim order in soft limit
 reclaim
Message-ID: <20120118151313.GF31112@tiehlicka.suse.cz>
References: <CAJd=RBBdDriMhfetM2AWGzgxiJ1DDs-W4Ff9_1Z8DUgbyQmSkA@mail.gmail.com>
 <20120117131601.GB14907@tiehlicka.suse.cz>
 <CAJd=RBBcL5RuW1wC_Yh=gy2Ja8wqJ6jhf28zNi1n6MJ=+0=m2Q@mail.gmail.com>
 <20120117140712.GC14907@tiehlicka.suse.cz>
 <CAJd=RBAyqPwKERQL4JyCO38gjE=y8_qasHTbLtMGWqtZ1JFnUg@mail.gmail.com>
 <20120118134053.GD31112@tiehlicka.suse.cz>
 <CAJd=RBAs3_ic+0UbZ_Bn4tBp_t2-HuohcRrWD1d6M2oSYRNYmQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAJd=RBAs3_ic+0UbZ_Bn4tBp_t2-HuohcRrWD1d6M2oSYRNYmQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <bsingharora@gmail.com>

On Wed 18-01-12 22:01:57, Hillf Danton wrote:
> On Wed, Jan 18, 2012 at 9:40 PM, Michal Hocko <mhocko@suse.cz> wrote:
> > On Wed 18-01-12 20:30:41, Hillf Danton wrote:
> >> On Tue, Jan 17, 2012 at 10:07 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >> > On Tue 17-01-12 21:29:52, Hillf Danton wrote:
> >> >> On Tue, Jan 17, 2012 at 9:16 PM, Michal Hocko <mhocko@suse.cz> wrote:
> >> >> > Hi,
> >> >> >
> >> >> > On Tue 17-01-12 20:47:59, Hillf Danton wrote:
> >> >> >> If async order-O reclaim expected here, it is settled down when setting up scan
> >> >> >> control, with scan priority hacked to be zero. Other than that, deny of reclaim
> >> >> >> should be removed.
> >> >> >
> >> >> > Maybe I have misunderstood you but this is not right. The check is to
> >> >> > protect from the _global_ reclaim with order > 0 when we prevent from
> >> >> > memcg soft reclaim.
> >> >> >
> >> >> need to bear mm hog in this way?
> >> >
> >> > Could you be more specific? Are you trying to fix any particular
> >> > problem?
> >> >
> >> My thought is simple, the outcome of softlimit reclaim depends little on the
> >> value of reclaim order, zero or not, and only exceeding is reclaimed, so
> >> selective response to swapd's request is incorrect.
> >
> > OK, got your point, finally. Let's add Balbir (the proposed patch can
> > be found at https://lkml.org/lkml/2012/1/17/166) to the CC list because
> > this seems to be a design decision.
> >
> > I always thought that this is because we want non-userspace (high order)
> > mem pressure to be handled by the global reclaim only. And it makes some
> > sense to me because it is little bit strange to reclaim for order-0
> > while the request is for an higher order. I guess this might lead to an
> > extensive and pointless reclaiming because we might end up with many
> > free pages which cannot satisfy higher order allocation.
> >
> > On the other hand, it is true that the documentation says that the soft
> > limit is considered when "the system detects memory contention or low
> > memory" which doesn't say that the contention comes from memcg accounted
> > memory.
> >
> > Anyway this changes the current behavior so it would better come with
> > much better justification which shows that over reclaim doesn't happen
> > and that we will not see higher latencies with higher order allocations.
> >
> 
> As the function shows, the checked reclaim order is not used, but the
> scan control is prepared with order(= 0), which is called async order-0
> reclaim in my tern, then your worries on over reclaim and higher latencies
> could be removed, I think 8-)

Not really. My concern was that memcg will reclaim for order-0 while the
kswapd reclaims for order-N so after we reclaimed something from cgroups
we finally start reclaiming for order-N.

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
