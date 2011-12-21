Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 2699F6B005A
	for <linux-mm@kvack.org>; Wed, 21 Dec 2011 01:15:11 -0500 (EST)
Received: by iacb35 with SMTP id b35so12494169iac.14
        for <linux-mm@kvack.org>; Tue, 20 Dec 2011 22:15:10 -0800 (PST)
Date: Tue, 20 Dec 2011 22:15:00 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [Resend] 3.2-rc6+: Reported regressions from 3.0 and 3.1
In-Reply-To: <CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1112202213310.3987@eggly.anvils>
References: <201112210054.46995.rjw@sisk.pl> <CA+55aFzee7ORKzjZ-_PrVy796k2ASyTe_Odz=ji7f1VzToOkKw@mail.gmail.com> <4EF15F42.4070104@oracle.com> <CA+55aFx=B9adsTR=-uYpmfJnQgdGN+1aL0KUabH5bSY6YcwO7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-688804515-1324448109=:3987"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Kleikamp <dave.kleikamp@oracle.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Dave Kleikamp <shaggy@kernel.org>, jfs-discussion@lists.sourceforge.net, Kernel Testers List <kernel-testers@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Maciej Rutecki <maciej.rutecki@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Florian Mickler <florian@mickler.org>, davem@davemloft.net, Al Viro <viro@zeniv.linux.org.uk>, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-688804515-1324448109=:3987
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 20 Dec 2011, Linus Torvalds wrote:
> On Tue, Dec 20, 2011 at 8:23 PM, Dave Kleikamp <dave.kleikamp@oracle.com>=
 wrote:
> >
> > I don't think this is a regression. =A0It's been seen before, but the
> > patch never got submitted, or was lost somewhere. I believe this
> > will fix it.
>=20
> Hmm. This patch looks obviously correct. But it looks *so* obviously
> correct that it just makes me suspicious - this is not new or seldom
> used code, it's been this way for ages and used all the time. That
> line literally goes back to 2007, commit eb2be189317d0. And it looks
> like even before that we had a GFP_KERNEL for the add_to_page_cache()
> case and that goes back to before the git history. So this is
> *ancient*.
>=20
> Maybe almost nobody uses __read_cache_page() with a non-GFP_KERNEL gfp
> and as a result we've not noticed.
>=20
> Or maybe there is some crazy reason why it calls "add_to_page_cache()"
> with GFP_KERNEL.
>=20
> Adding the usual suspects for mm/filemap.c to the cc line (Andrew is
> already cc'd, but Al and Hugh should comment).
>=20
> Ack's, people? Is it really as obvious as it looks, and we've just had
> this bug forever?

Certainly

Acked-by: Hugh Dickins <hughd@google.com>

from me (and add_to_page_cache_locked does the masking of inappropriate
bits when passing on down, so no need to worry about that aspect).

I agree that it's odd that we've never noticed it before, but I don't
think the GFP_KERNEL there has any more significance than oversight.
Nick cleaned up some similar instances in filemap.c a few years back,
I guess ones he hit in testing, but this just got left over.

page_cache_read()'s GFP_KERNEL looks similarly worrying, but as it's
only called by filemap_fault(), I suppose it's actually okay.

Ooh, maybe you should also update that comment on GFP_KERNEL above
read_cache_page_gfp()...

Hugh

>=20
>             Linus
>=20
> --- snip snip ---
> > vfs: __read_cache_page should use gfp argument rather than GFP_KERNEL
> >
> > lockdep reports a deadlock in jfs because a special inode's rw semaphor=
e
> > is taken recursively. The mapping's gfp mask is GFP_NOFS, but is not us=
ed
> > when __read_cache_page() calls add_to_page_cache_lru().
> >
> > Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
> >
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index c106d3b..c9ea3df 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1828,7 +1828,7 @@ repeat:
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D __page_cache_alloc(gfp | __GFP_=
COLD);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!page)
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return ERR_PTR(-ENOMEM);
> > - =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_to_page_cache_lru(page, mappi=
ng, index, GFP_KERNEL);
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D add_to_page_cache_lru(page, mappi=
ng, index, gfp);
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (unlikely(err)) {
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page_cache_release(page)=
;
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (err =3D=3D -EEXIST)
--8323584-688804515-1324448109=:3987--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
