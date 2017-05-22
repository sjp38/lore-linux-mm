Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0C227831F4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 13:13:21 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 36so56237947qkz.10
        for <linux-mm@kvack.org>; Mon, 22 May 2017 10:13:21 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n143si18112949qkn.4.2017.05.22.10.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 10:13:20 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
From: Waiman Long <longman@redhat.com>
Message-ID: <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
Date: Mon, 22 May 2017 13:13:16 -0400
MIME-Version: 1.0
In-Reply-To: <20170519202624.GA15279@wtj.duckdns.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/19/2017 04:26 PM, Tejun Heo wrote:
> Hello, Waiman.
>
> On Mon, May 15, 2017 at 09:34:10AM -0400, Waiman Long wrote:
>> Now we could have something like
>>
>> 	R -- A -- B
>> 	 \
>> 	  T1 -- T2
>>
>> where R is the thread root, A and B are non-threaded cgroups, T1 and
>> T2 are threaded cgroups. The cgroups R, T1, T2 form a threaded subtree=

>> where all the non-threaded resources are accounted for in R.  The no
>> internal process constraint does not apply in the threaded subtree.
>> Non-threaded controllers need to properly handle the competition
>> between internal processes and child cgroups at the thread root.
>>
>> This model will be flexible enough to support the need of the threaded=

>> controllers.
> Maybe I'm misunderstanding the design, but this seems to push the
> processes which belong to the threaded subtree to the parent which is
> part of the usual resource domain hierarchy thus breaking the no
> internal competition constraint.  I'm not sure this is something we'd
> want.  Given that the limitation of the original threaded mode was the
> required nesting below root and that we treat root special anyway
> (exactly in the way necessary), I wonder whether it'd be better to
> simply allow root to be both domain and thread root.

Yes, root can be both domain and thread root. I haven't placed any
restriction on that.

>
> Specific review points below but we'd probably want to discuss the
> overall design first.
>
>> +static inline bool cgroup_is_threaded(const struct cgroup *cgrp)
>> +{
>> +	return cgrp->proc_cgrp && (cgrp->proc_cgrp !=3D cgrp);
>> +}
>> +
>> +static inline bool cgroup_is_thread_root(const struct cgroup *cgrp)
>> +{
>> +	return cgrp->proc_cgrp =3D=3D cgrp;
>> +}
> Maybe add a bit of comments explaining what's going on with
> ->proc_cgrp?

Sure, will do that.

>>  /**
>> + * threaded_children_count - returns # of threaded children
>> + * @cgrp: cgroup to be tested
>> + *
>> + * cgroup_mutex must be held by the caller.
>> + */
>> +static int threaded_children_count(struct cgroup *cgrp)
>> +{
>> +	struct cgroup *child;
>> +	int count =3D 0;
>> +
>> +	lockdep_assert_held(&cgroup_mutex);
>> +	cgroup_for_each_live_child(child, cgrp)
>> +		if (cgroup_is_threaded(child))
>> +			count++;
>> +	return count;
>> +}
> It probably would be a good idea to keep track of the count so that we
> don't have to count them each time.  There are cases where people end
> up creating a very high number of cgroups and we've already been
> bitten a couple times with silly complexity issues.

Thanks for the suggestion, I can keep a count in the cgroup strcture to
avoid doing that repetitively.

>
>> @@ -2982,22 +3010,48 @@ static int cgroup_enable_threaded(struct cgrou=
p *cgrp)
>>  	LIST_HEAD(csets);
>>  	struct cgrp_cset_link *link;
>>  	struct css_set *cset, *cset_next;
>> +	struct cgroup *child;
>>  	int ret;
>> +	u16 ss_mask;
>> =20
>>  	lockdep_assert_held(&cgroup_mutex);
>> =20
>>  	/* noop if already threaded */
>> -	if (cgrp->proc_cgrp)
>> +	if (cgroup_is_threaded(cgrp))
>>  		return 0;
>> =20
>> -	/* allow only if there are neither children or enabled controllers *=
/
>> -	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
>> +	/*
>> +	 * Allow only if it is not the root and there are:
>> +	 * 1) no children,
>> +	 * 2) no non-threaded controllers are enabled, and
>> +	 * 3) no attached tasks.
>> +	 *
>> +	 * With no attached tasks, it is assumed that no css_sets will be
>> +	 * linked to the current cgroup. This may not be true if some dead
>> +	 * css_sets linger around due to task_struct leakage, for example.
>> +	 */
> It doesn't look like the code is actually making this (incorrect)
> assumption.  I suppose the comment is from before
> cgroup_is_populated() was added?

Yes, it is a bug. I should have checked the tasks_count instead of using
cgroup_is_populated. Thanks for catching that.

>
>>  	spin_lock_irq(&css_set_lock);
>>  	list_for_each_entry(link, &cgrp->cset_links, cset_link) {
>>  		cset =3D link->cset;
>> +		if (cset->dead)
>> +			continue;
> Hmm... is this a bug fix which is necessary regardless of whether we
> change the threadroot semantics or not?

That is true. I put it there because the the reference counting bug
fixed in patch 6 caused a lot of dead csets hanging around before the
fix. I can pull this out as a separate patch.

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
