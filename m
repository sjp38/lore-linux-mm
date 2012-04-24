Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id B08EE6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 04:05:15 -0400 (EDT)
Received: by obbeh20 with SMTP id eh20so807196obb.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 01:05:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4F965DCC.2000501@kernel.org>
References: <1335171318-4838-1-git-send-email-minchan@kernel.org>
	<4F963742.2030607@jp.fujitsu.com>
	<4F963B8E.9030105@kernel.org>
	<CAPa8GCA8q=S9sYx-0rDmecPxYkFs=gATGL-Dz0OYXDkwEECJkg@mail.gmail.com>
	<4F965413.9010305@kernel.org>
	<CAPa8GCCwfCFO6yxwUP5Qp9O1HGUqEU2BZrrf50w8TL9FH9vbrA@mail.gmail.com>
	<4F965DCC.2000501@kernel.org>
Date: Tue, 24 Apr 2012 18:05:14 +1000
Message-ID: <CAPa8GCC+BOLdMFzoYAVBUBxXm0yKgr4D1A81XBRk08y7DGWTsA@mail.gmail.com>
Subject: Re: [RFC] propagate gfp_t to page table alloc functions
From: Nick Piggin <npiggin@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 24 April 2012 18:01, Minchan Kim <minchan@kernel.org> wrote:
> On 04/24/2012 04:48 PM, Nick Piggin wrote:
>
>> On 24 April 2012 17:19, Minchan Kim <minchan@kernel.org> wrote:
>>> On 04/24/2012 03:13 PM, Nick Piggin wrote:
>>>
>>>> 2012/4/24 Minchan Kim <minchan@kernel.org>:
>>>>> On 04/24/2012 02:16 PM, KAMEZAWA Hiroyuki wrote:
>>>>>
>>>>>> (2012/04/23 17:55), Minchan Kim wrote:
>>>>>>
>>>>>>> As I test some code, I found a problem about deadlock by lockdep.
>>>>>>> The reason I saw the message is __vmalloc calls map_vm_area which calls
>>>>>>> pud/pmd_alloc without gfp_t. so although we call __vmalloc with
>>>>>>> GFP_ATOMIC or GFP_NOIO, it ends up allocating pages with GFP_KERNEL.
>>>>>>> The should be a BUG. This patch fixes it by passing gfp_to to low page
>>>>>>> table allocate functions.
>>>>>>>
>>>>>>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>>>>>>
>>>>>>
>>>>>> Hmm ? vmalloc should support GFP_ATOMIC ?
>>>>>
>>>>>
>>>>> I'm not sure but alloc_large_system_hash already has used.
>>>>> And it's not specific on GFP_ATOMIC.
>>>>> We have to care of GFP_NOFS and GFP_NOIO to prevent deadlock on reclaim
>>>>> context.
>>>>> There are some places to use GFP_NOFS and we don't emit any warning
>>>>> message in case of that.
>>>>
>>>> What's the lockdep warning?
>>>
>>>
>>> It's just some private-test code, not-mainlined and lockdep warning is like this.
>>>
>>> [ INFO: inconsistent lock state ]
>>> 3.4.0-rc3-next-20120417+ #80 Not tainted
>>> ---------------------------------
>>> inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-R} usage.
>>>
>>> It seems test code calls vmalloc inside reclaim context so that it enters
>>> reclaim context, again by map_vm_area which allocates pages with GFP_KERNEL.
>>>
>>> Of course, I can avoid this problem by fixing the caller but during I look into
>>> this problem, found other places to use gfp_t with "context restriction".
>>>
>>>
>>>>
>>>
>>>> vmalloc was never supposed to use gfp flags for allocation "context"
>>>> restriction. I.e., it
>>>> was always supposed to have blocking, fs, and io capable allocation
>>>> context. The flags
>>>> were supposed to be a memory type modifier.
>>>
>>>
>>> You mean "zone modifiers"?
>>
>> Yeah, things like that.
>>
>>>> These different classes of flags is a bit of a problem and source of
>>>> confusion we have.
>>>> We should be doing more checks for them, of course.
>>>
>>>
>>> It might need some warning in __vmalloc and family which use gfp_t
>>> if the caller use context flags.
>>
>> I think that would be a good idea.
>>
>>
>>>> I suspect you need to fix the caller?
>>>
>>>
>>> Hmm, there are several places to use GFP_NOIO and GFP_NOFS even, GFP_ATOMIC.
>>> I believe it's not trivial now.
>>
>> They're all buggy then. Unfortunately not through any real fault of their own.
>
>
> That's why I send it with RFC before I have to make all architecture change.
> Nick, Thanks!
>
>>
>> I would say add a bit of warnings and documentation, and see what can be done
>> about callers.
>
>>
>
>> We should not take lightly the decision to make the API more permissive, because
>> as you can see it's more work for implementation. Making it ATOMIC safe is even
>
>
> Agree. Will add waring and Cced all maintainers.

Thanks very much!

>
>> harder, requiring irqsafe locks and such, and it might be tricky for some
>
>
> irqsafe? Why should we consider it?
> Just out of curiosity.

I don't think we should just yet. It is an example of something that callers
have wanted in the past, but have solved in other ways when we have
objected.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
