Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BF2C88D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 21:36:25 -0500 (EST)
Message-ID: <4D5DDB77.8090807@cn.fujitsu.com>
Date: Fri, 18 Feb 2011 10:37:43 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] cpuset: Remove unneeded NODEMASK_ALLOC() in cpuset_attch()
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7EBF.2070603@cn.fujitsu.com> <AANLkTimRH=LVRLnajbtL3a8FwKkbEfLspAHXXeQLUY8=@mail.gmail.com>
In-Reply-To: <AANLkTimRH=LVRLnajbtL3a8FwKkbEfLspAHXXeQLUY8=@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

Paul Menage wrote:
> On Wed, Feb 16, 2011 at 5:49 PM, Li Zefan <lizf@cn.fujitsu.com> wrote:
>> oldcs->mems_allowed is not modified during cpuset_attch(), so
>> we don't have to copy it to a buffer allocated by NODEMASK_ALLOC().
>> Just pass it to cpuset_migrate_mm().
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> I'd be inclined to skip this one - we're already allocating one
> nodemask, so one more isn't really any extra complexity, and we're
> doing horrendously complicated stuff in cpuset_migrate_mm() that's
> much more likely to fail in low-memory situations.

That's true, but it's not a reason to add more cases that can fail.

> 
> It's true that mems_allowed can't change during the call to

Sorry to lead you to mistake what I meant. I meant 'from' is not modified
after it's copied from oldcs->mems_allowed, so the two are exactly the
same and thus we only need one.

> cpuset_attach(), but that's due to the fact that both cgroup_attach()
> and the cpuset.mems write paths take cgroup_mutex. I might prefer to
> leave the allocated nodemask here and wrap callback_mutex around the
> places in cpuset_attach() where we're reading from a cpuset's
> mems_allowed - that would remove the implicit synchronization via
> cgroup_mutex and leave the code a little more understandable.

It's not an implicit synchronization, but instead the lock rule for
reading/writing a cpuset's mems/cpus is described in the comment.

> 
>> ---
>>  kernel/cpuset.c |    7 ++-----
>>  1 files changed, 2 insertions(+), 5 deletions(-)
>>
>> diff --git a/kernel/cpuset.c b/kernel/cpuset.c
>> index f13ff2e..70c9ca2 100644
>> --- a/kernel/cpuset.c
>> +++ b/kernel/cpuset.c
>> @@ -1438,10 +1438,9 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>>        struct mm_struct *mm;
>>        struct cpuset *cs = cgroup_cs(cont);
>>        struct cpuset *oldcs = cgroup_cs(oldcont);
>> -       NODEMASK_ALLOC(nodemask_t, from, GFP_KERNEL);
>>        NODEMASK_ALLOC(nodemask_t, to, GFP_KERNEL);
>>
>> -       if (from == NULL || to == NULL)
>> +       if (to == NULL)
>>                goto alloc_fail;
>>
>>        if (cs == &top_cpuset) {
>> @@ -1463,18 +1462,16 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>>        }
>>
>>        /* change mm; only needs to be done once even if threadgroup */
>> -       *from = oldcs->mems_allowed;
>>        *to = cs->mems_allowed;
>>        mm = get_task_mm(tsk);
>>        if (mm) {
>>                mpol_rebind_mm(mm, to);
>>                if (is_memory_migrate(cs))
>> -                       cpuset_migrate_mm(mm, from, to);
>> +                       cpuset_migrate_mm(mm, &oldcs->mems_allowed, to);
>>                mmput(mm);
>>        }
>>
>>  alloc_fail:
>> -       NODEMASK_FREE(from);
>>        NODEMASK_FREE(to);
>>  }
>>
>> --
>> 1.7.3.1
>>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
