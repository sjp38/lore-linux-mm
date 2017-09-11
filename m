Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id F3C1D6B02B0
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 05:06:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g50so8159782wra.4
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:06:02 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o76si6776002wrb.226.2017.09.11.02.06.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 11 Sep 2017 02:06:01 -0700 (PDT)
Date: Mon, 11 Sep 2017 11:05:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170911090559.aknbuyqumsc2gm5j@dhcp22.suse.cz>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905215344.GA27427@cmpxchg.org>
 <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
 <20170907161457.GA1728@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170907161457.GA1728@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu 07-09-17 12:14:57, Johannes Weiner wrote:
> On Wed, Sep 06, 2017 at 10:28:59AM +0200, Michal Hocko wrote:
> > On Tue 05-09-17 17:53:44, Johannes Weiner wrote:
> > > The cgroup-awareness in the OOM killer is exactly the same thing. It
> > > should have been the default from the beginning, because the user
> > > configures a group of tasks to be an interdependent, terminal unit of
> > > memory consumption, and it's undesirable for the OOM killer to ignore
> > > this intention and compare members across these boundaries.
> > 
> > I would agree if that was true in general. I can completely see how the
> > cgroup awareness is useful in e.g. containerized environments (especially
> > with kill-all enabled) but memcgs are used in a large variety of
> > usecases and I cannot really say all of them really demand the new
> > semantic. Say I have a workload which doesn't want to see reclaim
> > interference from others on the same machine. Why should I kill a
> > process from that particular memcg just because it is the largest one
> > when there is a memory hog/leak outside of this memcg?
> 
> Sure, it's always possible to come up with a config for which this
> isn't the optimal behavior. But this is about picking a default that
> makes sense to most users, and that type of cgroup usage just isn't
> the common case.

How can you tell, really? Even if cgroup2 is a new interface we still
want as many legacy (v1) users to be migrated to the new hierarchy.
I have seen quite different usecases over time and I have hard time to
tell which of them to call common enough.

> > From my point of view the safest (in a sense of the least surprise)
> > way to go with opt-in for the new heuristic. I am pretty sure all who
> > would benefit from the new behavior will enable it while others will not
> > regress in unexpected way.
> 
> This thinking simply needs to be balanced against the need to make an
> unsurprising and consistent final interface.

Sure. And I _think_ we can come up with a clear interface to configure
the oom behavior - e.g. a kernel command line parameter with a default
based on a config option.
 
> The current behavior breaks isolation by letting tasks in different
> cgroups compete with each other during an OOM kill. While you can
> rightfully argue that it's possible for usecases to rely on this, you
> cannot tell me that this is the least-surprising thing we can offer
> users; certainly not new users, but also not many/most existing ones.

I would argue that a global OOM has been always a special case and
people got used to "kill the largest task" strategy. I have seen
multiple reports where people were complaining when this wasn't the case
(e.g. when the NUMA policies were involved).

> > We can talk about the way _how_ to control these oom strategies, of
> > course. But I would be really reluctant to change the default which is
> > used for years and people got used to it.
> 
> I really doubt there are many cgroup users that rely on that
> particular global OOM behavior.
> 
> We have to agree to disagree, I guess.

Yes, I am afraid so. And I do not hear this would be a feature so many
users have been asking for a long time to simply say "yeah everybody
wants that, make it a default". And as such I do not see a reason why we
should enforce it on all users. It is really trivial to enable it when
it is considered useful.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
