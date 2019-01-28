Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 671CA8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 09:52:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id d41so6567214eda.12
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 06:52:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u28si901768edi.62.2019.01.28.06.52.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 06:52:12 -0800 (PST)
Date: Mon, 28 Jan 2019 15:52:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190128145210.GM18811@dhcp22.suse.cz>
References: <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
 <20190125165152.GK50184@devbig004.ftw2.facebook.com>
 <20190125173713.GD20411@dhcp22.suse.cz>
 <20190125182808.GL50184@devbig004.ftw2.facebook.com>
 <20190128125151.GI18811@dhcp22.suse.cz>
 <20190128142816.GM50184@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128142816.GM50184@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Mon 28-01-19 06:28:16, Tejun Heo wrote:
> Hello, Michal.
> 
> On Mon, Jan 28, 2019 at 01:51:51PM +0100, Michal Hocko wrote:
> > > For example, a workload manager watching over a subtree for a job with
> > > nested memory limits set by the job itself.  It wants to take action
> > > (reporting and possibly other remediative actions) when something goes
> > > wrong in the delegated subtree but isn't involved in how the subtree
> > > is configured inside.
> > 
> > Yes, I understand this part, but it is not clear to me, _how_ to report
> > anything sensible without knowing _what_ has caused the event. You can
> > walk the cgroup hierarchy and compare cached results with new ones but
> > this is a) racy and b) clumsy.
> 
> All .events files generate aggregated stateful notifications.  For
> anyone to do anything, they'd have to remember the previous state to
> identify what actually happened.  Being hierarchical, it'd of course
> need to walk down when an event triggers.

And how do you do that in a raceless fashion?

> > > That sure is an option for use cases like above but it has the
> > > downside of carrying over the confusing interface into the indefinite
> > > future.
> > 
> > I actually believe that this is not such a big deal. For one thing the
> > current events are actually helpful to watch the reclaim/setup behavior.
> 
> Sure, it isn't something critical.  It's just confusing and I think
> it'd be better to improve.
> 
> > I do not really think you can go back. You cannot simply change semantic
> > back and forth because you just break new users.
> > 
> > Really, I do not see the semantic changing after more than 3 years of
> > production ready interface. If you really believe we need a hierarchical
> > notification mechanism for the reclaim activity then add a new one.
> 
> I don't see it as black and white as you do.  Let's agree to disagree.
> I'll ack the patch and note the disagreement.

Considering the justification behhind this change I really do not see
other option than nack this change. There is simply no _strong_ reason
to change the behavior. Even if the current behavior is confusing, the
documentation can be improved to be more specific. If there is a strong
demand for hierarchical reporting then add a new interface. But I have
to say that I would consider such a reporting clumsy at best.
-- 
Michal Hocko
SUSE Labs
