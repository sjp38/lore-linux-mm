Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 791DD6B0031
	for <linux-mm@kvack.org>; Mon, 16 Jun 2014 09:22:56 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so5812822wes.0
        for <linux-mm@kvack.org>; Mon, 16 Jun 2014 06:22:55 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i7si1406864wiz.5.2014.06.16.06.22.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 16 Jun 2014 06:22:54 -0700 (PDT)
Date: Mon, 16 Jun 2014 15:22:53 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140616132253.GD16915@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
 <20140612142237.GB32720@dhcp22.suse.cz>
 <20140612165105.GK2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612165105.GK2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 12-06-14 12:51:05, Johannes Weiner wrote:
> On Thu, Jun 12, 2014 at 04:22:37PM +0200, Michal Hocko wrote:
> > On Thu 12-06-14 09:56:00, Johannes Weiner wrote:
> > > On Thu, Jun 12, 2014 at 03:22:07PM +0200, Michal Hocko wrote:
> > [...]
> > > > Anyway, the situation now is pretty chaotic. I plan to gather all the
> > > > patchse posted so far and repost for the future discussion. I just need
> > > > to finish some internal tasks and will post it soon.
> > > 
> > > That would be great, thanks, it's really hard to follow this stuff
> > > halfway in and halfway outside of -mm.
> > > 
> > > Now that we roughly figured out what knobs and semantics we want, it
> > > would be great to figure out the merging logistics.
> > > 
> > > I would prefer if we could introduce max, high, low, min in unified
> > > hierarchy, and *only* in there, so that we never have to worry about
> > > it coexisting and interacting with the existing hard and soft limit.

Btw. what is the way to introduce a knob _only_ in the new cgroup API?
I am aware only about .flags = CFTYPE_INSANE which works other way
around.

> > The primary question would be, whether this is is the best transition
> > strategy. I do not know how many users apart from developers are really
> > using unified hierarchy. I would be worried that we merge a feature which
> > will not be used for a long time.
> 
> Unified hierarchy is the next version of the cgroup interface, and
> once the development tag drops I consider the old memcg interface
> deprecated. 

Deprecated in the unified hierarchy mount, right? There will be still
the old API around AFAIU. The deprecated knobs will be only not visible
in the new API. So we cannot simply remove all the code after unified
hierarchy drops its DEVEL status, can we?

> It makes very little sense to me to put up additional
> incentives at this point to continue the use of the old interface,
> when we already struggle with manpower to maintain even one of them.
> 
> > Moreover, if somebody wants to transition from soft limit then it would
> > be really hard because switching to unified hierarchy might be a no-go.
> >
> > I think that it is clear that we should deprecate soft_limit ASAP. I
> > also think it wont't hurt to have min, low, high in both old and unified
> > API and strongly warn if somebody tries to use soft_limit along with any
> > of the new APIs in the first step. Later we can even forbid any
> > combination by a hard failure.
> 
> Why would somebody NOT be able to convert to unified hierarchy
> eventually?

I've mentioned that in other email. I remember people complaining about
threads not being distributable over groups in the past. Things might
have changed in the mean time, I was too busy to pay closer attention so
I might be completely wrong here.

> How big is the intersection of cases that can't convert to unified
> hierarchy AND are using the soft limit AND want to use the new low
> limit?

I am not talking about intentional usage of soft limit with new knobs.
That would be unsupported of course and I meant to complain about that
in the logs and later even fail on an attempt.

> Merging a different concept with its own naming scheme into an already
> confusing interface, spamming the dmesg if someone gets it wrong,
> potentially introducing more breakage with the hard failure, putting
> up incentives to stick with a deprecated and confusing interface...
> This is a lot of horrible stuff in an attempt to accomodate very few
> usecases - if any - when we are *already versioning the interface* and
> have the opportunity for a clean transition.
> 
> The transition to min, low, high, max is effort in itself.  Conflating
> the two models sounds more detrimental than anything else, with a very
> dubious upside at that.
>
> > > It would also be beneficial to introduce them all close to each other,
> > > develop them together, possibly submit them in the same patch series,
> > > so that we know the requirements and how the code should look like in
> > > the big picture and can offer a fully consistent and documented usage
> > > model in the unified hierarchy.
> > 
> > Min and Low should definitely go together. High sounds like an
> > orthogonal problem (pro-active reclaim vs reclaim protection) so I think
> > it can go its own way and pace. We still have to discuss its semantic
> > and I feel it would be a bit disturbing to have everything in one
> > bundle.
> >
> > I do understand your point about the global picture, though. Do you
> > think that there is a risk that formulating semantic for High limit
> > might change the way how Min and Low would be defined?
> 
> I think one of the biggest hinderances in making forward progress on
> individual limits is that we only had a laundry list of occasionally
> conflicting requirements but never a consistent big picture to design
> around and match full usecases to.  It's much easier and less error
> prone to develop the concept as a whole, alongside full real-life
> configurations.
> 
> They are symmetrical pieces whose semantics very much depend on each
> other, so I wouldn't like too much lag between those.

Sure, I think we can target them for the same merge window. I am just
not sure whether one patch series is the appropriate way.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
