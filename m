Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5CA446B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 18:00:29 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id q75so2061823pfl.1
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 15:00:29 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id t9si9689219pge.444.2017.09.13.15.00.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 15:00:28 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:59:57 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 2/4] mm, oom: cgroup-aware OOM killer
Message-ID: <20170913215957.GB19259@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <20170911131742.16482-3-guro@fb.com>
 <alpine.DEB.2.10.1709131346200.146292@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1709131346200.146292@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 13, 2017 at 01:46:51PM -0700, David Rientjes wrote:
> On Mon, 11 Sep 2017, Roman Gushchin wrote:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 15af3da5af02..da2b12ea4667 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -2661,6 +2661,231 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
> >  	return ret;
> >  }
> >  
> > +static long memcg_oom_badness(struct mem_cgroup *memcg,
> > +			      const nodemask_t *nodemask,
> > +			      unsigned long totalpages)
> > +{
> > +	long points = 0;
> > +	int nid;
> > +	pg_data_t *pgdat;
> > +
> > +	/*
> > +	 * We don't have necessary stats for the root memcg,
> > +	 * so we define it's oom_score as the maximum oom_score
> > +	 * of the belonging tasks.
> > +	 */
> > +	if (memcg == root_mem_cgroup) {
> > +		struct css_task_iter it;
> > +		struct task_struct *task;
> > +		long score, max_score = 0;
> > +
> > +		css_task_iter_start(&memcg->css, 0, &it);
> > +		while ((task = css_task_iter_next(&it))) {
> > +			score = oom_badness(task, memcg, nodemask,
> > +					    totalpages);
> > +			if (max_score > score)
> 
> score > max_score

Ups. Fixed. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
