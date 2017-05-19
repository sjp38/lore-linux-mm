Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9FDC528071E
	for <linux-mm@kvack.org>; Fri, 19 May 2017 16:26:32 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id l39so29271643qtb.9
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:26:32 -0700 (PDT)
Received: from mail-qk0-x244.google.com (mail-qk0-x244.google.com. [2607:f8b0:400d:c09::244])
        by mx.google.com with ESMTPS id i26si9770108qti.269.2017.05.19.13.26.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 May 2017 13:26:31 -0700 (PDT)
Received: by mail-qk0-x244.google.com with SMTP id k74so11649433qke.2
        for <linux-mm@kvack.org>; Fri, 19 May 2017 13:26:31 -0700 (PDT)
Date: Fri, 19 May 2017 16:26:24 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
Message-ID: <20170519202624.GA15279@wtj.duckdns.org>
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1494855256-12558-12-git-send-email-longman@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

Hello, Waiman.

On Mon, May 15, 2017 at 09:34:10AM -0400, Waiman Long wrote:
> Now we could have something like
> 
> 	R -- A -- B
> 	 \
> 	  T1 -- T2
> 
> where R is the thread root, A and B are non-threaded cgroups, T1 and
> T2 are threaded cgroups. The cgroups R, T1, T2 form a threaded subtree
> where all the non-threaded resources are accounted for in R.  The no
> internal process constraint does not apply in the threaded subtree.
> Non-threaded controllers need to properly handle the competition
> between internal processes and child cgroups at the thread root.
> 
> This model will be flexible enough to support the need of the threaded
> controllers.

Maybe I'm misunderstanding the design, but this seems to push the
processes which belong to the threaded subtree to the parent which is
part of the usual resource domain hierarchy thus breaking the no
internal competition constraint.  I'm not sure this is something we'd
want.  Given that the limitation of the original threaded mode was the
required nesting below root and that we treat root special anyway
(exactly in the way necessary), I wonder whether it'd be better to
simply allow root to be both domain and thread root.

Specific review points below but we'd probably want to discuss the
overall design first.

> +static inline bool cgroup_is_threaded(const struct cgroup *cgrp)
> +{
> +	return cgrp->proc_cgrp && (cgrp->proc_cgrp != cgrp);
> +}
> +
> +static inline bool cgroup_is_thread_root(const struct cgroup *cgrp)
> +{
> +	return cgrp->proc_cgrp == cgrp;
> +}

Maybe add a bit of comments explaining what's going on with
->proc_cgrp?

>  /**
> + * threaded_children_count - returns # of threaded children
> + * @cgrp: cgroup to be tested
> + *
> + * cgroup_mutex must be held by the caller.
> + */
> +static int threaded_children_count(struct cgroup *cgrp)
> +{
> +	struct cgroup *child;
> +	int count = 0;
> +
> +	lockdep_assert_held(&cgroup_mutex);
> +	cgroup_for_each_live_child(child, cgrp)
> +		if (cgroup_is_threaded(child))
> +			count++;
> +	return count;
> +}

It probably would be a good idea to keep track of the count so that we
don't have to count them each time.  There are cases where people end
up creating a very high number of cgroups and we've already been
bitten a couple times with silly complexity issues.

> @@ -2982,22 +3010,48 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
>  	LIST_HEAD(csets);
>  	struct cgrp_cset_link *link;
>  	struct css_set *cset, *cset_next;
> +	struct cgroup *child;
>  	int ret;
> +	u16 ss_mask;
>  
>  	lockdep_assert_held(&cgroup_mutex);
>  
>  	/* noop if already threaded */
> -	if (cgrp->proc_cgrp)
> +	if (cgroup_is_threaded(cgrp))
>  		return 0;
>  
> -	/* allow only if there are neither children or enabled controllers */
> -	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
> +	/*
> +	 * Allow only if it is not the root and there are:
> +	 * 1) no children,
> +	 * 2) no non-threaded controllers are enabled, and
> +	 * 3) no attached tasks.
> +	 *
> +	 * With no attached tasks, it is assumed that no css_sets will be
> +	 * linked to the current cgroup. This may not be true if some dead
> +	 * css_sets linger around due to task_struct leakage, for example.
> +	 */

It doesn't look like the code is actually making this (incorrect)
assumption.  I suppose the comment is from before
cgroup_is_populated() was added?

>  	spin_lock_irq(&css_set_lock);
>  	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
>  		cset = link->cset;
> +		if (cset->dead)
> +			continue;

Hmm... is this a bug fix which is necessary regardless of whether we
change the threadroot semantics or not?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
