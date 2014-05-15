Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 25DB56B0036
	for <linux-mm@kvack.org>; Thu, 15 May 2014 11:45:16 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so2076389qgd.29
        for <linux-mm@kvack.org>; Thu, 15 May 2014 08:45:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s6si2740787qaj.200.2014.05.15.08.45.13
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 May 2014 08:45:13 -0700 (PDT)
Date: Thu, 15 May 2014 17:45:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm: filemap: Avoid unnecessary barries and waitqueue
 lookups in unlock_page fastpath v4
Message-ID: <20140515154506.GF11096@twins.programming.kicks-ass.net>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-20-git-send-email-mgorman@suse.de>
 <20140513125313.GR23991@suse.de>
 <20140513141748.GD2485@laptop.programming.kicks-ass.net>
 <20140514161152.GA2615@redhat.com>
 <20140514192945.GA10830@redhat.com>
 <20140515104808.GF23991@suse.de>
 <20140515132058.GL30445@twins.programming.kicks-ass.net>
 <20140515153424.GB30668@redhat.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="HJakWL7yBo69DI1O"
Content-Disposition: inline
In-Reply-To: <20140515153424.GB30668@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, David Howells <dhowells@redhat.com>


--HJakWL7yBo69DI1O
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 15, 2014 at 05:34:24PM +0200, Oleg Nesterov wrote:
> On 05/15, Peter Zijlstra wrote:
> >
> > So I suppose I'm failing to see the problem with something like:
>=20
> Yeeees, I was thinking about something like this too ;)
>=20
> > static inline void lock_page(struct page *page)
> > {
> > 	if (!trylock_page(page))
> > 		__lock_page(page);
> > }
> >
> > static inline void unlock_page(struct page *page)
> > {
> > 	clear_bit_unlock(&page->flags, PG_locked);
> > 	if (PageWaiters(page))
> > 		__unlock_page();
> > }
>=20
> but in this case we need mb() before PageWaiters(), I guess.

Ah indeed so, or rather, this is a good reason to use smp_mb__after_atomic(=
).

> > void __lock_page(struct page *page)
> > {
> > 	struct wait_queue_head_t *wqh =3D page_waitqueue(page);
> > 	DEFINE_WAIT_BIT(wait, &page->flags, PG_locked);
> >
> > 	spin_lock_irq(&wqh->lock);
> > 	if (!PageWaiters(page))
> > 		SetPageWaiters(page);
> >
> > 	wait.flags |=3D WQ_FLAG_EXCLUSIVE;
> > 	preempt_disable();
>=20
> why?
>=20
> > 	do {
> > 		if (list_empty(&wait->task_list))
> > 			__add_wait_queue_tail(wqh, &wait);
> >
> > 		set_current_state(TASK_UNINTERRUPTIBLE);
> >
> > 		if (test_bit(wait.key.bit_nr, wait.key.flags)) {
> > 			spin_unlock_irq(&wqh->lock);
> > 			schedule_preempt_disabled();
> > 			spin_lock_irq(&wqh->lock);
>=20
> OK, probably to avoid the preemption before schedule().

Indeed.

> Still can't  undestand why this makes sense,

Because calling schedule twice in a row is like a bit of wasted effort.
Its just annoying there isn't a more convenient way to express this,
because its a fairly common thing in wait loops.

> but in this case it would be better
> to do disable/enable under "if (test_bit())" ?

Ah yes.. that code grew and the preempt_disable came about before that
test_bit() block.. :-)

> Of course, this needs more work for lock_page_killable(), but this
> should be simple.

Yeah, I just wanted to illustrate the point, and cobbling one together
=66rom various wait loops was plenty I thought ;-)

--HJakWL7yBo69DI1O
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJTdOECAAoJEHZH4aRLwOS623wQAK23Jo8JO5J4d+UfM/tWWoA9
0qguSZkmn3AOdBTEz2b3yh2LkLMIauqTuLMfxM/zQaxySznVRrfm6kx7AWCjyOo6
GwDbIfBYYFla1+y9XCIC53qz8LComc2QDGhTtIcU7Alg44yllMr9Kk445dHEUfBz
DdBQDhzDmlq/0FnhzKDd6GYxVkwHFqfCxpJviA9M4copFu+pT0gVcR0vAeY5qfwS
616Xm5vQIaosAVjai4aCYW1PWDi2pasmyiIw5/dXXMxMrqcObbtE6IDboHk5NpNh
DSxY8Ua4GIbnJlnDHiFF52gfXMQc3bQeQn6rNkNq3baS4XVdnkQDapzOxCzmgru4
d1YvB7txk5RjBAavzrgxqNEY9z1c5Nt4b72AX54f9YjkWZ1Yi1FiNfOn/7dvks+b
TYO5gTzNOdEmkvkpAKQgJBBzZnN02Y6WcuOM38HdiDceqlblyL7YIoeNAOOUaOj8
nEU1ONOFtliyfKH2zZHO/Loce84TAH1ZlXi7LrnI/4MRz7ZMD04ij46RvUDc41hR
4mz2dmogCLHDXNFQ8gDeMm502kthzeDgmmzp+K45JG78ZCrmeKiGkQeMiTf0Ww/v
G6Az6zEf+n77v0EkoZPHzElTEWyPVA1KlIYoaXSSjxsGz9ymTu3hGNtFQmrYq+D/
Yoq+8KgJkDKoTZI37Ew6
=4rMb
-----END PGP SIGNATURE-----

--HJakWL7yBo69DI1O--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
