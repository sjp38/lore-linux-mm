Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 958116B0003
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 14:52:12 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id l8-v6so3482458ita.4
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 11:52:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o77-v6sor1224101itb.129.2018.07.31.11.52.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 11:52:10 -0700 (PDT)
MIME-Version: 1.0
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
In-Reply-To: <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2018 11:51:59 -0700
Message-ID: <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, gerrit@erg.abdn.ac.uk, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

On Tue, Jul 31, 2018 at 10:49 AM Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> So the re-use might initialize the fields lazily, not necessarily using a ctor.

In particular, the pattern that nf_conntrack uses looks like it is safe.

If you have a well-defined refcount, and use "atomic_inc_not_zero()"
to guard the speculative RCU access section, and use
"atomic_dec_and_test()" in the freeing section, then you should be
safe wrt new allocations.

If you have a completely new allocation that has "random stale
content", you know that it cannot be on the RCU list, so there is no
speculative access that can ever see that random content.

So the only case you need to worry about is a re-use allocation, and
you know that the refcount will start out as zero even if you don't
have a constructor.

So you can think of the refcount itself as always having a zero
constructor, *BUT* you need to be careful with ordering.

In particular, whoever does the allocation needs to then set the
refcount to a non-zero value *after* it has initialized all the other
fields. And in particular, it needs to make sure that it uses the
proper memory ordering to do so.

And in this case, we have

  static struct nf_conn *
  __nf_conntrack_alloc(struct net *net,
  {
        ...
        atomic_set(&ct->ct_general.use, 0);

which is a no-op for the re-use case (whether racing or not, since any
"inc_not_zero" users won't touch it), but initializes it to zero for
the "completely new object" case.

And then, the thing that actually exposes it to the speculative walkers does:

  int
  nf_conntrack_hash_check_insert(struct nf_conn *ct)
  {
        ...
        smp_wmb();
        /* The caller holds a reference to this object */
        atomic_set(&ct->ct_general.use, 2);

which means that it stays as zero until everything is actually set up,
and then the optimistic walker can use the other fields (including
spinlocks etc) to verify that it's actually the right thing. The
smp_wmb() means that the previous initialization really will be
visible before the object is visible.

Side note: on some architectures it might help to make that "smp_wmb
-> atomic_set()" sequence be am "smp_store_release()" instead. Doesn't
matter on x86, but might matter on arm64.

NOTE! One thing to be very worried about is that re-initializing
whatever RCU lists means that now the RCU walker may be walking on the
wrong list so the walker may do the right thing for this particular
entry, but it may miss walking *other* entries. So then you can get
spurious lookup failures, because the RCU walker never walked all the
way to the end of the right list. That ends up being a much more
subtle bug.

But the nf_conntrack case seems to get that right too, see the restart
in ____nf_conntrack_find().

So I don't see anything wrong in nf_conntrack.

But yes, using SLAB_TYPESAFE_BY_RCU is very very subtle. But most of
the subtleties have nothing to do with having a constructor, they are
about those "make sure memory ordering wrt refcount is right" and
"restart speculative RCU walk" issues that actually happen regardless
of having a constructor or not.

                  Linus
