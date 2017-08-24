Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id E784D28085D
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:10:57 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id 34so587181wrj.5
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:10:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 189si3216606wmi.20.2017.08.24.05.10.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 05:10:56 -0700 (PDT)
Date: Thu, 24 Aug 2017 14:10:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v6 3/4] mm, oom: introduce oom_priority for memory cgroups
Message-ID: <20170824121054.GI5943@dhcp22.suse.cz>
References: <20170823165201.24086-1-guro@fb.com>
 <20170823165201.24086-4-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170823165201.24086-4-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 23-08-17 17:52:00, Roman Gushchin wrote:
> Introduce a per-memory-cgroup oom_priority setting: an integer number
> within the [-10000, 10000] range, which defines the order in which
> the OOM killer selects victim memory cgroups.

Why do we need a range here?

> OOM killer prefers memory cgroups with larger priority if they are
> populated with eligible tasks.

So this is basically orthogonal to the score based selection and the
real size is only the tiebreaker for same priorities? Could you describe
the usecase? Becasuse to me this sounds like a separate oom killer
strategy. I can imagine somebody might be interested (e.g. always kill
the oldest memcgs...) but an explicit range wouldn't fly with such a
usecase very well.

That brings me back to my original suggestion. Wouldn't a "register an
oom strategy" approach much better than blending things together and
then have to wrap heads around different combinations of tunables?

[...]
> @@ -2760,7 +2761,12 @@ static void select_victim_memcg(struct mem_cgroup *root, struct oom_control *oc)
>  			if (iter->oom_score == 0)
>  				continue;
>  
> -			if (iter->oom_score > score) {
> +			if (iter->oom_priority > prio) {
> +				memcg = iter;
> +				prio = iter->oom_priority;
> +				score = iter->oom_score;
> +			} else if (iter->oom_priority == prio &&
> +				   iter->oom_score > score) {
>  				memcg = iter;
>  				score = iter->oom_score;
>  			}

Just a minor thing. Why do we even have to calculate oom_score when we
use it only as a tiebreaker?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
