Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABC86B0038
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 17:28:07 -0400 (EDT)
Received: by wiwd19 with SMTP id d19so1169729wiw.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:28:07 -0700 (PDT)
Received: from mail-wi0-x22c.google.com (mail-wi0-x22c.google.com. [2a00:1450:400c:c05::22c])
        by mx.google.com with ESMTPS id y11si4076892wiv.114.2015.06.11.14.28.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 14:28:06 -0700 (PDT)
Received: by wibut5 with SMTP id ut5so1139553wib.1
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 14:28:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAATkVEwBd=UXhaonUwW0OHh4Jo-6DMqvwhMqeZ-z9OHdZopbEw@mail.gmail.com>
References: <71a20cf185c485fa23d9347bd846a6f4e9753405.1434053941.git.shli@fb.com>
	<1434055687.27504.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAATkVEwBd=UXhaonUwW0OHh4Jo-6DMqvwhMqeZ-z9OHdZopbEw@mail.gmail.com>
Date: Thu, 11 Jun 2015 17:28:05 -0400
Message-ID: <CAATkVEwg-0=nBrcb2N_ZtEJdCwJbzbSyMK-3SpBj_BgfjKucHg@mail.gmail.com>
Subject: Re: [RFC] net: use atomic allocation for order-3 page allocation
From: Debabrata Banerjee <dbavatar@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shaohua Li <shli@fb.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, "davem@davemloft.net" <davem@davemloft.net>, Kernel-team@fb.com, Eric Dumazet <edumazet@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, "Banerjee, Debabrata" <dbanerje@akamai.com>, Joshua Hunt <johunt@akamai.com>

Resend in plaintext, thanks gmail:

It's somewhat an intractable problem to know if compaction will succeed
without trying it, and you can certainly end up in a state where memory is
heavily fragmented, even with compaction running. You can't compact kernel
pages for example, so you can end up in a state where compaction does
nothing through no fault of it's own.

In this case you waste time in compaction routines, then end up reclaiming
precious page cache pages or swapping out for whatever it is your machine
was doing trying to do to satisfy these order-3 allocations, after which all
those pages need to be restored from disk almost immediately. This is not a
happy server. Any mm fix may be years away. The only simple solution I can
think of is specifically caching these allocations, in any other case under
memory pressure they will be split by other smaller allocations.

We've been forcing these allocations to order-0 internally until we can
think of something else.

-Deb


> On Thu, Jun 11, 2015 at 4:48 PM, Eric Dumazet <eric.dumazet@gmail.com>
> wrote:
>>
>> On Thu, 2015-06-11 at 13:24 -0700, Shaohua Li wrote:
>> > We saw excessive memory compaction triggered by skb_page_frag_refill.
>> > This causes performance issues. Commit 5640f7685831e0 introduces the
>> > order-3 allocation to improve performance. But memory compaction has
>> > high overhead. The benefit of order-3 allocation can't compensate the
>> > overhead of memory compaction.
>> >
>> > This patch makes the order-3 page allocation atomic. If there is no
>> > memory pressure and memory isn't fragmented, the alloction will still
>> > success, so we don't sacrifice the order-3 benefit here. If the atomic
>> > allocation fails, compaction will not be triggered and we will fallback
>> > to order-0 immediately.
>> >
>> > The mellanox driver does similar thing, if this is accepted, we must fix
>> > the driver too.
>> >
>> > Cc: Eric Dumazet <edumazet@google.com>
>> > Signed-off-by: Shaohua Li <shli@fb.com>
>> > ---
>> >  net/core/sock.c | 2 +-
>> >  1 file changed, 1 insertion(+), 1 deletion(-)
>> >
>> > diff --git a/net/core/sock.c b/net/core/sock.c
>> > index 292f422..e9855a4 100644
>> > --- a/net/core/sock.c
>> > +++ b/net/core/sock.c
>> > @@ -1883,7 +1883,7 @@ bool skb_page_frag_refill(unsigned int sz, struct
>> > page_frag *pfrag, gfp_t gfp)
>> >
>> >       pfrag->offset = 0;
>> >       if (SKB_FRAG_PAGE_ORDER) {
>> > -             pfrag->page = alloc_pages(gfp | __GFP_COMP |
>> > +             pfrag->page = alloc_pages((gfp & ~__GFP_WAIT) | __GFP_COMP
>> > |
>> >                                         __GFP_NOWARN | __GFP_NORETRY,
>> >                                         SKB_FRAG_PAGE_ORDER);
>> >               if (likely(pfrag->page)) {
>>
>> This is not a specific networking issue, but mm one.
>>
>> You really need to start a discussion with mm experts.
>>
>> Your changelog does not exactly explains what _is_ the problem.
>>
>> If the problem lies in mm layer, it might be time to fix it, instead of
>> work around the bug by never triggering it from this particular point,
>> which is a safe point where a process is willing to wait a bit.
>>
>> Memory compaction is either working as intending, or not.
>>
>> If we enabled it but never run it because it hurts, what is the point
>> enabling it ?
>>
>>
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
