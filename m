Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4155F6B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 21:45:25 -0400 (EDT)
Received: by iebpz10 with SMTP id pz10so19108948ieb.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 18:45:25 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id q18si14049008ico.33.2015.05.12.18.45.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 18:45:24 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] mm/hugetlb: initialize order with UINT_MAX in
 dissolve_free_huge_pages()
Date: Wed, 13 May 2015 01:44:22 +0000
Message-ID: <20150513014418.GB14599@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
 <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512091349.GO16501@mwanda>
 <20150512091640.GE3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512092034.GF3068@hori1.linux.bs1.fc.nec.co.jp>
 <20150512161511.7967c400cae6c1d693b61d57@linux-foundation.org>
In-Reply-To: <20150512161511.7967c400cae6c1d693b61d57@linux-foundation.org>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <11DD24838ACFC74087128A6C8855AC18@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, May 12, 2015 at 04:15:11PM -0700, Andrew Morton wrote:
> On Tue, 12 May 2015 09:20:35 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec=
.com> wrote:
>=20
> > Currently the initial value of order in dissolve_free_huge_page is 64 o=
r 32,
> > which leads to the following warning in static checker:
> >=20
> >   mm/hugetlb.c:1203 dissolve_free_huge_pages()
> >   warn: potential right shift more than type allows '9,18,64'
> >=20
> > This is a potential risk of infinite loop, because 1 << order (=3D=3D 0=
) is used
> > in for-loop like this:
> >=20
> >   for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
> >       ...
> >=20
> > So this patch simply avoids the risk by initializing with UINT_MAX.
> >=20
> > ..
> >
> > --- a/mm/hugetlb.c
> > +++ b/mm/hugetlb.c
> > @@ -1188,7 +1188,7 @@ static void dissolve_free_huge_page(struct page *=
page)
> >   */
> >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long e=
nd_pfn)
> >  {
> > -	unsigned int order =3D 8 * sizeof(void *);
> > +	unsigned int order =3D UINT_MAX;
> >  	unsigned long pfn;
> >  	struct hstate *h;
> > =20
> > @@ -1200,6 +1200,7 @@ void dissolve_free_huge_pages(unsigned long start=
_pfn, unsigned long end_pfn)
> >  		if (order > huge_page_order(h))
> >  			order =3D huge_page_order(h);
> >  	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
> > +	VM_BUG_ON(order =3D=3D UINT_MAX);
> >  	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
> >  		dissolve_free_huge_page(pfn_to_page(pfn));
>=20
> Do we need to calculate this each time?  Can it be done in
> hugetlb_init_hstates(), save the result in a global?

Yes, it should work. How about the following?
This adds 4bytes to .data due to a new global variable, but reduces 47 byte=
s
.text size of code reduces, so it's a win in total.

   text    data     bss     dec     hex filename                        =20
  28313     469   84236  113018   1b97a mm/hugetlb.o (above patch)
  28266     473   84236  112975   1b94f mm/hugetlb.o (below patch)

---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 271e4432734c..fecb8bbfe11e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -40,6 +40,7 @@ int hugepages_treat_as_movable;
 int hugetlb_max_hstate __read_mostly;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
+unsigned int minimum_order __read_mostly;
=20
 __initdata LIST_HEAD(huge_boot_pages);
=20
@@ -1188,19 +1189,13 @@ static void dissolve_free_huge_page(struct page *pa=
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
@@ -1626,11 +1621,16 @@ static void __init hugetlb_init_hstates(void)
 {
 	struct hstate *h;
=20
+	minimum_order =3D UINT_MAX;
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
