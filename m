Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 774806B025F
	for <linux-mm@kvack.org>; Fri,  6 Oct 2017 08:05:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y8so9396013wrd.0
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 05:05:08 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id n7si1750607edn.262.2017.10.06.05.05.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Oct 2017 05:05:06 -0700 (PDT)
Date: Fri, 6 Oct 2017 13:04:35 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v11 4/6] mm, oom: introduce memory.oom_group
Message-ID: <20171006120435.GA22702@castle.dhcp.TheFacebook.com>
References: <20171005130454.5590-1-guro@fb.com>
 <20171005130454.5590-5-guro@fb.com>
 <20171005143104.wo5xstpe7mhkdlbr@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20171005143104.wo5xstpe7mhkdlbr@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Oct 05, 2017 at 04:31:04PM +0200, Michal Hocko wrote:
> Btw. here is how I would do the recursive oom badness. The diff is not
> the nicest one because there is some code moving but the resulting code
> is smaller and imho easier to grasp. Only compile tested though

Thanks!

I'm not against this approach, and maybe it can lead to a better code,
but the version you sent is just not there yet.

There are some problems with it:

1) If there are nested cgroups with oom_group set, you will calculate
a badness multiple times, and rely on the fact, that top memcg will
become the largest score. It can be optimized, of course, but it's
additional code.

2) cgroup_has_tasks() probably requires additional locking.
Maybe it's ok to read nr_populated_csets without explicit locking,
but it's not obvious for me.

3) Returning -1 from memcg_oom_badness() if eligible is equal to 0
is suspicious.

Right now your version has exactly the same amount of code
(skipping comments). I assume, this approach just requires some additional
thinking/rework.

Anyway, thank you for sharing this!

> ---
> diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
> index 085056e562b1..9cdba4682198 100644
> --- a/include/linux/cgroup.h
> +++ b/include/linux/cgroup.h
> @@ -122,6 +122,11 @@ void cgroup_free(struct task_struct *p);
>  int cgroup_init_early(void);
>  int cgroup_init(void);
>  
> +static bool cgroup_has_tasks(struct cgroup *cgrp)
> +{
> +	return cgrp->nr_populated_csets;
> +}
> +
>  /*
>   * Iteration helpers and macros.
>   */
> diff --git a/kernel/cgroup/cgroup.c b/kernel/cgroup/cgroup.c
> index 8dacf73ad57e..a2dd7e3ffe23 100644
> --- a/kernel/cgroup/cgroup.c
> +++ b/kernel/cgroup/cgroup.c
> @@ -319,11 +319,6 @@ static void cgroup_idr_remove(struct idr *idr, int id)
>  	spin_unlock_bh(&cgroup_idr_lock);
>  }
>  
> -static bool cgroup_has_tasks(struct cgroup *cgrp)
> -{
> -	return cgrp->nr_populated_csets;
> -}
> -
>  bool cgroup_is_threaded(struct cgroup *cgrp)
>  {
>  	return cgrp->dom_cgrp != cgrp;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
