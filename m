Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7D6656B02BE
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 08:50:48 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id q132so6255030lfe.1
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 05:50:48 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 26si3275426lfw.186.2017.09.11.05.50.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 05:50:47 -0700 (PDT)
Date: Mon, 11 Sep 2017 13:50:08 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v7 5/5] mm, oom: cgroup v2 mount option to disable cgroup-aware
 OOM killer
Message-ID: <20170911125008.GA4340@castle>
References: <20170904142108.7165-1-guro@fb.com>
 <20170904142108.7165-6-guro@fb.com>
 <20170905134412.qdvqcfhvbdzmarna@dhcp22.suse.cz>
 <20170905215344.GA27427@cmpxchg.org>
 <20170906082859.qlqenftxuib64j35@dhcp22.suse.cz>
 <20170907161457.GA1728@cmpxchg.org>
 <20170911090559.aknbuyqumsc2gm5j@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170911090559.aknbuyqumsc2gm5j@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, Sep 11, 2017 at 11:05:59AM +0200, Michal Hocko wrote:
> On Thu 07-09-17 12:14:57, Johannes Weiner wrote:
> > On Wed, Sep 06, 2017 at 10:28:59AM +0200, Michal Hocko wrote:
> > > On Tue 05-09-17 17:53:44, Johannes Weiner wrote:
> > > > The cgroup-awareness in the OOM killer is exactly the same thing. It
> > > > should have been the default from the beginning, because the user
> > > > configures a group of tasks to be an interdependent, terminal unit of
> > > > memory consumption, and it's undesirable for the OOM killer to ignore
> > > > this intention and compare members across these boundaries.
> > > 
> > > I would agree if that was true in general. I can completely see how the
> > > cgroup awareness is useful in e.g. containerized environments (especially
> > > with kill-all enabled) but memcgs are used in a large variety of
> > > usecases and I cannot really say all of them really demand the new
> > > semantic. Say I have a workload which doesn't want to see reclaim
> > > interference from others on the same machine. Why should I kill a
> > > process from that particular memcg just because it is the largest one
> > > when there is a memory hog/leak outside of this memcg?
> > 
> > Sure, it's always possible to come up with a config for which this
> > isn't the optimal behavior. But this is about picking a default that
> > makes sense to most users, and that type of cgroup usage just isn't
> > the common case.
> 
> How can you tell, really? Even if cgroup2 is a new interface we still
> want as many legacy (v1) users to be migrated to the new hierarchy.
> I have seen quite different usecases over time and I have hard time to
> tell which of them to call common enough.
> 
> > > From my point of view the safest (in a sense of the least surprise)
> > > way to go with opt-in for the new heuristic. I am pretty sure all who
> > > would benefit from the new behavior will enable it while others will not
> > > regress in unexpected way.
> > 
> > This thinking simply needs to be balanced against the need to make an
> > unsurprising and consistent final interface.
> 
> Sure. And I _think_ we can come up with a clear interface to configure
> the oom behavior - e.g. a kernel command line parameter with a default
> based on a config option.

I would say cgroup v2 mount option is better, because it allows to change
the behavior dynamically (without rebooting) and clearly reflects
cgroup v2 dependency.

Also, it makes systemd (or who is mounting cgroupfs) responsible for the
default behavior. And makes more or less not important what the default is.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
