Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 7F4156B0132
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 10:28:15 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <e82083d1-af9f-4766-992c-926413f02423@default>
Date: Mon, 11 Jun 2012 07:27:56 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH v3 04/10] mm: frontswap: split out __frontswap_unuse_pages
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
 <1339325468-30614-5-git-send-email-levinsasha928@gmail.com>
 <4FD5856C.5060708@kernel.org> <1339410650.4999.38.camel@lappy>
In-Reply-To: <1339410650.4999.38.camel@lappy>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>, Minchan Kim <minchan@kernel.org>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Sasha Levin [mailto:levinsasha928@gmail.com]
> Subject: Re: [PATCH v3 04/10] mm: frontswap: split out __frontswap_unuse_=
pages
>=20
> > > +=09assert_spin_locked(&swap_lock);
> >
> > Normally, we should use this assertion when we can't find swap_lock is =
hold or not easily
> > by complicated call depth or unexpected use-case like general function.
> > But I expect this function's caller is very limited, not complicated.
> > Just comment write down isn't enough?
>=20
> Is there a reason not to do it though? Debugging a case where this
> function is called without a swaplock and causes corruption won't be
> easy.

I'm not sure of the correct kernel style but I like the fact
that assert_spin_locked both documents the lock requirement and tests
it at runtime.

I don't know the correct kernel syntax but is it possible
to make this code be functional when the kernel "debug"
option is on, but a no-op when "debug" is disabled?
IMHO, that would be the ideal solution.
=20
> > > +=09for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
> > > +=09=09si =3D swap_info[type];
> > > +=09=09si_frontswap_pages =3D atomic_read(&si->frontswap_pages);
> > > +=09=09if (total_pages_to_unuse < si_frontswap_pages) {
> > > +=09=09=09pages =3D pages_to_unuse =3D total_pages_to_unuse;
> > > +=09=09} else {
> > > +=09=09=09pages =3D si_frontswap_pages;
> > > +=09=09=09pages_to_unuse =3D 0; /* unuse all */
> > > +=09=09}
> > > +=09=09/* ensure there is enough RAM to fetch pages from frontswap */
> > > +=09=09if (security_vm_enough_memory_mm(current->mm, pages)) {
> > > +=09=09=09ret =3D -ENOMEM;
> >
> >
> > Nipick:
> > I am not sure detailed error returning would be good.
> > Caller doesn't matter it now but it can consider it in future.
> > Hmm,
>=20
> Is there a reason to avoid returning a meaningful error when it's pretty
> easy?

I'm certainly not an expert on kernel style (as this whole series
of patches demonstrates :-) but I think setting a meaningful
error code is useful documentation and plans for future users
that might use the error code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
