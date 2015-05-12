Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f47.google.com (mail-oi0-f47.google.com [209.85.218.47])
	by kanga.kvack.org (Postfix) with ESMTP id BC4E06B0038
	for <linux-mm@kvack.org>; Tue, 12 May 2015 05:05:51 -0400 (EDT)
Received: by oign205 with SMTP id n205so594736oig.2
        for <linux-mm@kvack.org>; Tue, 12 May 2015 02:05:51 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id p3si8478040oev.93.2015.05.12.02.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 12 May 2015 02:05:51 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: mm: memory-hotplug: enable memory hotplug to handle hugepage
Date: Tue, 12 May 2015 09:04:55 +0000
Message-ID: <20150512090454.GD3068@hori1.linux.bs1.fc.nec.co.jp>
References: <20150511111748.GA20660@mwanda>
 <20150511235443.GA8513@hori1.linux.bs1.fc.nec.co.jp>
 <20150512084339.GN16501@mwanda>
In-Reply-To: <20150512084339.GN16501@mwanda>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <AE91DAC3236D3B4199F8A385A413789A@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>

On Tue, May 12, 2015 at 11:43:39AM +0300, Dan Carpenter wrote:
> On Mon, May 11, 2015 at 11:54:44PM +0000, Naoya Horiguchi wrote:
> > @@ -1086,7 +1086,8 @@ static void dissolve_free_huge_page(struct page *=
page)
> >   */
> >  void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long e=
nd_pfn)
> >  {
> > -	unsigned int order =3D 8 * sizeof(void *);
> > +	/* Initialized to "high enough" value which is capped later */
> > +	unsigned int order =3D 8 * sizeof(void *) - 1;
>=20
> Why not use UINT_MAX?  It's more clear that it's not valid that way.

It's OK if code checker doesn't show "too much right shift" warning.
With UINT_MAX, inserting VM_BUG_ON(order =3D=3D UINT_MAX) after for_each_hs=
tate
loop might be safer (1 << UINT_MAX is clearly wrong.)

> Otherwise doing a complicated calculation it makes it seem like we will
> use the variable.

OK.

Is the below OK for you?
---
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 271e4432734c..804437505a84 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1188,7 +1188,7 @@ static void dissolve_free_huge_page(struct page *page=
)
  */
 void dissolve_free_huge_pages(unsigned long start_pfn, unsigned long end_p=
fn)
 {
-	unsigned int order =3D 8 * sizeof(void *);
+	unsigned int order =3D UINT_MAX;
 	unsigned long pfn;
 	struct hstate *h;
=20
@@ -1200,6 +1200,7 @@ void dissolve_free_huge_pages(unsigned long start_pfn=
, unsigned long end_pfn)
 		if (order > huge_page_order(h))
 			order =3D huge_page_order(h);
 	VM_BUG_ON(!IS_ALIGNED(start_pfn, 1 << order));
+	VM_BUG_ON(order =3D=3D UINT_MAX);
 	for (pfn =3D start_pfn; pfn < end_pfn; pfn +=3D 1 << order)
 		dissolve_free_huge_page(pfn_to_page(pfn));
 }=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
