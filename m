Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id D689F6B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 17:02:49 -0500 (EST)
Message-ID: <50B5387C.1030005@redhat.com>
Date: Tue, 27 Nov 2012 17:02:36 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: kswapd craziness in 3.7
References: <1354049315-12874-1-git-send-email-hannes@cmpxchg.org> <CA+55aFywygqWUBNWtZYa+vk8G0cpURZbFdC7+tOzyWk6tLi=WA@mail.gmail.com> <50B52DC4.5000109@redhat.com> <20121127214928.GA20253@cmpxchg.org>
In-Reply-To: <20121127214928.GA20253@cmpxchg.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, George Spelvin <linux@horizon.com>, Johannes Hirte <johannes.hirte@fem.tu-ilmenau.de>, Tomas Racek <tracek@redhat.com>, Jan Kara <jack@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Josh Boyer <jwboyer@gmail.com>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jiri Slaby <jslaby@suse.cz>, Thorsten Leemhuis <fedora@leemhuis.info>, Zdenek Kabelac <zkabelac@redhat.com>, Bruno Wolff III <bruno@wolff.to>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On 11/27/2012 04:49 PM, Johannes Weiner wrote:
> On Tue, Nov 27, 2012 at 04:16:52PM -0500, Rik van Riel wrote:
>> On 11/27/2012 03:58 PM, Linus Torvalds wrote:
>>> Note that in the meantime, I've also applied (through Andrew) the
>>> patch that reverts commit c654345924f7 (see commit 82b212f40059
>>> 'Revert "mm: remove __GFP_NO_KSWAPD"').
>>>
>>> I wonder if that revert may be bogus, and a result of this same issue.
>>> Maybe that revert should be reverted, and replaced with your patch?
>>>
>>> Mel? Zdenek? What's the status here?
>>
>> Mel posted several patches to fix the kswapd issue.  This one is
>> slightly more risky than the outright revert, but probably preferred
>> from a performance point of view:
>>
>> https://lkml.org/lkml/2012/11/12/151
>>
>> It works by skipping the kswapd wakeup for THP allocations, only
>> if compaction is deferred or contended.
>
> Just to clarify, this would be a replacement strictly for the
> __GFP_NO_KSWAPD removal revert, to control how often kswapd is woken
> up for higher order allocations like THP.
>
> My patch is to fix how kswapd actually does higher order reclaim, and
> it is required either way.
>
> [ But isn't the _reason_ why the "wake up kswapd more carefully for
>    THP" patch was written kind of moot now since it was developed
>    against a crazy kswapd?  It would certainly need to be re-evaluated.
>    My (limited) testing didn't show any issues anymore with waking
>    kswapd unconditionally once it's fixed. ]

Kswapd going crazy is certainly a large part of the problem.

However, that leaves the issue of page_alloc.c waking up
kswapd when the system is not actually low on memory.

Instead, kswapd is woken up because memory compaction failed,
potentially even due to lock contention during compaction!

Ideally the allocation code would only wake up kswapd if
memory needs to be freed, or in order for kswapd to do
memory compaction (so the allocator does not have to).

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
