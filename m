Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 55D0C6B0538
	for <linux-mm@kvack.org>; Thu,  7 Sep 2017 12:15:11 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id k20so149130wre.6
        for <linux-mm@kvack.org>; Thu, 07 Sep 2017 09:15:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id m30si37259edj.280.2017.09.07.09.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Sep 2017 09:15:09 -0700 (PDT)
Date: Thu, 7 Sep 2017 12:14:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170907161457.GA1728@cmpxchg.org>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905215344.GA27427@cmpxchg.org>
 <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 06, 2017 at 10:28:59AM +0200, Michal Hocko wrote:
> On Tue 05-09-17 17:53:44, Johannes Weiner wrote:
> > The cgroup-awareness in the OOM killer is exactly the same thing. It
> > should have been the default from the beginning, because the user
> > configures a group of tasks to be an interdependent, terminal unit of
> > memory consumption, and it's undesirable for the OOM killer to ignore
> > this intention and compare members across these boundaries.
> 
> I would agree if that was true in general. I can completely see how the
> cgroup awareness is useful in e.g. containerized environments (especially
> with kill-all enabled) but memcgs are used in a large variety of
> usecases and I cannot really say all of them really demand the new
> semantic. Say I have a workload which doesn't want to see reclaim
> interference from others on the same machine. Why should I kill a
> process from that particular memcg just because it is the largest one
> when there is a memory hog/leak outside of this memcg?

Sure, it's always possible to come up with a config for which this
isn't the optimal behavior. But this is about picking a default that
makes sense to most users, and that type of cgroup usage just isn't
the common case.

> From my point of view the safest (in a sense of the least surprise)
> way to go with opt-in for the new heuristic. I am pretty sure all who
> would benefit from the new behavior will enable it while others will not
> regress in unexpected way.

This thinking simply needs to be balanced against the need to make an
unsurprising and consistent final interface.

The current behavior breaks isolation by letting tasks in different
cgroups compete with each other during an OOM kill. While you can
rightfully argue that it's possible for usecases to rely on this, you
cannot tell me that this is the least-surprising thing we can offer
users; certainly not new users, but also not many/most existing ones.

> We can talk about the way _how_ to control these oom strategies, of
> course. But I would be really reluctant to change the default which is
> used for years and people got used to it.

I really doubt there are many cgroup users that rely on that
particular global OOM behavior.

We have to agree to disagree, I guess.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
