Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DA4566B0031
	for <linux-mm@kvack.org>; Thu,  6 Jun 2013 08:08:27 -0400 (EDT)
Message-ID: <51B07BEC.9010205@parallels.com>
Date: Thu, 6 Jun 2013 16:09:16 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v10 29/35] memcg: per-memcg kmem shrinking
References: <1370287804-3481-1-git-send-email-glommer@openvz.org> <1370287804-3481-30-git-send-email-glommer@openvz.org> <20130605160841.909420c06bfde62039489d2e@linux-foundation.org> <51B049D5.2020809@parallels.com> <20130606024906.e5b85b28.akpm@linux-foundation.org>
In-Reply-To: <20130606024906.e5b85b28.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Glauber Costa <glommer@openvz.org>, linux-fsdevel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Dave Chinner <david@fromorbit.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, hughd@google.com, Greg Thelen <gthelen@google.com>, Dave Chinner <dchinner@redhat.com>, Rik van Riel <riel@redhat.com>

On 06/06/2013 01:49 PM, Andrew Morton wrote:
> On Thu, 6 Jun 2013 12:35:33 +0400 Glauber Costa <glommer@parallels.com> wrote:
> 
>> On 06/06/2013 03:08 AM, Andrew Morton wrote:
>>>> +
>>>>> +		/*
>>>>> +		 * We will try to shrink kernel memory present in caches. We
>>>>> +		 * are sure that we can wait, so we will. The duration of our
>>>>> +		 * wait is determined by congestion, the same way as vmscan.c
>>>>> +		 *
>>>>> +		 * If we are in FS context, though, then although we can wait,
>>>>> +		 * we cannot call the shrinkers. Most fs shrinkers (which
>>>>> +		 * comprises most of our kmem data) will not run without
>>>>> +		 * __GFP_FS since they can deadlock. The solution is to
>>>>> +		 * synchronously run that in a different context.
>>> But this is pointless.  Calling a function via a different thread and
>>> then waiting for it to complete is equivalent to calling it directly.
>>>
>> Not in this case. We are in wait-capable context (we check for this
>> right before we reach this), but we are not in fs capable context.
>>
>> So the reason we do this - which I tried to cover in the changelog, is
>> to escape from the GFP_FS limitation that our call chain has, not the
>> wait limitation.
> 
> But that's equivalent to calling the code directly.  Look:
> 
> some_fs_function()
> {
> 	lock(some-fs-lock);
> 	...
> }
> 
> some_other_fs_function()
> {
> 	lock(some-fs-lock);
> 	alloc_pages(GFP_NOFS);
> 	->...
> 	  ->schedule_work(some_fs_function);
> 	    flush_scheduled_work();
> 
> that flush_scheduled_work() won't complete until some_fs_function() has
> completed.  But some_fs_function() won't complete, because we're
> holding some-fs-lock.
> 

In my experience during this series, most of the kmem allocation here
will be filesystem related. This means that we will allocate that with
GFP_FS on. If we don't do anything like that, reclaim is almost
pointless since it will never free anything (only once here and there
when the allocation is not from fs).

It tend to work just fine like this. It may very well be because fs
people just mark everything as NOFS out of safety and we aren't *really*
holding any locks in common situations, but it will blow in our faces in
a subtle way (which none of us want).

That said, suggestions are more than welcome.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
