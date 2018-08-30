Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4D59D6B538A
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 17:51:22 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z44-v6so10532811qtg.5
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:51:22 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j8-v6si7166503qkm.293.2018.08.30.14.51.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 14:51:21 -0700 (PDT)
Subject: Re: [PATCH 2/2] fs/dcache: Make negative dentries easier to be
 reclaimed
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-3-git-send-email-longman@redhat.com>
 <20180829010228.GE1572@dastard>
 <6e2999b3-e93f-2138-6ceb-4f24712f419f@redhat.com>
 <20180830011245.GC5631@dastard>
From: Waiman Long <longman@redhat.com>
Message-ID: <187ee69a-451d-adaa-0714-2acbefc46d2f@redhat.com>
Date: Thu, 30 Aug 2018 17:51:19 -0400
MIME-Version: 1.0
In-Reply-To: <20180830011245.GC5631@dastard>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On 08/29/2018 09:12 PM, Dave Chinner wrote:
> On Wed, Aug 29, 2018 at 03:34:05PM -0400, Waiman Long wrote:
>> On 08/28/2018 09:02 PM, Dave Chinner wrote:
>>> On Tue, Aug 28, 2018 at 01:19:40PM -0400, Waiman Long wrote:
>>> And then there's shrinker behaviour. What happens if the shrinker
>>> isolate callback returns LRU_ROTATE on a negative dentry? It gets
>>> moved to the most recent end of the list, so it won't have an
>>> attempt to reclaim it again until it's tried to reclaim all the real
>>> dentries. IOWs, it goes back to behaving like LRUs are supposed to
>>> behaving.
>>>
>>> IOWs, reclaim behaviour of negative dentries will be
>>> highly unpredictable, it will not easily retain a working set, nor
>>> will the working set it does retain be predictable or easy to eject
>>> from memory when the workload changes.
>>>
>>> Is this the behavour what we want for negative dentries?
>> I am aware that the behavior is not strictly LRU for negative dentries.
>> This is a compromise for using one LRU list for 2 different classes of
>> dentries.
> Thus demonstrating just enough knowledge to be dangerous.
>
> We already 3 different classes of dentries on the LRU list:
>
> 	- in use dentries (because we use lazy removal to avoid
> 	  lru list lock contention on cache hit lookups)
> 	- unused, referenced dentries
> 	- unused, unreferenced dentries.
>
> Each of these classes of dentries are treated differently by the
> shrinker, but the key point is that they are all aged the same way
> and so there's consistent maintenance of the working set under
> memory pressure. Putting negative dentries at the head of the list
> doesn't create a new "class" of object on the LRU, it just changes
> the ordering of the lru list. This will cause unpredictable
> behaviour because objects haven't had a chance to age gracefully
> before they are reclaimed.
>
> FYI, the inode cache has the same list_lru setup, object types and
> shrinker algorithm as the dentry cache, so this isn't a one-off.
> Indeed, the XFS buffer cache has a multi-reference heirarchy of 13
> different types of {unused, referenced} buffers in it's list_lru to
> implement a quasi aging-NFU reclaim algorithm in it's shrinker.
>
> i.e. the list_lru infrastructure has never provided or enforced a
> pure LRU algorithm. It is common infrastructure intended to provide
> a scalable, flexible and memcg-aware FIFO-like object tracking
> system that interates tightly with memory reclaim to allow
> subsystems to implement cache reclaim algorithms that are optimal
> for that subsystem.
>
> IOWs, the list_lru doesn't define the reclaim algorithm the
> subsystem uses and there's no reason why we can't extend the
> infrastructure to support more complex algorithms without impacting
> existing subsystem reclaim algorithms at all. Only the subsystems
> that use the new infrastructure and algorithms would need careful
> examination.  Of course, the overall system cache balancing
> behaviour under different and changing workloads would still need to
> be verified, but you have to do that for any cache reclaim algorithm
> change that is made....
>
>> The basic idea is that negative dentries that are used only
>> once will go first irrespective of their age.
> Using MRU for negative dentries, as I've previously explained, is a
> flawed concept. It might be expedient to solve your specific
> problem, but it's not a solution to the general problem of negative
> dentry management.
>
>>> Perhaps a second internal LRU list in the list_lru for "immediate
>>> reclaim" objects would be a better solution. i.e. similar to the
>>> active/inactive lists used for prioritising the working set iover
>>> single use pages in page reclaim. negative dentries go onto the
>>> immediate list, real dentries go on the existing list. Both are LRU,
>>> and the shrinker operates on the immediate list first. When we
>>> rotate referenced negative dentries on the immediate list, promote
>>> them to the active list with all the real dentries so they age out
>>> with the rest of the working set. That way single use negative
>>> dentries get removed in LRU order in preference to the working set
>>> of real dentries.
>>>
>>> Being able to make changes to the list implementation easily was one
>>> of the reasons I hid the implementation of the list_lru from the
>>> interface callers use....
>>>
>>> [...]
>> I have thought about using 2 lists for dentries. That will require much
>> more extensive changes to the code and hence much more testing will be
>> needed to verify their correctness.  That is the main reason why I try to
>> avoid doing that.
> i.e. expediency.
>
> However, you're changing the behaviour of core caching and memory
> reclaim algorithms. The amount and level of testing and verification
> you need to do is the same regardless of whether it's a small change
> or a large change.  Sure, you've shown that *one* artificial
> micro-benchmark improves, but what about everything else?
>
>> As you have suggested, we could implement this 2-level LRU list in the
>> list_lru API. But it is used by other subsystems as well. Extensive
>> change like that will have similar issue in term of testing and
>> verification effort.
> I know what changing reclaim algorithm involves, how difficult
> it is to balance the competing caches quickly and to the desired
> ratios for acceptable performance, how difficult it is to measure
> and control the system reacts to transient and impulse memory
> pressure events, etc.
>
> I also know that "simple" and/or "obviously correct" subsystem
> changes can cause very unexepected system level effects, and that
> it's almost never what you think it is that caused the unexpected
> behaviour.  IOWs, getting anything even slightly wrong in these
> algorithms will adversely affect system performance and balance
> significantly.  Hence the bar is /always/ set high for core caching
> algorithm changes like this.
>
> Cheers,
>
> Dave.

Thanks for the comments. I will need more time to think about it.

Cheers,
Longman
