Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id E51056B0161
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 12:08:19 -0400 (EDT)
Received: by mail-wg0-f43.google.com with SMTP id b13so4397389wgh.26
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:08:19 -0700 (PDT)
Received: from mail-wi0-x232.google.com (mail-wi0-x232.google.com [2a00:1450:400c:c05::232])
        by mx.google.com with ESMTPS id bu8si42686389wjc.35.2014.06.11.09.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 09:08:12 -0700 (PDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so1426588wiw.5
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 09:08:09 -0700 (PDT)
Date: Wed, 11 Jun 2014 18:08:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/4] memcg, mm: introduce lowlimit reclaim
Message-ID: <20140611160805.GB23343@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <1398688005-26207-2-git-send-email-mhocko@suse.cz>
 <20140430225550.GD26041@cmpxchg.org>
 <20140502093628.GC3446@dhcp22.suse.cz>
 <20140502155805.GO23420@cmpxchg.org>
 <20140502164930.GP3446@dhcp22.suse.cz>
 <20140502220056.GP23420@cmpxchg.org>
 <20140505142100.GC32598@dhcp22.suse.cz>
 <20140611151544.GA22516@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611151544.GA22516@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 11-06-14 11:15:44, Johannes Weiner wrote:
> On Mon, May 05, 2014 at 04:21:00PM +0200, Michal Hocko wrote:
[...]
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2293,13 +2293,20 @@ static unsigned __shrink_zone(struct zone *zone, struct scan_control *sc,
> >  
> >  static void shrink_zone(struct zone *zone, struct scan_control *sc)
> >  {
> > -	if (!__shrink_zone(zone, sc, true)) {
> > +	bool honor_guarantee = true;
> > +
> > +	while (!__shrink_zone(zone, sc, honor_guarantee)) {
> >  		/*
> > -		 * First round of reclaim didn't find anything to reclaim
> > -		 * because of the memory guantees for all memcgs in the
> > -		 * reclaim target so try again and ignore guarantees this time.
> > +		 * The previous round of reclaim didn't find anything to scan
> > +		 * because
> > +		 * a) the whole reclaimed hierarchy is within guarantee so
> > +		 *    we fallback to ignore the guarantee because other option
> > +		 *    would be the OOM
> > +		 * b) multiple reclaimers are racing and so the first round
> > +		 *    should be retried
> >  		 */
> > -		__shrink_zone(zone, sc, false);
> > +		if (mem_cgroup_all_within_guarantee(sc->target_mem_cgroup))
> > +			honor_guarantee = false;
> >  	}
> 
> I don't like that this adds a non-chalant `for each memcg' here, we
> can have a lot of memcgs.  Sooner or later we'll have to break up that
> full hierarchy iteration in shrink_zone() because of scalability, I
> want to avoid adding more of them.

mem_cgroup_all_within_guarantee can be simply optimized to exclude whole
subtrees of each memcg which is mem_cgroup_within_guarantee. cgroups
iterator are easy and quite optimal to skip the whole subtree AFAIR so I
do not see this as a bottleneck here.

> How about these changes on top of what we currently have?

I really do not like how you got back to priority based break out.
We were discussing that 2 or so years ago and the main objection was
that this is really not useful. You do not want to scan/reclaim so far
"priviledged" memcgs at high priority all of the sudden.

> Sure it's not as accurate, but it should be good start, and it's a
> *lot* less overhead.
> 
> mem_cgroup_watermark() is also a more fitting name, given that this
> has nothing to do with a guarantee for now.

mem_cgroup_watermark sounds like a better name indeed.

> It can also be easily extended to support the MIN watermark while the
> code in vmscan.c remains readable.
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
