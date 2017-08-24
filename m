Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 44810440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:52:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 123so624997wml.8
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:52:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 53si3399805wrc.182.2017.08.24.05.52.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 05:52:02 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:51:13 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v6 3/4] mm, oom: introduce oom_priority for memory cgroups
Message-ID: <20170824125113.GB15916@castle.DHCP.thefacebook.com>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-4-guro@fb.com>
 <20170824121054.GI5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170824121054.GI5943@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Aug 24, 2017 at 02:10:54PM +0200, Michal Hocko wrote:
> On Wed 23-08-17 17:52:00, Roman Gushchin wrote:
> > Introduce a per-memory-cgroup oom_priority setting: an integer number
> > within the [-10000, 10000] range, which defines the order in which
> > the OOM killer selects victim memory cgroups.
> 
> Why do we need a range here?

No specific reason, both [INT_MIN, INT_MAX] and [-10000, 10000] will
work equally. We should be able to predefine an OOM killing order for
any reasonable amount of cgroups.

> 
> > OOM killer prefers memory cgroups with larger priority if they are
> > populated with eligible tasks.
> 
> So this is basically orthogonal to the score based selection and the
> real size is only the tiebreaker for same priorities? Could you describe
> the usecase? Becasuse to me this sounds like a separate oom killer
> strategy. I can imagine somebody might be interested (e.g. always kill
> the oldest memcgs...) but an explicit range wouldn't fly with such a
> usecase very well.

The usecase: you have a machine with several containerized workloads
of different importance, and some system-level stuff, also in (memory)
cgroups.
In case of global memory shortage, some workloads should be killed in
a first order, others should be killed only if there is no other option.
Several workloads can have equal importance. Size-based tiebreaking
is very useful to catch memory leakers amongst them.

> 
> That brings me back to my original suggestion. Wouldn't a "register an
> oom strategy" approach much better than blending things together and
> then have to wrap heads around different combinations of tunables?

Well, I believe that 90% of this patchset is still relevant; the only
thing you might want to customize/replace size-based tiebreaking with
something else (like timestamp-based tiebreaking, mentioned by David earlier).

What about tunables, there are two, and they are completely orthogonal:
1) oom_priority allows to define an order, in which cgroups will be OOMed
2) oom_kill_all defines if all or just one task should be killed

So, I don't think it's a too complex interface.

Again, I'm not against oom strategy approach, it just looks as a much bigger
project, and I do not see a big need.

Do you have an example, which can't be effectively handled by an approach
I'm suggesting?

> 
> [...]
> > @@ -2760,7 +2761,12 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> >  			if (iter->oom_score == 0)
> >  				continue;
> >  
> > -			if (iter->oom_score > score) {
> > +			if (iter->oom_priority > prio) {
> > +				memcg = iter;
> > +				prio = iter->oom_priority;
> > +				score = iter->oom_score;
> > +			} else if (iter->oom_priority == prio &&
> > +				   iter->oom_score > score) {
> >  				memcg = iter;
> >  				score = iter->oom_score;
> >  			}
> 
> Just a minor thing. Why do we even have to calculate oom_score when we
> use it only as a tiebreaker?

Right now it's necessary, because at the same time we do look for
per-existing OOM victims. But if we can have a memcg-level counter for it,
this can be optimized.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
