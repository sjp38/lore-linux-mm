Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id B23F26B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 13:49:40 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id w196-v6so3454413itb.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 10:49:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189-v6sor1150500itd.16.2018.07.31.10.49.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 10:49:39 -0700 (PDT)
MIME-Version: 1.0
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com> <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
In-Reply-To: <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2018 10:49:28 -0700
Message-ID: <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Tue, Jul 31, 2018 at 10:36 AM Christopher Lameter <cl@linux.com> wrote:
>
> If there is refcounting going on then why use SLAB_TYPESAFE_BY_RCU?

.. because the object can be accessed (by RCU) after the refcount has
gone down to zero, and the thing has been released.

That's the whole and only point of SLAB_TYPESAFE_BY_RCU.

That flag basically says:

  "I may end up accessing this object *after* it has been free'd,
because there may be RCU lookups in flight"

This has nothing to do with constructors. It's ok if the object gets
reused as an object of the same type and does *not* get
re-initialized, because we're perfectly fine seeing old stale data.

What it guarantees is that the slab isn't shared with any other kind
of object, _and_ that the underlying pages are free'd after an RCU
quiescent period (so the pages aren't shared with another kind of
object either during an RCU walk).

And it doesn't necessarily have to have a constructor, because the
thing that a RCU walk will care about is

 (a) guaranteed to be an object that *has* been on some RCU list (so
it's not a "new" object)

 (b) the RCU walk needs to have logic to verify that it's still the
*same* object and hasn't been re-used as something else.

So the re-use might initialize the fields lazily, not necessarily using a ctor.

And the point of using SLAB_TYPESAFE_BY_RCU is that using the more
traditional RCU freeing - where you free each object one by one with
an RCU delay - can be prohibitively slow and have a huge memory
overhead (because of big chunks of memory that are queued for
freeing).

In contrast, a SLAB_TYPESAFE_BY_RCU memory gets free'd and re-used
immediately, but because it gets reused as the same kind of object,
the RCU walker can "know" what parts have meaning for re-use, in a way
it couidn't if the re-use was random.

That said, it *is* subtle, and people should be careful.

                 Linus
