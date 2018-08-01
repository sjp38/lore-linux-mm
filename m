Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 45B8E6B000D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 11:37:20 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id k9-v6so13955097iob.16
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 08:37:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o55-v6sor7118987jal.149.2018.08.01.08.37.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 08:37:19 -0700 (PDT)
MIME-Version: 1.0
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <30ee6c72-dc90-275a-8e23-54221f393cb0@virtuozzo.com> <c03fd1ca-0169-4492-7d6f-2df7a91bff5e@gmail.com>
 <CACT4Y+bLbDunoz+0qB=atbQXJ9Gu3N6+UXPwNnqMbq5RyZu1mQ@mail.gmail.com>
 <cf751136-c459-853a-0210-abf16f54ad17@gmail.com> <CACT4Y+b6aCHMTQD21fSf2AMZoH5g8p-FuCVHviMLF00uFV+zGg@mail.gmail.com>
 <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
In-Reply-To: <01000164f60f3f12-b1253c6e-ee57-49fc-aed8-0944ab4fd7a2-000000@email.amazonses.com>
From: Eric Dumazet <edumazet@google.com>
Date: Wed, 1 Aug 2018 08:37:07 -0700
Message-ID: <CANn89i+KtwtLvSw1c=Ux8okKP+XyMxzYbuKhYb2qhYeMw=NTzg@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Eric Dumazet <eric.dumazet@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, jack@suse.com, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, netdev <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, jani.nikula@linux.intel.com, joonas.lahtinen@linux.intel.com, rodrigo.vivi@intel.com, airlied@linux.ie, intel-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Wed, Aug 1, 2018 at 8:15 AM Christopher Lameter <cl@linux.com> wrote:
>
> On Wed, 1 Aug 2018, Dmitry Vyukov wrote:
>
> > But we are trading 1 indirect call for comparable overhead removed
> > from much more common path. The path that does ctors is also calling
> > into page alloc, which is much more expensive.
> > So ctor should be a net win on performance front, no?
>
> ctor would make it esier to review the flow and guarantee that the object
> always has certain fields set as required before any use by the subsystem.
>
> ctors are run once on allocation of the slab page for all objects in it.
>
> ctors are not called duiring allocation and freeing of objects from the
> slab page. So we could avoid the intialization of the spinlock on each
> object allocation which actually should be faster.


This strategy might have been a win 30 years ago when cpu had no
caches (or too small anyway)

What probability is that the 60 bytes around the spinlock are not
touched after the object is freshly allocated ?

-> None

Writing 60 bytes  in one cache line instead of 64 has really the same
cost. The cache line miss is the real killer.

Feel free to write the patches, test them,  but I doubt you will have any gain.

Remember btw that TCP sockets can be either completely fresh
(socket() call, using memset() to clear the whole object),
or clones (accept() thus copying the parent socket)

The idea of having a ctor() would only be a win if all the fields that
can be initialized in the ctor are contiguous and fill an integral
number of cache lines.
