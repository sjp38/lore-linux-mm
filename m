Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5E8B6C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:55:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ECF924622
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 11:55:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=cmpxchg-org.20150623.gappssmtp.com header.i=@cmpxchg-org.20150623.gappssmtp.com header.b="1VcEEnwc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ECF924622
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=cmpxchg.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 86D066B0277; Tue,  4 Jun 2019 07:55:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 81DC86B0278; Tue,  4 Jun 2019 07:55:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E4F06B0279; Tue,  4 Jun 2019 07:55:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 428686B0277
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 07:55:29 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id y190so3310351qkc.21
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 04:55:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=h8UiBw5YF7XvZ0Sc1GxQewXB7h1IamgVFTbLK/OqV7s=;
        b=QnTCVFkgEhniDPxagqjz+lGJa35YB+YX8lsFEGz+CcdGq2if9zGmcEkTFGK3mk7VMd
         7BBviltugK7qZSMjguyZ0UFQL4ovorzhe8iiuQASAvguySWtl9Y24JSjk2I6eHgSnElN
         4HNCNULtO7LJbzi9pUgaNhHOrATDssp4/x1+HdfOIhr+fa86A3O5V8UGevJVFwoZHO1e
         7D3P1jqqR8kqi9ptW8DEDTc4mBJywfVwYapdWnvvq6Kj8sbSDpSu4Lic+/TP0fUMMIKS
         ZdUAzX3b6gwWu0BzRvRqT4bUKHWL3HcMB4o2QKGLmscFV2fCDy6fzf9qEF2oWIx09ZEf
         HWAg==
X-Gm-Message-State: APjAAAUvdPs2KCVM99SVimivb3E7wwbqaXxKL76cYz5u6Y/r5aDb3DKJ
	u1scDjQq8rJZdqSaxqH8kOOrh9EGIYuyeftYLZAC5UCv2Mm4XNNu/lJMFxL+9fKtcd91WtxGBUf
	Kyg+j4H23DdFf73XyF7oPp+jMk3fj9bRUv0/6oM9CnVs+KZdCZBlS9NBv19vLpKn86w==
X-Received: by 2002:ac8:38cf:: with SMTP id g15mr21370127qtc.268.1559649329000;
        Tue, 04 Jun 2019 04:55:29 -0700 (PDT)
