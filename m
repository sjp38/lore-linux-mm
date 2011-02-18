Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 006EC8D0039
	for <linux-mm@kvack.org>; Thu, 17 Feb 2011 21:46:34 -0500 (EST)
Message-ID: <4D5DDDD7.509@cn.fujitsu.com>
Date: Fri, 18 Feb 2011 10:47:51 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] cpuset: Fix unchecked calls to NODEMASK_ALLOC()
References: <4D5C7EA7.1030409@cn.fujitsu.com> <4D5C7ED1.2070601@cn.fujitsu.com> <20110217144643.0d60bef4.akpm@linux-foundation.org> <AANLkTin6TqQMHSpQjNXNrgGAHG8DL6CvzhTm3KHoxv0y@mail.gmail.com>
In-Reply-To: <AANLkTin6TqQMHSpQjNXNrgGAHG8DL6CvzhTm3KHoxv0y@mail.gmail.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

Paul Menage wrote:
> On Thu, Feb 17, 2011 at 2:46 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
>> On Thu, 17 Feb 2011 09:50:09 +0800
>> Li Zefan <lizf@cn.fujitsu.com> wrote:
>>
>>> +/*
>>> + * In functions that can't propogate errno to users, to avoid declaring a
>>> + * nodemask_t variable, and avoid using NODEMASK_ALLOC that can return
>>> + * -ENOMEM, we use this global cpuset_mems.
>>> + *
>>> + * It should be used with cgroup_lock held.
>>
>> I'll do s/should/must/ - that would be a nasty bug.
>>
>> I'd be more comfortable about the maintainability of this optimisation
>> if we had
>>
>>        WARN_ON(!cgroup_is_locked());
>>
>> at each site.
>>
> 
> Agreed - that was my first thought on reading the patch. How about:
> 
> static nodemask_t *cpuset_static_nodemask() {

Then this should be 'noinline', otherwise we'll have one copy for each
function that calls it.

>   static nodemask_t nodemask;
>   WARN_ON(!cgroup_is_locked());
>   return &nodemask;
> }
> 
> and then just call cpuset_static_nodemask() in the various locations
> being patched?
> 

I think a defect of this is people might call it twice in one function
but don't know it returns the same variable?

For example in cpuset_attach():

void cpuset_attach(...)
{
	nodemask_t *from = cpuset_static_nodemask();
	nodemask_t *to = cpuset_static_nodemask();
	...
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
