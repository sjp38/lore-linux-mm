Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8498F6B0069
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 14:00:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u81so22261860wmu.3
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 11:00:15 -0700 (PDT)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id z14si7309991wjw.111.2016.08.19.11.00.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 11:00:14 -0700 (PDT)
Received: by mail-wm0-x235.google.com with SMTP id o80so52127324wme.1
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 11:00:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1471543363.2581.30.camel@redhat.com>
References: <20160817222921.GA25148@www.outflux.net> <1471530118.2581.13.camel@redhat.com>
 <CA+55aFxYHn+4jJP89Pv=mKSKeKR+zkuJbZc8TSj6kORDUD1Qqw@mail.gmail.com> <1471543363.2581.30.camel@redhat.com>
From: Kees Cook <keescook@chromium.org>
Date: Fri, 19 Aug 2016 11:00:12 -0700
Message-ID: <CAGXu5jLFbgEVhzpNNiSBAT-QoMYamx9o3dYqTJHhDihEtmuReA@mail.gmail.com>
Subject: Re: [PATCH] usercopy: Skip multi-page bounds checking on SLOB
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Laura Abbott <labbott@fedoraproject.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, kernel test robot <xiaolong.ye@intel.com>

On Thu, Aug 18, 2016 at 11:02 AM, Rik van Riel <riel@redhat.com> wrote:
> On Thu, 2016-08-18 at 10:42 -0700, Linus Torvalds wrote:
>> On Thu, Aug 18, 2016 at 7:21 AM, Rik van Riel <riel@redhat.com>
>> wrote:
>> >
>> > One big question I have for Linus is, do we want
>> > to allow code that does a higher order allocation,
>> > and then frees part of it in smaller orders, or
>> > individual pages, and keeps using the remainder?
>>
>> Yes. We've even had people do that, afaik. IOW, if you know you're
>> going to allocate 16 pages, you can try to do an order-4 allocation
>> and just use the 16 pages directly (but still as individual pages),
>> and avoid extra allocation costs (and to perhaps get better access
>> patterns if the allocation succeeds etc etc).
>>
>> That sounds odd, but it actually makes sense when you have the order-
>> 4
>> allocation as a optimistic path (and fall back to doing smaller
>> orders
>> when a big-order allocation fails). To make that *purely* just an
>> optimization, you need to let the user then treat that order-4
>> allocation as individual pages, and free them one by one etc.
>>
>> So I'm not sure anybody actually does that, but the buddy allocator
>> was partly designed for that case.
>
> That makes sense.  With that in mind,
> it would probably be better to just drop
> all of the multi-page bounds checking
> from the usercopy code, not conditionally
> on SLOB.
>
> Alternatively, we could turn the
> __GFP_COMP flag into its negative, and
> set it only on the code paths that do
> what Linus describes (if anyone does
> it).
>
> A WARN_ON_ONCE in the page freeing code
> could catch these cases, and point people
> at exactly what to do if they trigger the
> warning.
>
> I am unclear no how to exclude legitimate
> usercopies that are larger than PAGE_SIZE
> from triggering warnings/errors, if we
> cannot identify every buffer where larger
> copies are legitimately going.
>
> Having people rewrite their usercopy code
> into loops that automatically avoids
> triggering page crossing or >PAGE_SIZE
> checks would be counterproductive, since
> that might just opens up new attack surface.

Yeah, I agree: we want to have centralized bounds checking and if we
offload >PAGE_SIZE copies to the callers, we're asking for a world of
hurt.

One thing I'm expecting to add in the future is a const-sized
copy_*_user API. This will give us a way to make exceptions to
non-whitelisted slab entries, given that the bounds are const at
compile time. It would behave more like get/put_user in that regard,
but could still handle small exceptions to allocations that would have
been otherwise disallowed (in the forthcoming
HARDENED_USERCOPY_WHITELIST series).

If we encounter another case of a multi-page false positive, we can
just entirely drop that check. For now, let's keep this removed for
SLOB only, and move forward.

-Kees

-- 
Kees Cook
Nexus Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
