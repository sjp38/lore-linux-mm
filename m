Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3CCC96B0133
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 03:57:34 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so5237227wib.5
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 00:57:33 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t8si40471662wjf.134.2014.06.11.00.57.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 00:57:32 -0700 (PDT)
Date: Wed, 11 Jun 2014 09:57:29 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140611075729.GA4520@dhcp22.suse.cz>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <xr934mzt4rwc.fsf@gthelen.mtv.corp.google.com>
 <20140610165756.GG2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140610165756.GG2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue 10-06-14 12:57:56, Johannes Weiner wrote:
> On Mon, Jun 09, 2014 at 03:52:51PM -0700, Greg Thelen wrote:
> > 
> > On Fri, Jun 06 2014, Michal Hocko <mhocko@suse.cz> wrote:
> > 
> > > Some users (e.g. Google) would like to have stronger semantic than low
> > > limit offers currently. The fallback mode is not desirable and they
> > > prefer hitting OOM killer rather than ignoring low limit for protected
> > > groups. There are other possible usecases which can benefit from hard
> > > guarantees. I can imagine workloads where setting low_limit to the same
> > > value as hard_limit to prevent from any reclaim at all makes a lot of
> > > sense because reclaim is much more disrupting than restart of the load.
> > >
> > > This patch adds a new per memcg memory.reclaim_strategy knob which
> > > tells what to do in a situation when memory reclaim cannot do any
> > > progress because all groups in the reclaimed hierarchy are within their
> > > low_limit. There are two options available:
> > > 	- low_limit_best_effort - the current mode when reclaim falls
> > > 	  back to the even reclaim of all groups in the reclaimed
> > > 	  hierarchy
> > > 	- low_limit_guarantee - groups within low_limit are never
> > > 	  reclaimed and OOM killer is triggered instead. OOM message
> > > 	  will mention the fact that the OOM was triggered due to
> > > 	  low_limit reclaim protection.
> > 
> > To (a) be consistent with existing hard and soft limits APIs and (b)
> > allow use of both best effort and guarantee memory limits, I wonder if
> > it's best to offer three per memcg limits, rather than two limits (hard,
> > low_limit) and a related reclaim_strategy knob.  The three limits I'm
> > thinking about are:
> > 
> > 1) hard_limit (aka the existing limit_in_bytes cgroupfs file).  No
> >    change needed here.  This is an upper bound on a memcg hierarchy's
> >    memory consumption (assuming use_hierarchy=1).
> 
> This creates internal pressure.  Outside reclaim is not affected by
> it, but internal charges can not exceed this limit.  This is set to
> hard limit the maximum memory consumption of a group (max).
> 
> > 2) best_effort_limit (aka desired working set).  This allow an
> >    application or administrator to provide a hint to the kernel about
> >    desired working set size.  Before oom'ing the kernel is allowed to
> >    reclaim below this limit.  I think the current soft_limit_in_bytes
> >    claims to provide this.  If we prefer to deprecate
> >    soft_limit_in_bytes, then a new desired_working_set_in_bytes (or a
> >    hopefully better named) API seems reasonable.
> 
> This controls how external pressure applies to the group.
> 
> But it's conceivable that we'd like to have the equivalent of such a
> soft limit for *internal* pressure.  Set below the hard limit, this
> internal soft limit would have charges trigger direct reclaim in the
> memcg but allow them to continue to the hard limit.  This would create
> a situation wherein the allocating tasks are not killed, but throttled
> under reclaim, which gives the administrator a window to detect the
> situation with vmpressure and possibly intervene.  Because as it
> stands, once the current hard limit is hit things can go down pretty
> fast and the window for reacting to vmpressure readings is often too
> small.  This would offer a more gradual deterioration.  It would be
> set to the upper end of the working set size range (high).
> 
> I think for many users such an internal soft limit would actually be
> preferred over the current hard limit, as they'd rather have some
> reclaim throttling than an OOM kill when the group reaches its upper
> bound.  

Yes, this sounds useful. We have already discussed that and the
primary question is whether the high limit reclaim should be direct
or background. There are some cons and pros for both. Direct one is
much easier to implement but it is questionable whether it is too
heavy.  Background is much more tricky to implement on the other
hand. The obvious advantage would be a more convergence to the global
behavior while we still get the notification that something bad is
going on.  I assume that a dedicated workqueque would be doable but we
would definitely need an evaluation of what happens with zillions of
high_limit reclaimers.

> The current hard limit would be reserved for more advanced or paid
> cases, where the admin would rather see a memcg get OOM killed than
> exceed a certain size.

So the hard_limit will not change, right? Still reclaim and fallback to
OOM if nothing can be reclaimable as we do currently.

> Then, as you proposed, we'd have the soft limit for external pressure,
> where the kernel only reclaims groups within that limit in order to
> avoid OOM kills.  It would be set to the estimated lower end of the
> working set size range (low).

OK, that is how the current low_limit is implemented.

> > 3) low_limit_guarantee which is a lower bound of memory usage.  A memcg
> >    would prefer to be oom killed rather than operate below this
> >    threshold.  Default value is zero to preserve compatibility with
> >    existing apps.
> 
> And this would be the external pressure hard limit, which would be set
> to the absolute minimum requirement of the group (min).
> 
> Either because it would be hopelessly thrashing without it, or because
> this guaranteed memory is actually paid for.  Again, I would expect
> many users to not even set this minimum guarantee but solely use the
> external soft limit (low) instead.
> 
> > Logically hard_limit >= best_effort_limit >= low_limit_guarantee.
> 
> max >= high >= low >= min

It might be a bit confusing for people familiar with the per-zone
watermarks where the meaning is opposite (hard reclaim if under min,
kswapd if between low and high). Nevertheless names have a good meaning
in the memcg context so I would go with min, low and high as you
suggest.

> I think we should be able to express all desired usecases with these
> four limits, including the advanced configurations, while making it
> easy for many users to set up groups without being a) dead certain
> about their memory consumption or b) prepared for frequent OOM kills,
> while still allowing them to properly utilize their machines.
> 
> What do you think?

OK, I think this sounds viable. low_limit part of it is already in
Andrew's tree and I will post a follow up patches for min_limit which
are quite trivial on top for further discussion.

Is this the kind of symmetry Tejun is asking for and that would make
change is Nack position? I am still not sure it satisfies his soft
guarantee objections from other email.

I am also not sure whether high_limit has to be bundled with
{min,low}_limit in one patchset necessarily. I think we need it and
we should discuss what is the best implementation but I do not see
any reason to postponing the memory protection part which is quite
independent on pro-active memory reclaim.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
