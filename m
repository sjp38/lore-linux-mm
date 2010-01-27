Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 726566B004D
	for <linux-mm@kvack.org>; Wed, 27 Jan 2010 11:52:50 -0500 (EST)
Date: Wed, 27 Jan 2010 16:52:30 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH] page_alloc: change bit ops 'or' to logical ops in
 free/new page check
In-Reply-To: <cf18f8341001260020p44cec4abq24a354251c78dacb@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1001271638410.25739@sister.anvils>
References: <cf18f8341001252256q65b90d76vfe3094a1bb5424e7@mail.gmail.com>  <20100126155852.1D53.A69D9226@jp.fujitsu.com> <cf18f8341001260020p44cec4abq24a354251c78dacb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1392313750-1264611150=:25739"
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1392313750-1264611150=:25739
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 26 Jan 2010, Bob Liu wrote:
> On Tue, Jan 26, 2010 at 3:00 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Using logical 'or' in =C2=A0function free_page_mlock() and
> >> check_new_page() makes code clear and
> >> sometimes more effective (Because it can ignore other condition
> >> compare if the first condition
> >> is already true).
> >>
> >> It's Nick's patch "mm: microopt conditions" changed it from logical
> >> ops to bit ops.
> >> Maybe I didn't consider something. If so, please let me know and just
> >> ignore this patch.

Yes, please do ignore (unless you've found that logicals and branches
are actually now more efficient than the bitwises on recent processors).

> >> Thanks!
> >
> > I think current code is intentional. On modern cpu, bit-or is faster th=
an
> > logical or.
>=20
> Hmm, but if use logical ops it can be optimized by the compiler.
> In this situation, eg, if page_mapcount(page) is true, then other compare=
tion
> including atomic_read() willn't be called anymore.
> If use bit ops, atomic_read() and other comparetion will still be called.

In many contexts that would be a valid point to make.  But please look at
what these checks are about.  999999999 times out of a billion every one of
those tests has to be made, as efficiently as possible.  You're asking to
optimize for when memory corruption or whatever has made one condition true
which should never be true.

Hugh

>=20
> I am not sure whether cpu and compiler will optimize it like the
> logical bit ops.
> If there will, the current code is intertional, else i think the
> logical ops is better.
> thanks!
>=20
> -       if (unlikely(page_mapcount(page) |
> -               (page->mapping !=3D NULL)  |
> -               (atomic_read(&page->_count) !=3D 0) |
> +       if (unlikely(page_mapcount(page) ||
> +               (page->mapping !=3D NULL)  ||
> +               (atomic_read(&page->_count) !=3D 0) ||
>                (page->flags & PAGE_FLAGS_CHECK_AT_FREE))) {
>=20
>=20
> >
> > Do you have opposite benchmark number result?
> >
>=20
> I haven't now :-).  I will test it when I have enough time.
>=20
> >
> >>
> >> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> >> ---
> >>
> >> diff --git mm/page_alloc.c mm/page_alloc.c
> >> index 05ae4e0..91ece14 100644
> >> --- mm/page_alloc.c
> >> +++ mm/page_alloc.c
> >> @@ -500,9 +500,9 @@ static inline void free_page_mlock(struct page *pa=
ge)
> >>
> >> =C2=A0static inline int free_pages_check(struct page *page)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) |
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D=
 NULL) =C2=A0|
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page-=
>_count) !=3D 0) |
> >> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) ||
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D=
 NULL) =C2=A0||
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page-=
>_count) !=3D 0) ||
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->flags &=
 PAGE_FLAGS_CHECK_AT_FREE))) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bad_page(page)=
;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> >> @@ -671,9 +671,9 @@ static inline void expand(struct zone *zone, struc=
t page *pa
> >> =C2=A0 */
> >> =C2=A0static inline int check_new_page(struct page *page)
> >> =C2=A0{
> >> - =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) |
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D=
 NULL) =C2=A0|
> >> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page-=
>_count) !=3D 0) =C2=A0|
> >> + =C2=A0 =C2=A0 =C2=A0 if (unlikely(page_mapcount(page) ||
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->mapping !=3D=
 NULL) =C2=A0||
> >> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (atomic_read(&page-=
>_count) !=3D 0) =C2=A0||
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 (page->flags &=
 PAGE_FLAGS_CHECK_AT_PREP))) {
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 bad_page(page)=
;
> >> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 return 1;
> >>
>=20
> --=20
> Regards,
> -Bob Liu
--8323584-1392313750-1264611150=:25739--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
