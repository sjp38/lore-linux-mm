Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id CBD106B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 21:40:50 -0500 (EST)
Received: by mail-ia0-f177.google.com with SMTP id o25so2227872iad.36
        for <linux-mm@kvack.org>; Thu, 28 Feb 2013 18:40:50 -0800 (PST)
Message-ID: <5130152B.9060904@gmail.com>
Date: Fri, 01 Mar 2013 10:40:43 +0800
From: Ric Mason <ric.masonn@gmail.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v2 1/2] mm: tuning hardcoded reserved memory
References: <20130227205629.GA8429@localhost.localdomain> <20130228141200.3fe7f459.akpm@linux-foundation.org> <20130228034803.GB3829@localhost.localdomain>
In-Reply-To: <20130228034803.GB3829@localhost.localdomain>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Shewmaker <agshew@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>

On 02/28/2013 11:48 AM, Andrew Shewmaker wrote:
> On Thu, Feb 28, 2013 at 02:12:00PM -0800, Andrew Morton wrote:
>> On Wed, 27 Feb 2013 15:56:30 -0500
>> Andrew Shewmaker <agshew@gmail.com> wrote:
>>
>>> The following patches are against the mmtom git tree as of February 27th.
>>>
>>> The first patch only affects OVERCOMMIT_NEVER mode, entirely removing
>>> the 3% reserve for other user processes.
>>>
>>> The second patch affects both OVERCOMMIT_GUESS and OVERCOMMIT_NEVER
>>> modes, replacing the hardcoded 3% reserve for the root user with a
>>> tunable knob.
>>>
>> Gee, it's been years since anyone thought about the overcommit code.
>>
>> Documentation/vm/overcommit-accounting says that OVERCOMMIT_ALWAYS is
>> "Appropriate for some scientific applications", but doesn't say why.
>> You're running a scientific cluster but you're using OVERCOMMIT_NEVER,
>> I think?  Is the documentation wrong?
> None of my scientists appeared to use sparse arrays as Alan described.
> My users would run jobs that appeared to initialize correctly. However,
> they wouldn't write to every page they malloced (and they wouldn't use
> calloc), so I saw jobs failing well into a computation once the
> simulation tried to access a page and the kernel couldn't give it to them.
>
> I think Roadrunner (http://en.wikipedia.org/wiki/IBM_Roadrunner) was
> the first cluster I put into OVERCOMMIT_NEVER mode. Jobs with
> infeasible memory requirements fail early and the OOM killer
> gets triggered much less often than in guess mode. More often than not
> the OOM killer seemed to kill the wrong thing causing a subtle brokenness.
> Disabling overcommit worked so well during the stabilization and
> early user phases that we did the same with other clusters.

Do you mean OVERCOMMIT_NEVER is more suitable for scientific application 
than OVERCOMMIT_GUESS and OVERCOMMIT_ALWAYS? Or should depend on 
workload? Since your users would run jobs that wouldn't write to every 
page they malloced, so why OVERCOMMIT_GUESS is not more suitable for you?

>
>>> __vm_enough_memory reserves 3% of free pages with the default
>>> overcommit mode and 6% when overcommit is disabled. These hardcoded
>>> values have become less reasonable as memory sizes have grown.
>>>
>>> On scientific clusters, systems are generally dedicated to one user.
>>> Also, overcommit is sometimes disabled in order to prevent a long
>>> running job from suddenly failing days or weeks into a calculation.
>>> In this case, a user wishing to allocate as much memory as possible
>>> to one process may be prevented from using, for example, around 7GB
>>> out of 128GB.
>>>
>>> The effect is less, but still significant when a user starts a job
>>> with one process per core. I have repeatedly seen a set of processes
>>> requesting the same amount of memory fail because one of them could
>>> not allocate the amount of memory a user would expect to be able to
>>> allocate.
>>>
>>> ...
>>>
>>> --- a/mm/mmap.c
>>> +++ b/mm/mmap.c
>>> @@ -182,11 +182,6 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
>>>   		allowed -= allowed / 32;
>>>   	allowed += total_swap_pages;
>>>   
>>> -	/* Don't let a single process grow too big:
>>> -	   leave 3% of the size of this process for other processes */
>>> -	if (mm)
>>> -		allowed -= mm->total_vm / 32;
>>> -
>>>   	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
>>>   		return 0;
>> So what might be the downside for this change?  root can't log in, I
>> assume.  Have you actually tested for this scenario and observed the
>> effects?
>>
>> If there *are* observable risks and/or to preserve back-compatibility,
>> I guess we could create a fourth overcommit mode which provides the
>> headroom which you desire.
>>
>> Also, should we be looking at removing root's 3% from OVERCOMMIT_GUESS
>> as well?
> The downside of the first patch, which removes the "other" reserve
> (sorry about the confusing duplicated subject line), is that a user
> may not be able to kill their process, even if they have a shell prompt.
> When testing, I did sometimes get into spot where I attempted to execute
> kill, but got: "bash: fork: Cannot allocate memory". Of course, a
> user can get in the same predicament with the current 3% reserve--they
> just have to start processes until 3% becomes negligible.
>
> With just the first patch, root still has a 3% reserve, so they can
> still log in.
>
> When I resubmit the second patch, adding a tunable rootuser_reserve_pages
> variable, I'll test both guess and never overcommit modes to see what
> minimum initial values allow root to login and kill a user's memory
> hogging process. This will be safer than the current behavior since
> root's reserve will never shrink to something useless in the case where
> a user has grabbed all available memory with many processes.

The idea of two patches looks reasonable to me.

>
> As an estimate of a useful rootuser_reserve_pages, the rss+share size of

Sorry for my silly, why you mean share size is not consist in rss size?

> sshd, bash, and top is about 16MB. Overcommit disabled mode would need
> closer to 360MB for the same processes. On a 128GB box 3% is 3.8GB, so
> the new tunable would still be a win.
>
> I think the tunable would benefit everyone over the current behavior,
> but would you prefer it if I only made it tunable in a fourth overcommit
> mode in order to preserve back-compatibility?
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
