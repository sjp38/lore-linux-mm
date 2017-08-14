Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 41E826B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 08:40:16 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id l2so133626160pgu.2
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 05:40:16 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id 94si4685187ple.611.2017.08.14.05.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 05:40:15 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:39:41 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v4 3/4] mm, oom: introduce oom_priority for memory cgroups
Message-ID: <20170814123941.GC24393@castle.DHCP.thefacebook.com>
References: <20170726132718.14806-1-guro@fb.com>
 <20170726132718.14806-4-guro@fb.com>
 <alpine.DEB.2.10.1708081607230.54505@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1708081607230.54505@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 08, 2017 at 04:14:50PM -0700, David Rientjes wrote:
> On Wed, 26 Jul 2017, Roman Gushchin wrote:
> 
> > Introduce a per-memory-cgroup oom_priority setting: an integer number
> > within the [-10000, 10000] range, which defines the order in which
> > the OOM killer selects victim memory cgroups.
> > 
> > OOM killer prefers memory cgroups with larger priority if they are
> > populated with elegible tasks.
> > 
> > The oom_priority value is compared within sibling cgroups.
> > 
> > The root cgroup has the oom_priority 0, which cannot be changed.
> > 
> 
> Awesome!  Very excited to see that you implemented this suggestion and it 
> is similar to priority based oom killing that we have done.  I think this 
> kind of support is long overdue in the oom killer.
> 
> Comment inline.
> 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: David Rientjes <rientjes@google.com>
> > Cc: Tejun Heo <tj@kernel.org>
> > Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: kernel-team@fb.com
> > Cc: cgroups@vger.kernel.org
> > Cc: linux-doc@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > ---
> >  include/linux/memcontrol.h |  3 +++
> >  mm/memcontrol.c            | 55 ++++++++++++++++++++++++++++++++++++++++++++--
> >  2 files changed, 56 insertions(+), 2 deletions(-)
> > 
> > diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> > index b21bbb0edc72..d31ac58e08ad 100644
> > --- a/include/linux/memcontrol.h
> > +++ b/include/linux/memcontrol.h
> > @@ -206,6 +206,9 @@ struct mem_cgroup {
> >  	/* cached OOM score */
> >  	long oom_score;
> >  
> > +	/* OOM killer priority */
> > +	short oom_priority;
> > +
> >  	/* handle for "memory.events" */
> >  	struct cgroup_file events_file;
> >  
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index ba72d1cf73d0..2c1566995077 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2710,12 +2710,21 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
> >  	for (;;) {
> >  		struct cgroup_subsys_state *css;
> >  		struct mem_cgroup *memcg = NULL;
> > +		short prio = SHRT_MIN;
> >  		long score = LONG_MIN;
> >  
> >  		css_for_each_child(css, &root->css) {
> >  			struct mem_cgroup *iter = mem_cgroup_from_css(css);
> >  
> > -			if (iter->oom_score > score) {
> > +			if (iter->oom_score == 0)
> > +				continue;
> > +
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
> Your tiebreaking is done based on iter->oom_score, which I suppose makes 
> sense given that the oom killer traditionally tries to kill from the 
> largest memory hogging process.
> 
> We actually tiebreak on a timestamp of memcg creation and prefer to kill 
> from the newer memcg when iter->oom_priority is the same.  The reasoning 
> is that we schedule jobs on a machine that have an inherent priority but 
> is unaware of other jobs running at the same priority and so the kill 
> decision, if based on iter->oom_score, may differ based on current memory 
> usage.
> 
> I'm not necessarily arguing against using iter->oom_score, but was 
> wondering if you would also find that tiebreaking based on a timestamp 
> when priorities are the same is a more clear semantic to describe?  It's 
> similar to how the system oom killer tiebreaked based on which task_struct 
> appeared later in the tasklist when memory usage was the same.
> 
> Your approach makes oom killing less likely in the near term since it 
> kills a more memory hogging memcg, but has the potential to lose less 
> work.  A timestamp based approach loses the least amount of work by 
> preferring to kill newer memcgs but oom killing may be more frequent if 
> smaller child memcgs are killed.  I would argue the former is the 
> responsibility of the user for using the same priority.

I think we should have the same approach for cgroups and processes.

We use the size-based approach for processes, and it will be really confusing
to have something different for memory cgroups. So I'd prefer to match
the existing behavior right now, and later, if required, extend both per-process
and per-cgroup algorithms to support the time-based evaluation.

Thanks!

Roman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
