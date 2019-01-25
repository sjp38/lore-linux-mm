Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C29418E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:42:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id b3so3423191edi.0
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:42:17 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bs9-v6si2249594ejb.272.2019.01.25.00.42.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Jan 2019 00:42:16 -0800 (PST)
Date: Fri, 25 Jan 2019 09:42:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] mm: Consider subtrees in memory.events
Message-ID: <20190125074824.GD3560@dhcp22.suse.cz>
References: <20190123223144.GA10798@chrisdown.name>
 <20190124082252.GD4087@dhcp22.suse.cz>
 <20190124160009.GA12436@cmpxchg.org>
 <20190124170117.GS4087@dhcp22.suse.cz>
 <20190124182328.GA10820@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190124182328.GA10820@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Chris Down <chris@chrisdown.name>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Dennis Zhou <dennis@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com

On Thu 24-01-19 13:23:28, Johannes Weiner wrote:
> On Thu, Jan 24, 2019 at 06:01:17PM +0100, Michal Hocko wrote:
> > On Thu 24-01-19 11:00:10, Johannes Weiner wrote:
> > [...]
> > > We cannot fully eliminate a risk for regression, but it strikes me as
> > > highly unlikely, given the extremely young age of cgroup2-based system
> > > management and surrounding tooling.
> > 
> > I am not really sure what you consider young but this interface is 4.0+
> > IIRC and the cgroup v2 is considered stable since 4.5 unless I
> > missrememeber and that is not a short time period in my book.
> 
> If you read my sentence again, I'm not talking about the kernel but
> the surrounding infrastructure that consumes this data. The risk is
> not dependent on the age of the interface age, but on its adoption.

You really have to assume the user visible interface is consumed shortly
after it is exposed/considered stable in this case as cgroups v2 was
explicitly called unstable for a considerable period of time. This is a
general policy regarding user APIs in the kernel. I can see arguments a
next release after introduction or in similar cases but this is 3 years
ago. We already have distribution kernels based on 4.12 kernel and it is
old comparing to 5.0.

> > Changing interfaces now represents a non-trivial risk and so far I
> > haven't heard any actual usecase where the current semantic is
> > actually wrong.  Inconsistency on its own is not a sufficient
> > justification IMO.
> 
> It can be seen either way, and in isolation it wouldn't be wrong to
> count events on the local level. But we made that decision for the
> entire interface, and this file is the odd one out now. From that
> comprehensive perspective, yes, the behavior is wrong.

I do see your point about consistency. But it is also important to
consider the usability of this interface. As already mentioned, catching
an oom event at a level where the oom doesn't happen and having hard
time to identify that place without races is a not a straightforward API
to use. So it might be really the case that the api is actually usable
for its purpose.

> It really
> confuses people who are trying to use it, because they *do* expect it
> to behave recursively.

Then we should improve the documentation. But seriously these are no
strong reasons to change a long term semantic people might rely on.

> I'm really having a hard time believing there are existing cgroup2
> users with specific expectations for the non-recursive behavior...

I can certainly imagine monitoring tools to hook at levels where limits
are set and report events as they happen. It would be more than
confusing to receive events for reclaim/ooms that hasn't happened at
that level just because a delegated memcg down the hierarchy has decided
to set a more restrictive limits. Really this is a very unexpected
behavior change for anybody using that interface right now on anything
but leaf memcgs.
-- 
Michal Hocko
SUSE Labs
