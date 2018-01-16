Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 27A9B28024A
	for <linux-mm@kvack.org>; Tue, 16 Jan 2018 17:09:13 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so12641054pfh.7
        for <linux-mm@kvack.org>; Tue, 16 Jan 2018 14:09:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l86si2694497pfg.288.2018.01.16.14.09.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 16 Jan 2018 14:09:11 -0800 (PST)
Date: Tue, 16 Jan 2018 23:09:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v13 0/7] cgroup-aware OOM killer
Message-ID: <20180116220907.GD17351@dhcp22.suse.cz>
References: <20171130152824.1591-1-guro@fb.com>
 <20171130123930.cf3217c816fd270fa35a40cb@linux-foundation.org>
 <alpine.DEB.2.10.1801091556490.173445@chino.kir.corp.google.com>
 <20180110131143.GB26913@castle.DHCP.thefacebook.com>
 <20180110113345.54dd571967fd6e70bfba68c3@linux-foundation.org>
 <20180111090809.GW1732@dhcp22.suse.cz>
 <20180111131845.GA13726@castle.DHCP.thefacebook.com>
 <alpine.DEB.2.10.1801121331110.120129@chino.kir.corp.google.com>
 <20180115115433.GA22473@dhcp22.suse.cz>
 <alpine.DEB.2.10.1801161323550.242486@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801161323550.242486@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Gushchin <guro@fb.com>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue 16-01-18 13:36:21, David Rientjes wrote:
> On Mon, 15 Jan 2018, Michal Hocko wrote:
> 
> > > No, this isn't how kernel features get introduced.  We don't design a new 
> > > kernel feature with its own API for a highly specialized usecase and then 
> > > claim we'll fix the problems later.  Users will work around the 
> > > constraints of the new feature, if possible, and then we can end up 
> > > breaking them later.  Or, we can pollute the mem cgroup v2 filesystem with 
> > > even more tunables to cover up for mistakes in earlier designs.
> > 
> > This is a blatant misinterpretation of the proposed changes. I haven't
> > heard _any_ single argument against the proposed user interface except
> > for complaints for missing tunables. This is not how the kernel
> > development works and should work. The usecase was clearly described and
> > far from limited to a single workload or company.
> >  
> 
> The complaint about the user interface is that it is not extensible, as my 
> next line states.

I disagree and will not repeat argument why.

> This doesn't need to be opted into with a mount option 
> locking the entire system into a single oom policy.  That, itself, is the 
> result of a poor design.  What is needed is a way for users to define an 
> oom policy that is generally useful, not something that is locked in for 
> the whole system. 

We have been discussing general oom policies for years now and there was
_no_ _single_ useful/acceptable approach suggested. Nor is your sketch
I am afraid because we could argue how that one doesn't address other
usecases out there which need a more specific control. All that without
having _no code_ merged. The current one is a policy that addresses a
reasonably large class of usecases out there based on containers without
forcing everybody else to use the same policy.

> We don't need several different cgroup mount options 
> only for mem cgroup oom policies.

cgroup mount option sounds like a reasonable approach already used for
the unified hierarchy in early stages.

> We also don't need random 
> memory.groupoom files being added to the mem cgroup v2 filesystem only for 
> one or two particular policies and being no-ops otherwise.

This groupoom is a fundamental API allowing to kill the whole cgroup
which is a reasonable thing to do and also sane user API regardless of
implementation details. Any oom selection policy can be built on top.

> It can easily 
> be specified as part of the policy itself.

No it cannot, because it would conflate oom selection _and_ oom action
together. And that would be wrong _semantically_, I believe. And I am quite
sure we can discuss what kind of policies we need to death and won't
move on. Exactly like, ehm, until now.

So let me repeat. There are users for the functionality. Users have to
explicitly opt-in so existing users are not in a risk of regressions.
Further more fine grained oom selection policies can be implemented on top
without breaking new users.
In short: There is no single reason to block this to be merged.

If your usecase is not covered yet then feel free to extend the existing
code/APIs to do so. I will happily review and discuss them like I've
been doing here even though I am myself not a user of this new
functionality.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
