Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 82C04440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 09:49:04 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id a110so997262wrc.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 06:49:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si3591082wrl.217.2017.08.24.06.49.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 06:49:02 -0700 (PDT)
Date: Thu, 24 Aug 2017 15:48:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 3/4] mm, oom: introduce oom_priority for memory cgroups
Message-ID: <20170824134859.GO5943@dhcp22.suse.cz>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-4-guro@fb.com>
 <20170824121054.GI5943@dhcp22.suse.cz>
 <20170824125113.GB15916@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824125113.GB15916@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 24-08-17 13:51:13, Roman Gushchin wrote:
> On Thu, Aug 24, 2017 at 02:10:54PM +0200, Michal Hocko wrote:
> > On Wed 23-08-17 17:52:00, Roman Gushchin wrote:
> > > Introduce a per-memory-cgroup oom_priority setting: an integer number
> > > within the [-10000, 10000] range, which defines the order in which
> > > the OOM killer selects victim memory cgroups.
> > 
> > Why do we need a range here?
> 
> No specific reason, both [INT_MIN, INT_MAX] and [-10000, 10000] will
> work equally.

Then do not enforce a range because this just reduces possible usecases
(e.g. timestamp one...).

> We should be able to predefine an OOM killing order for
> any reasonable amount of cgroups.
> 
> > 
> > > OOM killer prefers memory cgroups with larger priority if they are
> > > populated with eligible tasks.
> > 
> > So this is basically orthogonal to the score based selection and the
> > real size is only the tiebreaker for same priorities? Could you describe
> > the usecase? Becasuse to me this sounds like a separate oom killer
> > strategy. I can imagine somebody might be interested (e.g. always kill
> > the oldest memcgs...) but an explicit range wouldn't fly with such a
> > usecase very well.
> 
> The usecase: you have a machine with several containerized workloads
> of different importance, and some system-level stuff, also in (memory)
> cgroups.
> In case of global memory shortage, some workloads should be killed in
> a first order, others should be killed only if there is no other option.
> Several workloads can have equal importance. Size-based tiebreaking
> is very useful to catch memory leakers amongst them.

OK, please document that in the changelog.

> > That brings me back to my original suggestion. Wouldn't a "register an
> > oom strategy" approach much better than blending things together and
> > then have to wrap heads around different combinations of tunables?
> 
> Well, I believe that 90% of this patchset is still relevant;

agreed and didn't say otherwise.

> the only
> thing you might want to customize/replace size-based tiebreaking with
> something else (like timestamp-based tiebreaking, mentioned by David earlier).

> What about tunables, there are two, and they are completely orthogonal:
> 1) oom_priority allows to define an order, in which cgroups will be OOMed
> 2) oom_kill_all defines if all or just one task should be killed
> 
> So, I don't think it's a too complex interface.
> 
> Again, I'm not against oom strategy approach, it just looks as a much bigger
> project, and I do not see a big need.

Well, I was thinking that our current oom victim selection code is
quite extensible already. Your patches will teach it kill the whole
group semantic which is already very useful. Now we can talk about the
selection criteria and this is something to be replaceable. Because even
the current discussion has shown that different people might and will
have different requirements. Can we structure the code in such a way
that new comparison algorithm would be simple to add without reworking
the whole selection logic?

> Do you have an example, which can't be effectively handled by an approach
> I'm suggesting?

No, I do not have any which would be _explicitly_ requested but I do
envision new requirements will emerge. The most probable one would be
kill the youngest container because that would imply the least amount of
work wasted.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
