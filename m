Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 174286B0003
	for <linux-mm@kvack.org>; Thu, 12 Jul 2018 11:54:54 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id l23-v6so31775155qtp.1
        for <linux-mm@kvack.org>; Thu, 12 Jul 2018 08:54:54 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id q15-v6si7840122qke.4.2018.07.12.08.54.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Jul 2018 08:54:52 -0700 (PDT)
Subject: Re: [PATCH v6 0/7] fs/dcache: Track & limit # of negative dentries
References: <1530905572-817-1-git-send-email-longman@redhat.com>
 <20180709081920.GD22049@dhcp22.suse.cz>
 <62275711-e01d-7dbe-06f1-bf094b618195@redhat.com>
 <20180710142740.GQ14284@dhcp22.suse.cz>
 <a2794bcc-9193-cbca-3a54-47420a2ab52c@redhat.com>
 <20180711102139.GG20050@dhcp22.suse.cz>
 <9f24c043-1fca-ee86-d609-873a7a8f7a64@redhat.com>
 <1531330947.3260.13.camel@HansenPartnership.com>
 <18c5cbfe-403b-bb2b-1d11-19d324ec6234@redhat.com>
 <1531336913.3260.18.camel@HansenPartnership.com>
From: Waiman Long <longman@redhat.com>
Message-ID: <4d49a270-23c9-529f-f544-65508b6b53cc@redhat.com>
Date: Thu, 12 Jul 2018 11:54:51 -0400
MIME-Version: 1.0
In-Reply-To: <1531336913.3260.18.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>, Michal Hocko <mhocko@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>

On 07/11/2018 03:21 PM, James Bottomley wrote:
> On Wed, 2018-07-11 at 15:07 -0400, Waiman Long wrote:
>> On 07/11/2018 01:42 PM, James Bottomley wrote:
>>> On Wed, 2018-07-11 at 11:13 -0400, Waiman Long wrote:
>>>> On 07/11/2018 06:21 AM, Michal Hocko wrote:
>>>>> On Tue 10-07-18 12:09:17, Waiman Long wrote:
>>> [...]
>>>>>> I am going to reduce the granularity of each unit to 1/1000
>>>>>> of the total system memory so that for large system with TB
>>>>>> of memory, a smaller amount of memory can be specified.
>>>>> It is just a matter of time for this to be too coarse as well.
>>>> The goal is to not have too much memory being consumed by
>>>> negative
>>>> dentries and also the limit won't be reached by regular daily
>>>> activities. So a limit of 1/1000 of the total system memory will
>>>> be good enough on large memory system even if the absolute number
>>>> is really big.
>>> OK, I think the reason we're going round and round here without
>>> converging is that one of the goals of the mm subsystem is to
>>> manage all of our cached objects and to it the negative (and
>>> positive) dentries simply look like a clean cache of
>>> objects.  Right at the moment mm manages them in the same way it
>>> manages all the other caches, a lot of which suffer from the "you
>>> can cause lots of allocations to artificially grow them"
>>> problem.  So the main question is why doesn't the current mm
>>> control of the caches work well enough for dentries?=20
>>> What are the problems you're seeing that mm should be catching?  If
>>> you can answer this, then we could get on to whether a separate
>>> shrinker, cache separation or some fix in mm itself is the right
>>> answer.
>>>
>>> What you say above is based on a conclusion: limiting dentries
>>> improves the system performance.  What we're asking for is evidence
>>> for that conclusion so we can explore whether the same would go for
>>> any of our other system caches (so do we have a global cache
>>> management problem or is it only the dentry cache?)
>>>
>>> James
>>>
>> I am not saying that limiting dentries will improve performance. I am
>> just saying that unlimited growth in the number of negative dentries
>> will reduce the amount of memory available to other applications and
>> hence will have an impact on performance. Normally the amount of
>> memory consumed by dentries is a very small portion of the system
>> memory.
> OK, can we poke on only this point for a while?  Linux never really has=

> any "available memory": pretty much as soon as you boot up the system
> will consume all your free memory for some type of cache (usually the
> page cache which got filled during boot).  The expectation is that in a=

> steady, running, state the system is using almost all available memory
> for caching something ... if it's not negative dentries it will be
> something else.  The mm assumption is that clean cache is so cheap to
> recover that it's almost equivalent to free memory and your patch is
> saying this isn't so and we have a problem dumping the dentry cache.
>
> So, why can't we treat the dentry cache as equivalent to free memory?=20
> What in your tests is making it harder to recover the memory in the
> dentry cache?
>
> James

It is not that dentry cache is harder to get rid of than the other
memory. It is that the ability of generate unlimited number of negative
dentries that will displace other useful memory from the system. What
the patch is trying to do is to have a warning or notification system in
place to spot unusual activities in regard to the number of negative
dentries in the system. The system administrators can then decide on
what to do next.

For many user activities, there are ways to audit what the users are
doing and what resources they are consuming. I don't think that is the
case for negative dentries. The closest I can think of is the use of
memory controller to limit the amount of kernel memory use. This
patchset will provide more visibility about the memory consumption of
negative dentries for the system as a whole, though it won't go into the
per-user level. We just don't want a disproportionate amount of memory
to be used up by negative dentries.

Cheers,
Longman

Cheers,
Longman
