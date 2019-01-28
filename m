Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 084808E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:51:55 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id d41so6440346eda.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 04:51:54 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i46si713895eda.288.2019.01.28.04.51.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 04:51:53 -0800 (PST)
Date: Mon, 28 Jan 2019 13:51:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128125151.GI18811@dhcp22.suse.cz>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125182808.GL50184@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Fri 25-01-19 10:28:08, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Jan 25, 2019 at 06:37:13PM +0100, Michal Hocko wrote:
> > > What if a user wants to monitor any ooms in the subtree tho, which is
> > > a valid use case?
> > 
> > How is that information useful without know which memcg the oom applies
> > to?
> 
> For example, a workload manager watching over a subtree for a job with
> nested memory limits set by the job itself.  It wants to take action
> (reporting and possibly other remediative actions) when something goes
> wrong in the delegated subtree but isn't involved in how the subtree
> is configured inside.

Yes, I understand this part, but it is not clear to me, _how_ to report
anything sensible without knowing _what_ has caused the event. You can
walk the cgroup hierarchy and compare cached results with new ones but
this is a) racy and b) clumsy.

> > > If local event monitoring is useful and it can be,
> > > let's add separate events which are clearly identifiable to be local.
> > > Right now, it's confusing like hell.
> > 
> > From a backward compatible POV it should be a new interface added.
> 
> That sure is an option for use cases like above but it has the
> downside of carrying over the confusing interface into the indefinite
> future.

I actually believe that this is not such a big deal. For one thing the
current events are actually helpful to watch the reclaim/setup behavior.

> Again, I'd like to point back at how we changed the
> accounting write and trim accounting because the benefits outweighted
> the risks.
> 
> > Please note that I understand that this might be confusing with the rest
> > of the cgroup APIs but considering that this is the first time somebody
> > is actually complaining and the interface is "production ready" for more
> > than three years I am not really sure the situation is all that bad.
> 
> cgroup2 uptake hasn't progressed that fast.  None of the major distros
> or container frameworks are currently shipping with it although many
> are evaluating switching.  I don't think I'm too mistaken in that we
> (FB) are at the bleeding edge in terms of adopting cgroup2 and its
> various new features and are hitting these corner cases and oversights
> in the process.  If there are noticeable breakages arising from this
> change, we sure can backpaddle but I think the better course of action
> is fixing them up while we can.

I do not really think you can go back. You cannot simply change semantic
back and forth because you just break new users.

Really, I do not see the semantic changing after more than 3 years of
production ready interface. If you really believe we need a hierarchical
notification mechanism for the reclaim activity then add a new one.
-- 
Michal Hocko
SUSE Labs
