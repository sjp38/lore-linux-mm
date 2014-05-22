Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id C49D46B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 02:45:40 -0400 (EDT)
Received: by mail-qg0-f53.google.com with SMTP id f51so4892532qge.12
        for <linux-mm@kvack.org>; Wed, 21 May 2014 23:45:40 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id k10si4197763qaj.33.2014.05.21.23.45.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 May 2014 23:45:40 -0700 (PDT)
Date: Thu, 22 May 2014 08:45:29 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v5
Message-ID: <20140522064529.GI30445@twins.programming.kicks-ass.net>
References: <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515142414.16c47315a03160c58ceb9066@linux-foundation.org>
 <20140521121501.GT23991@suse.de>
 <20140521142622.049d0b3af5fc94912d5a1472@linux-foundation.org>
 <20140521213354.GL2485@laptop.programming.kicks-ass.net>
 <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="JA8sJ/HI0simWIGD"
Content-Disposition: inline
In-Reply-To: <20140521145000.f130f8779f7641d0d8afcace@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>


--JA8sJ/HI0simWIGD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, May 21, 2014 at 02:50:00PM -0700, Andrew Morton wrote:
> On Wed, 21 May 2014 23:33:54 +0200 Peter Zijlstra <peterz@infradead.org> =
wrote:

> Alternative solution is not to merge the patch ;)

There is always that.. :-)

> > Yeah, so we only clear that bit when at 'unlock' we find there are no
> > more pending waiters, so if the last unlock still had a waiter, we'll
> > leave the bit set.
>=20
> Confused.  If the last unlock had a waiter, that waiter will get woken
> up so there are no waiters any more, so the last unlock clears the flag.
>=20
> um, how do we determine that there are no more waiters?  By looking at
> the waitqueue.  But that waitqueue is hashed, so it may contain waiters
> for other pages so we're screwed?  But we could just go and wake up the
> other-page waiters anyway and still clear PG_waiters?
>=20
> um2, we're using exclusive waitqueues so we can't (or don't) wake all
> waiters, so we're screwed again?

Ah, so leave it set. Then when we do an uncontended wakeup, that is a
wakeup where there are _no_ waiters left, we'll iterate the entire
hashed queue, looking for a matching page.

We'll find none, and only then clear the bit.


> (This process is proving to be a hard way of writing Mel's changelog btw).

Agreed :/

> If I'm still on track here, what happens if we switch to wake-all so we
> can avoid the dangling flag?  I doubt if there are many collisions on
> that hash table?

Wake-all will be ugly and loose a herd of waiters, all racing to
acquire, all but one of whoem will loose the race. It also looses the
fairness, its currently a FIFO queue. Wake-all will allow starvation.

> If there *are* a lot of collisions, I bet it's because a great pile of
> threads are all waiting on the same page.  If they're trying to lock
> that page then wake-all is bad.  But if they're just waiting for IO
> completion (probable) then it's OK.

Yeah, I'm not entirely sure on the rationale for adding PG_waiters to
writeback completion, and yes PG_writeback is a wake-all.

--JA8sJ/HI0simWIGD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTfZ0EAAoJEHZH4aRLwOS6LGwP+wQjxlILW154B/dq1w01YDxy
5u9xbrY/+yo5xNTfJJNMD89kschbq/p+bf40Cb0HBG7lgn5gf5Lqxo4Af2oygZNB
YZncMP7t/L3r22eYnvveQ9omatlNXMUIy+yR84VJmH5b0Z7m+FM7OskI39/tcNde
Db8Yx7ytdAYtki6wQvSqxIp3ldxVfeNaWBFmR/NR+UYCOL8rf+scwO+l2pMmq0gJ
OY87kkzKQuBW8yga6sMdIjhmaz/muNjwxhAxf9OUOgJoA2vG/GHCxW3psj+9nDwC
xlK0uMy7WXOZb9YJRY6iIz4FPcwGv1IB5bnR9VZIa4+hYvoxrijY5LOyudloJU8x
sZRxOCU6GsJWp4+l4KPJOGW7q1V1b87E5ywZIJakHZfh1NQEx/CmHV9hy2zUcICO
OCvnszUUsNGWWQ69n0rw7qsHiXQVzka2paZqYDjCoMFXOUbiggHDsC9hySrG6IFW
gI9T9b3XWFj5DoaqdKlfuz72wwOZBuSDzgKXmzIjEwofElH4Uz7mDkOpqJpg8dii
oF7Y+c5n1Jqvpt3BRNldSgI8dDeTlSihKQe3C6bXApyYKI4jETewa6qIRCBZyQtl
ThDF6QPT3S/3zGWUh2+Z2iUqzOku5dAeY/Nx/zePeyouTDjO9E1MieSKVri4AKhB
PIdvMpoT4cdgg22ErxpS
=jeio
-----END PGP SIGNATURE-----

--JA8sJ/HI0simWIGD--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
