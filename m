Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 902386B026D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:53:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id t4-v6so13884577plo.0
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:53:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q4-v6sor4658921pgp.111.2018.08.01.08.53.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 08:53:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com> <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
 <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
 <cf751136-c459-853a-0210-abf16f54ad17@gmail.com> <CACT4Y+b6aCHMTQD21fSf2AMZoH5g8p-FuCVHviMLF00uFV+zGg@mail.gmail.com>
 <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
 <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 1 Aug 2018 17:53:00 +0200
Message-ID: <CACT4Y+axXa3HXG7ZoJSmP-g2QqtnvQ77oUZuioX-V9Ydi-56Dw@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <edumazet@google.com>
Cc: Christoph Lameter <cl@linux.com>, Eric Dumazet <eric.dumazet@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, David Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed, Aug 1, 2018 at 5:37 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Aug 1, 2018 at 8:15 AM Christopher Lameter <cl@linux.com> wrote:
>>
>> On Wed, 1 Aug 2018, Dmitry Vyukov wrote:
>>
>> > But we are trading 1 indirect call for comparable overhead removed
>> > from much more common path. The path that does ctors is also calling
>> > into page alloc, which is much more expensive.
>> > So ctor should be a net win on performance front, no?
>>
>> ctor would make it esier to review the flow and guarantee that the object
>> always has certain fields set as required before any use by the subsystem.
>>
>> ctors are run once on allocation of the slab page for all objects in it.
>>
>> ctors are not called duiring allocation and freeing of objects from the
>> slab page. So we could avoid the intialization of the spinlock on each
>> object allocation which actually should be faster.
>
>
> This strategy might have been a win 30 years ago when cpu had no
> caches (or too small anyway)
>
> What probability is that the 60 bytes around the spinlock are not
> touched after the object is freshly allocated ?
>
> -> None
>
> Writing 60 bytes  in one cache line instead of 64 has really the same
> cost. The cache line miss is the real killer.
>
> Feel free to write the patches, test them,  but I doubt you will have any gain.
>
> Remember btw that TCP sockets can be either completely fresh
> (socket() call, using memset() to clear the whole object),
> or clones (accept() thus copying the parent socket)
>
> The idea of having a ctor() would only be a win if all the fields that
> can be initialized in the ctor are contiguous and fill an integral
> number of cache lines.

Code size can have some visible performance impact too.

But either way, what you say only means that ctors are not necessary
significantly faster. But your original point was that they are
slower.
If they are not slower, then what Andrey said seems to make sense:
some gain on code comprehension front re type-stability invariant +
some gain on performance front (even if not too big) and no downsides.
