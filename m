Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4FAFA8E00D7
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 11:51:57 -0500 (EST)
Received: by mail-yw1-f69.google.com with SMTP id 201so5292779ywp.13
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 08:51:57 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h66sor3421451ywa.160.2019.01.25.08.51.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 08:51:56 -0800 (PST)
Date: Fri, 25 Jan 2019 08:51:52 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190125165152.GK50184@devbig004.ftw2.facebook.com>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
 <20190125074824.GD3560@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190125074824.GD3560@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

Hello, Michal.

On Fri, Jan 25, 2019 at 09:42:13AM +0100, Michal Hocko wrote:
> > If you read my sentence again, I'm not talking about the kernel but
> > the surrounding infrastructure that consumes this data. The risk is
> > not dependent on the age of the interface age, but on its adoption.
> 
> You really have to assume the user visible interface is consumed shortly
> after it is exposed/considered stable in this case as cgroups v2 was
> explicitly called unstable for a considerable period of time. This is a
> general policy regarding user APIs in the kernel. I can see arguments a
> next release after introduction or in similar cases but this is 3 years
> ago. We already have distribution kernels based on 4.12 kernel and it is
> old comparing to 5.0.

We do change userland-visible behaviors if the existing behavior is
buggy / misleading / confusing.  For example, we recently changed how
discard bytes are accounted (no longer included in write bytes or ios)
and even how mincore(2) behaves, both of which are far older than
cgroup2.

The main considerations are the blast radius and existing use cases in
these decisions.  Age does contribute to it but mostly because they
affect how widely the behavior may be depended upon.

> > > Changing interfaces now represents a non-trivial risk and so far I
> > > haven't heard any actual usecase where the current semantic is
> > > actually wrong.  Inconsistency on its own is not a sufficient
> > > justification IMO.
> > 
> > It can be seen either way, and in isolation it wouldn't be wrong to
> > count events on the local level. But we made that decision for the
> > entire interface, and this file is the odd one out now. From that
> > comprehensive perspective, yes, the behavior is wrong.
> 
> I do see your point about consistency. But it is also important to
> consider the usability of this interface. As already mentioned, catching
> an oom event at a level where the oom doesn't happen and having hard
> time to identify that place without races is a not a straightforward API
> to use. So it might be really the case that the api is actually usable
> for its purpose.

What if a user wants to monitor any ooms in the subtree tho, which is
a valid use case?  If local event monitoring is useful and it can be,
let's add separate events which are clearly identifiable to be local.
Right now, it's confusing like hell.

> > It really
> > confuses people who are trying to use it, because they *do* expect it
> > to behave recursively.
> 
> Then we should improve the documentation. But seriously these are no
> strong reasons to change a long term semantic people might rely on.

This is broken interface.  We're mixing local and hierarchical numbers
willy nilly without obvious way of telling them apart.

> > I'm really having a hard time believing there are existing cgroup2
> > users with specific expectations for the non-recursive behavior...
> 
> I can certainly imagine monitoring tools to hook at levels where limits
> are set and report events as they happen. It would be more than
> confusing to receive events for reclaim/ooms that hasn't happened at
> that level just because a delegated memcg down the hierarchy has decided
> to set a more restrictive limits. Really this is a very unexpected
> behavior change for anybody using that interface right now on anything
> but leaf memcgs.

Sure, there's some probability this change may cause some disruptions
although I'm pretty skeptical given that inner node event monitoring
is mostly useless right now.  However, there's also a lot of on-going
and future costs everyone is paying because the interface is so
confusing.

Thanks.

-- 
tejun
