Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 167EC6B026B
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 06:36:48 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id k15-v6so14255016wrq.1
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 03:36:48 -0700 (PDT)
Received: from Chamillionaire.breakpoint.cc (Chamillionaire.breakpoint.cc. [2a01:7a0:2:106d:670::1])
        by mx.google.com with ESMTPS id k203-v6si3503537wmd.165.2018.08.01.03.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 01 Aug 2018 03:36:46 -0700 (PDT)
Date: Wed, 1 Aug 2018 12:35:37 +0200
From: Florian Westphal <fw@strlen.de>
Subject: Re: SLAB_TYPESAFE_BY_RCU without constructors (was Re: [PATCH v4
 13/17] khwasan: add hooks implementation)
Message-ID: <20180801103537.d36t3snzulyuge7g@breakpoint.cc>
References: <e3b48104-3efb-1896-0d46-792419f49a75@virtuozzo.com>
 <01000164f169bc6b-c73a8353-d7d9-47ec-a782-90aadcb86bfb-000000@email.amazonses.com>
 <CA+55aFzHR1+YbDee6Cduo6YXHO9LKmLN1wP=MVzbP41nxUb5=g@mail.gmail.com>
 <CA+55aFzYLgyNp1jsqsvUOjwZdO_1Piqj=iB=rzDShjScdNtkbg@mail.gmail.com>
 <CACT4Y+aYZumcc-Od5T1AnP4mwn8-FaWfxvfb93MnNwQPqG8TDw@mail.gmail.com>
 <CACT4Y+ZkgqDT77dshHg+hBtc9YPW-eZ8wVQA9LTDQ6q_y99oiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZkgqDT77dshHg+hBtc9YPW-eZ8wVQA9LTDQ6q_y99oiQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, linux-ext4@vger.kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pablo Neira Ayuso <pablo@netfilter.org>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Florian Westphal <fw@strlen.de>, David Miller <davem@davemloft.net>, NetFilter <netfilter-devel@vger.kernel.org>, coreteam@netfilter.org, Network Development <netdev@vger.kernel.org>, Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org, Jani Nikula <jani.nikula@linux.intel.com>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Rodrigo Vivi <rodrigo.vivi@intel.com>, Dave Airlie <airlied@linux.ie>, intel-gfx <intel-gfx@lists.freedesktop.org>, DRI <dri-devel@lists.freedesktop.org>, Eric Dumazet <edumazet@google.com>, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, Ursula Braun <ubraun@linux.ibm.com>, linux-s390 <linux-s390@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>

Dmitry Vyukov <dvyukov@google.com> wrote:
> Still can't grasp all details.
> There is state that we read without taking ct->ct_general.use ref
> first, namely ct->state and what's used by nf_ct_key_equal.
> So let's say the entry we want to find is in the list, but
> ____nf_conntrack_find finds a wrong entry earlier because all state it
> looks at is random garbage, so it returns the wrong entry to
> __nf_conntrack_find_get.

If an entry can be found, it can't be random garbage.
We never link entries into global table until state has been set up.

> Now (nf_ct_is_dying(ct) || !atomic_inc_not_zero(&ct->ct_general.use))
> check in __nf_conntrack_find_get passes, and it returns NULL to the
> caller (which means entry is not present).

So entry is going away or marked as dead which for us is same as
'not present', we need to allocate a new entry.

> While in reality the entry
> is present, but we were just looking at the wrong one.

We never add tuples that are identical to the global table.

If N cores receive identical packets at same time with no prior state, all
will allocate a new conntrack, but we notice this when we try to insert the
nf_conn entries into the table.

Only one will succeed, other cpus have to cope with this.
(worst case: all raced packets are dropped along with their conntrack
 object).

For lookup, we have following scenarios:

1. It doesn't exist -> new allocation needed
2. It exists, not dead, has nonzero refount -> use it
3. It exists, but marked as dying -> new allocation needed
4. It exists but has 0 reference count -> new allocation needed
5. It exists, we get reference, but 2nd nf_ct_key_equal check
   fails.  We saw a matching 'old incarnation' that just got
   re-used on other core.  -> retry lookup

> Also I am not sure about order of checks in (nf_ct_is_dying(ct) ||
> !atomic_inc_not_zero(&ct->ct_general.use)), because checking state
> before taking the ref is only a best-effort hint, so it can actually
> be a dying entry when we take a ref.

Yes, it can also become a dying entry after we took the reference.
 
> So shouldn't it read something like the following?
> 
>         rcu_read_lock();
> begin:
>         h = ____nf_conntrack_find(net, zone, tuple, hash);
>         if (h) {
>                 ct = nf_ct_tuplehash_to_ctrack(h);
>                 if (!atomic_inc_not_zero(&ct->ct_general.use))
>                         goto begin;
>                 if (unlikely(nf_ct_is_dying(ct)) ||
>                     unlikely(!nf_ct_key_equal(h, tuple, zone, net))) {
>                         nf_ct_put(ct);

It would be ok to make this change, but dying bit can be set
at any time e.g. because userspace tells kernel to flush the conntrack table.
So refcount is always > 0 when the DYING bit is set.

I don't see why it would be a problem.

nf_conn struct will stay valid until all cpus have dropped references.
The check in lookup function only serves to hide the known-to-go-away entry.
