Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3C6956B006E
	for <linux-mm@kvack.org>; Fri,  6 Jun 2014 10:44:25 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n15so1134958wiw.8
        for <linux-mm@kvack.org>; Fri, 06 Jun 2014 07:44:24 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j4si47793828wix.45.2014.06.06.07.44.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 06 Jun 2014 07:44:23 -0700 (PDT)
Date: Fri, 6 Jun 2014 16:44:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140606144421.GE26253@dhcp22.suse.cz>
References: <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
 <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
 <20140604214553.GV2878@cmpxchg.org>
 <20140605145109.GA15939@dhcp22.suse.cz>
 <20140605161035.GY2878@cmpxchg.org>
 <20140605164355.GA22276@dhcp22.suse.cz>
 <20140605182336.GA2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140605182336.GA2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu 05-06-14 14:23:36, Johannes Weiner wrote:
> On Thu, Jun 05, 2014 at 06:43:55PM +0200, Michal Hocko wrote:
> > On Thu 05-06-14 12:10:35, Johannes Weiner wrote:
[...]
> > > It's not about whether hard guarantees are necessary, it's about
> > > getting away without additional fallback semantics.  The default
> > > position is still always simpler semantics, so we are looking for
> > > reasons for the fallback here, not the other way around.
> > 
> > This doesn't make much sense to me. So you are pushing for something
> > that is even not necessary. I have already mentioned that I am aware of
> > usecases which would prefer ephemeral reclaim rather than OOM and that
> > is pretty darn good reason to have a fallback mode.
> 
> I think it's quite clear that there is merit for both behaviors, but

OK, I am glad we are moving forward

> because there are less "traps" in the hard guarantee semantics their
> usefulness is much easier to assess.
> So can we please explore the situations wherein fallbacks would happen
> so that we can judge the applicability of both behaviors and pick a
> reasonable default?

This a hard question. NUMA interactions is the one thing that is quite
obvious. But there are other sources of allocations which are not
tracked by memcg (basically all kernel/drivers allocations or hugetlbfs)
which might produce a memory pressure which was not expected when the
limits where designed by admin.

> > > > They are asking for a reasonable memory isolation which they
> > > > currently do not have. Having a risk of OOM would be a no-go for
> > > > them so the feature wouldn't be useful for them.
> > > 
> > > Let's not go back to Handwaving Land on this, please.  What does
> > > "reasonable memory isolation" mean?
> >  
> > To not reclaim unless everybody is within limit. This doesn't happen
> > when the limit is not overcomitted normally but still cannot be ruled out
> > for different reasons (non-user allocations, NUMA setups and who knows
> > what else)
> 
> I'm desperately trying to gather a list of these corner cases to get a
> feeling for when that "best effort" falls apart, because that is part
> of the interface and something that we have to know for future kernel
> development, and the user has to know in order to pick a behavior.
>
> Your documentation doesn't mention any of those corner cases and leads
> on that you're basically guaranteed this memory unless you overcommit
> the limit.

Documentation can be always improved and I am open to suggestions. I
will send 2 patches to allow both modes + configuration as a reply to
this email so that we can discuss the direction further. And I can
definitely document at least the NUMA setup which can help us in the
future development as you said.

> > > > I have repeatedly said that I can see also some use for the hard
> > > > guarantee. Mainly to support overcommit on the limit. I didn't hear
> > > > about those usecases yet but it seems that at least Google would like to
> > > > have really hard guarantees.
> > > 
> > > Everybody who wants to charge for guaranteed memory can not afford to
> > > have other workloads break isolation at will.
> > 
> > I am getting tired of this discussion to be honest. You seem to be
> > locked up to guarantee ignoring that there are usecases which really do
> > not need have such requirements.
> 
> I already wrote Hugh that I'm not against the fall back per se, but I
> really want to map out the usecases and match them up with the hard
> and best-effort low limit, so that we know how to document this and
> what the default behavior should be.

OK

> It's not the fallback that's bothering me, it's your unwillingness to
> explore and document the vagueness that is inherent in the semantics.

Hmm, I do not remember any resistance to add or improve documentation.
I've tried to be as precise as possible. I understand that all the
consequences might not be clear from it but this can certainly be
improved.

> I really don't want to merge more underdefined best-effort features
> that will be useless to users and a hinderance in future development.

I think we have agreed that both modes make sense depending on the use
case. I do not think any of them is underdefined.

> "I'm aware of usecases that would prefer reclaim over OOM" is just not
> cutting it when it comes to designing an interface that we're going to
> be stuck with indefinitely. 

Best effort is a well established approach and I am quite surprised that
it is under such a strong hammering from you.

I think that a database workload I have mentioned is a nice example of
best effort semantic which makes a lot of sense. Normally it would get
reclaimed all the time (which might lead to slowdowns). Now you can
offer them a certain protection/prioritization over other loads on the
same system. This is exactly the kind of load which should never get OOM
and ephemeral reclaim is much better than no protection at all.

> We need a concrete understanding of how configurations would behave
> under common situations in the real world.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
