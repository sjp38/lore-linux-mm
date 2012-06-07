Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id B9EF16B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 16:57:11 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <08d98de0-2f1b-4461-8197-9700bc3e0c65@default>
Date: Thu, 7 Jun 2012 13:56:57 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH 06/11] mm: frontswap: make all branches of if statement in
 put page consistent
References: <1338980115-2394-1-git-send-email-levinsasha928@gmail.com>
 <1338980115-2394-6-git-send-email-levinsasha928@gmail.com>
 <20120607183022.GA9472@phenom.dumpdata.com>
In-Reply-To: <20120607183022.GA9472@phenom.dumpdata.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Wilk <konrad.wilk@oracle.com>, Sasha Levin <levinsasha928@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

> From: Konrad Rzeszutek Wilk
> Subject: Re: [PATCH 06/11] mm: frontswap: make all branches of if stateme=
nt in put page consistent
>=20
> On Wed, Jun 06, 2012 at 12:55:10PM +0200, Sasha Levin wrote:
> > Currently it has a complex structure where different things are compare=
d
> > at each branch. Simplify that and make both branches look similar.
> >
> > Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> > ---
> >  mm/frontswap.c |   10 +++++-----
> >  1 files changed, 5 insertions(+), 5 deletions(-)
> >
> > diff --git a/mm/frontswap.c b/mm/frontswap.c
> > index 618ef91..f2f4685 100644
> > --- a/mm/frontswap.c
> > +++ b/mm/frontswap.c
> > @@ -119,16 +119,16 @@ int __frontswap_put_page(struct page *page)
> >  =09=09frontswap_succ_puts++;
> >  =09=09if (!dup)
> >  =09=09=09atomic_inc(&sis->frontswap_pages);
> > -=09} else if (dup) {
> > +=09} else {
> >  =09=09/*
> >  =09=09  failed dup always results in automatic invalidate of
> >  =09=09  the (older) page from frontswap
> >  =09=09 */
> > -=09=09frontswap_clear(sis, offset);
> > -=09=09atomic_dec(&sis->frontswap_pages);
> > -=09=09frontswap_failed_puts++;
>=20
> Hmm, you must be using an older branch b/c the frontswap_failed_puts++
> doesn't exist anymore. Could you rebase on top of linus/master please.

Reminds me... at some point I removed the ability to observe
and set frontswap_curr_pages from userland, which is very useful
in testing and could be useful for future userland sysadmin tools.
IIRC, when transitioning from sysfs to debugfs (akpm's feedback),
I couldn't figure out how to make it writeable from debugfs, so
just dropped it and never added it back.

Writing the value is like a partial (or full) swapoff of the
pages stored via frontswap into zcache/ramster/tmem.  So kinda
similar to drop_caches?

I'd sure welcome a patch to add that back in!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