X-Received: by 2002:ac8:38cf:: with SMTP id g15mr21370090qtc.268.1559649328342;
        Tue, 04 Jun 2019 04:55:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559649328; cv=none;
        d=google.com; s=arc-20160816;
        b=m1zPcqBGv8qT0QmFSoXkPwub+yiqYxg4BSkVhca1YG2InNyBTnyIrubjFoKnS0z42t
         bkRX94H3M9gB6fKU69Uvu5we0wWSN0e9T2AI/58L/ozwIykiFH3uHqZiRtrMNgeFoWNg
         SrEzHx1mPtzrHFK580QuqZq1ApM/sevBfX45qFG/a0GefwYqLq9xOXPRdzHVgh+iQYig
         DX4hd0eryKc6QXtzcmGR8Yx16FNnlqdEDik9vn2jTffq1rAwmVRyI73WLPUdlTzA7YJH
         MZXr0epIV2JhwLDgJlgZr3YdiL4GzBf0vKZZHEC4DHA7Ilg6pCG/2shI/ULmTc+q31rQ
         cBAg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=h8UiBw5YF7XvZ0Sc1GxQewXB7h1IamgVFTbLK/OqV7s=;
        b=Vcy1aj2VRunC9rTzN+ZweIuiZA3EQNnR0HrweuiI/6rZ0qmBMN9yPtgk6lo1jEGuRD
         m0ExcBPFsheXIEYsDbRbErB+Zcrm8h1vPoEYsrGk2g3xw+zXN7u0XD1tOvRnmdb38o3E
         eSvIt5Dge/zZtx5YgUiHIrluyXcJK+ZK9bDgZd//8+U2n6SApvzwO6kqq780hFBgDJcf
         SSDzUSqX0Fcrxpq5F3rK4xgqY0Qfype8S+cpCuWeYQKHrVqGR+Ykdx4NXPaGZt75sODS
         U+phtscrvZihDp/5WHiQCJzI+TjyA78cj/joifIGIgYMwEwHViiB36bU4EhhPMLfQHTe
         p0CA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1VcEEnwc;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor1993226qvj.51.2019.06.04.04.55.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 04 Jun 2019 04:55:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@cmpxchg-org.20150623.gappssmtp.com header.s=20150623 header.b=1VcEEnwc;
       spf=pass (google.com: domain of hannes@cmpxchg.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=hannes@cmpxchg.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=cmpxchg.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=cmpxchg-org.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=h8UiBw5YF7XvZ0Sc1GxQewXB7h1IamgVFTbLK/OqV7s=;
        b=1VcEEnwcedHvdBV5Fz7LJACfGBlBEELnMr9lZCVc2tdNE17MzFVpq3PoO/OYI2CCab
         PbqwkZP2yZWzjc+T0Jzc8PjnxxRFUDS9opGd+STgN30OkQtqfd1ZTwE941ui9q0075y/
         Ps7mcgfZ/aX1FeJv1qcr8noLIEPZnU7n8FX4EcIymK1+Pod5kyZ/NwyceIZD0nfU37O+
         98J6uUSrYWKl6ib4NHpZBkNCay2V1SMDszW/Nn+a3cRNsbmEifBSv9VB70FZ/u4ov2+m
         EkfNnqfCq6StXsNSJ7hTQekxOgZ34KjdyYWuP0EgiVhA6B3nNr7XnM1j8ZPTD+B7tCed
         cfWA==
X-Google-Smtp-Source: APXvYqyV1Dm27WU4y+l7+YFidXGLtknNS0wTxBBMR5Oynuq7MZkxquuK4YQ95aMau8OAsZdcxtdeGw==
X-Received: by 2002:a0c:88c3:: with SMTP id 3mr8026706qvo.21.1559649321482;
        Tue, 04 Jun 2019 04:55:21 -0700 (PDT)
Received: from localhost (pool-108-27-252-85.nycmny.fios.verizon.net. [108.27.252.85])
        by smtp.gmail.com with ESMTPSA id 41sm3499015qtp.32.2019.06.04.04.55.20
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Jun 2019 04:55:20 -0700 (PDT)
Date: Tue, 4 Jun 2019 07:55:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
To: Joseph Qi <joseph.qi@linux.alibaba.com>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, akpm@linux-foundation.org,
	Tejun Heo <tj@kernel.org>,
	Jiufei Xue <jiufei.xue@linux.alibaba.com>,
	Caspar Zhang <caspar@linux.alibaba.com>
Subject: Re: [RFC PATCH 2/3] psi: cgroup v1 support
Message-ID: <20190604115519.GA18545@cmpxchg.org>
References: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
 <20190604015745.78972-3-joseph.qi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190604015745.78972-3-joseph.qi@linux.alibaba.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jun 04, 2019 at 09:57:44AM +0800, Joseph Qi wrote:
> Implements pressure stall tracking for cgroup v1.
> 
> Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
> ---
>  kernel/sched/psi.c | 65 +++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 56 insertions(+), 9 deletions(-)
> 
> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
> index 7acc632c3b82..909083c828d5 100644
> --- a/kernel/sched/psi.c
> +++ b/kernel/sched/psi.c
> @@ -719,13 +719,30 @@ static u32 psi_group_change(struct psi_group *group, int cpu,
>  	return state_mask;
>  }
>  
> -static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
> +static struct cgroup *psi_task_cgroup(struct task_struct *task, enum psi_res res)
> +{
> +	switch (res) {
> +	case NR_PSI_RESOURCES:
> +		return task_dfl_cgroup(task);
> +	case PSI_IO:
> +		return task_cgroup(task, io_cgrp_subsys.id);
> +	case PSI_MEM:
> +		return task_cgroup(task, memory_cgrp_subsys.id);
> +	case PSI_CPU:
> +		return task_cgroup(task, cpu_cgrp_subsys.id);
> +	default:  /* won't reach here */
> +		return NULL;
> +	}
> +}
> +
> +static struct psi_group *iterate_groups(struct task_struct *task, void **iter,
> +					enum psi_res res)
>  {
>  #ifdef CONFIG_CGROUPS
>  	struct cgroup *cgroup = NULL;
>  
>  	if (!*iter)
> -		cgroup = task->cgroups->dfl_cgrp;
> +		cgroup = psi_task_cgroup(task, res);
>  	else if (*iter == &psi_system)
>  		return NULL;
>  	else
> @@ -776,15 +793,45 @@ void psi_task_change(struct task_struct *task, int clear, int set)
>  		     wq_worker_last_func(task) == psi_avgs_work))
>  		wake_clock = false;
>  
> -	while ((group = iterate_groups(task, &iter))) {
> -		u32 state_mask = psi_group_change(group, cpu, clear, set);
> +	if (cgroup_subsys_on_dfl(cpu_cgrp_subsys) ||
> +	    cgroup_subsys_on_dfl(memory_cgrp_subsys) ||
> +	    cgroup_subsys_on_dfl(io_cgrp_subsys)) {
> +		while ((group = iterate_groups(task, &iter, NR_PSI_RESOURCES))) {
> +			u32 state_mask = psi_group_change(group, cpu, clear, set);
>  
> -		if (state_mask & group->poll_states)
> -			psi_schedule_poll_work(group, 1);
> +			if (state_mask & group->poll_states)
> +				psi_schedule_poll_work(group, 1);
>  
> -		if (wake_clock && !delayed_work_pending(&group->avgs_work))
> -			schedule_delayed_work(&group->avgs_work, PSI_FREQ);
> +			if (wake_clock && !delayed_work_pending(&group->avgs_work))
> +				schedule_delayed_work(&group->avgs_work, PSI_FREQ);
> +		}
> +	} else {
> +		enum psi_task_count i;
> +		enum psi_res res;
> +		int psi_flags = clear | set;
> +
> +		for (i = NR_IOWAIT; i < NR_PSI_TASK_COUNTS; i++) {
> +			if ((i == NR_IOWAIT) && (psi_flags & TSK_IOWAIT))
> +				res = PSI_IO;
> +			else if ((i == NR_MEMSTALL) && (psi_flags & TSK_MEMSTALL))
> +				res = PSI_MEM;
> +			else if ((i == NR_RUNNING) && (psi_flags & TSK_RUNNING))
> +				res = PSI_CPU;
> +			else
> +				continue;
> +
> +			while ((group = iterate_groups(task, &iter, res))) {
> +				u32 state_mask = psi_group_change(group, cpu, clear, set);

This doesn't work. Each resource state is composed of all possible
task states:

static bool test_state(unsigned int *tasks, enum psi_states state)
{
	switch (state) {
	case PSI_IO_SOME:
		return tasks[NR_IOWAIT];
	case PSI_IO_FULL:
		return tasks[NR_IOWAIT] && !tasks[NR_RUNNING];
	case PSI_MEM_SOME:
		return tasks[NR_MEMSTALL];
	case PSI_MEM_FULL:
		return tasks[NR_MEMSTALL] && !tasks[NR_RUNNING];
	case PSI_CPU_SOME:
		return tasks[NR_RUNNING] > 1;
	case PSI_NONIDLE:
		return tasks[NR_IOWAIT] || tasks[NR_MEMSTALL] ||
			tasks[NR_RUNNING];
	default:
		return false;
	}
}

So the IO controller needs to know of NR_RUNNING to tell some vs full,
the memory controller needs to know of NR_IOWAIT to tell nonidle etc.

You need to run the full psi task tracking and aggregation machinery
separately for each of the different cgroups a task can be in in v1.

Needless to say, that is expensive. For cpu, memory and io, it's
triple the scheduling overhead with three ancestor walks and three
times the cache footprint; three times more aggregation workers every
two seconds... We could never turn this on per default.

Have you considered just co-mounting cgroup2, if for nothing else, to
get the pressure numbers?

