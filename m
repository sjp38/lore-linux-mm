Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 0867C6B0032
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 05:34:21 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so12815419wib.1
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 02:34:20 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga2si6110399wjb.135.2015.06.12.02.34.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Jun 2015 02:34:19 -0700 (PDT)
Message-ID: <557AA799.8000306@suse.cz>
Date: Fri, 12 Jun 2015 11:34:17 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>	<CAATkVEwBd=UXhaonUwW0OHh4Jo-6DMqvwhMqeZ-z9OHdZopbEw@mail.gmail.com> <CAATkVEwg-0=nBrcb2N_ZtEJdCwJbzbSyMK-3SpBj_BgfjKucHg@mail.gmail.com>
In-Reply-To: <CAATkVEwg-0=nBrcb2N_ZtEJdCwJbzbSyMK-3SpBj_BgfjKucHg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Debabrata Banerjee <dbavatar@gmail.com>, Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shaohua Li <shli@fb.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Banerjee, Debabrata" <dbanerje@akamai.com>, Joshua Hunt <johunt@akamai.com>

On 06/11/2015 11:28 PM, Debabrata Banerjee wrote:
> Resend in plaintext, thanks gmail:
>
> It's somewhat an intractable problem to know if compaction will succeed
> without trying it,

There are heuristics, but those cannot be perfect by definition. I think 
the worse problem here is the extra latency, even if it does succeed, 
though.

> and you can certainly end up in a state where memory is
> heavily fragmented, even with compaction running. You can't compact kernel
> pages for example, so you can end up in a state where compaction does
> nothing through no fault of it's own.

Correct.

> In this case you waste time in compaction routines, then end up reclaiming
> precious page cache pages or swapping out for whatever it is your machine
> was doing trying to do to satisfy these order-3 allocations, after which all
> those pages need to be restored from disk almost immediately. This is not a
> happy server.

That sounds like an overloaded server to me.

> Any mm fix may be years away.

Well, what kind of "fix"? There's no way to always avoid fragmentation 
without some kind of an oracle that will tell you which unmovable 
allocations (e.g. kernel pages) to put side by side because they will be 
freed at the same time.

> The only simple solution I can
> think of is specifically caching these allocations, in any other case under
> memory pressure they will be split by other smaller allocations.

In this case the allocations have simple fallback to order-0, so caching 
them would make sense only if someone shows that the benefits of having 
order-3 instead of order-0 them are worth it.

> We've been forcing these allocations to order-0 internally until we can
> think of something else.

I think the proposed patch is better than forcing everything to order-0. 
It makes the attempt to allocate order-3 cheap.

The VM should generally serve you better if it's told your requirements. 
Communicating that the order-3 allocation is just an opportunistic 
attempt with simple fallback is the right way.

> -Deb
>
>
>> On Thu, Jun 11, 2015 at 4:48 PM, Eric Dumazet <eric.dumazet@gmail.com>
>> wrote:
>>>
>>> On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:
>>>> We saw excessive memory compaction triggered by skb_page_frag_refill.
>>>> This causes performance issues. Commit 5640f7685831e0 introduces the
>>>> order-3 allocation to improve performance. But memory compaction has
>>>> high overhead. The benefit of order-3 allocation can't compensate the
>>>> overhead of memory compaction.
>>>>
>>>> This patch makes the order-3 page allocation atomic. If there is no
>>>> memory pressure and memory isn't fragmented, the alloction will still
>>>> success, so we don't sacrifice the order-3 benefit here. If the atomic
>>>> allocation fails, compaction will not be triggered and we will fallback
>>>> to order-0 immediately.
>>>>
>>>> The mellanox driver does similar thing, if this is accepted, we must fix
>>>> the driver too.
>>>>
>>>> Cc: Eric Dumazet <edumazet@google.com>
>>>> Signed-off-by: Shaohua Li <shli@fb.com>
>>>> ---
>>>>   net/core/sock.c | 2 +-
>>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/core/sock.c b/net/core/sock.c
>>>> index 292f422..e9855a4 100644
>>>> --- a/net/core/sock.c
>>>> +++ b/net/core/sock.c
>>>> @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct
>>>> page_frag *pfrag, gfp_t gfp)
>>>>
>>>>        pfrag->offset = 0;
>>>>        if (SKB_FRAG_PAGE_ORDER) {
>>>> -             pfrag->page = alloc_pages(gfp | __GFP_COMP |
>>>> +             pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP
>>>> |
>>>>                                          __GFP_NOWARN | __GFP_NORETRY,
>>>>                                          SKB_FRAG_PAGE_ORDER);
>>>>                if (likely(pfrag->page)) {
>>>
>>> This is not a specific networking issue, but mm one.
>>>
>>> You really need to start a discussion with mm experts.
>>>
>>> Your changelog does not exactly explains what _is_ the problem.
>>>
>>> If the problem lies in mm layer, it might be time to fix it, instead of
>>> work around the bug by never triggering it from this particular point,
>>> which is a safe point where a process is willing to wait a bit.
>>>
>>> Memory compaction is either working as intending, or not.
>>>
>>> If we enabled it but never run it because it hurts, what is the point
>>> enabling it ?
>>>
>>>
>>>
>>> --
>>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>>> the body to majordomo@kvack.org.  For more info on Linux MM,
>>> see: http://www.linux-mm.org/ .
>>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>>
>>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
