Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 645BF6B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:23:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so113656814pgi.2
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:23:47 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id q78si18939851pfj.291.2017.01.16.22.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jan 2017 22:23:46 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 19so4796354pfo.3
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:23:46 -0800 (PST)
Date: Tue, 17 Jan 2017 14:24:08 +0800
From: Boqun Feng <boqun.feng@gmail.com>
Subject: Re: [PATCH v4 07/15] lockdep: Implement crossrelease feature
Message-ID: <20170117062408.GE15084@tardis.cn.ibm.com>
References: <1481260331-360-1-git-send-email-byungchul.park@lge.com>
 <1481260331-360-8-git-send-email-byungchul.park@lge.com>
 <20170116151319.GE3144@twins.programming.kicks-ass.net>
 <20170117023341.GG3326@X58A-UD3R>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="oOB74oR0WcNeq9Zb"
Content-Disposition: inline
In-Reply-To: <20170117023341.GG3326@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Peter Zijlstra <peterz@infradead.org>, mingo@kernel.org, tglx@linutronix.de, walken@google.com, kirill@shutemov.name, linux-kernel@vger.kernel.org, linux-mm@kvack.org, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, npiggin@gmail.com


--oOB74oR0WcNeq9Zb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 17, 2017 at 11:33:41AM +0900, Byungchul Park wrote:
> On Mon, Jan 16, 2017 at 04:13:19PM +0100, Peter Zijlstra wrote:
> > On Fri, Dec 09, 2016 at 02:12:03PM +0900, Byungchul Park wrote:
> > > +	/*
> > > +	 * We assign class_idx here redundantly even though following
> > > +	 * memcpy will cover it, in order to ensure a rcu reader can
> > > +	 * access the class_idx atomically without lock.
> > > +	 *
> > > +	 * Here we assume setting a word-sized variable is atomic.
> >=20
> > which one, where?
>=20
> I meant xlock_class(xlock) in check_add_plock().
>=20
> I was not sure about the following two.
>=20
> 1. Is it ordered between following a and b?
>    a. memcpy -> list_add_tail_rcu
>    b. list_for_each_entry_rcu -> load class_idx (xlock_class)
>    I assumed that it's not ordered.
> 2. Does memcpy guarantee atomic store for each word?
>    I assumed that it doesn't.
>=20
> But I think I was wrong.. The first might be ordered. I will remove
> the following redundant statement. It'd be orderd, right?
>=20

Yes, a and b are ordered, IOW, they could be paired, meaning when we
got the item in a list_for_each_entry_rcu() loop, all memory operations
before the corresponding list_add_tail_rcu() should be observed by us.

Regards,
Boqun

> >=20
> > > +	 */
> > > +	xlock->hlock.class_idx =3D hlock->class_idx;
> > > +	gen_id =3D (unsigned int)atomic_inc_return(&cross_gen_id);
> > > +	WRITE_ONCE(xlock->gen_id, gen_id);
> > > +	memcpy(&xlock->hlock, hlock, sizeof(struct held_lock));
> > > +	INIT_LIST_HEAD(&xlock->xlock_entry);
> > > +	list_add_tail_rcu(&xlock->xlock_entry, &xlocks_head);
> >=20

--oOB74oR0WcNeq9Zb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEj5IosQTPz8XU1wRHSXnow7UH+rgFAlh9uIUACgkQSXnow7UH
+ri78gf/eTrWmPpF6cancS8OeQqNgb2AZC9XhbkRlPN8gBBm9zZhzwPUIIBZ4lpY
Q7KoNqRpwFjT6oHbmeskywgQY4jivpsnPJoxpaeoOrvQZ3T9RIVKc/YdDdyCbraC
tIwSHi6rAEdrIofLheQad6As14v4wgRdkuzz8wTttV7kWSOBdLXgE2UTiTl+dg22
I80Gxj94F3hXtv4ppd8YO9lKM+bYRRUNeJEPAmkvbc0n7RZdKT87UKMBskXmnCH6
/WUVTYfZidz7xqn+mrKrjR4wyRkNvAQjbxZUI+60WVypyA3HySWdojRWKnHriFmK
TxjDHxGQh0N01IWhmp1H6iIFpcf4DA==
=VijH
-----END PGP SIGNATURE-----

--oOB74oR0WcNeq9Zb--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
