Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 10CC16B00F0
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 09:29:36 -0400 (EDT)
Received: by mail-wi0-f178.google.com with SMTP id n15so2956846wiw.5
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:29:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s1si27060063wiw.15.2014.06.12.06.29.34
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 06:29:35 -0700 (PDT)
Message-ID: <5399ab3f.814db40a.0ca2.ffffc952SMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
Date: Thu, 12 Jun 2014 09:29:15 -0400
In-Reply-To: <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com> <20140611173851.GA5556@MacBook-Pro.local> <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com> <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com> <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com> <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Denis,

On Thu, Jun 12, 2014 at 04:00:57PM +0400, Denis Kirjanov wrote:
> On 6/12/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> > On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org> wro=
te:
> >>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
> >>>>> I got a trace while running 3.15.0-08556-gdfb9454:
> >>>>>
> >>>>> [  104.534026] Unable to handle kernel paging request for data at=

> >>>>> address 0xc00000007f000000
> >>>>
> >>>> Were there any kmemleak messages prior to this, like "kmemleak
> >>>> disabled"? There could be a race when kmemleak is disabled because=
 of
> >>>> some fatal (for kmemleak) error while the scanning is taking place=

> >>>> (which needs some more thinking to fix properly).
> >>>
> >>> No. I checked for the similar problem and didn't find anything rele=
vant.
> >>> I'll try to bisect it.
> >>
> >> Does this happen soon after boot? I guess it=E2=80=99s the first sca=
n
> >> (scheduled at around 1min after boot). Something seems to be telling=

> >> kmemleak that there is a valid memory block at 0xc00000007f000000.
> >
> > Yeah, it happens after a while with a booted system so that's the
> > first kmemleak scan.
> >
> >> Catalin
> >
> =

> I've bisected to this commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92
> "mm: add !pte_present() check on existing hugetlb_entry callbacks".
> Reverting the commit fixes the issue

Thanks for the effort of bisecting.
I guess that this bug happens because pte_none() check was gone in this
commit, so could you try to find if the following patch fixes the problem=
?

I don't know much about kmemleak's details, so I'm not sure how this bug
affected kmemleak. So I'm appreciated if you would add some comment in
patch description.

Thanks,
Naoya Horiguchi
---
Date: Thu, 12 Jun 2014 08:56:27 -0400
Subject: [PATCH] mm: revoke pte_none() check for hugetlb_entry() callback=
s

commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92 ("mm: add !pte_present()=

check on existing hugetlb_entry callbacks") removed pte_none() check in
a ->hugetlb_entry() handler, which unexpectedly broke other features like=

kmemleak.

pte_none() check should be done in common page walk code, because we do
so for normal pages and page walk might want to handle holes with
->pte_hole() callback.

Reported-by: Denis Kirjanov <kda@linux-powerpc.org>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/pagewalk.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/pagewalk.c b/mm/pagewalk.c
index 2beeabf502c5..0618657285c4 100644
--- a/mm/pagewalk.c
+++ b/mm/pagewalk.c
@@ -118,6 +118,13 @@ static int walk_hugetlb_range(struct vm_area_struct =
*vma,
 	do {
 		next =3D hugetlb_entry_end(h, addr, end);
 		pte =3D huge_pte_offset(walk->mm, addr & hmask);
+		if (huge_pte_none(*pte)) {
+			if (walk->pte_hole)
+				err =3D walk->pte_hole(addr, next, walk);
+			if (err)
+				break;
+			continue;
+		}
 		if (pte && walk->hugetlb_entry)
 			err =3D walk->hugetlb_entry(pte, hmask, addr, next, walk);
 		if (err)
-- =

1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
