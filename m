Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE826B0038
	for <linux-mm@kvack.org>; Thu, 14 May 2015 02:16:25 -0400 (EDT)
Received: by igbhj9 with SMTP id hj9so64963219igb.1
        for <linux-mm@kvack.org>; Wed, 13 May 2015 23:16:25 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id u27si517220ioi.5.2015.05.13.23.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 13 May 2015 23:16:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hugetlb: introduce minimum hugepage order
Date: Thu, 14 May 2015 06:15:45 +0000
Message-ID: <20150514061543.GA9477@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
 <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512091349.GO16501@mwanda>
 <20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512161511.7967c400cae6c1d693b61d57@linux-foundation.org>
 <20150513014418.GB14599@hori1.linux.bs1.fc.nec.co.jp>
 <20150513135556.5d21cd52810f87460eb1f2a1@linux-foundation.org>
In-Reply-To: <20150513135556.5d21cd52810f87460eb1f2a1@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <789A4BFEA78DC54A8E2605348F8D2417@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, May 13, 2015 at 01:55:56PM -0700, Andrew Morton wrote:
> On Wed, 13 May 2015 01:44:22 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > > >  			order =3D huge_page_order(h);
> > > >  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
> > > > +	VM_BUG_ON(order =3D=3D UINT_MAX);
> > > >  	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
> > > >  		dissolve_free_huge_page(pfn_to_page(pfn));
> > >=20
> > > Do we need to calculate this each time?  Can it be done in
> > > hugetlb_init_hstates(), save the result in a global?
> >=20
> > Yes, it should work. How about the following?
> > This adds 4bytes to .data due to a new global variable, but reduces 47 =
bytes
> > .text size of code reduces, so it's a win in total.
> >=20
> >    text    data     bss     dec     hex filename                       =
 =20
> >   28313     469   84236  113018   1b97a mm/hugetlb.o (above patch)
> >   28266     473   84236  112975   1b94f mm/hugetlb.o (below patch)
>=20
> Looks good.  Please turn it into a real patch and send it over when
> convenient?

Yes, the patch is attached below.

> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -40,6 +40,7 @@ int hugepages_treat_as_movable;
> >  int hugetlb_max_hstate __read_mostly;
> >  unsigned int default_hstate_idx;
> >  struct hstate hstates[HUGE_MAX_HSTATE];
> > +unsigned int minimum_order __read_mostly;
>=20
> static.
>=20
> And a comment would be nice ;)

OK, fixed.

>=20
> >
> > ...
> >
> > @@ -1626,11 +1621,16 @@ static void __init hugetlb_init_hstates(void)
> >  {
> >  	struct hstate *h;
> > =20
> > +	minimum_order =3D UINT_MAX;
>=20
> Do this at compile time.

OK.

> >  	for_each_hstate(h) {
> > +		if (minimum_order > huge_page_order(h))
> > +			minimum_order =3D huge_page_order(h);
> > +
> >  		/* oversize hugepages were init'ed in early boot */
> >  		if (!hstate_is_gigantic(h))
> >  			hugetlb_hstate_alloc_pages(h);
> >  	}
> > +	VM_BUG_ON(minimum_order =3D=3D UINT_MAX);
>=20
> Is the system hopelessly screwed up when this happens, or will it still
> be able to boot up and do useful things?
>=20
> If the system is hopelessly broken then BUG_ON or, better, panic should
> be used here.  But if there's still potential to do useful things then
> I guess VM_BUG_ON is appropriate.

When this happens, hugetlb subsystem is broken but the system can run as
usual, so this is not critical. So I think VM_BUG_ON is OK.

Thanks,
Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm/hugetlb: introduce minimum hugepage order

Currently the initial value of order in dissolve_free_huge_page is 64 or 32=
,
which leads to the following warning in static checker:

  mm/hugetlb.c:1203 dissolve_free_huge_pages()
  warn: potential right shift more than type allows '9,18,64'

This is a potential risk of infinite loop, because 1 << order (=3D=3D 0) is=
 used
in for-loop like this:

  for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
      ...

So this patch fixes it by using global minimum_order calculated at boot tim=
e.

    text    data     bss     dec     hex filename
   28313     469   84236  113018   1b97a mm/hugetlb.o
   28256     473   84236  112965   1b945 mm/hugetlb.o (patched)

Fixes: c8721bbbdd36 ("mm: memory-hotplug: enable memory hotplug to handle h=
ugepage")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/hugetlb.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 271e4432734c..8c4c1f9f9a9a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -40,6 +40,11 @@ int hugepages_treat_as_movable;
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
+/*
+ * Minimum page order among possible hugepage sizes, set to a proper value
+ * at boot time.
+ */
+static unsigned int minimum_order __read_mostly =3D UINT_MAX;
=20
 __initdata LIST_HEAD(huge_boot_pages);
=20
@@ -1188,19 +1193,13 @@ static void dissolve_free_huge_page(struct page *pa=
ge)
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_p=
fn)
 {
-	unsigned int order =3D 8 * sizeof(void *);
 	unsigned long pfn;
-	struct hstate *h;
=20
 	if (!hugepages_supported())
 		return;
=20
-	/* Set scan step to minimum hugepage size */
-	for_each_hstate(h)
-		if (order > huge_page_order(h))
-			order =3D huge_page_order(h);
-	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
-	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
+	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << minimum_order));
+	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << minimum_order)
 		dissolve_free_huge_page(pfn_to_page(pfn));
 }
=20
@@ -1627,10 +1626,14 @@ static void __init hugetlb_init_hstates(void)
 	struct hstate *h;
=20
 	for_each_hstate(h) {
+		if (minimum_order > huge_page_order(h))
+			minimum_order =3D huge_page_order(h);
+
 		/* oversize hugepages were init'ed in early boot */
 		if (!hstate_is_gigantic(h))
 			hugetlb_hstate_alloc_pages(h);
 	}
+	VM_BUG_ON(minimum_order =3D=3D UINT_MAX);
 }
=20
 static char * __init memfmt(char *buf, unsigned long n)
--=20
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
