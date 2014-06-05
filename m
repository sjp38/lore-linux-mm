Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id F22EB6B0035
	for <linux-mm@kvack.org>; Thu,  5 Jun 2014 14:24:35 -0400 (EDT)
Received: by mail-wi0-f180.google.com with SMTP id hi2so4072551wib.13
        for <linux-mm@kvack.org>; Thu, 05 Jun 2014 11:24:35 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id gf2si42952921wib.61.2014.06.05.11.24.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 05 Jun 2014 11:24:11 -0700 (PDT)
Date: Thu, 5 Jun 2014 14:23:36 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140605182336.GA2878@cmpxchg.org>
References: <20140528163335.GI2878@cmpxchg.org>
 <20140603110743.GD1321@dhcp22.suse.cz>
 <20140603142249.GP2878@cmpxchg.org>
 <20140604144658.GB17612@dhcp22.suse.cz>
 <20140604154408.GT2878@cmpxchg.org>
 <alpine.LSU.2.11.1406041218080.9583@eggly.anvils>
 <20140604214553.GV2878@cmpxchg.org>
 <20140605145109.GA15939@dhcp22.suse.cz>
 <20140605161035.GY2878@cmpxchg.org>
 <20140605164355.GA22276@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140605164355.GA22276@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Thu, Jun 05, 2014 at 06:43:55PM +0200, Michal Hocko wrote:
> On Thu 05-06-14 12:10:35, Johannes Weiner wrote:
> > On Thu, Jun 05, 2014 at 04:51:09PM +0200, Michal Hocko wrote:
> > > On Wed 04-06-14 17:45:53, Johannes Weiner wrote:
> > > > On Wed, Jun 04, 2014 at 12:18:59PM -0700, Hugh Dickins wrote:
> > > > > On Wed, 4 Jun 2014, Johannes Weiner wrote:
> > > > > > On Wed, Jun 04, 2014 at 04:46:58PM +0200, Michal Hocko wrote:
> > > > > > > 
> > > > > > > In the other email I have suggested to add a knob with the configurable
> > > > > > > default. Would you be OK with that?
> > > > > > 
> > > > > > No, I want to agree on whether we need that fallback code or not.  I'm
> > > > > > not interested in merging code that you can't convince anybody else is
> > > > > > needed.
> > > > > 
> > > > > I for one would welcome such a knob as Michal is proposing.
> > > > 
> > > > Now we have a tie :-)
> > > > 
> > > > > I thought it was long ago agreed that the low limit was going to fallback
> > > > > when it couldn't be satisfied.  But you seem implacably opposed to that
> > > > > as default, and I can well believe that Google is so accustomed to OOMing
> > > > > that it is more comfortable with OOMing as the default.  Okay.  But I
> > > > > would expect there to be many who want the attempt towards isolation that
> > > > > low limit offers, without a collapse to OOM at the first misjudgement.
> > > > 
> > > > At the same time, I only see users like Google pushing the limits of
> > > > the machine to a point where guarantees cover north of 90% of memory.
> > > 
> > > I can think of in-memory database loads which would use the reclaim
> > > protection which is quite high as well (say 80% of available memory).
> > > Those would definitely like to see ephemeral reclaim rather than OOM.
> > 
> > The OOM wouldn't apply to the database workload, but to other stuff in
> > the system.
> 
> Are we talking about the same thing? If nothing is reclaimable because
> everybody is within limit then the database workload will be, of course,
> a candidate for OOM. And quite a hot one as the memory consumption will
> be dominating.

Yes, you're right.

> > > > I would expect more casual users to work with much smaller guarantees,
> > > > and a good chunk of slack on top - otherwise they already had better
> > > > be set up for the occasional OOM.  Is this an unreasonable assumption
> > > > to make?
> > > > 
> > > > I'm not opposed to this feature per se, but I'm really opposed to
> > > > merging it for the partial hard bindings argument
> > > 
> > > This was just an example that even setup which is not overcomiting the
> > > limit might be caught in an unreclaimable position. Sure we can mitigate
> > > those issues to some point and that would be surely welcome.
> > > 
> > > The more important part, however, is that not all usecases really
> > > _require_ hard guarantee. 
> > 
> > It's not about whether hard guarantees are necessary, it's about
> > getting away without additional fallback semantics.  The default
> > position is still always simpler semantics, so we are looking for
> > reasons for the fallback here, not the other way around.
> 
> This doesn't make much sense to me. So you are pushing for something
> that is even not necessary. I have already mentioned that I am aware of
> usecases which would prefer ephemeral reclaim rather than OOM and that
> is pretty darn good reason to have a fallback mode.

I think it's quite clear that there is merit for both behaviors, but
because there are less "traps" in the hard guarantee semantics their
usefulness is much easier to assess.

So can we please explore the situations wherein fallbacks would happen
so that we can judge the applicability of both behaviors and pick a
reasonable default?

> > > They are asking for a reasonable memory isolation which they
> > > currently do not have. Having a risk of OOM would be a no-go for
> > > them so the feature wouldn't be useful for them.
> > 
> > Let's not go back to Handwaving Land on this, please.  What does
> > "reasonable memory isolation" mean?
>  
> To not reclaim unless everybody is within limit. This doesn't happen
> when the limit is not overcomitted normally but still cannot be ruled out
> for different reasons (non-user allocations, NUMA setups and who knows
> what else)

I'm desperately trying to gather a list of these corner cases to get a
feeling for when that "best effort" falls apart, because that is part
of the interface and something that we have to know for future kernel
development, and the user has to know in order to pick a behavior.

Your documentation doesn't mention any of those corner cases and leads
on that you're basically guaranteed this memory unless you overcommit
the limit.

> > > I have repeatedly said that I can see also some use for the hard
> > > guarantee. Mainly to support overcommit on the limit. I didn't hear
> > > about those usecases yet but it seems that at least Google would like to
> > > have really hard guarantees.
> > 
> > Everybody who wants to charge for guaranteed memory can not afford to
> > have other workloads break isolation at will.
> 
> I am getting tired of this discussion to be honest. You seem to be
> locked up to guarantee ignoring that there are usecases which really do
> not need have such requirements.

I already wrote Hugh that I'm not against the fall back per se, but I
really want to map out the usecases and match them up with the hard
and best-effort low limit, so that we know how to document this and
what the default behavior should be.

It's not the fallback that's bothering me, it's your unwillingness to
explore and document the vagueness that is inherent in the semantics.
I really don't want to merge more underdefined best-effort features
that will be useless to users and a hinderance in future development.

"I'm aware of usecases that would prefer reclaim over OOM" is just not
cutting it when it comes to designing an interface that we're going to
be stuck with indefinitely.  We need a concrete understanding of how
configurations would behave under common situations in the real world.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
