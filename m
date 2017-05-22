Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F8C7831F5
	for <linux-mm@kvack.org>; Mon, 22 May 2017 13:32:25 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id f96so56252798qki.14
        for <linux-mm@kvack.org>; Mon, 22 May 2017 10:32:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 94si19303576qkw.248.2017.05.22.10.32.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 10:32:24 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/17] cgroup: Implement new thread mode semantics
References: <1494855256-12558-1-git-send-email-longman@redhat.com>
 <1494855256-12558-12-git-send-email-longman@redhat.com>
 <20170519202624.GA15279@wtj.duckdns.org>
 <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <71ce8f1c-3d92-64f2-085d-8900b8576d25@redhat.com>
Date: Mon, 22 May 2017 13:32:20 -0400
MIME-Version: 1.0
In-Reply-To: <b1d02881-f522-8baa-5ebe-9b1ad74a03e4@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, kernel-team@fb.com, pjt@google.com, luto@amacapital.net, efault@gmx.de

On 05/22/2017 01:13 PM, Waiman Long wrote:
> On 05/19/2017 04:26 PM, Tejun Heo wrote:
>>> @@ -2982,22 +3010,48 @@ static int cgroup_enable_threaded(struct cgroup *cgrp)
>>>  	LIST_HEAD(csets);
>>>  	struct cgrp_cset_link *link;
>>>  	struct css_set *cset, *cset_next;
>>> +	struct cgroup *child;
>>>  	int ret;
>>> +	u16 ss_mask;
>>>  
>>>  	lockdep_assert_held(&cgroup_mutex);
>>>  
>>>  	/* noop if already threaded */
>>> -	if (cgrp->proc_cgrp)
>>> +	if (cgroup_is_threaded(cgrp))
>>>  		return 0;
>>>  
>>> -	/* allow only if there are neither children or enabled controllers */
>>> -	if (css_has_online_children(&cgrp->self) || cgrp->subtree_control)
>>> +	/*
>>> +	 * Allow only if it is not the root and there are:
>>> +	 * 1) no children,
>>> +	 * 2) no non-threaded controllers are enabled, and
>>> +	 * 3) no attached tasks.
>>> +	 *
>>> +	 * With no attached tasks, it is assumed that no css_sets will be
>>> +	 * linked to the current cgroup. This may not be true if some dead
>>> +	 * css_sets linger around due to task_struct leakage, for example.
>>> +	 */
>> It doesn't look like the code is actually making this (incorrect)
>> assumption.  I suppose the comment is from before
>> cgroup_is_populated() was added?
> Yes, it is a bug. I should have checked the tasks_count instead of using
> cgroup_is_populated. Thanks for catching that.

Sorry, I would like to take it back. I think cgroup_is_populated() will
be set if there is any task attached to the cgroup. So I think it is
doing the right thing with regard to (3).

Cheers,
Longman

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
