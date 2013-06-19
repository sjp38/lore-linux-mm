Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 8745E6B0034
	for <linux-mm@kvack.org>; Wed, 19 Jun 2013 07:59:32 -0400 (EDT)
Date: Wed, 19 Jun 2013 13:59:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] memcg: event control at vmpressure.
Message-ID: <20130619115925.GA16457@dhcp22.suse.cz>
References: <008a01ce6b4e$079b6a50$16d23ef0$%kim@samsung.com>
 <20130617131551.GA5018@dhcp22.suse.cz>
 <CAOK=xRMYZokH1rg+dfE0KfPk9NsqPmmaTg-k8sagqRqvR+jG+w@mail.gmail.com>
 <CAOK=xRMz+qX=CQ+3oD6TsEiGckMAdGJ-GAUC8o6nQpx4SJtQPw@mail.gmail.com>
 <20130618110151.GI13677@dhcp22.suse.cz>
 <CAOK=xRPM90muz5nFh8oUVAPFU=e4cwyWPZELVKoXke2FUN9Xsg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOK=xRPM90muz5nFh8oUVAPFU=e4cwyWPZELVKoXke2FUN9Xsg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hyunhee Kim <hyunhee.kim@samsung.com>
Cc: Anton Vorontsov <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, Kyungmin Park <kyungmin.park@samsung.com>

On Wed 19-06-13 20:25:03, Hyunhee Kim wrote:
> 2013/6/18 Michal Hocko <mhocko@suse.cz>:
> > On Tue 18-06-13 17:00:06, Hyunhee Kim wrote:
> >> 2013/6/18 Hyunhee Kim <hyunhee.kim@samsung.com>:
> >> > 2013/6/17 Michal Hocko <mhocko@suse.cz>:
> >> >> On Mon 17-06-13 20:30:11, Hyunhee Kim wrote:
> >> >> [...]
> >> >>> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> >> >>> index 736a601..a18fdb3 100644
> >> >>> --- a/mm/vmpressure.c
> >> >>> +++ b/mm/vmpressure.c
> >> >> [...]
> >> >>> @@ -150,14 +151,16 @@ static bool vmpressure_event(struct vmpressure *vmpr,
> >> >>>       level = vmpressure_calc_level(scanned, reclaimed);
> >> >>>
> >> >>>       mutex_lock(&vmpr->events_lock);
> >> >>> -
> >> >>>       list_for_each_entry(ev, &vmpr->events, node) {
> >> >>>               if (level >= ev->level) {
> >> >>> +                     if (ev->edge_trigger && (level == vmpr->last_level
> >> >>
> >> >>> +                             || level != ev->level))
> >> >>
> >> >> Hmm, why this differs from the "always" semantic? You do not want to see
> >> >> lower events? Why?
> >> >
> >> > Yes, I didn't want to see every lower level events whenever the higher
> >> > level event occurs because the higher event signal implies that the
> >> > lower memory situation also occurs.
> >
> > Is there any guarantee that such a condition would be also signalled?
> 
> I think so. In the original implementation, ev is signaled if (level
> >= ev->level).
> This means that on "level == CRITICAL", LOW and MEDIUM are always
> signaled if these are registered and somebody listen to them.

But there is no guarantee that LOW and/or MEDIUM events are triggered
actually because the vmpressure calculation can jump directly to
CRITICAL. Just imagine a case when it is really hard to reclaim anything
at all (pages are dirty and need to be written back first etc.).

> What I wanted to do can be seperated two parts: (1) don't send signals
> if the current level is same as the last level. (2) only send the
> current level not every lower level.
>
> But, I think that (1) is more close to "edge trigger" and I'll
> implement "edge trigger".

OK
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
